defmodule Ytctapi.LiveHtmlChannel do
  use Ytctapi.Web, :channel

  alias Ytctapi.Transscript

  def join("live-html", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("search", payload, socket) do
    transscripts = from(t in Transscript, where: fragment(title: ^Mongo.Ecto.Helpers.regex(payload, "i"))) 
      |> Repo.all()
    
    push socket, "search_results", %{search_html: 
      Phoenix.View.render_to_string(Ytctapi.SearchView, "results.html", %{transscripts: transscripts})
    }

    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
