defmodule RotinaecoWeb.Router do
  use RotinaecoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RotinaecoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RotinaecoWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/sign-up", SignUpLive
    live "/profile/:id", ProfileLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", RotinaecoWeb do
  #   pipe_through :api
  # end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:rotinaeco, :dev_routes) do

    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
