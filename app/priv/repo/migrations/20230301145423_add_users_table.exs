defmodule TicketsAlert.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  @user_status_type :user_status

  @user_registration_type :user_registration_type

  def up do
    execute(
      """
        CREATE TYPE #{@user_status_type}
        AS ENUM ('active','not_active')
      """,
      "drop TYPE #{@user_status_type}"
    )

    execute(
      """
        CREATE TYPE #{@user_registration_type}
        AS ENUM ('default','google')
      """,
      "drop TYPE #{@user_registration_type}"
    )

    create table(:users) do
      add(:identifier, :uuid, null: false)
      add(:first_name, :string, null: false)
      add(:last_name, :string, null: false)
      add(:password, :string, null: false)
      add(:email, :string, null: false)
      add(:status, @user_status_type, null: false)
      add(:registration_type, @user_registration_type, null: false)
      timestamps(default: fragment("NOW()"))
    end

    create index("users", [:identifier])
    create index("users", [:email])
    create index("users", [:status])
  end

  def down do
    drop(table(:users))
  end
end
