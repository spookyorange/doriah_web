defmodule DoriahWeb.ScriptLive.Show do
  use DoriahWeb, :live_view

  alias Doriah.Scripting

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:script, Scripting.get_script!(id))}
  end

  defp page_title(:show), do: "Show Script"
  defp page_title(:edit), do: "Edit Script"
end
