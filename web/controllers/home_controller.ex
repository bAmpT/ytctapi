defmodule Ytctapi.HomeController do
  use Ytctapi.Web, :controller

  alias Ytctapi.Transscript

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    transscripts = Repo.all(from t in Transscript, order_by: [desc: :inserted_at])
    welcome = get_session(conn, :welcome)
    
    conn   
    |> delete_session(:welcome)
    |> render("index.html", transscripts: transscripts, user: user, welcome: welcome)
  end

end
