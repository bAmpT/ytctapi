defmodule Ytctapi.JiebaControllerTest do
  use Ytctapi.ConnCase

  alias Ytctapi.Jieba
  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, jieba_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    jieba = Repo.insert! %Jieba{}
    conn = get conn, jieba_path(conn, :show, jieba)
    assert json_response(conn, 200)["data"] == %{"id" => jieba.id}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, jieba_path(conn, :show, "111111111111111111111111")
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, jieba_path(conn, :create), jieba: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Jieba, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, jieba_path(conn, :create), jieba: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    jieba = Repo.insert! %Jieba{}
    conn = put conn, jieba_path(conn, :update, jieba), jieba: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Jieba, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    jieba = Repo.insert! %Jieba{}
    conn = put conn, jieba_path(conn, :update, jieba), jieba: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    jieba = Repo.insert! %Jieba{}
    conn = delete conn, jieba_path(conn, :delete, jieba)
    assert response(conn, 204)
    refute Repo.get(Jieba, jieba.id)
  end
end
