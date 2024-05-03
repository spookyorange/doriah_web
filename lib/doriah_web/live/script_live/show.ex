defmodule DoriahWeb.ScriptLive.Show do
  use DoriahWeb, :live_view

  alias Doriah.Scripting

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    script = Scripting.get_script_with_lines!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:script, script)
     |> assign(:mode, :show)
     |> stream(:script_lines, script.script_lines)
     |> stream(:script_variables, script.script_variables)
     |> assign(:script_variables, script.script_variables)
     |> assign(:script_sh_url, url(~p"/api/scripts/as_sh/#{script.id}"))
     |> assign(:show_import, false)
     |> assign(:controlful, false)
     |> assign(:keyboarder, false)}
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
        <button phx-value-mode-to-change={assigns.tab_mode} phx-click="change_display_mode">
          <p><%= @label %></p>
          <p class="text-xs hidden lg:block">(<%= @keyboard %>)</p>
        </button>
      </.link>
      """
    end
  end

  @impl true
  def handle_info({DoriahWeb.ScriptLive.InteractiveLineComponent, {:updated, line}}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Line updated successfully!")
     |> stream_insert(:script_lines, line)}
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
        "delete_line",
        %{"deleted-line-id" => deleted_line_id},
        socket
      ) do
    line = Scripting.get_script_line!(deleted_line_id)
    Scripting.delete_script_line(line)

    {:noreply,
     socket
     |> stream_delete(:script_lines, line)
     |> put_flash(:info, "Line deleted successfully!")}
  end

  @impl true
  def handle_event("copy", %{"id" => id}, socket) do
    {:noreply,
     push_event(socket, "copy_to_clipboard", %{
       id: id
     })}
  end

  @impl true
  def handle_event("add_line", %{"id" => id}, socket) do
    {:ok, new_script_line} = Scripting.create_associated_blank_script_line(id)

    {:noreply,
     socket
     |> put_flash(:info, "New line created successfully")
     |> stream_insert(:script_lines, new_script_line)}
  end

  def handle_event("import_from_file_modal_open", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_import, true)
     |> assign(:import_text, "")
     |> assign(:import_text_height, 2)}
  end

  def handle_event(
        "import_from_file_modal_close",
        _params,
        socket
      ) do
    {:noreply, assign(socket, :show_import, false)}
  end

  def handle_event(
        "import_input_change",
        %{"script_import" => %{"import_textarea" => input_value}},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:import_text, input_value)
     |> assign(:import_text_height, (String.split(input_value, "\n") |> length()) + 1)}
  end

  def handle_event("submit_import_script", _params, socket) do
    {:ok, whole_script_with_lines} =
      Scripting.import_multiline_script(socket.assigns.script.id, socket.assigns.import_text)

    {:noreply,
     socket
     |> stream(:script_lines, whole_script_with_lines.script_lines)
     |> assign(:show_import, false)
     |> assign(:import_text, "")}
  end

  def handle_event("change_display_mode", %{"mode-to-change" => mode_to_change}, socket) do
    {:noreply, socket |> assign(:mode, String.to_atom(mode_to_change))}
  end

  def handle_event("keydown", %{"key" => "e"}, socket) do
    if socket.assigns.keyboarder do
      {:noreply,
       socket
       |> push_redirect(to: ~p"/scripts/#{socket.assigns.script.id}/line_edit_mode")
       |> escape_controlful_and_keyboarder}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "r"}, socket) do
    if socket.assigns.keyboarder do
      {:noreply,
       socket
       |> push_redirect(to: ~p"/scripts/#{socket.assigns.script.id}")
       |> escape_controlful_and_keyboarder}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keyup", %{"key" => "Control"}, socket) do
    {:noreply, socket |> controlfulness}
  end

  def handle_event("keyup", %{"key" => "Escape"}, socket) do
    {:noreply, socket |> escape_controlful_and_keyboarder}
  end

  def handle_event("keydown", _, socket) do
    {:noreply, socket}
  end

  def handle_event("keyup", _, socket) do
    {:noreply, socket |> escape_controlful_and_keyboarder}
  end

  defp controlfulness(socket) do
    case {socket.assigns.controlful, socket.assigns.keyboarder} do
      {true, false} -> socket |> assign(:keyboarder, true) |> assign(:controlful, false)
      {false, false} -> assign(socket, :controlful, true)
      {_, true} -> assign(socket, :keyboarder, false)
    end
  end

  defp escape_controlful_and_keyboarder(socket) do
    socket |> assign(:keyboarder, false) |> assign(:controlful, false)
  end

  defp page_title(:show), do: "Show Script"
  defp page_title(:edit), do: "Edit Script"
  defp page_title(:variables), do: "Manage Variables"
  defp page_title(:line_edit_mode), do: "Script Line Edit"
end
