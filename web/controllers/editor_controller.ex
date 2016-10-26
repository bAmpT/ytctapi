defmodule Ytctapi.EditorController do
  use Ytctapi.Web, :controller

  alias Ytctapi.Transscript

  plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn) |> Repo.preload(:transscripts)
    render(conn, "index.html", transscripts: user.transscripts)
  end

  def new(conn, _params) do
    changeset = Transscript.changeset(%Transscript{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"transscript" => transscript_params}) do
    user = Guardian.Plug.current_resource(conn) 
    transscript_params = Map.put(transscript_params, "user_id", user.id)
    
    transscript_params = 
      case Poison.decode(URI.decode(transscript_params["lines"] || "")) do
        {:ok, lines} -> Map.put(transscript_params, "lines", lines)
        {:error, _} -> transscript_params
      end
    changeset = Transscript.changeset(%Transscript{}, transscript_params)

    case Repo.insert(changeset) do
      {:ok, _editor} ->
        conn
        |> put_flash(:info, "Transscript created successfully.")
        |> redirect(to: editor_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    transscript = Repo.get!(Transscript, id)
    render(conn, "show.html", transscript: transscript)
  end

  def edit(conn, %{"id" => id}) do
    transscript = Repo.get!(Transscript, id)
    changeset = Transscript.changeset(transscript)
    render(conn, "edit.html", transscript: transscript, changeset: changeset)
  end

  def update(conn, %{"id" => id, "transscript" => transscript_params}) do
    user = Guardian.Plug.current_resource(conn) 
    transscript = Repo.get_by!(Transscript, id: id, user_id: user.id)

    transscript_params = 
      case Poison.decode(URI.decode(transscript_params["lines"] || "")) do
        {:ok, lines} -> Map.put(transscript_params, "lines", lines)
        {:error, _} -> transscript_params
      end
    changeset = Transscript.changeset(transscript, transscript_params)

    case Repo.update(changeset) do
      {:ok, transscript} ->
        conn
        |> put_flash(:info, "Transscript updated successfully.")
        |> redirect(to: editor_path(conn, :show, transscript))
      {:error, changeset} ->
        render(conn, "edit.html", transscript: transscript, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn) 
    transscript = Repo.get_by!(Transscript, id: id, user_id: user.id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(transscript) 
    conn
    |> put_flash(:info, "Transscript deleted successfully.")
    |> redirect(to: editor_path(conn, :index))
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(401)
    |> json(%{message: "Authentication required"})
  end
end
