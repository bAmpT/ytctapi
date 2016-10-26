defmodule Ytctapi.CommentController do
  use Ytctapi.Web, :controller

  alias Ytctapi.Comment
  alias Ytctapi.Transscript
  alias Ecto.Repo

  def index(conn, _params) do
    comments = Repo.all(Comment)
    render(conn, "index.json", comments: comments)
  end

  def create(conn, %{"comment" => comment_params, "transscript_id" => transscript_id}) do
    transscript = Repo.get!(Transscript, transscript_id) |> Repo.preload([:user, :comments])
    changeset = transscript
    # |> build_assoc(:comments)
    |> Comment.changeset(comment_params)

    case Repo.insert(changeset) do
      {:ok, comment} ->
        conn
        |> put_status(:created)
        |> render("show.json", comment: comment)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Ytctapi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    comment = Repo.get!(Comment, id)
    render(conn, "show.json", comment: comment)
  end

  def update(conn, %{"id" => id, "comment" => comment_params}) do
    comment = Repo.get!(Comment, id)
    changeset = Comment.changeset(comment, comment_params)

    case Repo.update(changeset) do
      {:ok, comment} ->
        render(conn, "show.json", comment: comment)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Ytctapi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    comment = Repo.get!(Comment, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(comment)

    send_resp(conn, :no_content, "")
  end
end
