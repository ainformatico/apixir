# Apixir
A simple API to simulate fetching profiles, pagination and rate limiting.

The intention of this API is to be used during pair programming exercises, to simulate a real-world scenario where we need to fetch data from an external API, and we need to handle rate limiting.

## Quirks
* All attributes, except `id` or explicitly stated, are randomly generated **on every response**.
* Profile `2000` has `attributes.properties.cat: "Felix"`.
* Profiles with _even_ `id` have `attributes.properties.dog`.
* Profiles with _odd_ `id` do not have `attributes.properties.dog`.
* The API returns 403 status code if the rate limit is exceeded.

## Configuration
There are some defaults that can be configured, such as the rate limit and the number of returned profiles.
Configuration is in `config/config.exs`.

## Endpoints
Parameters:

* `limit`: Number of profiles to fetch
* `cursor`: Cursor to fetch the next page of profiles

### Profiles

#### Get all profiles:
```
/api/profiles
```

#### Get one profile:

```
/api/profiles/:id
```

### Response
```
HTTP/1.1 200 OK
x-ratelimit-limit: 10
x-ratelimit-remaining: 5
x-ratelimit-reset: 12
x-request-id: F-g3q-rD1ljat0MAAAEB

{
    "data": [
        {
            "attributes": {
                "created_at": "2024-01-02T17:26:57.571406Z",
                "email": "ebba1948@aufderhar.biz",
                "first_name": "Nora",
                "last_name": "Gerlach",
                "phone_number": "+44909686055",
                "properties": {
                    "pizza": "Extra-Large Meat Feast"
                },
                "updated_at": "2024-09-07T04:41:39.383496Z"
            },
            "id": 1,
            "type": "profile"
        }
    ],
    "links": {
        "next": "/api/profiles?cursor=Mg==",
        "prev": null,
        "self": "/api/profiles?cursor=MQ=="
    }
}
```

## How to use
To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
