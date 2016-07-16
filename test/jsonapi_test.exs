defmodule AssertJsonApiTest do
  use ExUnit.Case
  import JsonApiAssert, only: [assert_jsonapi: 2]

  test "assert - will not rise when matching jsonapi object exists" do
    payload = %{
      "jsonapi" => %{
        "version" => "1.0"
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
      }
    }

    try do
      assert_jsonapi(payload, version: "1.1")
    rescue
      error in [ExUnit.AssertionError] ->
        assert "jsonapi object mismatch\nExpected:\n  `version` \"1.1\"\nGot:\n  `version` \"1.0\"" == error.message
    end
  end

  test "assert will return original paylod" do
    payload = %{
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert payload == assert_jsonapi(payload, version: "1.0")
  end
end
