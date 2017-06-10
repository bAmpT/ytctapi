defmodule Ytctapi.WatchView do
  use Ytctapi.Web, :view

  def title do
    "Awesome New Title!"
  end

  def avatar(user) do
  	url = Ytctapi.Avatar.url({user.avatar, user}, :thumb)
    String.split(url, "/media") 
    |> Enum.take(2)
  end

  def annotation(words) do 
  	words = Annotator.jieba(words)
  	words = Annotator.lookup(words)
  	Annotator.annotate(words, Annotator.HTML)
  end

  def published_ago(transscript) do
    if (transscript.inserted_at == nil) do
      ""
    else 
      days = Ecto.DateTime.to_iso8601(transscript.inserted_at) 
      |> NaiveDateTime.from_iso8601!
      |> NaiveDateTime.diff(NaiveDateTime.utc_now()) 

      "#{round(-days / 86400)} days ago"
    end
     
  end
end
