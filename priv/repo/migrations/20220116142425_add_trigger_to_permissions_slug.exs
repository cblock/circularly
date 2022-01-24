defmodule Circularly.Repo.Migrations.AddTriggerToPermissionsSlug do
  use Ecto.Migration

  def up do
    execute "CREATE TRIGGER trigger_permissions_slug BEFORE INSERT ON permissions FOR EACH ROW EXECUTE PROCEDURE unique_short_slug();"
  end

  def down do
    execute "DROP TRIGGER trigger_permissions_slugm;"
  end
end
