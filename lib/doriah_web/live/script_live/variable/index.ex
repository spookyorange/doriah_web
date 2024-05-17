defmodule DoriahWeb.ScriptLive.Variable.Index do
  use DoriahWeb, :live_view

  attr :script, :any, required: true
  attr :variable_stream, :any, required: true

  def script_variable_dashboard(assigns) do
    ~H"""
    <div>
      <.header>
        Variable Management
        <:subtitle>Create, update, delete variables for your Script here.</:subtitle>
      </.header>

      <.live_component
        module={DoriahWeb.ScriptLive.Variable.CreationForm}
        id={"script-variable-creation-#{@script.id}"}
        script={@script}
      />
      <div class="mt-4 flex flex-col gap-4" id="script_variables" phx-update="stream">
        <div :for={{dom_id, variable} <- @variable_stream} id={dom_id}>
          <.live_component
            module={DoriahWeb.ScriptLive.Variable.Card}
            variable={variable}
            dom_id={dom_id}
            id={"orangesaregood-#{dom_id}"}
          />
        </div>
      </div>
    </div>
    """
  end
end
