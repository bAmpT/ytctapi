defmodule Ytctapi.UserView do
  use Ytctapi.Web, :view

  def render("me.json", %{user: user}) do
    %{data: %{
      id: user.id,
      username: user.username,
      transscripts: render_many(user.transscripts, Ytctapi.TransscriptView, "transscript.json"),
      likes: render_many(user.likes, Ytctapi.LikeView, "like.json")
      },
      meta: %{}}
  end

  def render("index.json", %{users: users}) do
    %{data: render_many(users, Ytctapi.UserView, "user.json"),
      meta: %{}}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, Ytctapi.UserView, "user.json"),
      meta: %{}}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      username: user.username}
  end
end
