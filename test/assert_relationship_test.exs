defmodule AssertRelationshipTest do
  use ExUnit.Case
  import JsonApiAssert, only: [assert_relationship: 3]
  import JsonApiAssert.TestData, only: [data: 1]

  test "will not raise when relationship is found in a data record" do
    assert_relationship(data(:payload), data(:author), as: "author", for: data(:post))
  end

  test "will raise if `as:` is not passed" do
    try do
      assert_relationship(data(:payload), data(:author), for: data(:post))
    rescue
      error in [ExUnit.AssertionError] ->
      assert "you must pass `as:` with the name of the relationship" == error.message
    end
  end

  test "will raise if `for:` is not passed" do
    try do
      assert_relationship(data(:payload), data(:author), as: "author")
    rescue
      error in [ExUnit.AssertionError] ->
        assert "you must pass `for:` with the parent record" == error.message
    end
  end

  test "will raise when child record's id not found as a relationship for parent" do
    msg = "could not find relationship `author` with `id` 2 and `type` \"author\" for record matching `id` 1 and `type` \"post\""
    author =
      data(:author)
      |> put_in(["id"], "2")

    try do
      assert_relationship(data(:payload), author, as: "author", for: data(:post))
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    end
  end

  test "will raise when child record's type not found as a relationship for parent" do
    msg = "could not find relationship `author` with `id` 1 and `type` \"writer\" for record matching `id` 1 and `type` \"post\""
    author =
      data(:author)
      |> put_in(["type"], "writer")

    try do
      assert_relationship(data(:payload), author, as: "author", for: data(:post))
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    end
  end

  test "will raise when relationship name not found" do
    msg = "could not find the relationship `writer` for record matching `id` 1 and `type` \"post\""

    try do
      assert_relationship(data(:payload), data(:author), as: "writer", for: data(:post))
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    end
  end

  test "will raise when no relationship data in parent record" do
    msg = "could not find any relationships for record matching `id` 1 and `type` \"post\""
    payload = %{
      "jsonapi" => %{ "version" => "1.0" },
      "data" => %{
        "id" => "1",
        "type" => "post",
        "attributes" => %{
          "title" => "Mother of all demos"
        }
      }
    }

    try do
      assert_relationship(payload, data(:author), as: "writer", for: data(:post))
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    end
  end

  test "will raise when parent record is not found" do
    post =
      data(:post)
      |> put_in(["attributes", "title"], "Father of all demos")

    try do
      assert_relationship(data(:payload), data(:author), as: "writer", for: post)
    rescue
      error in [ExUnit.AssertionError] ->
        assert %{"title" => "Mother of all demos"} == error.left
        assert %{"title" => "Father of all demos"} == error.right
        assert "record with `id` 1 and `type` \"post\" was found but had mis-matching attributes" == error.message
    end
  end

  test "will return the original payload" do
    payload = assert_relationship(data(:payload), data(:author), as: "author", for: data(:post))
    assert payload == data(:payload)
  end

  test "will assert the record is included when `included: true` is used" do
    assert_relationship(data(:payload), data(:comment_1), as: "comments", for: data(:post), included: true)
  end

  test "will raise when  the record is not included and `included: true` is used" do
    msg = "could not find a record with matching `id` 5 and `type` \"comment\""

    try do
      assert_relationship(data(:payload), data(:comment_5), as: "comments", for: data(:post), included: true)
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    end
  end

  test "will raise when the record is included and `included: false` is used" do
    record = %{
      "id" => "1",
      "type" => "comment"
    }
    msg = "did not expect #{inspect record} to be found."

    try do
      assert_relationship(data(:payload), data(:comment_1), as: "comments", for: data(:post), included: false)
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    end
  end

  test "can assert many records at once" do
    payload = assert_relationship(data(:payload_2), [data(:comment_1), data(:comment_2)], as: "comments", for: data(:post))

    assert payload == data(:payload_2)
  end

  test "will fail if one of the records is not present" do
    msg = "could not find relationship `comments` with `id` 3 and `type` \"comment\" for record matching `id` 1 and `type` \"post\""

    try do
      assert_relationship(data(:payload_2), [data(:comment_1), data(:comment_3)], as: "comments", for: data(:post))
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    end
  end
end
