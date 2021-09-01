defmodule TodoWeb.Live.Component.TodoItem do
  use TodoWeb, :live_component

  import Phoenix.HTML.Form

  def render(assigns) do
    ~H"""
    <li class={"#{if @editing == true, do: "editing"} #{if @completed == true, do: "completed"}"}>
        <div>
          <.form let={f} for={@changeset} phx-target={@myself} phx-submit={:edit} url="#" autocomplete="off" spellcheck="false" autocorrect="off" autocapitalize="off">
            <div class="view">
              <%= checkbox f, :completed, [id: @toggle_uuid, class: "toggle", phx_click: "complete", phx_target: @myself] %>
              <label><%= link @text, to: "#", phx_click: "toggle_edit", phx_target: @myself %></label>
              <button phx-value-id={@id} phx-click="delete_todo" type="button" class="destroy"></button>
            </div>
            <%= text_input f, :text, [id: @uuid, class: "edit", phx_blur: :blur_text, phx_target: @myself] %>
          </.form>
        </div>
      </li>
    """
  end

  def mount(socket) do
    uuid = Ecto.UUID.generate()

    {:ok, assign(socket, editing: false, uuid: uuid, toggle_uuid: "toggle_#{uuid}")}
  end

  def update(%{todo: %{id: id, text: text, completed: completed}}, socket) do
    %{assigns: %{editing: editing}} = socket

    changeset =
      Todo.Form.changeset(%Todo.Form{id: id, text: text, completed: completed}, %{})
      |> Map.put(:action, :insert)

    {:ok,
     assign(socket,
       id: id,
       text: text,
       editing: editing,
       completed: completed,
       changeset: changeset
     )}
  end

  def handle_event("toggle_edit", %{"detail" => 1}, socket), do: {:noreply, socket}

  def handle_event("toggle_edit", %{"detail" => 2}, %{assigns: %{editing: editing}} = socket) do
    {:noreply, assign(socket, editing: !editing)}
  end

  def handle_event("blur_text", _params, %{assigns: %{editing: editing}} = socket) do
    {:noreply, assign(socket, editing: !editing)}
  end

  def handle_event("edit", %{"form" => %{"text" => text}}, socket) do
    %{assigns: %{changeset: %{data: %{id: id}}}} = socket
    send(self(), {:edit, %{id: id, text: text}})

    {:noreply, socket}
  end

  def handle_event("complete", %{"value" => value}, socket), do: complete_event(value, socket)
  def handle_event("complete", _params, socket), do: complete_event(false, socket)

  defp complete_event(completed, socket) do
    %{assigns: %{changeset: %{data: %{id: id}}}} = socket

    send(self(), {:complete, %{id: id, completed: completed}})

    {:noreply, socket}
  end
end
