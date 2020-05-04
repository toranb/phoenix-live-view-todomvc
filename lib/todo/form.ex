defmodule Todo.Form do
  use Ecto.Schema

  import Ecto.Changeset

  schema "todo_form" do
    field :text, :string
    field :completed, :boolean
  end

  @required_attrs [
    :text,
    :completed
  ]

  def changeset(todo, params \\ %{}) do
    todo
    |> cast(params, @required_attrs)
    |> validate_required(@required_attrs)
  end
end
