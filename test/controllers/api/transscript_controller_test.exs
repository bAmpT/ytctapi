defmodule Ytctapi.TransscriptControllerTest do
  use Ytctapi.ConnCase

  alias Ytctapi.Transscript
  @valid_attrs %{language: "some content", lines: %{}, title: "some content", userid: "some content", ytid: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    # user = create(:user)
    # {:ok, jwt, full_claims} = Guardian.encode_and_sign(user)
    # {:ok, %{user: user, jwt: jst, claims: full_claims}}
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, transscript_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    transscript = Repo.insert! %Transscript{}
    conn = get conn, transscript_path(conn, :show, transscript)
    assert json_response(conn, 200)["data"] == %{"id" => transscript.id,
      "userid" => transscript.userid,
      "ytid" => transscript.ytid,
      "title" => transscript.title,
      "language" => transscript.language,
      "lines" => transscript.lines}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, transscript_path(conn, :show, "111111111111111111111111")
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, transscript_path(conn, :create), transscript: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Transscript, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, transscript_path(conn, :create), transscript: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    transscript = Repo.insert! %Transscript{}
    conn = put conn, transscript_path(conn, :update, transscript), transscript: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Transscript, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    transscript = Repo.insert! %Transscript{}
    conn = put conn, transscript_path(conn, :update, transscript), transscript: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    transscript = Repo.insert! %Transscript{}
    conn = delete conn, transscript_path(conn, :delete, transscript)
    assert response(conn, 204)
    refute Repo.get(Transscript, transscript.id)
  end
end
