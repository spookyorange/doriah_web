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
     |> stream(:script_lines, script.script_lines)}
  end

  @impl true
  def handle_event("add_line", %{"id" => id}, socket) do
    {:ok, new_script_line} = Scripting.create_associated_blank_script_line(id)

    {:noreply,
     socket
     |> put_flash(:info, "New line created successfully")
     |> stream_insert(:script_lines, new_script_line)}
  end

  defp page_title(:show), do: "Show Script"
  defp page_title(:edit), do: "Edit Script"
end
