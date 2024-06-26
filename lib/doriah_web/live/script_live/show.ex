defmodule DoriahWeb.ScriptLive.Show do
  alias Doriah.VariableManagement
  use DoriahWeb, :live_view
  use DoriahWeb.BaseUtil.Controlful

  alias Doriah.Scripting

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign_controlful()}
  end

  attr :script, :any, required: true

  def status_indicator(assigns) do
    ~H"""
    <.beautiful_section>
      <:title>
        Status
      </:title>
      <div class="flex w-full justify-center items-center gap-2">
        <p>
          <%= Scripting.status_name_to_displayable_name(@script.status) %>
        </p>
        <.status_symbol status={@script.status} />
      </div>
      <div
        :if={@script.status == :deprecated && @script.deprecated_suggestion_link}
        class="flex w-full justify-center"
      >
        Author left this link: "
        <.link
          target="_blank"
          href={fix_deprecation_link(@script.deprecated_suggestion_link)}
          class="text-orange-700"
        >
          <%= fix_deprecation_link(@script.deprecated_suggestion_link) %>
        </.link>
        "
      </div>
    </.beautiful_section>
    """
  end

  defp fix_deprecation_link(the_link) do
    unless the_link |> String.starts_with?("http") || the_link |> String.starts_with?("https") do
      "https://#{the_link}"
    else
      the_link
    end
  end

  attr :status, :string, required: true

  def status_symbol(assigns) do
    ~H"""
    <%= case @status do %>
      <% :under_development -> %>
        <div title="Under development">
          <.icon name="hero-cog" />
        </div>
      <% :untested_usable -> %>
        <div title="Not tested yet, but usable!">
          <.icon name="hero-question-mark-circle" />
        </div>
      <% :stable -> %>
        <div title="Stable, ready to go!!">
          <.icon name="hero-check-badge" />
        </div>
      <% :deprecated -> %>
        <div title="Deprecated, maybe the maintainer left a note?">
          <.icon name="hero-document-minus" />
        </div>
      <% :discounted -> %>
        <div title="Discounted, please don't use this">
          <.icon name="hero-no-symbol" />
        </div>
      <% :just_imported -> %>
        <div title="Imported just now, you might want to wait a bit before using this">
          <.icon name="hero-arrow-down-on-square" />
        </div>
      <% _ -> %>
        unknown
    <% end %>
    """
  end

  defp common_assigns(socket, script) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:script, script)
    |> assign(:whole_script, script.whole_script)
    |> assign(:bypassed, false)
    |> apply_action(socket.assigns.live_action, script)
  end

  @impl true
  def handle_params(%{"id" => id, "loadout_title" => loadout_title}, _, socket) do
    try do
      script = Scripting.get_script_with_loadouts!(id)

      try do
        loadout = VariableManagement.get_loadout_by_title!(id, loadout_title)

        {:noreply,
         socket
         |> common_assigns(script)
         |> assign(:loadout, loadout)
         |> assign(
           :script_sh_url,
           url(~p"/api/scripts/as_sh/#{script}/with_applied_loadout/#{loadout.title}")
         )}
      rescue
        _ ->
          {:noreply,
           socket
           |> push_navigate(to: ~p"/scripts/#{script}")
           |> put_flash(:error, "Loadout not found")}
      end
    rescue
      _ ->
        {:noreply, socket |> push_navigate(to: ~p"/") |> put_flash(:error, "Script not found")}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    try do
      script = Scripting.get_script_with_loadouts!(id)

      {:noreply,
       socket
       |> common_assigns(script)
       |> assign(:loadout, nil)
       |> assign(:script_sh_url, url(~p"/api/scripts/as_sh/#{script.id}"))}
    rescue
      _ ->
        {:noreply, socket |> push_navigate(to: ~p"/") |> put_flash(:error, "Script not found")}
    end
  end

  defp default_loadout_exists?(script) do
    script.default_loadout_codename &&
      Enum.any?(script.loadouts, fn x -> x.title == script.default_loadout_codename end)
  end

  defp apply_action(socket, :show, _script) do
    socket
  end

  defp apply_action(socket, :select_loadout, _script) do
    socket
  end

  defp apply_action(socket, :with_loadout, _script) do
    socket
  end

  defp apply_action(socket, :initial, script) do
    if(default_loadout_exists?(script)) do
      socket
      |> go_default_loadout(script)
      |> clear_flash()
      |> put_flash(:info, "Rerouted: Default loadout found")
    else
      socket
      |> push_patch(to: ~p"/scripts/#{script}")
    end
  end

  @impl true
  def handle_event("copy", %{"type" => type}, socket) do
    {:noreply, send_copy_script_link_command(socket, type)}
  end

  @impl true
  def handle_event("bypass_advice", _, socket) do
    {:noreply, bypass_advice(socket)}
  end

  @impl true
  def handle_event("revert_advice", _, socket) do
    {:noreply, revert_advice(socket)}
  end

  @impl true
  def handle_event("go_default_loadout", _, socket) do
    {:noreply, go_default_loadout(socket, socket.assigns.script)}
  end

  def handle_event("keydown", %{"key" => "e"}, socket) do
    if socket.assigns.keyboarder &&
         (socket.assigns.live_action == :show || socket.assigns.live_action == :with_loadout) do
      {:noreply,
       socket
       |> push_redirect(to: ~p"/scripts/#{socket.assigns.script}/edit_mode")}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "v"}, socket) do
    if socket.assigns.keyboarder &&
         (socket.assigns.live_action == :show || socket.assigns.live_action == :with_loadout) do
      {:noreply,
       socket
       |> push_redirect(to: ~p"/scripts/#{socket.assigns.script}/variable_loadout")}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "b"}, socket) do
    if socket.assigns.keyboarder &&
         (socket.assigns.live_action == :show || socket.assigns.live_action == :with_loadout) do
      {:noreply,
       socket
       |> push_navigate(to: ~p"/scripts/")}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "c"}, socket) do
    if socket.assigns.keyboarder &&
         (socket.assigns.live_action == :show || socket.assigns.live_action == :with_loadout) do
      {:noreply,
       socket
       |> send_copy_script_link_command("curl")}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "w"}, socket) do
    if socket.assigns.keyboarder &&
         (socket.assigns.live_action == :show || socket.assigns.live_action == :with_loadout) do
      {:noreply,
       socket
       |> send_copy_script_link_command("wget")}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "l"}, socket) do
    if socket.assigns.keyboarder &&
         (socket.assigns.live_action == :show || socket.assigns.live_action == :with_loadout) do
      {:noreply,
       socket
       |> push_navigate(to: ~p"/scripts/#{socket.assigns.script}/select_loadout")}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "f"}, socket) do
    if socket.assigns.keyboarder &&
         socket.assigns.live_action == :show && socket.assigns.script.loadout_required do
      {:noreply,
       socket
       |> bypass_advice()}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "r"}, socket) do
    if socket.assigns.keyboarder &&
         socket.assigns.live_action == :show && socket.assigns.script.loadout_required do
      {:noreply,
       socket
       |> revert_advice()}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "d"}, socket) do
    if socket.assigns.keyboarder &&
         socket.assigns.live_action == :show do
      {:noreply,
       socket
       |> go_default_loadout(socket.assigns.script)}
    else
      {:noreply, socket}
    end
  end

  use DoriahWeb.BaseUtil.KeyboardSupport

  defp bypass_advice(socket) do
    socket |> assign(:bypassed, true)
  end

  defp go_default_loadout(socket, script) do
    socket
    |> push_patch(to: ~p"/scripts/#{script}/with_loadout/#{script.default_loadout_codename}")
  end

  defp revert_advice(socket) do
    socket |> assign(:bypassed, false)
  end

  def send_copy_script_link_command(socket, type) do
    if socket.assigns.script.loadout_required && socket.assigns.loadout == nil &&
         !socket.assigns.bypassed do
      socket
      |> clear_flash()
      |> put_flash(:error, "This is forbidden, maybe you want to bypass(f)?")
    else
      socket
      |> push_event("copy-to-clipboard", %{"id" => "copy-#{socket.assigns.script.id}-#{type}"})
      |> clear_flash()
      |> put_flash(:info, "Copied as #{type} to clipboard!")
    end
  end

  def fill_variables_to_script(script, loadout) do
    if loadout == nil do
      script
    else
      Scripting.fill_content_with_variables(
        script,
        loadout.variables
        |> Scripting.standardize_variables()
        |> Scripting.put_list_to_map()
      )
    end
  end

  defp page_title(:show), do: "Script - Preview"
  defp page_title(:initial), do: "Script - Initializing"
  defp page_title(:select_loadout), do: "Script - Select Loadout"
  defp page_title(:with_loadout), do: "Script - Preview With Loadout"
end
