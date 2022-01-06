defmodule Circularly.Repo do
  use Ecto.Repo,
    otp_app: :circularly,
    adapter: Ecto.Adapters.Postgres

  require Ecto.Query

  @tenant_key {__MODULE__, :org_id}

  @doc """
  Store org_id in process dictionary. Each test and each web_request runs
  as a separate process and thus has its own process dictionary.
  We need to set org_id in all our tests and as part of the request processing.
  """
  @spec put_org_id(Ecto.UUID.t()) :: Ecto.UUID.t() | nil
  def put_org_id(org_id) do
    Process.put(@tenant_key, org_id)
  end

  @doc """
  Read org_id from process_dictionary
  """
  @spec get_org_id :: Ecto.UUID.t() | nil
  def get_org_id() do
    Process.get(@tenant_key)
  end

  @doc """
    Overriding prepare_query/3 in order to make repo aware of org_id als multitenancy key
    org_id is a required parameter unless :skip_org_id or :schema_migration options are
    explicitly set to true
  """
  @impl true
  def prepare_query(_operation, query, opts) do
    cond do
      opts[:skip_org_id] || opts[:schema_migration] ->
        {query, opts}

      org_id = opts[:org_id] ->
        {Ecto.Query.where(query, org_id: ^org_id), opts}

      true ->
        raise "expected org_id or skip_org_id to be set"
    end
  end

  @doc """
  Set org_id as default option on all repository operations
  """
  @impl true
  def default_options(_operation) do
    [org_id: get_org_id()]
  end
end
