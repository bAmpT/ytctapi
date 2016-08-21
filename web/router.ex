defmodule Ytctapi.Router do
  use Ytctapi.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_auth do  
  	plug Guardian.Plug.VerifySession
  	plug Guardian.Plug.LoadResource
  end  

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do  
  	plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  	plug Guardian.Plug.LoadResource
  end  

  scope "/", Ytctapi do
    pipe_through :browser # Use the default browser stack

    get "/login", LoginController, :index
  	post "/login", LoginController, :login
  end

  scope "/", Ytctapi do
  	pipe_through [:browser, :browser_auth]

  	get "/", HomeController, :index
    get "/watch", WatchController, :show
    get "/logout", LoginController, :logout
  end

  scope "/api/v1", Ytctapi do
    pipe_through :api

	post "/auth", AuthController, :login
  end

  scope "/api/v1", Ytctapi do
  	pipe_through [:api, :api_auth]

    resources "/jieba", JiebaController, only: [:index, :show]

  	resources "/transscripts", TransscriptController, except: [:new, :edit]
    resources "/users", UserController
    resources "/likes", LikeController
  end

end
