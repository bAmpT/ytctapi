defmodule Ytctapi.Comment do
  use Ytctapi.Web, :model

  alias Ytctapi.Repo
  alias Ytctapi.Transscript
  alias Ytctapi.User

  schema "comments" do
    field :author, :string
    field :body, :string
    field :approved, :boolean, default: false
    belongs_to :transscript, Ytctapi.Transscript
    belongs_to :user, Ytctapi.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:author, :body, :transscript_id])
  end

  def create(%{"transscript_id" => transscript_id, "body" => body, "author" => author}, _socket) do
    transscript = Repo.get!(Transscript, transscript_id)
    changeset = Ytctapi.Comment.changeset(%Ytctapi.Comment{}, %{body: body, author: author, transscript_id: transscript.id})
   
    Repo.insert(changeset)
  end


  def approve(%{"transscript_id" => transscript_id, "comment_id" => comment_id}, %{assigns: %{user: user_id}}) do
    IO.inspect user_id
    IO.inspect transscript_id
    authorize_and_perform(transscript_id, user_id, fn ->
      comment = Repo.get!(Ytctapi.Comment, comment_id)
      changeset = Ytctapi.Comment.changeset(comment, %{approved: true})
      Repo.update(changeset)
    end)
  end
  def approve(_params, %{}), do: {:error, "User is not authorized"}
  def approve(_params, nil), do: {:error, "User is not authorized"}

  def delete(%{"transscript_id" => transscript_id, "comment_id" => comment_id}, %{assigns: %{user: user_id}}) do
    authorize_and_perform(transscript_id, user_id, fn ->
      comment = Repo.get!(Comment, comment_id)
      Repo.delete(comment)
    end)
  end
  def delete(_params, %{}), do: {:error, "User is not authorized"}
  def delete(_params, nil), do: {:error, "User is not authorized"}

  defp authorize_and_perform(transscript_id, user_id, action) do
    transscript = Repo.get!(Transscript, transscript_id) |> Repo.preload([:user, :comments])
    user = Repo.get!(User, user_id)
    if is_authorized_user?(user, transscript) do
      action.()
    else
      {:error, "User is not authorized"}
    end
  end

  defp is_authorized_user?(user, transscript) do
    (user && (user.id == transscript.user_id))
  end
end
