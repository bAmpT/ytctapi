defmodule Ytctapi.AuthControllerTest do
  use Ytctapi.ConnCase

  alias Ytctapi.User
  import Comeonin.Bcrypt

  @valid_attrs %{username: "test", password: "secret123"}
  @invalid_attrs %{username: "test", password: "no"}

  setup %{conn: conn} do
    user = Repo.insert! %User{username: "test", encrypted_password: Comeonin.Bcrypt.hashpassword(@valid_attrs[:password]), email: "test@wlm.de"}
    {:ok, conn: put_req_header(conn, "accept", "application/json"), user: user}
  end

  test "logging in user and checks if valid", %{conn: conn} do
    conn = post conn, auth_path(conn, :login), @valid_attrs
    assert json_response(conn, 200)["data"]["username"] == @valid_attrs[:username]
  end

  test "logging in with wrong cred", %{conn: conn} do
    conn = post conn, auth_path(conn, :login), @invalid_attrs
    assert json_response(conn, 401) == %{
      "status" => 401,
      "message" => "Could not login"
    }
  end

  # test "deletes chosen resource", %{conn: conn, user: user} do
  #   conn = delete conn, auth_path(conn, :delete, user)
  #   assert response(conn, 204)
  #   refute Repo.get(Auth, user.id)
  # end
end
