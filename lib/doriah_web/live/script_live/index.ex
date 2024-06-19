defmodule DoriahWeb.ScriptLive.Index do
  use DoriahWeb, :live_view
  use DoriahWeb.BaseUtil.Controlful

  alias Doriah.Scripting
  alias Doriah.Scripting.Script

  defp split_atoms_to_strings(list) do
    list
    |> Enum.map(fn x -> String.to_atom(x) end)
  end

  defp list_or_singular(list, singular) do
    if length(list) == 0 do
      [singular]
    else
      list
    end
  end

  defp get_statuses_from_params(params) do
    all_possible_statuses = Scripting.all_statuses_atoms()

    from_params =
      get_stuff_from_params(params, "statuses")
      |> split_atoms_to_strings()
      |> Enum.filter(fn x -> x in all_possible_statuses end)

    list_or_singular(from_params, :stable)
  end

  defp get_switchables_from_params(params) do
    from_params =
      get_stuff_from_params(params, "switchables") |> split_atoms_to_strings()

    list_or_singular(from_params, :listed)
  end

  defp get_stuff_from_params(params, name) do
    if params[name] do
      String.split(params[name], ",")
    else
      []
    end
  end

  @impl true
  def mount(params, _session, socket) do
    statuses = get_statuses_from_params(params)
    switchables = get_switchables_from_params(params)

    {:ok,
     assign(
       socket,
       :scripts,
       Scripting.list_scripts(statuses, switchables)
     )
     |> assign_controlful()
     |> assign(:filterable_statuses, filterable_statuses())
     |> assign(:switchable_categories, switchable_categories())
     |> assign(:to_be_applied_statuses, statuses)
     |> assign(:to_be_applied_switchables, switchables)
     |> assign(:applied_statuses, statuses)
     |> assign(:applied_switchables, switchables)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Scripts")
    |> assign(:script, nil)
    |> assign(:filter_selector_on, false)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Scripts - Create")
    |> assign(:script, %Script{listed: true})
  end

  defp apply_action(socket, :import, _params) do
    socket
    |> assign(:page_title, "Scripts - Import")
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
      <div class="flex items-center gap-2">
        <%= @script.title %>
        <DoriahWeb.ScriptLive.Show.status_symbol status={@script.status} />
      </div>
      <.link
        patch={~p"/scripts/#{@script}/initial"}
        class="flex align-center gap-2 bg-gray-950 text-white focus-visible:ring-zinc-500 focus-visible:ring-8"
        tabindex="0"
      >
        Visit <.icon name="hero-chevron-double-right" />
      </.link>
    </div>
    """
  end

  defp filterable_statuses() do
    Scripting.all_statuses_atoms()
  end

  defp switchable_categories() do
    [
      :listed
    ]
  end

  defp switch_filter_dropdown(socket) do
    socket |> assign(:filter_selector_on, !socket.assigns.filter_selector_on)
  end

  def handle_event("switch_switchable", %{"switchable" => switchable, "to" => to}, socket) do
    if to == "true" do
      with_switchable =
        [switchable |> String.to_atom() | socket.assigns.to_be_applied_switchables] |> Enum.uniq()

      {:noreply, socket |> assign(:to_be_applied_switchables, with_switchable)}
    else
      without_switchable =
        socket.assigns.to_be_applied_switchables |> List.delete(switchable |> String.to_atom())

      {:noreply, socket |> assign(:to_be_applied_switchables, without_switchable)}
    end
  end

  def handle_event("switch_status", %{"status" => status, "to" => to}, socket) do
    if to == "true" do
      with_status =
        [status |> String.to_atom() | socket.assigns.to_be_applied_statuses] |> Enum.uniq()

      {:noreply, socket |> assign(:to_be_applied_statuses, with_status)}
    else
      without_status =
        socket.assigns.to_be_applied_statuses |> List.delete(status |> String.to_atom())

      {:noreply, socket |> assign(:to_be_applied_statuses, without_status)}
    end
  end

  def handle_event("switch_filter_dropdown", _, socket) do
    {:noreply, switch_filter_dropdown(socket)}
  end

  def handle_event("apply_filters", _, socket) do
    {:noreply, socket |> apply_filters()}
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

  def handle_event("keydown", %{"key" => "i"}, socket) do
    if socket.assigns.keyboarder do
      {:noreply,
       socket
       |> push_navigate(to: ~p"/scripts/import")}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "f"}, socket) do
    if socket.assigns.keyboarder do
      {:noreply,
       socket
       |> switch_filter_dropdown()}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "a"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.filter_selector_on do
      {:noreply,
       socket
       |> apply_filters()}
    else
      {:noreply, socket}
    end
  end

  use DoriahWeb.BaseUtil.KeyboardSupport

  defp apply_filters(socket) do
    statuses = socket.assigns.to_be_applied_statuses
    switchables = socket.assigns.to_be_applied_switchables

    socket
    |> push_patch(to: generate_url_with_filters(socket))
    |> assign(:applied_statuses, statuses)
    |> assign(:applied_switchables, switchables)
    |> assign(:scripts, Scripting.list_scripts(statuses, switchables))
    |> clear_flash()
    |> put_flash(:info, "Filters applied successfully!")
  end

  defp concat_as_param(list) do
    list
    |> Enum.map(fn x -> Atom.to_string(x) end)
    |> Enum.join(",")
  end

  defp generate_url_with_filters(socket) do
    statuses =
      socket.assigns.to_be_applied_statuses
      |> concat_as_param()

    switchables =
      socket.assigns.to_be_applied_switchables
      |> concat_as_param()

    ~p"/scripts?statuses=#{statuses}&switchables=#{switchables}"
  end
end
