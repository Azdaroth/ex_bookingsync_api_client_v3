# BookingsyncApiClientV3 [![Build Status](https://travis-ci.org/Azdaroth/ex_bookingsync_api_client_v3.svg?branch=master)](https://travis-ci.org/Azdaroth/ex_bookingsync_api_client_v3) [![Coverage Status](https://coveralls.io/repos/github/Azdaroth/ex_bookingsync_api_client_v3/badge.svg?branch=master)](https://coveralls.io/github/Azdaroth/ex_bookingsync_api_client_v3?branch=master)

Elixir BookingSync (https://www.bookingsync.com) API v3 client. Find more at: http://developers.bookingsync.com

## Installation

- Add :bookingsync_api_client_v3 to your list of dependencies in `mix.exs`:

``` elixir
def deps do
  [{:bookingsync_api_client_v3, "~> 0.0.1"}]
end
```

- Ensure :bookingsync_api_client_v3 is started before your application:

``` elixir
def application do
  [applications: [:bookingsync_api_client_v3]]
end
```

- Fetch dependencies:

```
mix deps.get
```

## Usage

You will need oauth access token to perform any request. If you don't know where you can get one, please visit http://developers.bookingsync.com.

For every request you will need to pass `BookingsyncApiClientV3.Data` struct. Here's an example how to initialize one

``` iex
%BookingsyncApiClientV3.Data{
  base_url: "https://bookingsync.dev", # required
  oauth_token: "MY_ACCESS_TOKEN", # required
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
data = %BookingsyncApiClientV3.Data{base_url: "http://bookingsync.dev", oauth_token: "MY_ACCESS_TOKEN"}

# index action, performs autopagination if `next` are available
data |> BookingsyncApiClientV3.Client.get("bookings")

# index action, with query params which will be appended to the url
data |> BookingsyncApiClientV3.Client.get("clients", %{fullname: "Rich Piana"})

# show action, get client with id 96
data |> BookingsyncApiClientV3.Client.get("clients", 96)

# create action, create client with given payload
data |> BookingsyncApiClientV3.Client.post("clients", %{clients: [%{fullname: "Rich Piana"}]})

# create action with scope, create bathroom for rental with id 1 with given payload
data |> BookingsyncApiClientV3.Client.post("rentals", 1, "bathrooms", %{bathrooms: [%{name_en: bathroom_name}]})

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

You can also fetch relationships from single resource:

``` iex
# fetchting single relationship, e.g. rental, returns BookingsyncApiClientV3.Result
# with single rental as resource
{:ok, booking} = data |> BookingsyncApiClientV3.Client.get("bookings", 500)
{:ok,
 %BookingsyncApiClientV3.Result{links: %{"bookings.account" => "http://bookingsync.dev/api/v3/accounts/{bookings.account}",
    "bookings.bookings_fees" => "http://bookingsync.dev/api/v3/bookings_fees/{bookings.bookings_fees}",
    "bookings.bookings_tags" => "http://bookingsync.dev/api/v3/bookings_tags/{bookings.bookings_tags}",
    "bookings.bookings_taxes" => "http://bookingsync.dev/api/v3/bookings_taxes/{bookings.bookings_taxes}",
    "bookings.client" => "http://bookingsync.dev/api/v3/clients/{bookings.client}",
    "bookings.inquiry" => "http://bookingsync.dev/api/v3/inquiries/{bookings.inquiry}",
    "bookings.rental" => "http://bookingsync.dev/api/v3/rentals/{bookings.rental}",
    "bookings.rental_agreement" => "http://bookingsync.dev/api/v3/rental_agreements/{bookings.rental_agreement}",
    "bookings.source" => "http://bookingsync.dev/api/v3/sources/{bookings.source}"},
  meta: %{},
  resource: %{"damage_deposit" => "0.0", "notes" => "Baby bed required",
    "locked" => nil, "expected_checkin_time" => nil,
    "initial_price" => "1000.0", "initial_rental_price" => "1000.0",
    "id" => 500, "end_at" => "2016-08-17T10:00:00Z", "children" => nil,
    "currency" => "GBP", "bookings_payments_count" => 1,
    "final_price_to_owner" => nil, "canceled_at" => nil, "unavailable" => false,
    "review_requests_count" => 0, "final_rental_price" => "1000.0",
    "payment_url" => nil, "expected_checkout_time" => nil,
    "links" => %{"account" => 1, "bookings_fees" => [], "bookings_tags" => [],
      "bookings_taxes" => [], "client" => 39, "inquiry" => nil, "rental" => 3,
      "rental_agreement" => nil, "source" => nil}, "status" => "Booked",
    "paid_amount" => "1000.0", "final_price" => "1000.0", "discount" => nil,
    "created_at" => "2015-07-21T13:05:12Z", "downpayment" => nil,
    "commission" => nil, "owned_by_app" => false,
    "charge_damage_deposit_on_arrival" => true, "tentative_expires_at" => nil,
    "booked" => true, "balance_due_at" => nil,
    "start_at" => "2016-08-09T16:00:00Z", "reference" => "0000DW",
    "adults" => 9, "updated_at" => "2015-07-21T13:05:12Z"},
  resource_name: "bookings"}}

{:ok, rental} = data |> BookingsyncApiClientV3.Relationship.from_result(booking, "rental")
{:ok,
 %BookingsyncApiClientV3.Result{links: %{"rentals.account" => "http://bookingsync.dev/api/v3/accounts/{rentals.account}",
    "rentals.availability" => "http://bookingsync.dev/api/v3/availabilities/{rentals.availability}",
    "rentals.bathrooms" => "http://bookingsync.dev/api/v3/bathrooms/{rentals.bathrooms}",
    "rentals.bedrooms" => "http://bookingsync.dev/api/v3/bedrooms/{rentals.bedrooms}",
    "rentals.destination" => "http://bookingsync.dev/api/v3/destinations/{rentals.destination}",
    "rentals.photos" => "http://bookingsync.dev/api/v3/photos/{rentals.photos}",
    "rentals.rates" => "http://bookingsync.dev/api/v3/rates/{rentals.rates}",
    "rentals.rates_table" => "http://bookingsync.dev/api/v3/rates_tables/{rentals.rates_table}",
    "rentals.rental_agreement" => "http://bookingsync.dev/api/v3/rental_agreements/{rentals.rental_agreement}",
    "rentals.rental_cancelation_policy" => "http://bookingsync.dev/api/v3/rental_cancelation_policies/{rentals.rental_cancelation_policy}",
    "rentals.rentals_amenities" => "http://bookingsync.dev/api/v3/rentals_amenities/{rentals.rentals_amenities}",
    "rentals.rentals_fees" => "http://bookingsync.dev/api/v3/rentals_fees/{rentals.rentals_fees}",
    "rentals.rentals_tags" => "http://bookingsync.dev/api/v3/rentals_tags/{rentals.rentals_tags}",
    "rentals.reviews" => "http://bookingsync.dev/api/v3/reviews/{rentals.reviews}",
    "rentals.special_offers" => "http://bookingsync.dev/api/v3/special_offers/{rentals.special_offers}"},
  meta: %{},
  resource: %{"bookable_online" => false, "balance_due" => 30,
    "damage_deposit" => "0.0", "sleeps_max" => nil,
    "published_at" => "2015-10-08T09:28:56Z", "surface_unit" => "metric",
    "notes" => nil, "website_url" => %{}, "initial_price" => nil,
    "address2" => nil, "base_rate" => "700.0", "owner_email" => nil, "id" => 3,
    "contact_name" => "Contact Fullname", "max_price" => "700.0",
    "country_code" => "FR", "stories_count" => nil, "currency" => "USD",
    "price_public_notes" => %{"en" => "Public notes in english"},
    "owner_fullname" => nil, "checkout_details" => %{}, "floor" => "",
    "lat" => 45.02, "absolute_min_price" => "0.0", "bedrooms_count" => nil,
    "sleeps" => 7,
    "links" => %{"account" => 1, "availability" => 3,
      "bathrooms" => [7, 8, 9, 27, 28, 29], "bedrooms" => [],
      "destination" => 136, "photos" => [3], "rates" => [6, 7, 8],
      "rates_table" => 1, "rental_agreement" => 13,
      "rental_cancelation_policy" => 13, "rentals_amenities" => [],
      "rentals_fees" => [29, 30, 31, 34, 35, 37, 38], "rentals_tags" => [],
      "reviews" => [75, 76, 77, 78, 79, ...], "special_offers" => [2]},
    "final_price" => nil, "state" => nil,
    "created_at" => "2015-04-03T13:23:32Z", "name" => "Apartment 1 2",
    "address1" => nil, "checkin_details" => %{}, "checkin_time" => 16,
    "downpayment" => 30, "city" => "Nevache", "reviews_average_rating" => "4.6",
    "bookable_on_request" => true, "lng" => 6.6, "price_kind" => "weekly",
    "description" => %{"en" => "Complete description"}, "owner_notes" => nil,
    "reviews_count" => 115, "rental_type" => "villa", "position" => 3,
    "min_price" => "700.0", ...}, resource_name: "rentals"}}

# fetching multi relationship, e.g. bathrooms, returns BookingsyncApiClientV3.Result
# with bathrooms as resource
{:ok, bathrooms} = data |> BookingsyncApiClientV3.Relationship.from_result(rental, "bathrooms")
{:ok,
 %BookingsyncApiClientV3.Result{links: %{"bathrooms.rental" => "http://bookingsync.dev/api/v3/rentals/{bathrooms.rental}"},
  meta: %{},
  resource: [%{"bath_count" => 0, "created_at" => "2015-08-18T15:08:50Z",
     "id" => 7, "links" => %{"rental" => 3},
     "name" => %{"en" => "Bathroom 1", "fr" => "Chambre 1"},
     "shower_count" => 0, "updated_at" => "2015-08-18T15:08:50Z",
     "wc_count" => 0},
   %{"bath_count" => 0, "created_at" => "2015-08-18T15:08:50Z", "id" => 8,
     "links" => %{"rental" => 3},
     "name" => %{"en" => "Bathroom 2", "fr" => "Chambre 2"},
     "shower_count" => 0, "updated_at" => "2015-08-18T15:08:50Z",
     "wc_count" => 0},
   %{"bath_count" => 0, "created_at" => "2015-08-18T15:08:50Z", "id" => 9,
     "links" => %{"rental" => 3},
     "name" => %{"en" => "Bathroom 3", "fr" => "Chambre 3"},
     "shower_count" => 0, "updated_at" => "2015-08-18T15:08:50Z",
     "wc_count" => 0},
   %{"bath_count" => 0, "created_at" => "2015-09-01T09:19:46Z", "id" => 27,
     "links" => %{"rental" => 3},
     "name" => %{"en" => "Bathroom 1", "fr" => "Salle de bains 1"},
     "shower_count" => 0, "updated_at" => "2015-09-01T09:19:46Z",
     "wc_count" => 0},
   %{"bath_count" => 0, "created_at" => "2015-09-01T09:19:46Z", "id" => 28,
     "links" => %{"rental" => 3},
     "name" => %{"en" => "Bathroom 2", "fr" => "Salle de bains 2"},
     "shower_count" => 0, "updated_at" => "2015-09-01T09:19:46Z",
     "wc_count" => 0},
   %{"bath_count" => 0, "created_at" => "2015-09-01T09:19:46Z", "id" => 29,
     "links" => %{"rental" => 3},
     "name" => %{"en" => "Bathroom 3", "fr" => "Salle de bains 3"},
     "shower_count" => 0, "updated_at" => "2015-09-01T09:19:46Z",
     "wc_count" => 0}], resource_name: "bathrooms"}}
```
## Contributing

- Fork this repo.

- Install dependencies and run tests:

```
mix test
```

If you need to record any VCR cassette, you need to provide `BOOKINGSYNC_OAUTH_ACCESS_TOKEN` ENV variable:

```
BOOKINGSYNC_OAUTH_ACCESS_TOKEN=MY_ACCESS_TOKEN mix test
```

By default `http://bookingsync.dev` URL will be used, which can be customized with `BOOKINGSYNC_URL` ENV variable:

```
BOOKINGSYNC_OAUTH_ACCESS_TOKEN=MY_ACCESS_TOKEN BOOKINGSYNC_URL=https://bookingsync.dev mix test
```

- Submit pull request.
