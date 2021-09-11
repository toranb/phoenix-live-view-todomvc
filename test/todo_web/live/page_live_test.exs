defmodule TodoWeb.PageLiveTest do
  use TodoWeb.ConnCase

  import Phoenix.LiveViewTest

  test "drag n drop should reorder todos", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view |> add_todo("hello two")
    view |> add_todo("hello three")
    view |> add_todo("hello four")

    assert view |> element("li.item-1", "Use Phoenix LiveView") |> has_element?()
    assert view |> element("li.item-2", "hello two") |> has_element?()
    assert view |> element("li.item-3", "hello three") |> has_element?()
    assert view |> element("li.item-4", "hello four") |> has_element?()

    view
    |> element("#draglist")
    |> render_hook("dropped", %{"id" => 1, "item_order" => 2})

    assert view |> element("li.item-1", "hello two") |> has_element?()
    assert view |> element("li.item-2", "Use Phoenix LiveView") |> has_element?()
    assert view |> element("li.item-3", "hello three") |> has_element?()
    assert view |> element("li.item-4", "hello four") |> has_element?()

    view
    |> element("#draglist")
    |> render_hook("dropped", %{"id" => 3, "item_order" => 1})

    assert view |> element("li.item-1", "hello three") |> has_element?()
    assert view |> element("li.item-2", "hello two") |> has_element?()
    assert view |> element("li.item-3", "Use Phoenix LiveView") |> has_element?()
    assert view |> element("li.item-4", "hello four") |> has_element?()

    view
    |> element("#draglist")
    |> render_hook("dropped", %{"id" => 3, "item_order" => 4})

    assert view |> element("li.item-1", "hello two") |> has_element?()
    assert view |> element("li.item-2", "Use Phoenix LiveView") |> has_element?()
    assert view |> element("li.item-3", "hello four") |> has_element?()
    assert view |> element("li.item-4", "hello three") |> has_element?()
  end

  def add_todo(view, text) do
    view
    |> form("#newtodo")
    |> render_submit(%{"form" => %{"text" => text}})
  end
end
