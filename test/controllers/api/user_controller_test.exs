defmodule Ytctapi.UserControllerTest do
  use Ytctapi.ConnCase

  alias Ytctapi.User

  @valid_attrs %{username: "test", password: "secret123", email: "test@wlm.de"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    user = Repo.insert! %User{username: @valid_attrs[:username], encrypted_password: Comeonin.Bcrypt.hashpwsalt(@valid_attrs[:password]), email: @valid_attrs[:email]}
    {:ok, conn: put_req_header(conn, "accept", "application/json"), user: user}
  end

  test "show own profile without auth", %{conn: conn} do
    conn = get conn, "/api/v1/users/me"
    assert json_response(conn, 401)["data"] == %{
      "status" => 401,
      "message" => "Authentication required"
    }
  end

  test "show own profile", %{conn: conn, user: user} do
    # Get Auth Token
    jwt = Guardian.Plug.api_sign_in(conn, user) |> Guardian.Plug.current_token
    conn = put_req_header(conn, "authorization", "Bearer " <> jwt)

    conn = get conn, "/api/v1/users/me"
    assert json_response(conn, 200)["data"] == %{"id" => user.id,
      "username" => user.username,
      "likes" => [], 
      "transscripts" => []
    }
  end

  # test "lists all entries on index", %{conn: conn} do
  #   conn = get conn, user_path(conn, :index)
  #   assert json_response(conn, 200)["data"] == []
  # end

  # test "shows chosen resource", %{conn: conn} do
  #   user = Repo.insert! %User{}
  #   conn = get conn, user_path(conn, :show, user)
  #   assert json_response(conn, 200)["data"] == %{"id" => user.id,
  #     "username" => user.username,
  #     "password" => user.password}
  # end

  # test "renders page not found when id is nonexistent", %{conn: conn} do
  #   assert_error_sent 404, fn ->
  #     get conn, user_path(conn, :show, "111111111111111111111111")
  #   end
  # end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: %{email: "reguser@wlm.de", username: "reguser", password: "regpass"}
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(User, %{email: "reguser@wlm.de", username: "reguser"})
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: %{email: "reguserinvalid@wlm.de", username: "reguserinvalid"}
    assert json_response(conn, 422)["errors"] != %{}
  end

  # test "updates and renders chosen resource when data is valid", %{conn: conn} do
  #   user = Repo.insert! %User{}
  #   conn = put conn, user_path(conn, :update, user), user: @valid_attrs
  #   assert json_response(conn, 200)["data"]["id"]
  #   assert Repo.get_by(User, @valid_attrs)
  # end

  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   user = Repo.insert! %User{}
  #   conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end

  # test "deletes chosen resource", %{conn: conn} do
  #   user = Repo.insert! %User{}
  #   conn = delete conn, user_path(conn, :delete, user)
  #   assert response(conn, 204)
  #   refute Repo.get(User, user.id)
  # end
end
