defmodule DoriahWeb.ScriptLive.Edit do
  use DoriahWeb, :live_view
  use DoriahWeb.BaseUtil.Controlful

  alias Doriah.Scripting

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign_controlful()}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    script = Scripting.get_script_with_loadouts!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:script, script)
     |> assign(:whole_script, script.whole_script)
     |> assign(:whole_script_as_input, script.whole_script)
     |> assign(
       :whole_script_as_input_height,
       get_row_count_of_textarea(script.whole_script)
     )
     |> assign(:unsaved_changes_for_whole_script, false)
     |> apply_action(socket.assigns.live_action, script)}
  end

  defp apply_action(socket, :edit_mode, _script) do
    socket
  end

  defp apply_action(socket, :basic_info, _script) do
    socket
  end

  defp apply_action(socket, :change_status, _script) do
    socket
  end

  defp apply_action(socket, :change_deprecation_suggestion_link, _script) do
    socket
  end

  defp get_row_count_of_textarea(area_value) do
    String.split(area_value, "\n") |> length()
  end

  @impl true
  def handle_info({DoriahWeb.ScriptLive.FormComponent, {:saved, script}}, socket) do
    {:noreply,
     socket
     |> assign(:script, script)}
  end

  def handle_event(
        "whole_script_input_change",
        %{"whole-script" => %{"itself" => new_value}},
        socket
      ) do
    whole_script_changed = new_value != socket.assigns.whole_script

    {:noreply,
     socket
     |> assign(:whole_script_as_input, new_value)
     |> assign(:whole_script_as_input_height, get_row_count_of_textarea(new_value))
     |> assign(:unsaved_changes_for_whole_script, whole_script_changed)
     |> push_event("get-screen-to-middle-for-editor", %{})}
  end

  def handle_event("change_status", %{"status" => status_to_change}, socket) do
    {:ok, updated_one} =
      Scripting.update_script(socket.assigns.script, %{status: status_to_change})

    {:noreply,
     socket
     |> clear_flash()
     |> put_flash(
       :info,
       "Status is successfully set to: #{Scripting.status_name_to_displayable_name(updated_one.status)}"
     )
     |> push_patch(to: ~p"/scripts/#{socket.assigns.script}/edit_mode")}
  end

  def handle_event(
        "change_deprecation_suggestion_link",
        %{"deprecation_suggestion_link" => the_link},
        socket
      ) do
    {:ok, updated_one} =
      Scripting.update_script(socket.assigns.script, %{deprecated_suggestion_link: the_link})

    {:noreply,
     socket
     |> clear_flash()
     |> put_flash(
       :info,
       "Suggestion link is successfully set to: #{updated_one.deprecated_suggestion_link}"
     )
     |> push_patch(to: ~p"/scripts/#{socket.assigns.script}/edit_mode")}
  end

  def handle_event("save_whole_script", _params, socket) do
    {:noreply, socket |> save_whole_script()}
  end

  def handle_event("delete_script", _, socket) do
    {:ok, _} = Scripting.delete_script(socket.assigns.script)

    {:noreply, socket |> push_navigate(to: ~p"/scripts")}
  end

  def handle_event("keydown", %{"key" => "b"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :edit_mode do
      {:noreply,
       socket
       |> push_navigate(to: ~p"/scripts/#{socket.assigns.script}")}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "e"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :edit_mode do
      {:noreply,
       socket
       |> push_redirect(to: ~p"/scripts/#{socket.assigns.script}/edit_mode/basic_info")}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "w"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :edit_mode do
      {:noreply,
       socket
       |> push_event("focus-on-id-textarea-and-focus-end", %{"id" => "whole-script[itself]"})}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "c"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :edit_mode do
      {:noreply,
       socket
       |> push_navigate(to: ~p"/scripts/#{socket.assigns.script}/edit_mode/change_status")}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "d"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :edit_mode &&
         socket.assigns.script.status == :deprecated do
      {:noreply,
       socket
       |> push_navigate(
         to: ~p"/scripts/#{socket.assigns.script}/edit_mode/change_deprecation_suggestion_link"
       )}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "s"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :edit_mode do
      {:noreply,
       socket
       |> save_whole_script()}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "v"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :edit_mode do
      {:noreply,
       socket
       |> push_navigate(to: ~p"/scripts/#{socket.assigns.script}/variable_loadout")}
    else
      {:noreply, socket}
    end
  end

  use DoriahWeb.BaseUtil.KeyboardSupport

  def save_whole_script(socket) do
    if !socket.assigns.unsaved_changes_for_whole_script do
      socket |> clear_flash() |> put_flash(:error, "Nothing has changed to save")
    else
      {:ok, updated_script} =
        Scripting.update_script(socket.assigns.script, %{
          whole_script: socket.assigns.whole_script_as_input
        })

      socket
      |> assign(:script, updated_script)
      |> assign(whole_script: updated_script.whole_script)
      |> assign(whole_script_as_input: updated_script.whole_script)
      |> assign(
        whole_script_as_input_height: get_row_count_of_textarea(updated_script.whole_script)
      )
      |> assign(:unsaved_changes_for_whole_script, false)
      |> clear_flash()
      |> put_flash(:info, "Script saved successfully!")
    end
  end

  defp page_title(:edit_mode), do: "Script - Edit"
  defp page_title(:basic_info), do: "Script - Edit Basic Information"
  defp page_title(:change_status), do: "Script - Change Status"

  defp page_title(:change_deprecation_suggestion_link),
    do: "Script - Change Deprecation Suggestion Link"
end
