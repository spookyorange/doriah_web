defmodule DoriahWeb.ScriptLive.Show do
  use DoriahWeb, :live_view
  use DoriahWeb.BaseUtil.Controlful

  alias Doriah.Scripting

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign_controlful()}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    script = Scripting.get_script_with_variables!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:script, script)
     |> assign(:script_sh_url, url(~p"/api/scripts/as_sh/#{script.id}"))
     |> apply_action(socket.assigns.live_action, script)}
  end

  defp apply_action(socket, :show, script) do
    socket
    |> assign(:whole_script, script.whole_script)
    |> assign(:script_variables, script.script_variables)
  end

  @impl true
  def handle_event("copy", _params, socket) do
    {:noreply, send_copy_script_link_command(socket)}
  end

  def handle_event("keydown", %{"key" => "e"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :show do
      {:noreply,
       socket
       |> push_redirect(to: ~p"/scripts/#{socket.assigns.script}/edit_mode")
       |> escape_controlful_and_keyboarder()}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "b"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :show do
      {:noreply,
       socket
       |> push_navigate(to: ~p"/scripts/")}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "c"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :show do
      {:noreply,
       socket
       |> send_copy_script_link_command
       |> escape_controlful_and_keyboarder()}
    else
      {:noreply, socket}
    end
  end

  use DoriahWeb.BaseUtil.KeyboardSupport

  def send_copy_script_link_command(socket) do
    socket
    |> push_event("copy-to-clipboard", %{"id" => "copy-#{socket.assigns.script.id}"})
    |> clear_flash()
    |> put_flash(:info, "Copied to clipboard!")
  end

  def fill_variables_to_script(script, variables) do
    Scripting.fill_line_content_with_variables(
      script,
      variables
      |> Scripting.standardize_variables()
      |> Scripting.put_list_to_map()
    )
  end

  defp page_title(:show), do: "Script - Preview Mode"
end
