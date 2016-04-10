defmodule BookingsyncApiClientV3.Client do
  def get(data, endpoint) do
    result = perform_get_for_index_action(data, endpoint) |> autopaginate(data, %{})
    {:ok, result}
  end

  def get(data = %BookingsyncApiClientV3.Data{oauth_token: oauth_token}, endpoint, id) do
    response = request(:get, data, authorization_header(oauth_token), endpoint, id)
    {:ok, response |> deserialize_one}
  end

  def post(data = %BookingsyncApiClientV3.Data{oauth_token: oauth_token}, endpoint, body) do
    response = request(:post, data, jsonapi_content_type ++ authorization_header(oauth_token), endpoint, body)
    {:ok, response |> deserialize_one}
  end

  def post(data = %BookingsyncApiClientV3.Data{oauth_token: oauth_token}, scope, scope_id, endpoint, body) do
    response = request(:post, data, jsonapi_content_type ++ authorization_header(oauth_token), scope, scope_id, endpoint, body)
    {:ok, response |> deserialize_one}
  end

  def patch(data = %BookingsyncApiClientV3.Data{oauth_token: oauth_token}, endpoint, id, body) do
    response = request(:patch, data, jsonapi_content_type ++ authorization_header(oauth_token), endpoint, id, body)
    {:ok, response |> deserialize_one}
  end

  def delete(data = %BookingsyncApiClientV3.Data{oauth_token: oauth_token}, endpoint, id) do
    response = request(:delete, data, jsonapi_content_type ++ authorization_header(oauth_token), endpoint, id)
    :ok
  end

  def request_with_url(method, %BookingsyncApiClientV3.Data{oauth_token: oauth_token, timeout: timeout}, url) do
    HTTPotion.request method, url, [headers: authorization_header(oauth_token), timeout: timeout]
  end

  defp request(method, %BookingsyncApiClientV3.Data{base_url: base_url, timeout: timeout}, headers, endpoint) do
    HTTPotion.request method, generate_url(base_url, endpoint), [headers: headers, timeout: timeout]
  end

  defp request(method, %BookingsyncApiClientV3.Data{base_url: base_url, timeout: timeout}, headers, endpoint, id) when is_integer(id) do
    HTTPotion.request method, generate_url(base_url, endpoint, id), [headers: headers, timeout: timeout]
  end

  defp request(method, %BookingsyncApiClientV3.Data{base_url: base_url, timeout: timeout}, headers, endpoint, body) do
    { :ok, encoded_body } = body |> JSON.encode
    HTTPotion.request method, generate_url(base_url, endpoint), [body: encoded_body, headers: headers, timeout: timeout]
  end

  defp request(method, %BookingsyncApiClientV3.Data{base_url: base_url, timeout: timeout}, headers, endpoint, id, body) when is_integer(id) do
    { :ok, encoded_body } = body |> JSON.encode
    HTTPotion.request method, generate_url(base_url, endpoint, id), [body: encoded_body, headers: headers, timeout: timeout]
  end

  defp request(method, %BookingsyncApiClientV3.Data{base_url: base_url, timeout: timeout}, headers, scope, scope_id, endpoint, body) do
    { :ok, encoded_body } = body |> JSON.encode
    HTTPotion.request method, generate_url(base_url, scope, scope_id, endpoint), [body: encoded_body, headers: headers, timeout: timeout]
  end

  defp generate_url(base_url, scope, scope_id, endpoint) do
    BookingsyncApiClientV3.UrlAssembler.generate_url(base_url, scope, scope_id, endpoint)
  end

  defp generate_url(base_url, endpoint, id) do
    BookingsyncApiClientV3.UrlAssembler.generate_url(base_url, endpoint, id)
  end

  defp generate_url(base_url, endpoint) do
    BookingsyncApiClientV3.UrlAssembler.generate_url(base_url, endpoint)
  end

  defp authorization_header(token) do
    ["Authorization": "Bearer #{token}"]
  end

  defp jsonapi_content_type do
    ["Content-Type": "application/vnd.api+json"]
  end

  defp perform_get_for_index_action(data = %BookingsyncApiClientV3.Data{oauth_token: oauth_token}, endpoint) do
    request :get, data, authorization_header(oauth_token), endpoint
  end

  defp autopaginate(%HTTPotion.Response{body: json_body, headers: %HTTPotion.Headers{hdrs: headers}}, data, current_body) do
    next_link = headers
    |> extract_link
    |> format_next_link

    { :ok, body_from_response } = json_body |> JSON.decode

    resource_name = body_from_response |> BookingsyncApiClientV3.ResourceName.extract_from_body
    merged_resources = (current_body[resource_name] || []) ++ body_from_response[resource_name]
    updated_body = Map.put(body_from_response, resource_name, merged_resources)

    case next_link do
      nil  -> BookingsyncApiClientV3.Deserializer.deserialize(updated_body,
                updated_body[resource_name], resource_name)
      _    -> request_with_url(:get, data, next_link) |> autopaginate(data, updated_body)
    end
  end

  defp deserialize_one(response) do
    response |> BookingsyncApiClientV3.Deserializer.deserialize_one
  end

  defp extract_link(headers) do
    headers[:link]
    |> String.split(",")
    |> Enum.find(fn link -> link |> String.contains?("next") end)
  end

  defp format_next_link(nil) do
    nil
  end

  defp format_next_link(link_expression) when is_binary(link_expression) do
    Regex.run(~r/(?<=\<)(.*?)(?=\>)/, link_expression) |> Enum.at(0)
  end
end

