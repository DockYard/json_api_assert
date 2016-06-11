defmodule JsonApiAssert.SerializerTest do
  use ExUnit.Case
  import JsonApiAssert.Serializer, only: [serialize: 1, serialize: 2, s: 1, s: 2]

  defmodule Author do
    defstruct id: nil,
              first_name: nil,
              last_name: nil
  end

  defmodule Writer do
    defstruct other_id: nil,
              first_name: nil,
              last_name: nil
  end

  defmodule Post do
    defstruct id: nil,
              created_at: nil
  end

  test "serializes data from a record" do
    actual =
      %Author{id: 1, first_name: "Douglas", last_name: "Engelbart"}
      |> serialize()

    expected = %{
      "id" => 1,
      "type" => "author",
      "attributes" => %{
        "first-name" => "Douglas",
        "last-name" => "Engelbart"
      }
    }

    assert actual == expected
  end

  test "serializes data from a map" do
    actual = %{
      id: 1,
      first_name: "Douglas",
      last_name: "Engelbart"
    }

    actual = serialize(actual, type: "author")

    expected = %{
      "id" => 1,
      "type" => "author",
      "attributes" => %{
        "first-name" => "Douglas",
        "last-name" => "Engelbart"
      }
    }

    assert actual == expected
  end

  test "raises when serialize can not determine type" do
    assert_raise ArgumentError, "No type can be derived from record. Please pass a type to `serialize`.", fn ->
      %{
        id: 1,
        first_name: "Douglas",
        last_name: "Engelbart"
      }
      |> serialize()
    end
  end

  test "serializer can override type" do
    actual =
      %Author{id: 1, first_name: "Douglas", last_name: "Engelbart"}
      |> serialize(type: "writers")

    expected = %{
      "id" => 1,
      "type" => "writers",
      "attributes" => %{
        "first-name" => "Douglas",
        "last-name" => "Engelbart"
      }
    }

    assert actual == expected
  end

  test "serializer can override primary_key" do

    actual =
      %Writer{other_id: 1, first_name: "Douglas", last_name: "Engelbart"}
      |> serialize(primary_key: :other_id)

    expected = %{
      "id" => 1,
      "type" => "writer",
      "attributes" => %{
        "first-name" => "Douglas",
        "last-name" => "Engelbart"
      }
    }

    assert actual == expected
  end

  test "serializer can override with string primary_key" do
    actual =
      %Writer{other_id: 1, first_name: "Douglas", last_name: "Engelbart"}
      |> serialize(primary_key: "other_id")

    expected = %{
      "id" => 1,
      "type" => "writer",
      "attributes" => %{
        "first-name" => "Douglas",
        "last-name" => "Engelbart"
      }
    }

    assert actual == expected
  end

  test "can exclude certain attributes with `except`" do
    actual =
      %Author{id: 1, first_name: "Douglas", last_name: "Engelbart"}
      |> serialize(except: [:first_name])

    expected = %{
      "id" => 1,
      "type" => "author",
      "attributes" => %{
        "last-name" => "Engelbart"
      }
    }

    assert actual == expected
  end

  test "can limit attributes with `only`" do
    actual =
      %Author{id: 1, first_name: "Douglas", last_name: "Engelbart"}
      |> serialize(only: [:first_name])

    expected = %{
      "id" => 1,
      "type" => "author",
      "attributes" => %{
        "first-name" => "Douglas"
      }
    }

    assert actual == expected
  end

  test "`except` overrides `only`" do
    actual =
      %Author{id: 1, first_name: "Douglas", last_name: "Engelbart"}
      |> serialize(except: [:first_name], only: [:first_name])

    expected = %{
      "id" => 1,
      "type" => "author",
      "attributes" => %{
        "last-name" => "Engelbart"
      }
    }

    assert actual == expected
  end

  test "shortened `s` function" do
    actual =
      %Author{id: 1, first_name: "Douglas", last_name: "Engelbart"}
      |> s()

    expected = %{
      "id" => 1,
      "type" => "author",
      "attributes" => %{
        "first-name" => "Douglas",
        "last-name" => "Engelbart"
      }
    }

    assert actual == expected
  end

  test "shortened `s` take options" do
    actual =
      %Author{id: 1, first_name: "Douglas", last_name: "Engelbart"}
      |> s(type: "writers")

    expected = %{
      "id" => 1,
      "type" => "writers",
      "attributes" => %{
        "first-name" => "Douglas",
        "last-name" => "Engelbart"
      }
    }

    assert actual == expected
  end

  test "serializaing Ecto.DateTime values" do
    actual =
      %Post{id: 1, created_at: Ecto.DateTime.from_erl({{2016,1,1},{0,0,0}})}
      |> serialize()

    expected = %{
      "id" => 1,
      "type" => "post",
      "attributes" => %{
        "created-at" => "2016-01-01T00:00:00Z"
      }
    }

    assert actual == expected
  end

  test "serializaing Ecto.Time values" do
    actual =
      %Post{id: 1, created_at: Ecto.Time.from_erl({0,0,0})}
      |> serialize()

    expected = %{
      "id" => 1,
      "type" => "post",
      "attributes" => %{
        "created-at" => "00:00:00"
      }
    }

    assert actual == expected
  end

  test "serializaing Ecto.Date values" do
    actual =
      %Post{id: 1, created_at: Ecto.Date.from_erl({2016,1,1})}
      |> serialize()

    expected = %{
      "id" => 1,
      "type" => "post",
      "attributes" => %{
        "created-at" => "2016-01-01"
      }
    }

    assert actual == expected
  end
end
