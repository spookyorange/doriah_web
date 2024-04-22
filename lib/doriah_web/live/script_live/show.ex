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
     |> stream(:script_lines, script.script_lines)
     |> stream(:script_variables, script.script_variables)
     |> assign(:script_sh_url, url(~p"/api/scripts/as_sh/#{script.id}"))
     |> assign(:show_import, false)}
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
  def handle_info({DoriahWeb.ScriptLive.Variable.Card, {:saved, script_variable}}, socket) do
    {:noreply, stream_insert(socket, :script_variables, script_variable)}
  end

  @impl true
  def handle_event("add_line", %{"id" => id}, socket) do
    {:ok, new_script_line} = Scripting.create_associated_blank_script_line(id)

    {:noreply,
     socket
     |> put_flash(:info, "New line created successfully")
     |> stream_insert(:script_lines, new_script_line)}
  end

  @impl true
  def handle_event("copy", %{"id" => id}, socket) do
    {:noreply,
     push_event(socket, "copy_to_clipboard", %{
       id: id
     })}
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

  defp page_title(:show), do: "Show Script"
  defp page_title(:edit), do: "Edit Script"
  defp page_title(:variables), do: "Manage Variables"
end
