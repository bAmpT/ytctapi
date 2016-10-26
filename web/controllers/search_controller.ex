defmodule Ytctapi.SearchController do
  use Ytctapi.Web, :controller

  alias Ytctapi.Transscript

  def index(conn, params) do
  	query = Map.get(params, "q")
  	transscripts = nil
  	if query != nil do
  		transscripts = from(t in Transscript, where: fragment(title: ^Mongo.Ecto.Helpers.regex(query, "i"))) 
      					|> Repo.all()
  	end

    render(conn, "index.html", query: query, search_results: transscripts)
  end

end
