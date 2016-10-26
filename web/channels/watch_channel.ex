defmodule Ytctapi.WatchChannel do
  use Ytctapi.Web, :channel
  alias Ytctapi.Presence

  alias Ecto.Queryable
  import Ecto.Query

  alias Ytctapi.Transscript

  def random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end

  def join("watch:" <> _room_name, payload, socket) do
    if authorized?(payload) do
      send(self, :after_join)
      if user = Guardian.Phoenix.Socket.current_resource(socket) do 
        {:ok, assign(socket,  :user_id, user.username )}
      else 
        {:ok, assign(socket, :user_id, "anym_"  <> random_string(5))}
      end
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (watch:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    push socket, "presence_state", Ytctapi.Presence.list(socket)
    {:ok, _} = Ytctapi.Presence.track(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:seconds))
    })

    ytid = String.slice(socket.topic, 6..-1)
    from(t in Transscript, where: t.ytid == ^ytid)
      |> Repo.update_all([inc: [views_count: 1]], returning: :views_count)

    # views_count = from(t in Transscript, where: t.ytid == ^ytid, select: t.views_count)
    #   |> Repo.one()
    # broadcast socket, "views_count", %{views_count: views_count}

    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
