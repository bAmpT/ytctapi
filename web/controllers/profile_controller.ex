defmodule Ytctapi.ProfileController do
  use Ytctapi.Web, :controller

  alias Ytctapi.User

  def show(conn, %{"id" => username}) do
    user = Repo.get_by!(User, username: username) 
   	|> Repo.preload([:transscripts]) # , :likes, likes: :transscript
    
    render(conn, "show.html", conn: conn, user: user)
  end

end
