# JsonApiAssert

Easily build composable queries for Ecto.

[![Build Status](https://secure.travis-ci.org/DockYard/json_api_assert.svg?branch=master)](http://travis-ci.org/DockYard/json_api_assert)

## Usage

JsonApiAssert is a collection of composable test helpers to ease
the pain of testing [JSON API](http://jsonapi.org) payloads.

You can use the functions individually but they are optimally used in a composable
fashion with the pipe operator:

```elixir
payload
|> assert_data(user1)
|> assert_data(user2)
|> refute_data(user3)
|> assert_relationship(pet1, as: "pets", for: user1)
|> assert_relationship(pet2, as: "pets", for: user2)
|> assert_included(pet1)
|> assert_included(pet2)
```

The records passed *must* be already be serialized. Read more about
[serializers](#record-serialization) below to see how to easily manage this with structs or Ecto
models.

If you've tested JSON API payloads before the benefits of this pattern should
be obvious. Hundreds of lines of codes can be reduced to just a handful. Brittle tests are
now flexible and don't care about inseration / render order.
"""

@doc """
Asserts that the "jsonapi" object exists in the payload

```elixir
payload
|> assert_jsonapi(version: "1.0")
```

The members argument should be a key/value pair of members you expect to be be in
the "jsonapi" object of the payload.

## Record Serialization

The assert/refute function expect json-api serialized maps. You can
write these yourself but that can be verbose. Instead it is easier to
manage your data as structs or better from Ecto models. Just use our
built-in serializers.

```elixir
import JsonApiAssert.Serializer, only: [serialize: 1]

user1 = serialize(user)

payload
|> assert_data(user1)
```

As a convenience you can import the short-hand `s` function

```elixir
import JsonApiAssert.Serializer, only: [s: 1]

payload
|> assert_data(s(user))
```

The built-in serializers should be good enough for most cases. However,
they are not a requirement. Feel free to use any serializer you'd like.
The final schema just needs to match the [json-api resource
schema](http://jsonapi.org/format/#document-resource-objects):

```elixir
%{
  "id" => 1,
  "type" => "author",
  "attributes" => %{
    "first-name" => "Brian",
    "last-name" => "Cardarella"
  }
}
```

## Authors

* [Brian Cardarella](http://twitter.com/bcardarella)

[We are very thankful for the many contributors](https://github.com/dockyard/json_api_assert/graphs/contributors)

## Versioning

This library follows [Semantic Versioning](http://semver.org)

## Want to help?

Please do! We are always looking to improve this library. Please see our
[Contribution Guidelines](https://github.com/dockyard/json_api_assert/blob/master/CONTRIBUTING.md)
on how to properly submit issues and pull requests.

## Legal

[DockYard](http://dockyard.com/), Inc. &copy; 2016

[@dockyard](http://twitter.com/dockyard)

[Licensed under the MIT license](http://www.opensource.org/licenses/mit-license.php)
