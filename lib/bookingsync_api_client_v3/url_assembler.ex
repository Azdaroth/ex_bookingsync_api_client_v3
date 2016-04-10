defmodule BookingsyncApiClientV3.UrlAssembler do
  def generate_url(base_url, scope, scope_id, endpoint) do
    [base_url, api_scope, scope, scope_id, endpoint] |> Enum.join("/")
  end

  def generate_url(base_url, endpoint, id) do
    [base_url, api_scope, endpoint, id] |> Enum.join("/")
  end

  def generate_url(base_url, endpoint) do
    [base_url, api_scope, endpoint] |> Enum.join("/")
  end

  defp api_scope do
    "api/v3"
  end
end

