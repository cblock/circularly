defmodule Circularly.Repo.Migrations.AddTriggerToOrganizationsSlug do
  use Ecto.Migration

  def up do
    execute "CREATE TRIGGER trigger_organizations_slug BEFORE INSERT ON organizations FOR EACH ROW EXECUTE PROCEDURE unique_short_slug();"
  end

  def down do
    execute "DROP TRIGGER trigger_organizations_slug;"
  end
end
