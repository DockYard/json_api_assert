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

  test "will not raise when record is found using regex" do
    post =
      data(:post)
      |> put_in(["id"], ~r/\d+/)

    assert_data(data(:payload), post)
  end

  test "will not raise when matching attribute with regex" do
    post =
      data(:post)
      |> put_in(["attributes", "title"], ~r/^Mother.+$/)

    assert_data(data(:payload), post)
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

    try do
      assert_data(data(:payload), post)
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    end
  end

  test "will raise when there is an id mismatch via regex" do
    msg = "could not find a record with matching `id` ~r/^$/ and `type` \"post\""

    post =
      data(:post)
      |> put_in(["id"], ~r/^$/)

    try do
      assert_data(data(:payload), post)
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    end
  end

  test "will raise when there is a type mismatch" do
    msg = "could not find a record with matching `id` 1 and `type` \"article\""

    try do
      assert_data(data(:payload), @article)
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    end
  end

  test "will return the original payload" do
    payload = assert_data(data(:payload), data(:post))

    assert payload == data(:payload)
  end

  test "can assert many records at once" do
    payload = assert_data(data(:payload_2), [data(:post), data(:post_2)])

    assert payload == data(:payload_2)
  end

  test "will fail if one of the records is not present" do
    msg = "could not find a record with matching `id` 2 and `type` \"post\""

    try do
      assert_data(data(:payload), [data(:post), data(:post_2)])
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    end
  end
end
