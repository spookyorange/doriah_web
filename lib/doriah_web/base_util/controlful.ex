defmodule DoriahWeb.BaseUtil.Controlful do
  use DoriahWeb, :live_view

  defmacro __using__(_opts) do
    quote do
      defp assign_controlful(socket) do
        socket |> assign(:controlful, false) |> assign(:keyboarder, false)
      end

      defp controlfulness(socket) do
        case {socket.assigns.controlful, socket.assigns.keyboarder} do
          {true, false} ->
            socket
            |> assign(:keyboarder, true)
            |> assign(:controlful, false)
            |> push_event("focus-keyboarder", %{})

          {false, false} ->
            assign(socket, :controlful, true)

          {_, true} ->
            assign(socket, :keyboarder, false)
        end
      end

      defp escape_controlful_and_keyboarder(socket) do
        socket |> assign(:keyboarder, false) |> assign(:controlful, false)
      end
    end
  end
end
