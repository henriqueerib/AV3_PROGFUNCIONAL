defmodule Rotinaeco.CheckIns do
  import Ecto.Query, warn: false

  alias Rotinaeco.Repo
  alias Rotinaeco.CheckIns.CheckIn
  alias Rotinaeco.Habits.Habit

  @topic "community_feed"

  @doc """
  Retorna o tópico PubSub do feed da comunidade.
  """
  def topic, do: @topic

  @doc """
  Registra um check-in para o usuário e hábito informados.
  Em caso de sucesso, transmite o evento via PubSub para o feed da comunidade.
  """
  def create_check_in(user, habit, attrs \\ %{}) do
    attrs_with_date = Map.put_new(attrs, "date", Date.utc_today())

    result =
      %CheckIn{}
      |> CheckIn.changeset(attrs_with_date)
      |> Ecto.Changeset.put_change(:user_id, user.id)
      |> Ecto.Changeset.put_change(:habit_id, habit.id)
      |> Repo.insert()

    case result do
      {:ok, check_in} ->
        check_in_com_assocs = Repo.preload(check_in, [:user, :habit])

        Phoenix.PubSub.broadcast(
          Rotinaeco.PubSub,
          @topic,
          {:check_in_created, check_in_com_assocs}
        )

        {:ok, check_in_com_assocs}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Retorna os check-ins mais recentes de todos os usuários (feed da comunidade).
  """
  def recent_check_ins(limit \\ 20) do
    Repo.all(
      from c in CheckIn,
        order_by: [desc: c.inserted_at],
        limit: ^limit,
        preload: [:user, :habit]
    )
  end

  @doc """
  Retorna todos os check-ins de um usuário específico.
  """
  def list_check_ins_for_user(user_id) do
    Repo.all(
      from c in CheckIn,
        where: c.user_id == ^user_id,
        order_by: [desc: c.date],
        preload: [:habit]
    )
  end

  @doc """
  Retorna a pontuação total do usuário na semana atual.
  """
  def weekly_score(user_id) do
    inicio_da_semana = Date.beginning_of_week(Date.utc_today())

    Repo.one(
      from c in CheckIn,
        join: h in Habit,
        on: c.habit_id == h.id,
        where: c.user_id == ^user_id and c.date >= ^inicio_da_semana,
        select: sum(h.points)
    ) || 0
  end

  @doc """
  Retorna a pontuação por semana das últimas N semanas.
  Cada entrada é um mapa com %{week_label: "DD/MM", score: inteiro}.
  """
  def weekly_scores(user_id, semanas \\ 4) do
    hoje = Date.utc_today()

    Enum.map(0..(semanas - 1), fn offset ->
      dia_ref = Date.add(hoje, -offset * 7)
      inicio = Date.beginning_of_week(dia_ref)
      fim = Date.end_of_week(dia_ref)

      pontos =
        Repo.one(
          from c in CheckIn,
            join: h in Habit,
            on: c.habit_id == h.id,
            where: c.user_id == ^user_id and c.date >= ^inicio and c.date <= ^fim,
            select: sum(h.points)
        ) || 0

      %{week_label: Calendar.strftime(inicio, "%d/%m"), score: pontos}
    end)
    |> Enum.reverse()
  end
end
