defmodule DoriahWeb.ScriptLive.Variable.Card do
  use DoriahWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  slot :variable

  def render(assigns) do
    ~H"""
    <div>
      <.as_form variable={@variable} />
    </div>
    """
  end

  attr :variable, :any, required: true

  defp as_form(assigns) do
    ~H"""
    <div class="bg-zinc-950 text-white p-4">
      <.label_and_inputful_form_part
        input_name="key"
        variable_id={@variable.id}
        current_value={@variable.key}
      />

      <.label_and_inputful_form_part
        input_name="Default Value"
        variable_id={@variable.id}
        current_value={@variable.default_value}
      />

      <.label_and_inputful_form_part
        input_name="purpose"
        variable_id={@variable.id}
        current_value={@variable.purpose}
      />
    </div>
    """
  end

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
        class="overflow-scroll whitespace-nowrap bg-zinc-950 text-white h-6 w-full p-0 border-0 focus:border-b-2 focus:border-white focus:outline-none focus:ring-0"
        value={@current_value}
        id={"variable-#{@variable_id}-#{@input_name}"}
      />
    </label>
    """
  end
end
