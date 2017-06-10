defmodule Ytctapi.LiveApiChannel do
  use Ytctapi.Web, :channel

  alias Ytctapi.Transscript
  alias Ytctapi.Word

  def join("live-api", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("search", payload, socket) do
    transscripts = from(t in Transscript, where: fragment(title: ^Mongo.Ecto.Helpers.regex(payload, "i"))) 
      |> Repo.all()

    push socket, "search_results", Phoenix.View.render(Ytctapi.TransscriptView, "index.json", %{transscripts: transscripts})

    {:noreply, socket}
  end

  def handle_in("addNewWord", payload, socket) do
    word_changeset = Word.changeset(%Word{}, payload)

    user = Guardian.Phoenix.Socket.current_resource(socket)
    changeset = Ecto.Changeset.change(user)
             |> Ecto.Changeset.put_embed(:words, user.words ++ [word_changeset])

    case Repo.update(changeset) do
      {:ok, _transscript} ->
        push socket, "addNewWord", %{status: :created}
      {:error, _changeset} ->
        push socket, "addNewWord", %{status: :error}
    end

    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
