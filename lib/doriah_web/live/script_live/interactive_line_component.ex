defmodule DoriahWeb.ScriptLive.InteractiveLineComponent do
  alias Doriah.Scripting
  use DoriahWeb, :live_component

  def mount(socket) do
    {:ok, assign(socket, edit_mode: false)}
  end

  def render(assigns) do
    ~H"""
    <div
      class="flex justify-between gap-4 bg-zinc-950 text-white py-2 px-4"
      phx-target={@myself}
      id={"form-line-itself-#{@line.id}"}
    >
      <div class="flex w-full h-6">
        <p class="text-sm font-bold text-zinc-300/70 select-none text-end mr-2">
          <%= @line.order %>-
        </p>
        <input
          :if={@live_action === :line_edit_mode}
          class="overflow-scroll whitespace-nowrap bg-zinc-950 text-white h-6 w-full p-0 border-0 focus:border-b-2 focus:border-white focus:outline-none focus:ring-0"
          value={@line.line_itself}
          type="text"
          name="line_itself"
          phx-focus="edit_mode_on"
          phx-blur="edit_mode_off"
          phx-target={@myself}
        />
        <p
          :if={@live_action === :show}
          class="overflow-scroll whitespace-nowrap bg-zinc-950 text-white h-6 w-full p-0 border-0 focus:border-b-2 focus:border-white focus:outline-none focus:ring-0"
        >
          <%= fill_variables(@line.line_itself, @variables) %>
        </p>
      </div>
      <div
        :if={@live_action === :line_edit_mode}
        class="flex gap-4"
        phx-click="delete_line"
        phx-target={@myself}
      >
        <span
          :if={!@edit_mode}
          title="This icon indicates that this line is up to date!"
          class="select-none"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="w-6 h-6"
          >
            <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
          </svg>
        </span>

        <span
          :if={@edit_mode}
          title="This icon indicates that this line is not updated yet, please change focus!"
          class="select-none"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="w-6 h-6"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M18.364 18.364A9 9 0 0 0 5.636 5.636m12.728 12.728A9 9 0 0 1 5.636 5.636m12.728 12.728L5.636 5.636"
            />
          </svg>
        </span>

        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="w-6 h-6"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0"
          />
        </svg>
      </div>
    </div>
    """
  end

  defp fill_variables(line, vars) do
    Scripting.fill_line_content_with_variables(line, vars)
  end

  def handle_event("edit_mode_on", _value, socket) do
    {:noreply,
     socket
     |> assign(edit_mode: true)
     |> assign(current_state: socket.assigns.line.line_itself)
     |> push_event("set-focus-to-eol", %{id: "form-line-itself-#{socket.assigns.line.id}"})}
  end

  def handle_event("delete_line", _value, socket) do
    Scripting.delete_script_line(socket.assigns.line)

    {:noreply,
     push_event(socket, "remove-from-lines", %{id: "form-line-itself-#{socket.assigns.line.id}"})}
  end

  def handle_event("edit_mode_off", %{"value" => value}, socket) do
    # we save it whenever we lose focus
    {:ok, line} = Scripting.update_script_line(socket.assigns.line, %{line_itself: value})

    notify_parent({:updated, line})

    {:noreply, assign(socket, edit_mode: false)}
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
