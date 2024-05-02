defmodule DoriahWeb.ScriptLive.Variable.CreationForm do
  alias Doriah.Scripting
  alias Doriah.Scripting.ScriptVariable

  use DoriahWeb, :live_component

  def mount(socket) do
    {:ok, socket |> assign_form(Scripting.change_script_variable(%ScriptVariable{}))}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={@form} id="script-variable-form" phx-target={@myself} phx-submit="save">
        <div class="w-full flex justify-between gap-8">
          <div class="grow">
            <.input field={@form[:key]} type="text" label="Key" />
          </div>
          <div class="grow">
            <.input field={@form[:default_value]} type="text" label="Default Value" />
          </div>
        </div>
        <.input field={@form[:purpose]} type="text" label="Purpose" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Script Variable</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def handle_event("save", %{"script_variable" => script_variable_params}, socket) do
    case Scripting.create_script_variable(socket.assigns.script, script_variable_params) do
      {:ok, script_variable} ->
        notify_parent({:saved, script_variable})

        {:noreply,
         socket
         |> push_event("reset-all-inputs", %{hey: "hey"})
         |> assign_form(Scripting.change_script_variable(%ScriptVariable{}))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end

    {:noreply, socket}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
