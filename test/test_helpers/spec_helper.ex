defmodule TestHelpers.SpecHelper do
  def data_for_request do
    %BookingsyncApiClientV3.Data{
      base_url: System.get_env("BOOKINGSYNC_URL") || "http://bookingsync.dev",
      oauth_token: System.get_env("BOOKINGSYNC_OAUTH_ACCESS_TOKEN")
    }
  end

  def base_url do
    data_for_request.base_url
  end

  def request_methods_from_cassette(cassette) do
    cassette_path = cassette_path_for(cassette)
    { :ok, content } = cassette_path |> File.read! |> JSON.decode
    content |> Enum.map(fn body -> body |> Map.get("request") |> Map.get("method") end)
  end

  def requested_urls_from_cassette(cassette) do
    cassette_path = cassette_path_for(cassette)
    { :ok, content } = cassette_path |> File.read! |> JSON.decode
    content |> Enum.map(fn body -> body |> Map.get("request") |> Map.get("url") end)
  end

  defp cassette_path_for(cassette) do
    "#{ExVCR.Setting.get(:cassette_library_dir)}/#{cassette}.json"
  end
end

