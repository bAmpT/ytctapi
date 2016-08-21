defmodule Ytctapi.TransscriptController do
  use Ytctapi.Web, :controller
  use Guardian.Phoenix.Controller

  alias Ytctapi.Transscript

  # plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__

  def index(conn, _params, _u, _c) do
    transscripts = Repo.all(Transscript) |> Repo.preload(:likes)

    render(conn, "index.json", transscripts: transscripts)
  end

  def create(conn, %{"transscript" => transscript_params}, user, _claims) do
    transscript_params_ = Map.put(transscript_params, "user_id", user.id)
    changeset = Transscript.changeset(%Transscript{}, transscript_params_) 
  
    case Repo.insert(changeset) do
      {:ok, transscript} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", transscript_path(conn, :show, transscript))
        |> render("show.json", transscript: transscript)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Ytctapi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, _u, _c) do
    transscript = Repo.get_by!(Transscript, ytid: id)
    render(conn, "show.json", transscript: transscript)
  end

  def update(conn, %{"id" => id, "transscript" => transscript_params}) do
    transscript = Repo.get!(Transscript, id)
    changeset = Transscript.changeset(transscript, transscript_params)

    case Repo.update(changeset) do
      {:ok, transscript} ->
        render(conn, "show.json", transscript: transscript)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Ytctapi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, _user, _claims) do
    transscript = Repo.get_by!(Transscript, id: id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(transscript)

    send_resp(conn, :no_content, "")
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(401)
    |> json(%{message: "Authentication required"})
  end

end
