defmodule TodoWeb.Live.Component.Footer do
  use TodoWeb, :live_component

  def render(assigns) do
    ~H"""
      <footer class="footer">
        <div>
          <%= render_block(@inner_block, selected: @selected) %>
        </div>
      </footer>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{inner_block: inner_block, show: show}, socket) do
    {:ok,
     assign(socket,
       inner_block: inner_block,
       selected: fn selection -> apply(&is_selected/2, [show, selection]) end
     )}
  end

  defp is_selected(show, selection) do
    if show == selection do
      "selected"
    end
  end
end
