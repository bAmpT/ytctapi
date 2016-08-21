defmodule Ytctapi.JiebaView do
  use Ytctapi.Web, :view

  def render("index.json", %{jieba: jieba}) do
    %{data: render_many(jieba, Ytctapi.JiebaView, "jieba.json")}
  end

  def render("show.json", %{jieba: jieba}) do
    %{data: render_one(jieba, Ytctapi.JiebaView, "jieba.json")}
  end

  def render("jieba.json", %{jieba: jieba}) do
    jieba
  end
end
