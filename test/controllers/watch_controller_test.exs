defmodule Ytctapi.WatchControllerTest do
  use Ytctapi.ConnCase

  alias Ytctapi.Watch
  @valid_attrs %{ytid: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, watch_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing watches"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, watch_path(conn, :new)
    assert html_response(conn, 200) =~ "New watch"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, watch_path(conn, :create), watch: @valid_attrs
    assert redirected_to(conn) == watch_path(conn, :index)
    assert Repo.get_by(Watch, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, watch_path(conn, :create), watch: @invalid_attrs
    assert html_response(conn, 200) =~ "New watch"
  end

  test "shows chosen resource", %{conn: conn} do
    watch = Repo.insert! %Watch{}
    conn = get conn, watch_path(conn, :show, watch)
    assert html_response(conn, 200) =~ "Show watch"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, watch_path(conn, :show, "111111111111111111111111")
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    watch = Repo.insert! %Watch{}
    conn = get conn, watch_path(conn, :edit, watch)
    assert html_response(conn, 200) =~ "Edit watch"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    watch = Repo.insert! %Watch{}
    conn = put conn, watch_path(conn, :update, watch), watch: @valid_attrs
    assert redirected_to(conn) == watch_path(conn, :show, watch)
    assert Repo.get_by(Watch, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    watch = Repo.insert! %Watch{}
    conn = put conn, watch_path(conn, :update, watch), watch: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit watch"
  end

  test "deletes chosen resource", %{conn: conn} do
    watch = Repo.insert! %Watch{}
    conn = delete conn, watch_path(conn, :delete, watch)
    assert redirected_to(conn) == watch_path(conn, :index)
    refute Repo.get(Watch, watch.id)
  end
end
