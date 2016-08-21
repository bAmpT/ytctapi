defmodule Ytctapi.WatchController do
  use Ytctapi.Web, :controller

  alias Ytctapi.Transscript

  def show(conn, %{"v" => ytid}) do
    user = Guardian.Plug.current_resource(conn)
    watch = Repo.get_by!(Transscript, ytid: ytid) |> Repo.preload(:user)

    #TODO:
    # get info from youtube if no transscript found
    
    render(conn, "show.html", watch: watch, user: user)
  end

end
