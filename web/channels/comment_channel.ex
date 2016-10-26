defmodule Ytctapi.CommentChannel do
  use Ytctapi.Web, :channel

  alias Ytctapi.Comment
  alias Ytctapi.Transscript

  def join("comment:"<> _comment_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("create_comment", payload, socket) do
    case Comment.create(payload, socket) do
      {:ok, comment} ->
        broadcast socket, "created_comment", Map.merge(payload, %{
          insertedAt: comment.inserted_at, 
          commentId: comment.id, 
          approved: comment.approved
        })
        {:noreply, socket}
      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_in("approved_comment", payload, socket) do
    case Comment.approve(payload, socket) do
      {:ok, comment} ->
        broadcast socket, "approved_comment", Map.merge(payload, %{
          insertedAt: comment.inserted_at, 
          commentId: comment.id,
          approved: comment.approved
        })
        {:noreply, socket}
      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_in("deleted_comment", payload, socket) do
    case Comment.delete(payload, socket) do
      {:ok, _} ->
        broadcast socket, "deleted_comment", payload
        {:noreply, socket}
      {:error, _} ->
        {:noreply, socket}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
