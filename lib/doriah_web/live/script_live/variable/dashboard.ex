defmodule DoriahWeb.ScriptLive.Variable.Dashboard do
  use DoriahWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  slot :variables, required: true
  slot :script, required: true

  def render(assigns) do
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
      <div class="mt-4 flex flex-col gap-4">
        <.live_component
          :for={variable <- assigns.variables}
          module={DoriahWeb.ScriptLive.Variable.Card}
          variable={variable}
          id={"variable-#{variable.id}"}
        />
      </div>
    </div>
    """
  end
end
