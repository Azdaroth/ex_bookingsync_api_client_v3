defmodule BookingsyncApiClientV3.RelationshipTest do
  use ExUnit.Case
  use ExVCR.Mock, options: [clear_mock: true]
  import TestHelpers.SpecHelper
  doctest BookingsyncApiClientV3.Relationship

  test ".from_result returns deserialized singular relationship from result
  when the relationship is singular" do
    use_cassette "singular_relationship_from_result", match_requests_on: [:query] do
      rental_id = 1
      booking_resource = %{"links" => %{"rental" => rental_id}}
      result = %BookingsyncApiClientV3.Result{
        resource: booking_resource,
        links: %{"bookings.rental" => "#{base_url}/api/v3/rentals/{bookings.rental}"},
        meta: %{},
        resource_name: "bookings"
      }

      %BookingsyncApiClientV3.Result{
        resource: resource,
        links: links,
        meta: meta,
        resource_name: resource_name
      } = data_for_request |> BookingsyncApiClientV3.Relationship.from_result(result, "rental")

      assert is_map(resource)
      assert is_map(links)
      assert resource["id"] == rental_id
      assert is_map(meta)
      assert resource_name == "rentals"

      expected_urls = ["#{base_url}/api/v3/rentals/#{rental_id}"]
      assert requested_urls_from_cassette("singular_relationship_from_result") == expected_urls
      assert request_methods_from_cassette("singular_relationship_from_result") == ["get"]
    end
  end

  test ".from_result returns deserialized multi relationship from result
  when the relationship is non-singular" do
    use_cassette "multi_relationship_from_result", match_requests_on: [:query] do
      bathroom_id_1 = 1
      bathroom_id_2 = 39
      rental_resource = %{"links" => %{"bathrooms" => [bathroom_id_1, bathroom_id_2]}}
      result = %BookingsyncApiClientV3.Result{
        resource: rental_resource,
        links: %{"rentals.bathrooms" => "#{base_url}/api/v3/bathrooms/{rentals.bathrooms}"},
        meta: %{},
        resource_name: "rentals"
      }

      %BookingsyncApiClientV3.Result{
        resource: resource,
        links: links,
        meta: meta,
        resource_name: resource_name
      } = data_for_request |> BookingsyncApiClientV3.Relationship.from_result(result, "bathrooms")

      assert is_list(resource)
      assert resource |> Enum.count == 2
      assert resource |> Enum.map(fn resource_map -> resource_map["id"] end) == [bathroom_id_1, bathroom_id_2]
      assert is_map(links)
      assert is_map(meta)
      assert resource_name == "bathrooms"

      expected_urls = ["#{base_url}/api/v3/bathrooms/#{bathroom_id_1},#{bathroom_id_2}"]
      assert requested_urls_from_cassette("multi_relationship_from_result") == expected_urls
      assert request_methods_from_cassette("multi_relationship_from_result") == ["get"]
    end
  end
end
