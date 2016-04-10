defmodule BookingsyncApiClientV3.DeserializerTest do
  use ExUnit.Case
  doctest BookingsyncApiClientV3.Deserializer

  test ".deserialize_one returns Result struct with singular resource
  based on HTTPotion.Response" do
    body = "{\"bookings\":[{\"id\":1}],\"links\":" <>
      "{\"bookings.account\":\"http://test.host/api/v3/accounts/{bookings.account}\"}," <>
      "\"meta\":{\"deleted_ids\":[100]}}"
    response = %HTTPotion.Response{body: body}
    expected_result = %BookingsyncApiClientV3.Result{
      resource: %{"id" => 1},
      resource_name: "bookings",
      links: %{"bookings.account" => "http://test.host/api/v3/accounts/{bookings.account}"},
      meta: %{"deleted_ids" => [100]}
    }
    returned_result = response |> BookingsyncApiClientV3.Deserializer.deserialize_one
    assert expected_result == returned_result
  end


  test ".deserialize_many returns Result struct with array resource
  based on HTTPotion.Response" do
    body = "{\"bookings\":[{\"id\":1}],\"links\":" <>
      "{\"bookings.account\":\"http://test.host/api/v3/accounts/{bookings.account}\"}," <>
      "\"meta\":{\"deleted_ids\":[100]}}"
    response = %HTTPotion.Response{body: body}
    expected_result = %BookingsyncApiClientV3.Result{
      resource: [%{"id" => 1}],
      resource_name: "bookings",
      links: %{"bookings.account" => "http://test.host/api/v3/accounts/{bookings.account}"},
      meta: %{"deleted_ids" => [100]}
    }
    returned_result = response |> BookingsyncApiClientV3.Deserializer.deserialize_many
    assert expected_result == returned_result
  end

  test ".deserialize returns Result struct with populated data" do
    body_from_response = %{
      "links" => %{ "a" => "b" },
      "meta" => %{ "deleted_ids" => [] }
    }
    resource = []
    expected_result = %BookingsyncApiClientV3.Result{
      resource: [],
      resource_name: "bookings",
      links: %{ "a" => "b" },
      meta: %{ "deleted_ids" => [] }
    }
    returned_result = body_from_response |> BookingsyncApiClientV3.Deserializer.deserialize(
      resource, "bookings")
    assert expected_result == returned_result
  end

   test ".deserialize returns Result struct with populated data with fallback to
   empty maps if links or meta are nil" do
    body_from_response = %{}
    resource = []
    expected_result = %BookingsyncApiClientV3.Result{
      resource: [],
      resource_name: "bookings",
      links: %{},
      meta: %{}
    }
    returned_result = body_from_response |> BookingsyncApiClientV3.Deserializer.deserialize(
      resource, "bookings")
    assert expected_result == returned_result
  end

  test ".extract_body returns parsed json from HTTPotion.Response body" do
    response = %HTTPotion.Response{body: "[{\"bookings\":{}}]"}
    expected_body = [%{"bookings" => %{}}]
    returned_body = response |> BookingsyncApiClientV3.Deserializer.extract_body
    assert returned_body == expected_body
  end

  test ".extract_body returns original body from HTTPotion.Response if not a json" do
    original_body = "<error></error>Lulz, what happened here."
    response = %HTTPotion.Response{body: original_body}
    expected_body = original_body
    returned_body = response |> BookingsyncApiClientV3.Deserializer.extract_body
    assert returned_body == expected_body
  end
end
