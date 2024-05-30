defmodule DoriahWeb.CustomComponents do
  use Phoenix.Component

  attr :controlful, :boolean, required: true
  attr :keyboarder, :boolean, required: true

  def controlful_panel(assigns) do
    ~H"""
    <div
      inert
      class={[
        "fixed hidden lg:flex flex-col gap-2 lg:items-center w-full max-w-2xl top-4 bg-zinc-800/50 text-white px-8 py-4 text-xl z-[51] opacity-50",
        @controlful && "opacity-75",
        @keyboarder && "opacity-90"
      ]}
      phx-window-keydown="keydown"
      phx-window-keyup="keyup"
    >
      <div>
        <p>
          <%= case {@controlful, @keyboarder} do %>
            <% {false, false} -> %>
              To activate Keyboarder, press CTRL twice!
            <% {true, false} -> %>
              Press CTRL once more to activate Keyboarder!
            <% {_, true} -> %>
              Keyboarder is active!
              Press ESC or CTRL to cancel Keyboarder
          <% end %>
        </p>
      </div>
    </div>
    """
  end

  attr :char, :string, required: true
  attr :keyboarder, :boolean, required: true

  def controlful_indicator_span(assigns) do
    ~H"""
    <span class={["hidden lg:block text-xs font-normal", @keyboarder && "animate-icondance text-lg"]}>
      (<%= @char %>)
    </span>
    """
  end

  attr :char, :string, required: true
  attr :name, :string, required: true
  attr :keyboarder, :boolean, required: true

  def controlful_indicator_powered_paragraph(assigns) do
    ~H"""
    <p class="flex flex-col items-center">
      <%= @name %><.controlful_indicator_span char={@char} keyboarder={@keyboarder} />
    </p>
    """
  end

  slot :inner_block, required: true
  slot :title, required: true

  def beautiful_section(assigns) do
    ~H"""
    <div class="p-2 border-2 border-black">
      <h4 class="text-lg underline font-bold mb-2 text-center">
        <%= render_slot(@title) %>
      </h4>

      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
