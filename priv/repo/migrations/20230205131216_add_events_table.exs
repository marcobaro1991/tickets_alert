defmodule TicketsAlert.Repo.Migrations.AddEventsTable do
  use Ecto.Migration

  @provider :provider

  def change do
    execute(
      """
        CREATE TYPE #{@provider}
        AS ENUM ('fansale','other')
      """,
      "drop TYPE #{@provider}"
    )

    create table(:events) do
      add(:identifier, :uuid, null: false)
      add(:external_identifier, :string, null: false)
      add(:title, :string, null: false)
      add(:date, :date, null: false)
      add :provider, @provider, null: false
      add :enabled, :boolean, null: false
      timestamps(default: fragment("NOW()"))
    end

    create index("events", [:identifier], comment: "add index on identifier column")
  end

  def down do
    drop(table(:events))
  end
end
