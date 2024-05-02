defmodule DoriahWeb.Router do
  use DoriahWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DoriahWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DoriahWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/scripts", ScriptLive.Index, :index
    live "/scripts/new", ScriptLive.Index, :new
    live "/scripts/:id/edit", ScriptLive.Index, :edit

    live "/scripts/:id", ScriptLive.Show, :show
    live "/scripts/:id/show/edit", ScriptLive.Show, :edit

    live "/scripts/:id/show/variables", ScriptLive.Show, :variables
    live "/scripts/:id/line_edit_mode", ScriptLive.Show, :line_edit_mode
  end

  # Other scopes may use custom stacks.
  scope "/api", DoriahWeb do
    pipe_through :api

    get "/scripts/as_sh/:id", ScriptController, :get_script
    get "/scripts/as_sh_file/:id", ScriptController, :get_script_download
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:doriah, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DoriahWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
