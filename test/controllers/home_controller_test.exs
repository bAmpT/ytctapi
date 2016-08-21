defmodule Ytctapi.HomeControllerTest do
  use Ytctapi.ConnCase

  alias Ytctapi.Home
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, home_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing homes"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, home_path(conn, :new)
    assert html_response(conn, 200) =~ "New home"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, home_path(conn, :create), home: @valid_attrs
    assert redirected_to(conn) == home_path(conn, :index)
    assert Repo.get_by(Home, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, home_path(conn, :create), home: @invalid_attrs
    assert html_response(conn, 200) =~ "New home"
  end

  test "shows chosen resource", %{conn: conn} do
    home = Repo.insert! %Home{}
    conn = get conn, home_path(conn, :show, home)
    assert html_response(conn, 200) =~ "Show home"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, home_path(conn, :show, "111111111111111111111111")
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    home = Repo.insert! %Home{}
    conn = get conn, home_path(conn, :edit, home)
    assert html_response(conn, 200) =~ "Edit home"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    home = Repo.insert! %Home{}
    conn = put conn, home_path(conn, :update, home), home: @valid_attrs
    assert redirected_to(conn) == home_path(conn, :show, home)
    assert Repo.get_by(Home, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    home = Repo.insert! %Home{}
    conn = put conn, home_path(conn, :update, home), home: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit home"
  end

  test "deletes chosen resource", %{conn: conn} do
    home = Repo.insert! %Home{}
    conn = delete conn, home_path(conn, :delete, home)
    assert redirected_to(conn) == home_path(conn, :index)
    refute Repo.get(Home, home.id)
  end
end
