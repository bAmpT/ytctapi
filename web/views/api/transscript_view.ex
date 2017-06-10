defmodule Ytctapi.TransscriptView do
  use Ytctapi.Web, :view
  import Kerosene.JSON

  def render("index.json", %{conn: conn, transscripts: transscripts, kerosene: kerosene}) do
    %{
      data: render_many(transscripts, Ytctapi.TransscriptView, "transscript.json"),
      meta: %{pagination: paginate(conn, kerosene)}
    }
  end

  def render("show.json", %{transscript: transscript}) do
    %{
      data: render_one(transscript, Ytctapi.TransscriptView, "transscript.json"),
      meta: %{}
    }
  end

  def render("transscript.json", %{transscript: transscript}) do
    %{
      id: transscript.id,
      user_id: transscript.user_id,
      ytid: transscript.ytid,
      title: transscript.title,
      language: transscript.language,
      lines: transscript.lines,
      views_count: transscript.views_count,
      likes_count: transscript.likes_count,
      words_count: transscript.words_count
    }
  end
end
