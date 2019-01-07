defmodule OdysseyWeb.Router do
  use OdysseyWeb, :router
  alias Odyssey.Auth.Guardian

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug Guardian.AuthPipeline
  end

  scope "/", OdysseyWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", OdysseyWeb do
    pipe_through :api

    post "/sign-up", UserController, :create
    post "/sign-in", UserController, :sign_in
  end

  scope "/api/v1", OdysseyWeb do
    pipe_through [:api, :jwt_authenticated]

    get "/my-account", UserController, :show
    get "/users", UserController, :index
  end
end
