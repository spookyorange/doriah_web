defmodule DoriahWeb.ScriptLive.EditModules.ChangeDeprecationSuggestionLink do
  use DoriahWeb, :live_component

  attr :script, :any, required: true

  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.header>
        Add/Change the deprecation suggestion link
        <:subtitle>
          Add a deprecation suggestion link, so that the users will know where to go after they see the script is deprecated
        </:subtitle>
      </.header>
      <form class="flex flex-col gap-2" phx-submit="change_deprecation_suggestion_link">
        <.input
          name="deprecation_suggestion_link"
          id="deprecation_suggestion_link"
          label="The link"
          value={@script.deprecated_suggestion_link}
        />
        <.button>
          Pull the plug!
        </.button>
      </form>
    </div>
    """
  end
end
