defmodule Ytctapi.AuthController do
  use Ytctapi.Web, :controller

  import Comeonin.Bcrypt
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

       new_conn
       |> put_resp_header("x-expires", "#{exp}")
       |> put_resp_header("authorization", "Bearer #{jwt}")
       |> render("login.json", user: user, jwt: jwt, exp: exp)

       end
    {:error, _} ->
      conn
      |> put_status(401)
      |> json(%{status: 401, message: "Could not login", })
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

  def token_auth(conn, %{"id_token" => id_token}) do
    #CLIENT_ID
    #if token ====== Cliuentid
   # https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=XYZ123
   
    url = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{id_token}"

    case HTTPotion.get(url) do
      %HTTPotion.Response{status_code: 200, body: body} ->
        resp = Poison.decode!(body)

        #Repo.get_by(User, username: "jose") || Repo.insert(%User{username: "jose"})

        case Repo.get_by(Ytctapi.User, email: resp["email"]) do
          %User{} = user -> 
            conn 
            |> Guardian.Plug.sign_in(user)
            |> redirect(to: "/")
          nil ->
            changeset = User.registration_changeset(%User{}, %{
              email: resp["email"], 
              username: resp["given_name"], 
              password: Comeonin.Otp.gen_secret()
            })

            case Repo.insert(changeset) do
              {:ok, user} ->
                assign_login(conn, user)
              {:error, changeset} ->
                conn
                |> put_status(:unprocessable_entity)
                |> render(Ytctapi.ChangesetView, "error.json", changeset: changeset)
            end
        end
      %HTTPotion.Response{} ->
        conn
        |> put_status(401)
        |> json(%{status: 401, message: "Could not login", })
    end

  end

  def assign_login(conn, user) do
    new_conn = Guardian.Plug.api_sign_in(conn, user)
    jwt = Guardian.Plug.current_token(new_conn)
    claims = Guardian.Plug.claims(new_conn)
    case claims do
      {:ok, claims} -> exp = Map.get(claims, "exp")

       new_conn
       |> put_resp_header("x-expires", "#{exp}")
       |> put_resp_header("authorization", "Bearer #{jwt}")
       |> render("login.json", user: user, jwt: jwt, exp: exp)

       {:error, _msg} -> 
        conn
        |> put_status(401)
        |> json(%{status: 401, message: "Could not login", })
    end
  end

end
