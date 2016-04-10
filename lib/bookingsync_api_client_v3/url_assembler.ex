defmodule BookingsyncApiClientV3.UrlAssembler do
  def generate_url(base_url, scope, scope_id, endpoint) do
    [base_url, api_scope, scope, scope_id, endpoint] |> Enum.join("/")
  end

  def generate_url(base_url, endpoint, query_params: query_params) when query_params == %{} do
    generate_url(base_url, endpoint)
  end

  def generate_url(base_url, endpoint, query_params: query_params) do
    [base_url, api_scope, endpoint]
    |> Enum.join("/")
    |> join_url_and_query_params_with(query_params, "?")
  end

  def generate_url(base_url, endpoint, id) when is_integer(id) do
    [base_url, api_scope, endpoint, id] |> Enum.join("/")
  end

  def generate_url(base_url, endpoint) do
    [base_url, api_scope, endpoint] |> Enum.join("/")
  end

  defp join_url_and_query_params_with(url, query_params, joiner) do
    [url, URI.encode_query(query_params)] |> Enum.join(joiner)
  end

  defp api_scope do
    "api/v3"
  end
end

