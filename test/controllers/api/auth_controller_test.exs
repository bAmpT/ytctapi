defmodule Ytctapi.AuthControllerTest do
  use Ytctapi.ConnCase

  alias Ytctapi.Auth
  alias Ytctapi.User

  @valid_attrs %{username: "test", password: "secret123"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    user = Repo.insert! %User{username: "test", encrypted_password: User.hashpassword(@valid_attrs[:password]), email: "test@wlm.de"}
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "logging in user and checks if valid", %{conn: conn} do
    conn = post conn, auth_path(conn, :create), @valid_attrs
    assert json_response(conn, 200)["username"] == @valid_attrs[:username]
  end

  test "deletes chosen resource", %{conn: conn} do
    conn = delete conn, auth_path(conn, :delete, user)
    assert response(conn, 204)
    refute Repo.get(Auth, user.id)
  end
end
