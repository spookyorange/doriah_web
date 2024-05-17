defmodule DoriahWeb.ScriptLive.Edit do
  use DoriahWeb, :live_view
  use DoriahWeb.BaseUtil.Controlful

  import DoriahWeb.ScriptLive.Variable.Index
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

  defp apply_action(socket, :import, _script) do
    socket
    |> assign(:import_text, "")
    |> assign(:import_text_height, 1)
  end

  defp apply_action(socket, :variables, script) do
    socket
    |> stream(:script_variables, script.script_variables)
  end

  defp apply_action(socket, :basic_info, _script) do
    socket
  end

  defp get_row_count_of_textarea(area_value) do
    String.split(area_value, "\n") |> length()
  end

  def handle_info({DoriahWeb.ScriptLive.FormComponent, {:saved, script}}, socket) do
    {:noreply,
     socket
     |> assign(:script, script)}
  end

  @impl true
  def handle_info({DoriahWeb.ScriptLive.Variable.Card, {:saved, script_variable}}, socket) do
    {:noreply,
     stream_insert(socket, :script_variables, script_variable)
     |> assign(:script_variables, socket.assigns.streams.script_variables)}
  end

  @impl true
  def handle_info({DoriahWeb.ScriptLive.Variable.CreationForm, {:saved, script_variable}}, socket) do
    {:noreply,
     socket
     |> stream_insert(:script_variables, script_variable)
     |> push_event("reset-all-inputs-of-a-form", %{id: "script-variable-form"})}
  end

  @impl true
  def handle_event(
        "delete_variable",
        %{
          "deleted-variable-dom-id" => deleted_variable_dom_id,
          "deleted-variable-self-id" => deleted_variable_self_id
        },
        socket
      ) do
    script_variable = Scripting.get_script_variable!(deleted_variable_self_id)
    {:ok, _} = Scripting.delete_script_variable(script_variable)

    {:noreply, socket |> stream_delete_by_dom_id(:script_variables, deleted_variable_dom_id)}
  end

  def handle_event(
        "import_input_change",
        %{"script_import" => %{"import_textarea" => input_value}},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:import_text, input_value)
     |> assign(:import_text_height, get_row_count_of_textarea(input_value))}
  end

  def handle_event("submit_import_script", _params, socket) do
    {:ok, updated_script} =
      Scripting.import_sh_script(socket.assigns.script.id, socket.assigns.import_text)

    {:noreply,
     socket
     |> assign(:whole_script, updated_script.whole_script)
     |> assign(:import_text, "")
     |> clear_flash()
     |> put_flash(:info, "Script imported successfully!")
     |> push_redirect(to: ~p"/scripts/#{socket.assigns.script.id}/edit_mode")}
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

  def handle_event("save_whole_script", _params, socket) do
    {:noreply, socket |> save_whole_script()}
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
       |> push_redirect(to: ~p"/scripts/#{socket.assigns.script}/edit_mode/basic_info")
       |> escape_controlful_and_keyboarder()}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "v"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :edit_mode do
      {:noreply,
       socket
       |> push_redirect(to: ~p"/scripts/#{socket.assigns.script}/edit_mode/variables")
       |> escape_controlful_and_keyboarder()}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "i"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :edit_mode do
      {:noreply,
       socket
       |> push_redirect(to: ~p"/scripts/#{socket.assigns.script}/edit_mode/import")
       |> escape_controlful_and_keyboarder()}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "w"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :edit_mode do
      {:noreply,
       socket
       |> push_event("focus-on-id-textarea-and-focus-end", %{"id" => "whole-script[itself]"})
       |> escape_controlful_and_keyboarder()}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "s"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :edit_mode do
      {:noreply,
       socket
       |> save_whole_script()
       |> escape_controlful_and_keyboarder()}
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

  defp page_title(:edit_mode), do: "Script - Edit Mode"
  defp page_title(:basic_info), do: "Script - Edit Basic Information"
  defp page_title(:variables), do: "Script - Manage Variables"
  defp page_title(:import), do: "Script - Import Script"
end
