defmodule TodoWeb.PageLive do
  use TodoWeb, :live_view

  import Phoenix.HTML.Form

  alias TodoWeb.Live.Component.Header
  alias TodoWeb.Live.Component.Footer
  alias TodoWeb.Live.Component.TodoItem
  alias TodoWeb.Live.Component.Input

  @impl true
  def render(assigns) do
    ~L"""
      <div class="main">
        <div>
          <div class="todoapp">
            <%= live_component Header, id: 1 do %>
              <h1>todos</h1>
              <%= f = form_for @changeset, "#", [phx_target: @parent, phx_submit: :add, autocomplete: "off", autocorrect: "off", autocapitalize: "off", spellcheck: "false"] %>
                <%= live_component(Input, id: @uuid, form: f, field: :text) %>
                <%= submit "submit", [class: "d-none"] %>
              </form>
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
              <span class="todo-count"><strong><%= assigns.count %></strong>item left</span>
              <ul class="filters">
                <li><%= link "All", to: "#", phx_click: "show_all", class: @selected.("all"), style: "cursor: pointer" %></li>
                <li><%= link "Active", to: "#", phx_click: "show_active", class: @selected.("active"), style: "cursor: pointer" %></li>
                <li><%= link "Completed", to: "#", phx_click: "show_completed", class: @selected.("completed"), style: "cursor: pointer" %></li>
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
    todo = %{id: 1, text: "Use Phoenix LiveView", completed: false}
    todos = [todo]

    %{computed_todos: computed_todos, count: count} = compute_todos(show, todos)

    {:ok, assign(socket, show: show, count: count, computed_todos: computed_todos, todos: todos)}
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

    new_todos = todos ++ [%{id: id + 1, text: text, completed: false}]

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
        todos
      else
        completed =
          if show == "completed" do
            true
          else
            false
          end

        todos |> Enum.filter(fn todo -> todo.completed == completed end)
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
