defmodule LiveViewDemosWeb.Router do
  use LiveViewDemosWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LiveViewDemosWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", LiveViewDemosWeb do
    pipe_through :browser

    live_session :default do
      live "/", TweetsLive, :index
    end
  end
end
