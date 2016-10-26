defmodule Ytctapi.LikeView do
  use Ytctapi.Web, :view

  def render("index.json", %{likes: likes}) do
    %{data: render_many(likes, Ytctapi.LikeView, "like.json")}
  end

  def render("show.json", %{like: like}) do
    %{data: render_one(like, Ytctapi.LikeView, "like.json")}
  end

  def render("like.json", %{like: like}) do
    %{id: like.id,
      user_id: like.user_id,
      transscript: render_one(like.transscript, Ytctapi.TransscriptView, "transscript.json")
    }
  end
end
