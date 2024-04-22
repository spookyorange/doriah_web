defmodule DoriahWeb.ScriptLive.Variable.Card do
  alias Doriah.Scripting
  use DoriahWeb, :live_component

  def mount(socket) do
    {:ok, socket |> assign(:edit_mode, false)}
  end

  slot :variable
  slot :dom_id

  def render(assigns) do
    ~H"""
    <div>
      <%= if @edit_mode do %>
        <.as_form variable={@variable} phx_target={@myself} form={@form} />
      <% else %>
        <.as_display variable={@variable} phx_target={@myself} dom_id={@dom_id} />
      <% end %>
    </div>
    """
  end

  attr :variable, :any, required: true
  attr :phx_target, :any, required: true
  attr :dom_id, :integer, required: true

  defp as_display(assigns) do
    ~H"""
    <div class="bg-zinc-950 text-white p-4">
      <.inputless_display_part input_name="key" value={@variable.key} />
      <.inputless_display_part input_name="Default Value" value={@variable.default_value} />
      <.inputless_display_part input_name="purpose" value={@variable.purpose} />

      <.button class="mt-4 bg-zinc-600/60" phx-click="edit_mode_on" phx-target={@phx_target}>
        Edit
      </.button>
      <.button
        class="mt-4 bg-zinc-600/60"
        phx-value-deleted-variable-dom-id={@dom_id}
        phx-value-deleted-variable-self-id={@variable.id}
        phx-click="delete_variable"
      >
        Delete
      </.button>
    </div>
    """
  end

  attr :variable, :any, required: true
  attr :phx_target, :any, required: true
  attr :form, :any, required: true

  defp as_form(assigns) do
    ~H"""
    <.simple_form_classless phx-submit="variable_mod" for={@form} phx-target={@phx_target}>
      <div class="bg-zinc-950 text-white p-4">
        <.label_and_inputful_form_part
          logical_input={@form[:key]}
          input_name="key"
          variable_id={@variable.id}
          current_value={@variable.key}
        />

        <.label_and_inputful_form_part
          logical_input={@form[:default_value]}
          input_name="Default Value"
          variable_id={@variable.id}
          current_value={@variable.default_value}
        />

        <.label_and_inputful_form_part
          logical_input={@form[:purpose]}
          input_name="purpose"
          variable_id={@variable.id}
          current_value={@variable.purpose}
        />

        <.button class="mt-4 bg-zinc-600/60" type="submit" phx-disable-with="Saving...">
          Save Changes
        </.button>
        <.button class="mt-4 bg-zinc-600/60" type="reset">Reset Changes</.button>
        <.button
          class="mt-4 bg-zinc-600/60"
          phx-click="edit_mode_off"
          phx-target={@phx_target}
          type="button"
        >
          Cancel
        </.button>
      </div>
    </.simple_form_classless>
    """
  end

  attr :logical_input, :any, required: true
  attr :input_name, :string, required: true
  attr :current_value, :string, required: true
  attr :variable_id, :integer, required: true

  defp label_and_inputful_form_part(assigns) do
    ~H"""
    <label for={"variable-#{@variable_id}-#{@input_name}"} class="flex gap-2">
      <span class="w-[150px]">
        <%= String.capitalize(@input_name) %>:
      </span>
      <input
        name={@logical_input.name}
        class="overflow-scroll whitespace-nowrap bg-zinc-950 text-white h-6 w-full p-0 border-0 focus:border-b-2 focus:border-white focus:outline-none focus:ring-0"
        value={@current_value}
        id={"variable-#{@variable_id}-#{@input_name}"}
      />
    </label>
    """
  end

  attr :input_name, :string, required: true
  attr :value, :string, required: true

  defp inputless_display_part(assigns) do
    ~H"""
    <div class="flex gap-2">
      <span class="w-[150px]">
        <%= String.capitalize(@input_name) %>:
      </span>
      <p class="overflow-scroll whitespace-nowrap bg-zinc-950 text-white h-6 w-full p-0 border-0 focus:border-b-2 focus:border-white focus:outline-none focus:ring-0">
        <%= @value %>
      </p>
    </div>
    """
  end

  def handle_event("edit_mode_on", _params, socket) do
    {:noreply,
     socket
     |> assign_form(Scripting.change_script_variable(socket.assigns.variable))
     |> assign(:edit_mode, true)}
  end

  def handle_event("edit_mode_off", _params, socket) do
    {:noreply, socket |> assign(:edit_mode, false)}
  end

  def handle_event("variable_mod", %{"script_variable" => script_variable_params}, socket) do
    case Scripting.update_script_variable(socket.assigns.variable, script_variable_params) do
      {:ok, script_variable} ->
        notify_parent({:saved, script_variable})

        {:noreply,
         socket
         |> put_flash(:info, "Script Variable updated successfully")
         |> assign(:edit_mode, false)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
