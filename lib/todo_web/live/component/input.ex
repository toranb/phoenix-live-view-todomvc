defmodule TodoWeb.Live.Component.Input do
  use Phoenix.LiveComponent

  import Phoenix.HTML.Form

  def render(assigns) do
    ~H"""
      <i>
      <%= text_input @form, @field, [class: "new-todo", placeholder: "What needs to be done?", autofocus: true] %>
      </i>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end
end
