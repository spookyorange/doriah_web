defmodule DoriahWeb.CustomComponents do
  use Phoenix.Component

  attr :controlful, :boolean, required: true
  attr :keyboarder, :boolean, required: true

  def controlful_panel(assigns) do
    ~H"""
    <div
      class="fixed hidden lg:flex flex-col gap-2 lg:items-center w-full max-w-2xl top-4 bg-zinc-800/50 text-white px-8 py-4 text-xl z-[51]"
      phx-window-keydown="keydown"
      phx-window-keyup="keyup"
    >
      <div>
        <%= case {@controlful, @keyboarder} do %>
          <% {false, false} -> %>
            <p class="opacity-50">
              To activate Keyboarder, press CTRL twice!
            </p>
          <% {true, false} -> %>
            <p class="opacity-50">
              Press CTRL once more to activate Keyboarder(ESC for cancel)
            </p>
          <% {_, true} -> %>
            <p>
              Press ESC or CTRL to cancel Keyboarder
            </p>
        <% end %>
      </div>

      <div title="Use Keyboarder to quickly navigate through this page! Some buttons may have a little key underneath them, use them when in Keyboarder mode">
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
            d="m11.25 11.25.041-.02a.75.75 0 0 1 1.063.852l-.708 2.836a.75.75 0 0 0 1.063.853l.041-.021M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9-3.75h.008v.008H12V8.25Z"
          />
        </svg>
      </div>
    </div>
    """
  end

  attr :char, :string, required: true

  def controlful_indicator_span(assigns) do
    ~H"""
    <span class="hidden lg:block text-xs font-normal">(<%= @char %>)</span>
    """
  end

  attr :char, :string, required: true
  attr :name, :string, required: true

  def controlful_indicator_powered_paragraph(assigns) do
    ~H"""
    <p class="flex flex-col items-center">
      <%= @name %><.controlful_indicator_span char={@char} />
    </p>
    """
  end
end
