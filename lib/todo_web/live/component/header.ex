defmodule TodoWeb.Live.Component.Header do
  use TodoWeb, :live_component

  def render(assigns) do
    ~L"""
      <header class="header">
        <div>
          <%= render_block(@inner_block, uuid: @uuid, changeset: @changeset, parent: @myself) %>
        </div>
      </header>
    """
  end

  def mount(socket) do
    {:ok, initial_state(socket)}
  end

  def handle_event("add", %{"form" => %{"text" => text}}, socket) do
    send(self(), {:add, %{text: text}})

    {:noreply, initial_state(socket)}
  end

  defp initial_state(socket) do
    assign(socket, uuid: Ecto.UUID.generate(), changeset: Todo.Form.changeset(%Todo.Form{}, %{}))
  end
end
