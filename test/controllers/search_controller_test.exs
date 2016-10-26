defmodule Ytctapi.SearchControllerTest do
  use Ytctapi.ConnCase

  alias Ytctapi.Search
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, search_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing search"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, search_path(conn, :new)
    assert html_response(conn, 200) =~ "New search"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, search_path(conn, :create), search: @valid_attrs
    assert redirected_to(conn) == search_path(conn, :index)
    assert Repo.get_by(Search, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, search_path(conn, :create), search: @invalid_attrs
    assert html_response(conn, 200) =~ "New search"
  end

  test "shows chosen resource", %{conn: conn} do
    search = Repo.insert! %Search{}
    conn = get conn, search_path(conn, :show, search)
    assert html_response(conn, 200) =~ "Show search"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, search_path(conn, :show, "111111111111111111111111")
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    search = Repo.insert! %Search{}
    conn = get conn, search_path(conn, :edit, search)
    assert html_response(conn, 200) =~ "Edit search"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    search = Repo.insert! %Search{}
    conn = put conn, search_path(conn, :update, search), search: @valid_attrs
    assert redirected_to(conn) == search_path(conn, :show, search)
    assert Repo.get_by(Search, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    search = Repo.insert! %Search{}
    conn = put conn, search_path(conn, :update, search), search: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit search"
  end

  test "deletes chosen resource", %{conn: conn} do
    search = Repo.insert! %Search{}
    conn = delete conn, search_path(conn, :delete, search)
    assert redirected_to(conn) == search_path(conn, :index)
    refute Repo.get(Search, search.id)
  end
end
