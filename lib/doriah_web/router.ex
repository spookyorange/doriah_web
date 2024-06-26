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
    live "/scripts/import", ScriptLive.Index, :import

    live "/scripts/:id", ScriptLive.Show, :show
    live "/scripts/:id/initial", ScriptLive.Show, :initial
    live "/scripts/:id/select_loadout", ScriptLive.Show, :select_loadout
    live "/scripts/:id/with_loadout/:loadout_title", ScriptLive.Show, :with_loadout

    live "/scripts/:id/variable_loadout", ScriptLive.Variable.Loadout, :variable_loadout

    live "/scripts/:id/variable_loadout/select_default",
         ScriptLive.Variable.Loadout,
         :select_default

    live "/scripts/:id/variable_loadout/load_out", ScriptLive.Variable.Loadout, :load_out

    live "/scripts/:id/variable_loadout/delete_loadout",
         ScriptLive.Variable.Loadout,
         :delete_loadout

    live "/scripts/:id/variable_loadout/:loadout_title",
         ScriptLive.Variable.Loadout,
         :variable_loadout

    live "/scripts/:id/edit_mode", ScriptLive.Edit, :edit_mode
    live "/scripts/:id/edit_mode/basic_info", ScriptLive.Edit, :basic_info
    live "/scripts/:id/edit_mode/change_status", ScriptLive.Edit, :change_status

    live "/scripts/:id/edit_mode/change_deprecation_suggestion_link",
         ScriptLive.Edit,
         :change_deprecation_suggestion_link
  end

  # Other scopes may use custom stacks.
  scope "/api", DoriahWeb do
    pipe_through :api

    get "/scripts/as_sh/:id", ScriptController, :get_script

    get "/scripts/as_sh/:id/with_applied_loadout/:loadout_title",
        ScriptController,
        :get_script_with_applied_loadout

    get "/scripts/export/as_sh/:id", ScriptController, :export_as_sh
    get "/scripts/export/as_doriah/:id", ScriptController, :export_as_doriah
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
