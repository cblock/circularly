defmodule Circularly.People.Person do
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "people" do
    field :description, :string
    field :joined_at, :utc_datetime
    field :name, :string
    field :org_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:name, :description, :joined_at])
    |> put_change(:org_id, Circularly.Repo.get_org_id())
    |> validate_required([:name, :org_id])
  end
end
