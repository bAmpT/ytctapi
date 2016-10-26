defmodule Ytctapi.Word do
  use Ytctapi.Web, :model

  embedded_schema do
    field :simp, :string
    field :trad, :string
    field :pinyin, :string
    field :translation, :string
    
    field :hsklevel, :integer
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
  end
end
