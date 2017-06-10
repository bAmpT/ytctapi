defmodule Ytctapi.LiveHtmlChannel do
  use Ytctapi.Web, :channel

  alias Ytctapi.Transscript
  alias Ytctapi.User

  def join("live-html", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("transscripts", payload, socket) do
    params = Poison.Parser.parse!(payload)

    filters = Ecto.Changeset.cast(%Transscript{}, params, [], [:language, :difficulty, :category, :topic])
              |> Map.fetch!(:changes)
              |> Map.to_list

    transscripts = Repo.all(from t in Transscript, where: ^filters, order_by: [desc: :inserted_at])
    
    push socket, "home_query", %{home_html: 
      Phoenix.View.render_to_string(Ytctapi.HomeView, "query.html", %{transscripts: transscripts})
    }

    {:noreply, socket}
  end


  def handle_in("search", payload, socket) do
    transscripts = from(t in Transscript, where: fragment(title: ^Mongo.Ecto.Helpers.regex(payload, "i"))) 
      |> Repo.all()
    
    push socket, "search_results", %{search_html: 
      Phoenix.View.render_to_string(Ytctapi.SearchView, "results.html", %{transscripts: transscripts})
    }

    {:noreply, socket}
  end

  def handle_in("profile_words", payload, socket) do
    user = Repo.get_by!(User, username: payload) 
    
    push socket, "profile_words_result", %{profile_words_html: 
      Phoenix.View.render_to_string(Ytctapi.ProfileView, "words.html", %{user: user})
    }

    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
