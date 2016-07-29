defmodule AssertJsonApiTest do
  use ExUnit.Case
  import JsonApiAssert, only: [assert_jsonapi: 2]
  import JsonApiAssert.TestData, only: [data: 1]

  test "assert - will not raise when matching jsonapi object exists" do
    payload = %{
      "jsonapi" => %{
        "version" => "1.0"
      },
      "meta" => %{
        "authors" => [
          "Brian Cardarella"
        ]
      }
    }

    assert_jsonapi(payload, version: "1.0")
  end

  test "assert - will raise if no jsonapi object exists" do
    try do
      assert_jsonapi(%{}, version: "1.1")
    rescue
      error in [ExUnit.AssertionError] ->
        assert "jsonapi object not found" == error.message
    end
  end

  test "assert will raise when matching jsonapi object does not exist" do
    payload = %{
      "jsonapi" => %{
        "version" => "1.0"
      },
      "meta" => %{
        "authors" => [
          "Brian Cardarella"
        ]
      }
    }

    try do
      assert_jsonapi(payload, version: "1.1")
    rescue
      error in [ExUnit.AssertionError] ->
        assert "jsonapi object mismatch\nExpected:\n  `version` \"1.1\"\nGot:\n  `version` \"1.0\"" == error.message
    end
  end

  test "assert will return original payload" do
    payload = %{
      "jsonapi" => %{
        "version" => "1.0"
      },
      "meta" => %{
        "authors" => [
          "Brian Cardarella"
        ]
      }
    }

    assert payload == assert_jsonapi(payload, version: "1.0")
  end

  test "will raise when both errors and data objects exist in the response" do
    msg = ~r/the members `data` and `errors` MUST NOT coexist in the same document/

    assert_raise(ExUnit.AssertionError, msg, fn ->
      Map.merge(data(:payload), %{"errors" => []})
      |> assert_jsonapi(version: "1.0")
    end)
  end

  test "will raise when an included object exists in the response without the presence of the data object" do
    msg = ~r/If a document does not contain a top-level data key, the included member MUST NOT be present either./

    assert_raise(ExUnit.AssertionError, msg, fn ->
      Map.delete(data(:payload), "data")
      |> assert_jsonapi(version: "1.0")
    end)
  end

  test "will raise if document does not contain at least one of the following objects: 'data', 'errors', 'meta'" do
    msg = ~r/A document MUST contain at least one of the following top-level members: 'data', 'errors', 'meta'/

    assert_raise(ExUnit.AssertionError, msg, fn ->
      Map.delete(data(:payload), "data")
      |> Map.delete("included")
      |> assert_jsonapi(version: "1.0")
    end)

    Map.delete(data(:payload), "data")
    |> Map.delete("included")
    |> Map.merge(%{"errors" => []})
    |> assert_jsonapi(version: "1.0")

    Map.delete(data(:payload), "data")
    |> Map.delete("included")
    |> Map.merge(%{"meta" => []})
    |> assert_jsonapi(version: "1.0")
  end
end
