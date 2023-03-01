defmodule TicketsAlert.Repo.Migrations.AddTokensTable do
  use Ecto.Migration

  def up do
    create table(:tokens) do
      add(:value, :text, null: false)
      add(:jti, :uuid, null: false)
      add(:sub, :uuid, null: false)
      add(:created_at, :utc_datetime_usec, null: false)
      add(:exp, :utc_datetime_usec, null: false)
    end
  end

  def down do
    drop(table(:tokens))
  end
end
