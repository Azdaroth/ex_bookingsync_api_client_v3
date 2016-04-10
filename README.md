# BookingsyncApiClientV3 [![Build Status](https://travis-ci.org/Azdaroth/ex_bookingsync_api_client_v3.svg?branch=master "Build Status")]((https://travis-ci.org/Azdaroth/ex_bookingsync_api_client_v3))

Elixir BookingSync (https://www.bookingsync.com) API v3 client. Find more at: http://developers.bookingsync.com

## Installation

1. Add :bookingsync_api_client_v3 to your list of dependencies in `mix.exs`:

``` elixir
def deps do
  [{:bookingsync_api_client_v3, "~> 0.0.1"}]
end
```

2. Ensure :bookingsync_api_client_v3 is started before your application:

``` elixir
def application do
  [applications: [:bookingsync_api_client_v3]]
end
```

3. Fetch dependencies:

```
mix deps.get
```

## Usage

You will need oauth access token to perform any request. If you don't know where you can get one, please visit http://developers.bookingsync.com.

For every request you will need to pass `BookingsyncApiClientV3.Data` struct. Here's an example how to initialize one

``` iex
%BookingsyncApiClientV3.Data{
  base_url: "https://bookingsync.dev", # required
  oauth_token: "MY_SECRET_TOKEN", # required
  timeout: 50_000 # not required, 10_000 (10 s) is the default value
}
```

The result for any request is one of the following options:

1. `{:ok, result}` tuple indicating success where `result` is `BookingsyncApiClientV3.Result` struct.
2. `{:error, error_code, error_message}` tuple indicating error where `error_code` is integer standing for HTTP status and `error_message` is either returned error message deserialized into map if the body was of JSON format or original body if wasn't of JSON format.


`BookingsyncApiClientV3.Result` contains the following fields:

1. `resource` containing deserialized body from response. For `index` action it is list of maps and for `show`, `update` and `create` actions it is map (as only the single record is returned in body).
2. `links` - map with links from response.
3. `meta` - map with meta data from response
4. `resource_name` - name of the resource, e.g. "bookings"

Here are some examples of requests:

``` iex
data = %BookingsyncApiClientV3.Data{base_url: "http://bookingsync.dev", oauth_token: "MY_SECRET_TOKEN"}

# index action, performs autopagination if `next` are available
data |> BookingsyncApiClientV3.Client.get("bookings")

# index action, with query params which will be appended to the url
data |> BookingsyncApiClientV3.Client.get("clients", %{fullname: "Rich Piana"})

# show action, get client with id 96
data |> BookingsyncApiClientV3.Client.get("clients", 96)

# create action, create client with given payload
data |> BookingsyncApiClientV3.Client.post("clients", %{clients: [%{fullname: "Rich Piana"}]})

# update action, update client with id 98 with given payload
data |> BookingsyncApiClientV3.Client.patch("clients", 98, %{clients: [%{fullname: "Updated fullname"}]})

# delete action, destroy booking with id 98
data |> BookingsyncApiClientV3.Client.delete("bookings", 98)

# example of successful request
iex> data |> BookingsyncApiClientV3.Client.get("clients", 96)
{:ok,
 %BookingsyncApiClientV3.Result{links: %{"clients.account" => "http://bookingsync.dev/api/v3/accounts/{clients.account}"},
  meta: %{},
  resource: %{"addresses" => [], "created_at" => "2016-04-01T10:56:49Z",
    "emails" => [], "fullname" => "fullname", "id" => 96,
    "links" => %{"account" => 1}, "notes" => nil, "passport" => nil,
    "phones" => [], "preferred_locale" => nil,
    "updated_at" => "2016-04-01T10:56:49Z"}, resource_name: "clients"}}

# example of request with error
{:error, 401, error_message} = data |> BookingsyncApiClientV3.Client.get("bookings", 1)

iex> error_message == %{"errors" => [%{"code" => "unauthorized"}]}
true
```

## Contributing

- Fork this repo.

- Install dependencies and run tests:

```
mix test
```

If you need to record any VCR cassette, you need to provide `BOOKINGSYNC_OAUTH_ACCESS_TOKEN` ENV variable:

```
BOOKINGSYNC_OAUTH_ACCESS_TOKEN=MY_SECRET_TOKEN mix test
```

By default `http://bookingsync.dev` URL will be used, which can be customized with `BOOKINGSYNC_URL` ENV variable:

```
BOOKINGSYNC_OAUTH_ACCESS_TOKEN=MY_SECRET_TOKEN BOOKINGSYNC_URL=https://bookingsync.dev mix test
```

- Submit pull request.
