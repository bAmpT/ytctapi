defmodule Ytctapi.LoginController do
  use Ytctapi.Web, :controller

  import Comeonin.Bcrypt

  alias Ytctapi.User

  def index(conn, _parmas) do
    render conn, "index.html"
  end

  def login(conn, %{"id_token" => id_token}) do

    url = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{id_token}"

    case HTTPotion.get(url) do
      %HTTPotion.Response{status_code: 200, body: body} ->
        resp = Poison.decode!(body)

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
                conn 
                |> Guardian.Plug.sign_in(user)
                |> redirect(to: "/")
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
    user = Repo.get_by!(User, email: email)
    if checkpw(password, user.encrypted_password) do
      {:ok, user}
    else 
      {:error, nil}
    end
  end

end
