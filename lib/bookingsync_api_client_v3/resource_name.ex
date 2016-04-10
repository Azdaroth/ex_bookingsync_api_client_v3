defmodule BookingsyncApiClientV3.ResourceName do
  # Response containts ["links", "meta" and resource_name]
  # safe assumption
  def extract_from_body(body) do
    all_keys = body |> Map.keys
    (all_keys -- fixed_attributes_in_response)|> Enum.at(0)
  end

  defp fixed_attributes_in_response do
    ["links", "meta"]
  end
end
