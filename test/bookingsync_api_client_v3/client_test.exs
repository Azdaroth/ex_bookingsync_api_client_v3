defmodule BookingsyncApiClientV3.ClientTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, options: [clear_mock: true]
  import TestHelpers.SpecHelper
  doctest BookingsyncApiClientV3.Client

  test ".get for index action performs autopagination" do
    use_cassette "get_bookings_autopagination", match_requests_on: [:query] do
      {:ok, result} = data_for_request |> BookingsyncApiClientV3.Client.get("bookings")
      # 100 per page
      assert result.resource |> Enum.count > 100

      expected_urls = ["#{base_url}/api/v3/bookings", "#{base_url}/api/v3/bookings?page=2"]
      assert requested_urls_from_cassette("get_bookings_autopagination") == expected_urls
      assert request_methods_from_cassette("get_bookings_autopagination") == ["get", "get"]
    end
  end

  test ".get for index action performs autopagination appending query params to every url" do
    use_cassette "get_bookings_autopagination_with_query_params", match_requests_on: [:query] do
      query_params = %{start_at: "2016-10-10"}
      {:ok, _} = data_for_request |> BookingsyncApiClientV3.Client.get("bookings", query_params)

      expected_urls = ["#{base_url}/api/v3/bookings?start_at=2016-10-10",
        "#{base_url}/api/v3/bookings?page=2&start_at=2016-10-10"]
      assert requested_urls_from_cassette("get_bookings_autopagination_with_query_params") == expected_urls
      assert request_methods_from_cassette("get_bookings_autopagination_with_query_params") == ["get", "get"]
    end
  end

  test ".get for index action returns Result with resource as list, resource name, links and meta" do
    use_cassette "get_bookings_autopagination", match_requests_on: [:query] do
      {:ok, %BookingsyncApiClientV3.Result{
        resource: resource,
        links: links,
        meta: meta,
        resource_name: resource_name
      }} = data_for_request |> BookingsyncApiClientV3.Client.get("bookings")

      assert is_list(resource)
      assert is_map(links)
      assert links["bookings.account"] == "#{base_url}/api/v3/accounts/{bookings.account}"
      assert is_map(meta)
      assert resource_name == "bookings"
    end
  end

  test ".get for index action returns :error status, error code and raw error message on error
  when body is not json" do
    use_cassette "get_non_existent_resources", match_requests_on: [:query] do
      {:error, 404, raw_response} = data_for_request |> BookingsyncApiClientV3.Client.get("users")
      assert JSON.decode(raw_response) == {:error, {:unexpected_token, raw_response}}
    end
  end

  test ".get for index action returns :error status, error code and
  deserialized error message when body is josn" do
    use_cassette "get_bookings_unauthorized", match_requests_on: [:query] do
      {:error, 401, error_message} = data_for_request |> BookingsyncApiClientV3.Client.get("bookings")
      assert error_message == %{"errors" => [%{"code" => "unauthorized"}]}
    end
  end

  test ".get for show action returns Result with resource as singular map, resource name,
  links and meta" do
    use_cassette "get_booking", match_requests_on: [:query] do
      booking_id = 500
      {:ok, %BookingsyncApiClientV3.Result{
        resource: resource,
        links: links,
        meta: meta,
        resource_name: resource_name
      }} = data_for_request |> BookingsyncApiClientV3.Client.get("bookings", booking_id)

      refute is_list(resource)
      assert is_map(resource)
      assert resource["id"] == booking_id
      assert is_map(links)
      assert links["bookings.account"] == "#{base_url}/api/v3/accounts/{bookings.account}"
      assert is_map(meta)
      assert resource_name == "bookings"

      expected_urls = ["#{base_url}/api/v3/bookings/#{booking_id}"]
      assert requested_urls_from_cassette("get_booking") == expected_urls
      assert request_methods_from_cassette("get_booking") == ["get"]
    end
  end

  test ".get for show action returns :error status, error code and raw error message on error
  when body is not json" do
    use_cassette "get_non_existent_resource_with_id", match_requests_on: [:query] do
      {:error, 404, raw_response} = data_for_request |> BookingsyncApiClientV3.Client.get("users", 1)
      assert JSON.decode(raw_response) == {:error, {:unexpected_token, raw_response}}
    end
  end

  test ".get for show action returns :error status, error code and
  deserialized error message when body is json" do
    use_cassette "get_booking_unauthorized", match_requests_on: [:query] do
      {:error, 401, error_message} = data_for_request |> BookingsyncApiClientV3.Client.get("bookings", 1)
      assert error_message == %{"errors" => [%{"code" => "unauthorized"}]}
    end
  end

  test ".post creates resource and returns Result with resource as singular map, resource name,
  links and meta" do
    use_cassette "create_client", match_requests_on: [:query] do
      client_fullname = "Some new client"
      client_payload = %{clients: [%{fullname: client_fullname}]}

      {:ok, %BookingsyncApiClientV3.Result{
        resource: resource,
        links: links,
        meta: meta,
        resource_name: resource_name
      }} = data_for_request |> BookingsyncApiClientV3.Client.post("clients", client_payload)

      refute is_list(resource)
      assert is_map(resource)
      assert resource["fullname"] == client_fullname
      assert is_map(links)
      assert links["clients.account"] == "#{base_url}/api/v3/accounts/{clients.account}"
      assert is_map(meta)
      assert resource_name == "clients"

      expected_urls = ["#{base_url}/api/v3/clients"]
      assert requested_urls_from_cassette("create_client") == expected_urls
      assert request_methods_from_cassette("create_client") == ["post"]
    end
  end

  test ".post returns :error status, error code and deserialized error message when body is json" do
    use_cassette "create_invalid_rental", match_requests_on: [:query] do
      rental_payload = %{rentals: [%{name: ""}]}
      {:error, 422, error_message} = data_for_request |> BookingsyncApiClientV3.Client.post("rentals",
        rental_payload)
      assert error_message == %{"errors" =>
        [
          %{"code" => "validation_failed", "field" => "name", "title" => "is too short (minimum is 3 characters)"}
        ]
      }
    end
  end

  test ".post can be scoped which creates resource and returns Result with resource as singular
  map, resource name, links and meta" do
    use_cassette "create_bathroom_for_rental", match_requests_on: [:query] do
      rental_id = 1
      bathroom_name = "some awesome bathroom"
      bathrooms_payload = %{bathrooms: [%{name_en: bathroom_name}]}

      {:ok, %BookingsyncApiClientV3.Result{
        resource: resource,
        links: links,
        meta: meta,
        resource_name: resource_name
      }} = data_for_request |> BookingsyncApiClientV3.Client.post("rentals", rental_id, "bathrooms",
        bathrooms_payload)

      refute is_list(resource)
      assert is_map(resource)
      assert resource["name"] == %{"en" => bathroom_name}
      assert resource["links"]["rental"] == rental_id
      assert is_map(links)
      assert links["bathrooms.rental"] == "#{base_url}/api/v3/rentals/{bathrooms.rental}"
      assert is_map(meta)
      assert resource_name == "bathrooms"

      expected_urls = ["#{base_url}/api/v3/rentals/#{rental_id}/bathrooms"]
      assert requested_urls_from_cassette("create_bathroom_for_rental") == expected_urls
      assert request_methods_from_cassette("create_bathroom_for_rental") == ["post"]
    end
  end

   test ".post with scope returns :error status, error code and deserialized error message
   when body is json" do
    use_cassette "create_invalid_bathroom", match_requests_on: [:query] do
      rental_id = 1
      bathrooms_payload = %{bathrooms: [%{rental_id: rental_id, name_en: ""}]}
      {:error, 422, error_message} = data_for_request |> BookingsyncApiClientV3.Client.post("rentals",
        rental_id, "bathrooms", bathrooms_payload)
      assert error_message == %{"errors" => [
          %{"code" => "validation_failed", "field" => "name_en", "title" => "can't be blank"},
          %{"code" => "validation_failed", "field" => "name_en", "title" => "can't be blank"}
        ]
      }
    end
  end

  test ".patch updates resource and returns Result with resource as singular map, resource name,
  links and meta" do
    use_cassette "patch_client", match_requests_on: [:query] do
      client_id = 101
      client_fullname = "some updated fullname"
      client_payload = %{clients: [%{fullname: client_fullname}]}

      {:ok, %BookingsyncApiClientV3.Result{
        resource: resource,
        links: links,
        meta: meta,
        resource_name: resource_name
      }} = data_for_request |> BookingsyncApiClientV3.Client.patch("clients", client_id, client_payload)

      refute is_list(resource)
      assert is_map(resource)
      assert resource["fullname"] == client_fullname
      assert is_map(links)
      assert links["clients.account"] == "#{base_url}/api/v3/accounts/{clients.account}"
      assert is_map(meta)
      assert resource_name == "clients"

      expected_urls = ["#{base_url}/api/v3/clients/#{client_id}"]
      assert requested_urls_from_cassette("patch_client") == expected_urls
      assert request_methods_from_cassette("patch_client") == ["patch"]
    end
  end

  test ".patch returns :error status, error code and deserialized error message
  when body is json" do
    use_cassette "patch_client_invalid", match_requests_on: [:query] do
      client_id = 101
      client_payload = %{clients: [%{preferred_locale: "invalid"}]}
      {:error, 422, error_message} = data_for_request |> BookingsyncApiClientV3.Client.patch("clients",
        client_id, client_payload)
      assert error_message == %{"errors" => [
          %{"code" => "validation_failed", "field" => "preferred_locale", "title" => "is not included in the list"},
        ]
      }
    end
  end

  test ".delete destroys resource returning :ok status" do
    use_cassette "delete_booking", match_requests_on: [:query] do
      booking_id = 735
      result = data_for_request |> BookingsyncApiClientV3.Client.delete("bookings", booking_id)

      assert result == {:ok, ""}
      expected_urls = ["#{base_url}/api/v3/bookings/#{booking_id}"]
      assert requested_urls_from_cassette("delete_booking") == expected_urls
      assert request_methods_from_cassette("delete_booking") == ["delete"]
    end
  end

  test ".delete returns :error status, error code and deserialized error message
  when body is json" do
    use_cassette "delete_booking_unauthorized", match_requests_on: [:query] do
      booking_id = 735
      {:error, 401, error_message} = data_for_request |> BookingsyncApiClientV3.Client.delete(
        "bookings", booking_id)
      assert error_message == %{"errors" => [%{"code" => "unauthorized"}]}
      assert error_message == %{"errors" => [%{"code" => "unauthorized"}]}
    end
  end

  test ".request_with_url performs request with proper headers to given endpoint on BookingSync
  returning HTTPotion.Response" do
    use_cassette "request_with_url", match_requests_on: [:query] do
      booking_id = 500
      url = "#{base_url}/api/v3/bookings/#{booking_id}"
      %HTTPotion.Response{
        body: _
      } = BookingsyncApiClientV3.Client.request_with_url(:get, data_for_request, url)

      expected_urls = [url]
      assert requested_urls_from_cassette("request_with_url") == expected_urls
      assert request_methods_from_cassette("request_with_url") == ["get"]
    end
  end
end
