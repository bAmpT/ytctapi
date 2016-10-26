defmodule Ytctapi.CommentView do
  use Ytctapi.Web, :view

  def render("index.json", %{comments: comments}) do
    %{data: render_many(comments, Ytctapi.CommentView, "comment.json")}
  end

  def render("show.json", %{comment: comment}) do
    %{data: render_one(comment, Ytctapi.CommentView, "comment.json")}
  end

  def render("comment.json", %{comment: comment}) do
    %{id: comment.id}
  end
end
