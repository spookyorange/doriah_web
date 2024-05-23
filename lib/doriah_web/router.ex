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

    live "/scripts/:id", ScriptLive.Show, :show
    live "/scripts/:id/select_loadout", ScriptLive.Show, :select_loadout
    live "/scripts/:id/with_loadout/:loadout_id", ScriptLive.Show, :with_loadout

    live "/scripts/:id/variable_loadout", ScriptLive.Variable.Loadout, :variable_loadout
    live "/scripts/:id/variable_loadout/load_out", ScriptLive.Variable.Loadout, :load_out

    live "/scripts/:id/variable_loadout/delete_loadout",
         ScriptLive.Variable.Loadout,
         :delete_loadout

    live "/scripts/:id/variable_loadout/:loadout_id",
         ScriptLive.Variable.Loadout,
         :variable_loadout

    live "/scripts/:id/edit_mode", ScriptLive.Edit, :edit_mode
    live "/scripts/:id/edit_mode/basic_info", ScriptLive.Edit, :basic_info
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
