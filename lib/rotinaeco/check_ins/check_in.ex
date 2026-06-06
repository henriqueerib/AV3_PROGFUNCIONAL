defmodule Rotinaeco.CheckIns.CheckIn do
  use Ecto.Schema
  import Ecto.Changeset

  alias Rotinaeco.Accounts.User
  alias Rotinaeco.Habits.Habit

  schema "check_ins" do
    field :date, :date

    belongs_to :user, User
    belongs_to :habit, Habit

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset para criar um check-in.
  Valida campos obrigatórios e impede duplicidade (mesmo usuário, hábito e data).
  """
  def changeset(check_in, attrs) do
    check_in
    |> cast(attrs, [:date])
    |> validate_required([:date])
    |> unsafe_validate_unique([:user_id, :habit_id, :date], Rotinaeco.Repo,
      message: "já foi registrado para este hábito nesta data"
    )
    |> unique_constraint([:user_id, :habit_id, :date],
      message: "já foi registrado para este hábito nesta data"
    )
  end
end
