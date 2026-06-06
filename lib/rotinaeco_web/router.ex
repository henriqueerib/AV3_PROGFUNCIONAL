defmodule RotinaecoWeb.Router do
  use RotinaecoWeb, :router

  import RotinaecoWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RotinaecoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Public routes
  scope "/", RotinaecoWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Routes that mount the current user (but don't require auth)
  scope "/", RotinaecoWeb do
    pipe_through :browser

    live_session :current_user,
      on_mount: [{RotinaecoWeb.UserAuth, :mount_current_scope}] do
      live "/sign-up", UserLive.Registration, :new
      live "/login", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end

  # Authenticated routes
  scope "/", RotinaecoWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{RotinaecoWeb.UserAuth, :require_authenticated}] do
      live "/dashboard", DashboardLive, :index
      live "/profile", ProfileLive, :show
      live "/habits", HabitLive.Index, :index
      live "/habits/new", HabitLive.Index, :new
      live "/habits/:id/edit", HabitLive.Index, :edit
      live "/community", CommunityFeedLive, :index
      live "/feed", CommunityFeedLive, :index
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  if Application.compile_env(:rotinaeco, :dev_routes) do
    scope "/dev" do
      pipe_through :browser
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
