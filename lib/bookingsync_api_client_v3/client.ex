defmodule BookingsyncApiClientV3.Client do
  defdelegate generate_url(base_url, scope, scope_id, endpoint), to: BookingsyncApiClientV3.UrlAssembler
  defdelegate generate_url(base_url, endpoint, id_or_query_params), to: BookingsyncApiClientV3.UrlAssembler
  defdelegate generate_url(base_url, endpoint), to: BookingsyncApiClientV3.UrlAssembler

  def get(data, endpoint) do
    result = perform_get_for_index_action(data, endpoint, %{}) |> autopaginate(data, %{}, %{})
    case result do
      {:error, status_code, body} -> {:error, status_code, body}
      _                           -> {:ok, result}
    end
  end

  def get(data, endpoint, query_params) when is_map(query_params) do
    result = perform_get_for_index_action(data, endpoint, query_params) |> autopaginate(data, %{}, query_params)
    case result do
      {:error, status_code, body} -> {:error, status_code, body}
      _                           -> {:ok, result}
    end
  end

  def get(data = %BookingsyncApiClientV3.Data{
                    oauth_token: oauth_token
                  }, endpoint, id) do
    request(:get, data, authorization_header(oauth_token), endpoint, id)
    |> handle_response(200)
  end

  def post(data = %BookingsyncApiClientV3.Data{
                    oauth_token: oauth_token
                  }, endpoint, body) do
    request(:post, data,
      jsonapi_content_type ++ authorization_header(oauth_token), endpoint, body)
    |> handle_response(201)
  end

  def post(data = %BookingsyncApiClientV3.Data{
                    oauth_token: oauth_token
                  }, scope, scope_id, endpoint, body) do
    request(:post, data,
      jsonapi_content_type ++ authorization_header(oauth_token), scope, scope_id, endpoint, body)
    |> handle_response(201)
  end

  def patch(data = %BookingsyncApiClientV3.Data{oauth_token: oauth_token}, endpoint, id, body) do
    request(:patch, data,
      jsonapi_content_type ++ authorization_header(oauth_token), endpoint, id, body)
    |> handle_response(200)
  end

  def delete(data = %BookingsyncApiClientV3.Data{
                      oauth_token: oauth_token
                    }, endpoint, id) do
    response = request(:delete, data, jsonapi_content_type ++ authorization_header(oauth_token),
      endpoint, id)
    case response.status_code do
      204 -> {:ok, ""}
      _   -> handle_error(response)
    end
  end

  def request_with_url(method, %BookingsyncApiClientV3.Data{
                                  oauth_token: oauth_token,
                                  timeout: timeout
                                }, url) do
    HTTPotion.request method, url, [headers: authorization_header(oauth_token), timeout: timeout]
  end

  defp request(method, %BookingsyncApiClientV3.Data{
                          base_url: base_url,
                          timeout: timeout
                        }, headers, endpoint, query_params: query_params) do
    HTTPotion.request method, generate_url(base_url, endpoint, query_params: query_params),
      [headers: headers, timeout: timeout]
  end

  defp request(method, %BookingsyncApiClientV3.Data{
                          base_url: base_url,
                          timeout: timeout
                        }, headers, endpoint, id) when is_integer(id) do
    HTTPotion.request method, generate_url(base_url, endpoint, id),
      [headers: headers, timeout: timeout]
  end

  defp request(method, %BookingsyncApiClientV3.Data{
                          base_url: base_url,
                          timeout: timeout
                        }, headers, endpoint, body) do
    {:ok, encoded_body} = body |> JSON.encode
    HTTPotion.request method, generate_url(base_url, endpoint), [body: encoded_body,
      headers: headers, timeout: timeout]
  end

  defp request(method, %BookingsyncApiClientV3.Data{
                          base_url: base_url,
                          timeout: timeout
                        }, headers, endpoint, id, body) when is_integer(id) do
    {:ok, encoded_body} = body |> JSON.encode
    HTTPotion.request method, generate_url(base_url, endpoint, id), [body: encoded_body,
    headers: headers, timeout: timeout]
  end

  defp request(method, %BookingsyncApiClientV3.Data{
                          base_url: base_url,
                          timeout: timeout
                        }, headers, scope, scope_id, endpoint, body) do
    {:ok, encoded_body} = body |> JSON.encode
    HTTPotion.request method, generate_url(base_url, scope, scope_id, endpoint), [
      body: encoded_body, headers: headers, timeout: timeout]
  end

  defp authorization_header(token) do
    ["Authorization": "Bearer #{token}"]
  end

  defp jsonapi_content_type do
    ["Content-Type": "application/vnd.api+json"]
  end

  defp perform_get_for_index_action(data = %BookingsyncApiClientV3.Data{
                                              oauth_token: oauth_token
                                            }, endpoint, query_params) do
    request(:get, data, authorization_header(oauth_token), endpoint, query_params: query_params)
  end

  defp autopaginate(response = %HTTPotion.Response{
                                headers: %HTTPotion.Headers{hdrs: headers},
                                status_code: 200
                              }, data, current_body, query_params) do
    next_link = headers
    |> extract_link
    |> format_next_link

    body_from_response = response |> BookingsyncApiClientV3.Deserializer.extract_body
    resource_name = body_from_response |> BookingsyncApiClientV3.ResourceName.extract_from_body
    merged_resources = (current_body[resource_name] || []) ++ body_from_response[resource_name]
    updated_body = Map.put(body_from_response, resource_name, merged_resources)

    case next_link do
      nil  -> BookingsyncApiClientV3.Deserializer.deserialize(updated_body,
                updated_body[resource_name], resource_name)
      _    -> request_with_url(:get, data, next_link)
              |> autopaginate(data, updated_body, query_params)
    end
  end

  defp autopaginate(response = %HTTPotion.Response{}, _, _, _) do
    handle_error(response)
  end

  defp handle_response(response = %HTTPotion.Response{status_code: status_code}, expected_code) do
    if expected_code == status_code do
      {:ok, response |> deserialize_one}
    else
      handle_error(response)
    end
  end

  defp handle_error(response = %HTTPotion.Response{status_code: status_code}) do
    {:error, status_code, response |> BookingsyncApiClientV3.Deserializer.extract_body}
  end

  defp deserialize_one(response) do
    response |> BookingsyncApiClientV3.Deserializer.deserialize_one
  end

  defp extract_link(headers) do
    headers["link"]
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
