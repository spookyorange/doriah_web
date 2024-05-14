defmodule DoriahWeb.ScriptLive.Show do
  use DoriahWeb, :live_view
  use DoriahWeb.BaseUtil.Controlful

  alias Doriah.Scripting

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    script = Scripting.get_script_with_variables!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:script, script)
     |> assign(:mode, :show)
     |> assign(:whole_script, script.whole_script)
     |> assign(:whole_script_as_input, script.whole_script)
     |> assign(
       :whole_script_as_input_height,
       get_row_count_of_textarea(script.whole_script)
     )
     |> assign(:unsaved_changes_for_whole_script, false)
     |> stream(:script_variables, script.script_variables)
     |> assign(:script_variables, script.script_variables)
     |> assign(:script_sh_url, url(~p"/api/scripts/as_sh/#{script.id}"))
     |> assign(:import_text, "")
     |> assign(:import_text_height, 2)
     |> assign_controlful()}
  end

  attr :label, :string, required: true
  attr :tab_mode, :atom, required: true
  attr :current_mode, :atom, required: true
  attr :keyboard, :string, required: false
  attr :navigate, :string, required: false

  def tab_button(assigns) do
    if assigns.tab_mode === assigns.current_mode do
      ~H"""
      <.link
        patch={@navigate}
        class="grow p-2 rounded-xl text-white font-regular bg-zinc-700 text-center"
      >
        <button>
          <p class="underline font-bold"><%= @label %></p>
          <p class="text-xs hidden lg:block">(<%= @keyboard %>)</p>
        </button>
      </.link>
      """
    else
      ~H"""
      <.link patch={@navigate} class="p-2 rounded-xl text-white grow font-regular text-center">
        <button phx-value-mode-to-change={assigns.tab_mode}>
          <p><%= @label %></p>
          <p class="text-xs hidden lg:block">(<%= @keyboard %>)</p>
        </button>
      </.link>
      """
    end
  end

  defp get_row_count_of_textarea(area_value) do
    (String.split(area_value, "\n") |> length()) + 1
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

  @impl true
  def handle_event("copy", _params, socket) do
    {:noreply, send_copy_script_link_command(socket)}
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
     |> push_redirect(to: ~p"/scripts/#{socket.assigns.script.id}/line_edit_mode")}
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
    {:noreply, socket |> save_whole_script}
  end

  def handle_event("keydown", %{"key" => "b"}, socket) do
    if socket.assigns.keyboarder do
      {:noreply,
       socket
       |> push_navigate(to: ~p"/scripts/")}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "c"}, socket) do
    if socket.assigns.keyboarder do
      {:noreply,
       socket
       |> send_copy_script_link_command
       |> escape_controlful_and_keyboarder}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "e"}, socket) do
    if socket.assigns.keyboarder do
      {:noreply,
       socket
       |> push_redirect(to: ~p"/scripts/#{socket.assigns.script}/line_edit_mode")
       |> escape_controlful_and_keyboarder}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "r"}, socket) do
    if socket.assigns.keyboarder do
      {:noreply,
       socket
       |> push_redirect(to: ~p"/scripts/#{socket.assigns.script}")
       |> escape_controlful_and_keyboarder}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "v"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :line_edit_mode do
      {:noreply,
       socket
       |> push_redirect(to: ~p"/scripts/#{socket.assigns.script}/variables")
       |> escape_controlful_and_keyboarder}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "i"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :line_edit_mode do
      {:noreply,
       socket
       |> push_redirect(to: ~p"/scripts/#{socket.assigns.script}/import")
       |> escape_controlful_and_keyboarder}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "w"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :line_edit_mode do
      {:noreply,
       socket
       |> push_event("focus-on-id-textarea-and-focus-end", %{"id" => "whole-script[itself]"})
       |> escape_controlful_and_keyboarder}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "s"}, socket) do
    if socket.assigns.keyboarder && socket.assigns.live_action == :line_edit_mode do
      {:noreply,
       socket
       |> save_whole_script
       |> escape_controlful_and_keyboarder}
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

  def send_copy_script_link_command(socket) do
    socket
    |> push_event("copy-to-clipboard", %{"id" => "copy-#{socket.assigns.script.id}"})
    |> clear_flash()
    |> put_flash(:info, "Copied to clipboard!")
  end

  def fill_variables_to_script(script, variables) do
    Scripting.fill_line_content_with_variables(script, variables)
  end

  defp page_title(:show), do: "Show Script"
  defp page_title(:edit), do: "Edit Script"
  defp page_title(:variables), do: "Manage Variables"
  defp page_title(:import), do: "Import Script"
  defp page_title(:line_edit_mode), do: "Script Line Edit"
end
