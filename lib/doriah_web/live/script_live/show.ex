defmodule DoriahWeb.ScriptLive.Show do
  alias Doriah.VariableManagement
  use DoriahWeb, :live_view
  use DoriahWeb.BaseUtil.Controlful

  alias Doriah.Scripting

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign_controlful()}
  end

  @impl true
  def handle_params(%{"id" => id, "loadout_id" => loadout_id}, _, socket) do
    script = Scripting.get_script_with_variables!(id)
    loadout = VariableManagement.get_loadout!(id, loadout_id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:script, script)
     |> assign(:loadout, loadout)
     |> assign(
       :script_sh_url,
       url(~p"/api/scripts/as_sh/#{script}/with_applied_loadout/#{loadout}")
     )
     |> assign(:whole_script, script.whole_script)
     |> apply_action(socket.assigns.live_action, script)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    script = Scripting.get_script_with_variables!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:script, script)
     |> assign(:loadout, nil)
     |> assign(:script_sh_url, url(~p"/api/scripts/as_sh/#{script.id}"))
     |> assign(:whole_script, script.whole_script)
     |> apply_action(socket.assigns.live_action, script)}
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

  @impl true
  def handle_event("copy", %{"type" => type}, socket) do
    {:noreply, send_copy_script_link_command(socket, type)}
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

  use DoriahWeb.BaseUtil.KeyboardSupport

  def send_copy_script_link_command(socket, type) do
    socket
    |> push_event("copy-to-clipboard", %{"id" => "copy-#{socket.assigns.script.id}-#{type}"})
    |> clear_flash()
    |> put_flash(:info, "Copied as #{type} to clipboard!")
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
  defp page_title(:select_loadout), do: "Script - Select Loadout"
  defp page_title(:with_loadout), do: "Script - Preview With Loadout"
end
