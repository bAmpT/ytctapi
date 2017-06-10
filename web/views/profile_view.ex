defmodule Ytctapi.ProfileView do
  use Ytctapi.Web, :view
  #import Kerosene.HTML

  defp avatar_url(user) do
  	case Ytctapi.Avatar.url({user.avatar, user}, :original) do
      nil -> nil
      url -> String.split(url, "/media") 
            |> Enum.take(2)
    end
  end

  defp transscripts(user) do
  	 user.transscripts |> Enum.with_index
  end
end
