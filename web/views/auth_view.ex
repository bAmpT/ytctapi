defmodule Ytctapi.AuthView do
  use Ytctapi.Web, :view

  def render("index.json", %{auths: auths}) do
    %{data: render_many(auths, Ytctapi.AuthView, "auth.json")}
  end

  def render("login.json", %{user: user, jwt: jwt, exp: exp}) do
    %{data: %{username: user.username, jwt: jwt, exp: exp},
      meta: %{}}
  end

  def render("auth.json", %{user: user, jwt: jwt, exp: exp}) do
    %{user: user, jwt: jwt, exp: exp}
  end
end
