defmodule Rotinaeco.Habits do
  import Ecto.Query, warn: false

  alias Rotinaeco.Repo
  alias Rotinaeco.Habits.Habit

  @doc """
  Retorna a lista de hábitos, opcionalmente filtrada por categoria.
  """
  def list_habits(category \\ nil) do
    query =
      case category do
        nil -> from(h in Habit, order_by: [desc: h.inserted_at])
        cat -> from(h in Habit, where: h.category == ^cat, order_by: [desc: h.inserted_at])
      end

    Repo.all(query)
  end

  @doc """
  Busca um hábito pelo ID. Lança erro se não existir.
  """
  def get_habit!(id), do: Repo.get!(Habit, id)

  @doc """
  Cria um hábito para o usuário informado.
  """
  def create_habit(user, attrs) do
    %Habit{}
    |> Habit.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, user.id)
    |> Repo.insert()
  end

  @doc """
  Atualiza um hábito. Somente o dono pode editar.
  """
  def update_habit(%Habit{} = habit, user, attrs) do
    if habit.user_id != user.id do
      {:error, :unauthorized}
    else
      habit
      |> Habit.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc """
  Remove um hábito. Somente o dono pode excluir.
  """
  def delete_habit(%Habit{} = habit, user) do
    if habit.user_id != user.id do
      {:error, :unauthorized}
    else
      Repo.delete(habit)
    end
  end

  @doc """
  Retorna um changeset para o hábito informado.
  """
  def change_habit(%Habit{} = habit, attrs \\ %{}) do
    Habit.changeset(habit, attrs)
  end
end
