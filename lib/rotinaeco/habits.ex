defmodule Rotinaeco.Habits do
  import Ecto.Query, warn: false

  alias Rotinaeco.Repo
  alias Rotinaeco.Habits.Habit

  def list_habits(category \\ nil) do
    query =
      case category do
        nil -> from(h in Habit, order_by: [desc: h.inserted_at])
        cat -> from(h in Habit, where: h.category == ^cat, order_by: [desc: h.inserted_at])
      end

    Repo.all(query)
  end

  def get_habit!(id), do: Repo.get!(Habit, id)

  def create_habit(user, attrs) do
    %Habit{}
    |> Habit.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, user.id)
    |> Repo.insert()
  end

  def update_habit(%Habit{} = habit, user, attrs) do
    if habit.user_id != user.id do
      {:error, :unauthorized}
    else
      habit
      |> Habit.changeset(attrs)
      |> Repo.update()
    end
  end

  def delete_habit(%Habit{} = habit, user) do
    if habit.user_id != user.id do
      {:error, :unauthorized}
    else
      Repo.delete(habit)
    end
  end

  def change_habit(%Habit{} = habit, attrs \\ %{}) do
    Habit.changeset(habit, attrs)
  end
end
