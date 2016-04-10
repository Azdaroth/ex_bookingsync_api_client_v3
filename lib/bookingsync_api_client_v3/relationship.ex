# TODO: support polymorphic relationships
defmodule BookingsyncApiClientV3.Relationship do
  def from_result(data, %BookingsyncApiClientV3.Result{
                    resource: resource,
                    links: links,
                    resource_name: resource_name
                  }, relationship_name) do
    relationship_id_or_ids = resource["links"][relationship_name]
    { :ok, url} = links |> extract_url_for_relationship(resource_name, relationship_name)
                        |> populate_url(relationship_id_or_ids)

    response = BookingsyncApiClientV3.Client.request_with_url(:get, data, url)
    {:ok, response |> deserialize(relationship_id_or_ids)}
  end

  defp extract_url_for_relationship(links, resource_name, relationship_name) do
    links["#{resource_name}.#{relationship_name}"]
  end

  defp populate_url(prepared_url, ids) when is_list(ids) do
    { :ok, String.replace(prepared_url, ~r/{.+}/, Enum.join(ids, ","))}
  end

  defp populate_url(prepared_url, id) when is_integer(id) do
    { :ok, String.replace(prepared_url, ~r/{.+}/, to_string(id))}
  end

  defp populate_url(_, id_or_ids) when is_nil(id_or_ids) do
    { :error, "id or ids nil" }
  end

  defp deserialize(response, ids) when is_list(ids) do
    response |> BookingsyncApiClientV3.Deserializer.deserialize_many
  end

  defp deserialize(response, id) when is_integer(id) do
    response |> BookingsyncApiClientV3.Deserializer.deserialize_one
  end
end
