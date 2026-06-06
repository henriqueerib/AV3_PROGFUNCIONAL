defmodule Rotinaeco.Repo.Migrations.CreateCheckIns do
  use Ecto.Migration

  def change do
    create table(:check_ins) do
      add :date, :date, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :habit_id, references(:habits, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:check_ins, [:user_id])
    create index(:check_ins, [:habit_id])
    create unique_index(:check_ins, [:user_id, :habit_id, :date])
  end
end
