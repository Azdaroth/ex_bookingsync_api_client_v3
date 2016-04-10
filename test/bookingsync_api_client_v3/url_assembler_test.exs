defmodule BookingsyncApiClientV3.UrlAssemblerTest do
  use ExUnit.Case
  doctest BookingsyncApiClientV3.UrlAssembler

  test ".generate_url creates URL for API v3 based on passes arguments" do
    base_url = "http://bookingsync.dev"

    expected_url = "http://bookingsync.dev/api/v3/bookings"
    generated_url = BookingsyncApiClientV3.UrlAssembler.generate_url(base_url, "bookings")
    assert generated_url == expected_url

    expected_url = "http://bookingsync.dev/api/v3/bookings/1"
    generated_url = BookingsyncApiClientV3.UrlAssembler.generate_url(base_url, "bookings", 1)
    assert generated_url == expected_url

    expected_url = "http://bookingsync.dev/api/v3/rentals/1/bookings"
    generated_url = BookingsyncApiClientV3.UrlAssembler.generate_url(base_url, "rentals", 1,
      "bookings")
    assert generated_url == expected_url
  end
end
