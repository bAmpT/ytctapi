defmodule Ytctapi.HomeController do
  use Ytctapi.Web, :controller

  alias Ytctapi.Transscript

  def index(conn, params) do
    user = Guardian.Plug.current_resource(conn)

    filters = Ecto.Changeset.cast(
            %Transscript{},  # the model/schema
            params,
            [],
            [:language, :difficulty, :category, :topic] # the filters I want to allow
          )
          |> Map.fetch!(:changes)
          |> Map.to_list

    transscripts = Repo.all(from t in Transscript, where: ^filters, order_by: [desc: :inserted_at])
    welcome = get_session(conn, :welcome)
    
    conn   
    |> delete_session(:welcome)
    |> render("index.html", transscripts: transscripts, user: user, welcome: welcome)
  end

end
