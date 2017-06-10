defmodule Ytctapi.SearchController do
  use Ytctapi.Web, :controller

  alias Ytctapi.Transscript

  def index(conn, %{"q" => query}) do

  	transscripts = 
        with title = Mongo.Ecto.Helpers.regex(query, "i"),
        do: Repo.all(from t in Transscript, where: fragment(title: ^title))

    render(conn, "index.html", query: query, search_results: transscripts)
  end

  def index(conn, _params) do
    render(conn, "index.html", query: nil, search_results: nil)
  end

end
