defmodule TodoWeb.Live.Component.Footer do
  use TodoWeb, :live_component

  def render(assigns) do
    ~L"""
    <footer class="footer">
      <div>
        <%= @inner_content.(selected: @selected) %>
      </div>
    </footer>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{inner_content: inner_content, show: show}, socket) do
    {:ok,
     assign(socket,
       inner_content: inner_content,
       selected: fn selection -> apply(&is_selected/2, [show, selection]) end
     )}
  end

  defp is_selected(show, selection) do
    if show == selection do
      "selected"
    end
  end
end
