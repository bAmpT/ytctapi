defmodule Ytctapi.CommentChannelTest do
  use Ytctapi.ChannelCase

  alias Ytctapi.CommentChannel
  alias Ytctapi.Comment
  alias Ytctapi.Transscript
  alias Ytctapi.User

  setup do
    user_changeset = User.changeset(%User{}, %{username: "testuser", email: "test@wlm.de", encrypted_password: "lol"})
    {:ok, user} = Repo.insert(user_changeset)

    changeset = Transscript.changeset(%Transscript{}, %{title: "Empty", ytid: "09324823049", language: "zh/zh", user_id: user.id})
    {:ok, transscript} = Repo.insert(changeset)

    comment_changeset = Comment.changeset(%Comment{}, %{author: "testauthor", body: "testcomment", user_id: user.id, transscript_id: transscript.id})
    {:ok, comment} = Repo.insert(comment_changeset)

    {:ok, _, socket} =
      socket("user", %{some: "assign"})
      |> subscribe_and_join(CommentChannel, "comment:"<>transscript.id)

    socket = Phoenix.Socket.assign(socket, :user, user.id)

    {:ok, socket: socket, transscript: transscript, comment: comment}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push socket, "ping", %{"hello" => "there"}
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "creates a comment for a transscript", %{transscript: transscript} do
    {:ok, comment} = Comment.create(%{
      "transscript_id" => transscript.id,
      "author" => "Some Person",
      "body" => "Some Post"
    }, %{})
    assert comment
    assert Repo.get(Comment, comment.id)
  end

  test "approves a comment when an authorized user", %{transscript: transscript, comment: comment, socket: socket} do
    {:ok, comment} = Comment.approve(%{"transscript_id" => transscript.id, "comment_id" => comment.id}, socket)
    assert comment.approved
  end

  test "does not approve a comment when not an authorized user", %{transscript: transscript, comment: comment} do
    {_, message} = Comment.approve(%{"transscript_id" => transscript.id, "comment_id" => comment.id}, %{})
    assert message == "User is not authorized"
  end

end
