defmodule TodoWeb.Live.Component.Input do
  use TodoWeb, :live_component

  import Phoenix.HTML.Form

  def render(assigns) do
    ~L"""
      <%= text_input @form, @field, [class: "new-todo", placeholder: "What needs to be done?", autofocus: true] %>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end
end
