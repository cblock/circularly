defmodule Circularly.PeopleFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Circularly.People` context.
  """

  @doc """
  Generate a person.
  """
  def person_fixture(attrs \\ %{}) do
    {:ok, person} =
      attrs
      |> Enum.into(%{
        description: "some description",
        joined_at: ~U[2022-04-17 19:30:00Z],
        name: "some name"
      })
      |> Circularly.People.create_person()

    person
  end
end
