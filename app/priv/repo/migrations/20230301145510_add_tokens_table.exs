defmodule TicketsAlert.Repo.Migrations.AddTokensTable do
  use Ecto.Migration

  def up do
    create table(:tokens) do
      add(:identifier, :uuid, null: false)
      add(:owner, :uuid, null: false)
      add(:value, :text, null: false)
      add(:created_at, :utc_datetime, null: false)
      add(:exp, :utc_datetime, null: false)
    end
  end

  def down do
    drop(table(:tokens))
  end
end
