defmodule Ytctapi.WatchController do
  use Ytctapi.Web, :controller

  alias Ytctapi.Transscript
  alias Ytctapi.Like

  def show(conn, %{"v" => ytid}) do
    user = Guardian.Plug.current_resource(conn)
    transscript = Repo.get_by!(Transscript, ytid: ytid) |> Repo.preload(:user)
    liked = if user && Repo.get_by(Like, transscript_id: transscript.id, user_id: user.id) do
    	true
    else 
      false
    end
    #TODO:
    # get info from youtube if no transscript found
    
    render(conn, "show.html", watch: transscript, user: user, liked: liked)
  end

end
