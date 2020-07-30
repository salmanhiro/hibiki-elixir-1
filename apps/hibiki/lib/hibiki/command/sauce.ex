defmodule Hibiki.Command.Sauce do
  use Teitoku.Command
  alias Teitoku.Command.Options
  alias Hibiki.Sauce
  alias Hibiki.Upload
  alias Hibiki.Entity

  def name, do: "sauce"

  def description, do: "Bruh I need sauce"

  def options,
    do:
      %Options{}
      |> Options.allow_empty()
      |> Options.add_named("url", desc: "image url, can be empty to use last sent image")

  def handle(%{"url" => ""} = args, %{source: source} = ctx) do
    case Entity.Data.get(source, :last_image_id) do
      nil ->
        {:reply_error, "Please send an image first"}

      image_id ->
        provider = Upload.Provider.Tenshi

        case Upload.upload_from_image_id(provider, image_id) do
          {:ok, image_url} ->
            args = %{args | "url" => image_url}
            handle(args, ctx)

          {:error, err} ->
            {:reply_error, err}
        end
    end
  end

  def handle(%{"url" => url}, _) do
    res = url |> Sauce.sauce_all_provider() |> Enum.map(fn x -> "> #{x}" end) |> Enum.join("\n")
    res = "May the sauce be with you: \n" <> res

    {:reply,
     %LineSdk.Model.TextMessage{
       text: res
     }}
  end
end