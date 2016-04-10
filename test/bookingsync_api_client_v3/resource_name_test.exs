defmodule BookingsyncApiClientV3.ResourceNameTest do
  use ExUnit.Case
  doctest BookingsyncApiClientV3.ResourceName

  test ".extract_from_body returns the resource name which is the key
  different than 'links' and 'meta'" do
    body = %{"links" => %{}, "meta" => %{}, "bookings" => []}
    expected_resource_name = "bookings"
    assert BookingsyncApiClientV3.ResourceName.extract_from_body(body) == expected_resource_name
  end
end
