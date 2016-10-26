defmodule Ytctapi.EditorControllerTest do
  use Ytctapi.ConnCase

  alias Ytctapi.Transscript
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, editor_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing editor"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, editor_path(conn, :new)
    assert html_response(conn, 200) =~ "New editor"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, editor_path(conn, :create), editor: @valid_attrs
    assert redirected_to(conn) == editor_path(conn, :index)
    assert Repo.get_by(Transscript, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, editor_path(conn, :create), editor: @invalid_attrs
    assert html_response(conn, 200) =~ "New editor"
  end

  test "shows chosen resource", %{conn: conn} do
    editor = Repo.insert! %Transscript{}
    conn = get conn, editor_path(conn, :show, editor)
    assert html_response(conn, 200) =~ "Show editor"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, editor_path(conn, :show, "111111111111111111111111")
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    editor = Repo.insert! %Transscript{}
    conn = get conn, editor_path(conn, :edit, editor)
    assert html_response(conn, 200) =~ "Edit editor"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    editor = Repo.insert! %Transscript{}
    conn = put conn, editor_path(conn, :update, editor), editor: @valid_attrs
    assert redirected_to(conn) == editor_path(conn, :show, editor)
    assert Repo.get_by(Transscript, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    editor = Repo.insert! %Transscript{}
    conn = put conn, editor_path(conn, :update, editor), editor: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit editor"
  end

  test "deletes chosen resource", %{conn: conn} do
    editor = Repo.insert! %Transscript{}
    conn = delete conn, editor_path(conn, :delete, editor)
    assert redirected_to(conn) == editor_path(conn, :index)
    refute Repo.get(Transscript, editor.id)
  end
end
