defmodule Ytctapi.UserController do
  use Ytctapi.Web, :controller
  use Guardian.Phoenix.Controller

  plug Guardian.Plug.EnsureAuthenticated, [handler: __MODULE__] when action in [:me, :update, :delete]

  alias Ytctapi.User

  def me(conn, _params, user, _claims) do
    user = user |> Repo.preload([:transscripts, :likes, likes: :transscript])
    render(conn, "me.json", user: user)
  end

# not public
  def index(conn, _params, _user, _claims) do
    users = Repo.all(User)
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}, _user, _claims) do
    user_params = Map.put( user_params, "encrypted_password", User.hashpassword( user_params["password"] )  )
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> render("show.json", user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Ytctapi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, _user, _claims) do
    user = Repo.get!(User, id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}, user, _claims) do
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        render(conn, "show.json", user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Ytctapi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user, _claims) do

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    send_resp(conn, :no_content, "")
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(401)
    |> render(Ytctapi.ErrorView, "unauthenticated.json", %{status: 401, message: "Authentication required"})
  end
end
