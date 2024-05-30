defmodule DoriahWeb.ScriptLive.EditModules.ChangeStatus do
  use DoriahWeb, :live_component

  alias Doriah.Scripting

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Change Status
        <:subtitle>
          Current Status => <%= Scripting.status_name_to_displayable_name(@script.status) %>
        </:subtitle>
      </.header>

      <form class="flex flex-col gap-4 mt-4" phx-submit="change_status">
        <.status_change_select current_value={assigns.script.status} />
        <.button class="grow">
          Hit it!
        </.button>
      </form>
    </div>
    """
  end

  def status_change_select(assigns) do
    ~H"""
    <.input
      type="select"
      name="status"
      id="status"
      label="New Status"
      value={assigns.current_value}
      options={[
        "Under Development": :under_development,
        "Untested Usable": :untested_usable,
        Stable: :stable,
        Deprecated: :deprecated,
        Discounted: :discounted
      ]}
    />
    """
  end
end
