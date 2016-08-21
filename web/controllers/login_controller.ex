defmodule Ytctapi.LoginController do
  use Ytctapi.Web, :controller

  import Comeonin.Bcrypt

  alias Ytctapi.User
  alias Ytctapi.Auth

  def index(conn, parmas) do
    render conn, "index.html"
  end

  def login(conn, params) do  
    case find_and_confirm_password(params) do
    {:ok, user} ->
       conn
       |> Guardian.Plug.sign_in(user)
       |> put_session(:welcome, true)
       |> redirect(to: "/")
    {:error, changeset} ->
      render conn, "login.html", changeset: changeset
    end
  end  

  def logout(conn, _params) do
    conn
    |> Guardian.Plug.sign_out
    |> put_flash(:info, "Logged out")
    |> redirect(to: "/")
  end

  def find_and_confirm_password(%{"login_email" => email, "login_password" => password})  do
    user = Repo.get_by!(Ytctapi.User, email: email)
    if checkpw(password, user.encrypted_password) do
      {:ok, user}
    else 
      {:error, nil}
    end
  end

end
