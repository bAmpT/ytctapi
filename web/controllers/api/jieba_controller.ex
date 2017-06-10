defmodule Ytctapi.JiebaController do
  use Ytctapi.Web, :controller

  alias ExJieBa
  alias Ytctapi.Transscript

  # plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__

  def show(conn, %{"text" => text}) do
    if String.length(text) > 100 do
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{status: "error", message: "Unprocessable, text too long!"})
    end
    
    jieba = ExJieba.MixSegment.cut text
    render(conn, "show.json", jieba: jieba)
  end

  def index(conn, %{"ytid" => id}) do
    transscript = Repo.get_by!(Transscript, ytid: id)
    
    jiebas = Enum.map transscript.lines, fn(line) ->
      Map.put line, "q", ExJieba.MixSegment.cut( Map.get(line, "q") )
    end

    json(conn, %{data: jiebas, meta: %{}})
  end
end
