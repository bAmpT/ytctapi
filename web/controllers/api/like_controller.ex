defmodule Ytctapi.LikeController do
  use Ytctapi.Web, :controller
  use Guardian.Phoenix.Controller

  alias Ytctapi.Like

  plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__

  def index(conn, _params, _user, _claims) do
    likes = Repo.all(Like)
    render(conn, "index.json", likes: likes)
  end

  def create(conn, %{"transscript_id" => transscript_id}, user, _claims) do
    changeset = Like.changeset(%Like{}, %{transscript_id: transscript_id, user_id: user.id})

    transscript = Repo.get!(Ytctapi.Transscript, transscript_id)

    case Repo.insert(changeset) do
      {:ok, like} ->
        conn
        |> put_status(:created)
        |> render("show.json", like: like)

        #TODO:
        # Update Likes_Count of Transscript
        # do it in a worker
        changeset = transscript
        |> Ecto.Changeset.change
        |> Ecto.Changeset.put_change(:likes_count, transscript.likes_count + 1)

        Repo.update!(changeset)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Ytctapi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, _user, _claims) do
    like = Repo.get!(Like, id)
    render(conn, "show.json", like: like)
  end

  def update(conn, %{"id" => id, "like" => like_params}, _user, _claims) do
    like = Repo.get!(Like, id)
    changeset = Like.changeset(like, like_params)

    case Repo.update(changeset) do
      {:ok, like} ->
        render(conn, "show.json", like: like)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Ytctapi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, _user, _claims) do
    like = Repo.get!(Like, id) |> Repo.preload(:transscript)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(like)

    #TODO:
    # Update Likes Count in Transscript
    changeset = like.transscript
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_change(:likes_count, like.transscript.likes_count - 1)

    Repo.update!(changeset)

    send_resp(conn, :no_content, "")
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(401)
    |> json(%{message: "Authentication required"})
  end
  
end
