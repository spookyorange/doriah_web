defmodule DoriahWeb.ScriptLive.Index do
  use DoriahWeb, :live_view

  alias Doriah.Scripting
  alias Doriah.Scripting.Script

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :scripts, Scripting.list_scripts())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Script")
    |> assign(:script, Scripting.get_script!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Script")
    |> assign(:script, %Script{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Scripts")
    |> assign(:script, nil)
  end

  @impl true
  def handle_info({DoriahWeb.ScriptLive.FormComponent, {:saved, script}}, socket) do
    {:noreply, stream_insert(socket, :scripts, script)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    script = Scripting.get_script!(id)
    {:ok, _} = Scripting.delete_script(script)

    {:noreply, stream_delete(socket, :scripts, script)}
  end
end
