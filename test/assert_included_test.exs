defmodule AssertIncludedTest do
  use ExUnit.Case
  import JsonApiAssert, only: [assert_included: 2]
  import JsonApiAssert.TestData, only: [data: 1]

  @writer %{
    "id" => 1,
    "type" => "writer",
    "attributes" => %{
      "first-name" => "Douglas",
      "last-name" => "Engelbart"
    }
  }

  test "will not raise when record is found" do
    assert_included(data(:payload), data(:author))
  end

  test "will raise when record with different attribute values is not found" do
    author =
      data(:author)
      |> put_in(["attributes", "first-name"], "Yosemite")
      |> put_in(["attributes", "last-name"], "Sam")

    try do
      assert_included(data(:payload), author)
    rescue
      error in [ExUnit.AssertionError] ->
        assert %{"first-name" => "Douglas", "last-name" => "Engelbart"} == error.left
        assert %{"first-name" => "Yosemite", "last-name" => "Sam"} == error.right
        assert "record with `id` 1 and `type` \"author\" was found but had mis-matching attributes" == error.message
    end
  end

  test "will raise when there is an id mismatch" do
    msg = "could not find a record with matching `id` 2 and `type` \"author\""
    author =
      data(:author)
      |> put_in(["id"], 2)

    assert_raise ExUnit.AssertionError, msg, fn ->
      assert_included(data(:payload), author)
    end
  end

  test "will raise when there is a type mismatch" do
    msg = "could not find a record with matching `id` 1 and `type` \"writer\""

    assert_raise ExUnit.AssertionError, msg, fn ->
      assert_included(data(:payload), @writer)
    end
  end

  test "will return the original payload" do
    payload = assert_included(data(:payload), data(:author))

    assert payload == data(:payload)
  end
end
