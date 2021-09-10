defmodule TodoWeb.PageLive do
  use TodoWeb, :live_view

  import Phoenix.HTML.Form

  alias TodoWeb.Live.Component.Header
  alias TodoWeb.Live.Component.Footer
  alias TodoWeb.Live.Component.TodoItem
  alias TodoWeb.Live.Component.Input

  @impl true
  def render(assigns) do
    ~H"""
      <div class="main">
        <div>
          <div class="todoapp">
            <%= live_component Header, id: Ecto.UUID.generate() do %>
              <% uuid: uuid, changeset: changeset, parent: parent -> %>
                <h1>todos</h1>
                <.form let={f} for={changeset} phx-target={parent} phx-submit={:add} id="newtodo" url="#" autocomplete="off" spellcheck="false" autocorrect="off" autocapitalize="off">
                  <%= live_component(Input, id: uuid, form: f, field: :text) %>
                  <%= submit "submit", [class: "d-none"] %>
                </.form>
            <% end %>
            <section class="main">
              <input class="toggle-all" value="on" type="checkbox">
              <ul class="todo-list">
                <%= for todo <- assigns.computed_todos do %>
                  <%= live_component(TodoItem, id: todo.id, todo: todo) %>
                <% end %>
              </ul>
            </section>
            <%= live_component Footer, show: assigns.show do %>
              <% selected: selected -> %>
                <span class="todo-count"><strong><%= assigns.count %></strong>item left</span>
                <ul class="filters">
                  <li><%= link "All", to: "#", phx_click: "show_all", class: selected.("all"), style: "cursor: pointer" %></li>
                  <li><%= link "Active", to: "#", phx_click: "show_active", class: selected.("active"), style: "cursor: pointer" %></li>
                  <li><%= link "Completed", to: "#", phx_click: "show_completed", class: selected.("completed"), style: "cursor: pointer" %></li>
                </ul>
            <% end %>
          </div>
        </div>
      </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    show = "all"
    todos = [
      %{id: 1, text: "Use Phoenix LiveView", completed: false, order: 1},
      %{id: 2, text: "hello two", completed: false, order: 2},
      %{id: 3, text: "hello three", completed: false, order: 3},
      %{id: 4, text: "hello four", completed: false, order: 4}
    ]

    %{computed_todos: computed_todos, count: count} = compute_todos(show, todos)

    {:ok, assign(socket, show: show, count: count, computed_todos: computed_todos, todos: todos)}
  end

  @impl true
  def handle_event("dropped", %{"id" => todo_id, "item_order" => item_order}, %{assigns: %{:todos => todos, :show => show}} = socket) do
    replace_me = todos |> Enum.find(& &1.id == todo_id)

    new_todos =
      todos
      |> Enum.sort_by(& &1.order)
      |> Enum.with_index()
      |> Enum.map(fn {todo,idx} ->
        todo
        |> case do
          %{id: ^todo_id} ->
            %{todo | order: item_order}
          %{order: ^item_order} ->
            %{todo | order: replace_me.order}
          _ ->
            %{todo | order: idx + 1}
        end
      end)

    # new_todos |> IO.inspect(label: "NEW TODOS")

    %{computed_todos: computed_todos, count: count} = compute_todos(show, new_todos)

    {:noreply, assign(socket, count: count, computed_todos: computed_todos, todos: new_todos)}
  end

  @impl true
  def handle_event("show_all", _, %{assigns: %{:todos => todos}} = socket) do
    show = "all"

    %{computed_todos: computed_todos, count: count} = compute_todos(show, todos)

    {:noreply, assign(socket, count: count, computed_todos: computed_todos, show: show)}
  end

  @impl true
  def handle_event("show_active", _, %{assigns: %{:todos => todos}} = socket) do
    show = "active"

    %{computed_todos: computed_todos, count: count} = compute_todos(show, todos)

    {:noreply, assign(socket, count: count, computed_todos: computed_todos, show: show)}
  end

  @impl true
  def handle_event("show_completed", _, %{assigns: %{:todos => todos}} = socket) do
    show = "completed"

    %{computed_todos: computed_todos, count: count} = compute_todos(show, todos)

    {:noreply, assign(socket, count: count, computed_todos: computed_todos, show: show)}
  end

  @impl true
  def handle_event(
        "delete_todo",
        %{"id" => id},
        %{assigns: %{:todos => todos, :show => show}} = socket
      ) do
    todo_id = id |> String.to_integer()

    new_todos =
      todos
      |> Enum.reject(fn todo -> todo.id == todo_id end)

    %{computed_todos: computed_todos, count: count} = compute_todos(show, new_todos)

    {:noreply, assign(socket, count: count, computed_todos: computed_todos, todos: new_todos)}
  end

  @impl true
  def handle_info({:add, %{text: text}}, %{assigns: %{:todos => todos, :show => show}} = socket) do
    %{id: id} =
      todos
      |> Enum.sort_by(& &1.id)
      |> List.last()

    new_todos = todos ++ [%{id: id + 1, text: text, completed: false, order: id + 1}]

    %{computed_todos: computed_todos, count: count} = compute_todos(show, new_todos)

    {:noreply, assign(socket, count: count, computed_todos: computed_todos, todos: new_todos)}
  end

  @impl true
  def handle_info({:complete, payload}, %{assigns: %{:todos => todos, :show => show}} = socket) do
    %{id: id, completed: completed} = payload

    new_todos =
      todos
      |> Enum.map(fn todo ->
        if todo.id == id do
          todo |> Map.put(:completed, boolean?(completed))
        else
          todo
        end
      end)

    %{computed_todos: computed_todos, count: count} = compute_todos(show, new_todos)

    {:noreply, assign(socket, count: count, computed_todos: computed_todos, todos: new_todos)}
  end

  @impl true
  def handle_info({:edit, payload}, %{assigns: %{:todos => todos, :show => show}} = socket) do
    %{id: id, text: text} = payload

    new_todos =
      todos
      |> Enum.map(fn todo ->
        if todo.id == id do
          todo |> Map.put(:text, text)
        else
          todo
        end
      end)

    %{computed_todos: computed_todos, count: count} = compute_todos(show, new_todos)

    {:noreply, assign(socket, count: count, computed_todos: computed_todos, todos: new_todos)}
  end

  defp compute_todos(show, todos) do
    computed_todos =
      if show == "all" do
        todos |> Enum.sort_by(& &1.order)
      else
        completed =
          if show == "completed" do
            true
          else
            false
          end

        todos
        |> Enum.filter(fn todo -> todo.completed == completed end)
        |> Enum.sort_by(& &1.order)
      end

    count = Enum.count(computed_todos)

    %{computed_todos: computed_todos, count: count}
  end

  defp boolean?(value) do
    if value == "true" do
      true
    else
      false
    end
  end
end
