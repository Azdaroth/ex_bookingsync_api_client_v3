defmodule BookingsyncApiClientV3.Deserializer do
  def deserialize_one(response) do
    body_from_response = response |> extract_body
    resource_name = body_from_response |> BookingsyncApiClientV3.ResourceName.extract_from_body
    resource = body_from_response[resource_name] |> Enum.at(0)
    deserialize(body_from_response, resource, resource_name)
  end

  def deserialize_many(response) do
    body_from_response = response |> extract_body
    resource_name = body_from_response |> BookingsyncApiClientV3.ResourceName.extract_from_body
    resource = body_from_response[resource_name]
    deserialize(body_from_response, resource, resource_name)
  end

  def deserialize(body_from_response, resource, resource_name) do
    %BookingsyncApiClientV3.Result{
      resource: resource,
      resource_name: resource_name,
      links: body_from_response["links"] || %{},
      meta: body_from_response["meta"] || %{}
    }
  end

  def extract_body(%HTTPotion.Response{body: json_body}) do
    { ok, body_from_response} = json_body |> JSON.decode
    body_from_response
  end
end
