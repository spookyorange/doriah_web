defmodule DoriahWeb.ScriptLive.Index do
  use DoriahWeb, :live_view
  use DoriahWeb.BaseUtil.Controlful

  alias Doriah.Scripting
  alias Doriah.Scripting.Script

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :scripts, Scripting.list_scripts()) |> assign_controlful()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Scripts - Create")
    |> assign(:script, %Script{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Scripts")
    |> assign(:script, nil)
  end

  @impl true
  def handle_info({DoriahWeb.ScriptLive.FormComponent, {:saved, script}}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/scripts/#{script}")}
  end

  attr :script, :any, required: true

  def script_card(assigns) do
    ~H"""
    <div
      class="flex justify-between p-4 rounded-xl bg-gray-950 text-white focus-visible:ring-zinc-500 focus-visible:ring-8"
      tabindex="-1"
    >
      <%= @script.title %>
      <.link
        patch={~p"/scripts/#{@script}"}
        class="flex align-center gap-2 bg-gray-950 text-white focus-visible:ring-zinc-500 focus-visible:ring-8"
        tabindex="0"
      >
        Visit <.icon name="hero-chevron-double-right" />
      </.link>
    </div>
    """
  end

  def handle_event("keydown", %{"key" => "n"}, socket) do
    if socket.assigns.keyboarder do
      {:noreply,
       socket
       |> push_navigate(to: ~p"/scripts/new")}
    else
      {:noreply, socket}
    end
  end

  use DoriahWeb.BaseUtil.KeyboardSupport
end
