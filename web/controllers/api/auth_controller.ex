defmodule Ytctapi.AuthController do
  use Ytctapi.Web, :controller

  import Comeonin.Bcrypt

  alias Ytctapi.Auth
  alias Ytctapi.User

# Login
  def login(conn, params) do
    
    case find_and_confirm_password(params) do
    {:ok, user} ->
       new_conn = Guardian.Plug.api_sign_in(conn, user)
       jwt = Guardian.Plug.current_token(new_conn)
       claims = Guardian.Plug.claims(new_conn)
       case claims do
         {:ok, claims} -> exp = Map.get(claims, "exp")
       end

       new_conn
       |> put_resp_header("x-expires", "#{exp}")
       |> put_resp_header("authorization", "Bearer #{jwt}")
       |> render "login.json", user: user, jwt: jwt, exp: exp
    {:error, changeset} ->
      conn
      |> put_status(401)
      |> json %{status: 401, message: "Could not login", }
    end
  end

# Logout
  def logout(conn, _params) do
    jwt = Guardian.Plug.current_token(conn)
    case Guardian.Plug.claims(conn) do
      {:ok, claims} -> 
        Guardian.revoke!(jwt, claims)
        json conn, %{status: 200, message: "Logout complete"}
      {:error, message} -> 
        json conn, %{status: 401, message: message}
    end
  end

  def find_and_confirm_password(%{"username" => username, "password" => password})  do
    user = Repo.get_by!(Ytctapi.User, username: username)
    if checkpw(password, user.encrypted_password) do
      {:ok, user}
    else 
      {:error, nil}
    end
  end

end
