defmodule TicketsAlert.Repo.Migrations.AddOffersTable do
  use Ecto.Migration

  def change do
    create table(:offers) do
      add(:identifier, :uuid, null: false)
      add :event_id, references(:events)
      add(:external_identifier, :string, null: false)
      add(:data, :json, null: false)
      timestamps(default: fragment("NOW()"))
    end

    create index("offers", [:identifier], comment: "add index on identifier column")
  end

  def down do
    drop(table(:events))
  end
end
