defmodule Ytctapi.TransscriptTest do
  use Ytctapi.ModelCase

  alias Ytctapi.Transscript

  @valid_attrs %{language: "some content", lines: %{}, title: "some content", userid: "some content", ytid: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Transscript.changeset(%Transscript{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Transscript.changeset(%Transscript{}, @invalid_attrs)
    refute changeset.valid?
  end
end
