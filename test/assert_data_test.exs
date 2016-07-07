defmodule AssertDataTest do
  use ExUnit.Case
  import JsonApiAssert, only: [assert_data: 2]
  import JsonApiAssert.TestData, only: [data: 1]

  @article %{
    "id" => "1",
    "type" => "article",
    "attributes" => %{
      "title" => "Mother of all demos"
    }
  }

  test "will not raise when record is found" do
    assert_data(data(:payload), data(:post))
  end

  test "will raise when record with different attribute values is not found" do
    post =
      data(:post)
      |> put_in(["attributes", "title"], "Father of all demos")

    try do
      assert_data(data(:payload), post)
    rescue
      error in [ExUnit.AssertionError] ->
        assert %{"title" => "Mother of all demos"} == error.left
        assert %{"title" => "Father of all demos"} == error.right
        assert "record with `id` 1 and `type` \"post\" was found but had mis-matching attributes" == error.message
    end
  end

  test "will raise when there is an id mismatch" do
    msg = "could not find a record with matching `id` 2 and `type` \"post\""

    post =
      data(:post)
      |> put_in(["id"], "2")

    assert_raise ExUnit.AssertionError, msg, fn ->
      assert_data(data(:payload), post)
    end
  end

  test "will raise when there is a type mismatch" do
    msg = "could not find a record with matching `id` 1 and `type` \"article\""

    assert_raise ExUnit.AssertionError, msg, fn ->
      assert_data(data(:payload), @article)
    end
  end

  test "will return the original payload" do
    payload = assert_data(data(:payload), data(:post))

    assert payload == data(:payload)
  end
end
