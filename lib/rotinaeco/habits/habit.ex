defmodule Rotinaeco.Habits.Habit do
  use Ecto.Schema
  import Ecto.Changeset

  alias Rotinaeco.Accounts.User

  @categories ~w(alimentação transporte energia água resíduos)

  schema "habits" do
    field :name, :string
    field :description, :string
    field :category, :string
    field :points, :integer, default: 0

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  def categories, do: @categories

  @doc """
  Changeset para criar ou atualizar um hábito.
  """
  def changeset(habit, attrs) do
    habit
    |> cast(attrs, [:name, :description, :category, :points])
    |> validate_required([:name, :description, :category, :points])
    |> validate_length(:name, min: 3, max: 100)
    |> validate_length(:description, max: 500)
    |> validate_inclusion(:category, @categories,
      message: "deve ser um de: #{Enum.join(@categories, ", ")}"
    )
    |> validate_number(:points, greater_than_or_equal_to: 1, message: "deve ser no mínimo 1")
  end
end
