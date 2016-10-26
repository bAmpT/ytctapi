defmodule Ytctapi.LikeChannel do
  use Ytctapi.Web, :channel

  alias Ytctapi.Like
  alias Ytctapi.Transscript

  def join("like:" <> _transscript_id, payload, socket) do
    if user = Guardian.Phoenix.Socket.current_resource(socket) do 
      {:ok, assign(socket, :user_id, user.id )}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("create_like", %{"transscript_id" => transscript_id} = payload, socket) do
    transscript = case Mongo.Ecto.ObjectID.cast(transscript_id) do 
       {:ok, objectID} -> 
          Repo.get_by!(Transscript, id: objectID)
       :error -> 
          Repo.get_by!(Transscript, ytid: transscript_id)
    end
    changeset = Like.changeset(%Like{}, %{transscript_id: transscript.id, user_id: socket.assigns.user_id})

    case Repo.insert(changeset) do
      {:ok, like} -> 

        likes_count = Repo.one from(l in Like, where: l.transscript_id == ^transscript.id, select: count(l.id))
        
        changeset = transscript
        |> Ecto.Changeset.change
        |> Ecto.Changeset.put_change(:likes_count, likes_count)

        Repo.update!(changeset)

        broadcast socket, "likes_count", %{likes_count: likes_count}

        {:noreply, socket}
      {:error, _} ->
        {:error, %{reason: "unknown error"}}
    end
  end

  def handle_in("delete_like", %{"transscript_id" => transscript_id} = payload, socket) do
    transscript = case Mongo.Ecto.ObjectID.cast(transscript_id) do 
       {:ok, objectID} -> 
          Repo.get_by!(Transscript, id: objectID)
       :error -> 
          Repo.get_by!(Transscript, ytid: transscript_id)
    end
    like = Repo.get_by!(Like, transscript_id: transscript.id, user_id: socket.assigns.user_id)
    Repo.delete!(like)

    likes_count = Repo.one from(l in Like, where: l.transscript_id == ^transscript.id, select: count(l.id))
        
    changeset = transscript
        |> Ecto.Changeset.change
        |> Ecto.Changeset.put_change(:likes_count, likes_count)

        Repo.update!(changeset)

    broadcast socket, "likes_count", %{likes_count: likes_count}

    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
