defmodule AssertRelationshipTest do
  use ExUnit.Case
  import JsonApiAssert, only: [assert_relationship: 3]
  import JsonApiAssert.TestData, only: [data: 1]

  test "will not raise when relationship is found in a data record" do
    assert_relationship(data(:payload), data(:author), as: "author", for: data(:post))
  end

  test "will raise if `as:` is not passed" do
    assert_raise ExUnit.AssertionError, "you must pass `as:` with the name of the relationship", fn ->
      assert_relationship(data(:payload), data(:author), for: data(:post))
    end
  end

  test "will raise if `for:` is not passed" do
    assert_raise ExUnit.AssertionError, "you must pass `for:` with the parent record", fn ->
      assert_relationship(data(:payload), data(:author), as: "author")
    end
  end

  test "will raise when child record's id not found as a relationship for parent" do
    msg = "could not find relationship `author` with `id` 2 and `type` \"author\" for record matching `id` 1 and `type` \"post\""
    author =
      data(:author)
      |> put_in(["id"], "2")

    assert_raise ExUnit.AssertionError, msg, fn ->
      assert_relationship(data(:payload), author, as: "author", for: data(:post))
    end
  end

  test "will raise when child record's type not found as a relationship for parent" do
    msg = "could not find relationship `author` with `id` 1 and `type` \"writer\" for record matching `id` 1 and `type` \"post\""
    author =
      data(:author)
      |> put_in(["type"], "writer")

    assert_raise ExUnit.AssertionError, msg, fn ->
      assert_relationship(data(:payload), author, as: "author", for: data(:post))
    end
  end

  test "will raise when relationship name not found" do
    msg = "could not find the relationship `writer` for record matching `id` 1 and `type` \"post\""

    assert_raise ExUnit.AssertionError, msg, fn ->
      assert_relationship(data(:payload), data(:author), as: "writer", for: data(:post))
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

    assert_raise ExUnit.AssertionError, msg, fn ->
      assert_relationship(payload, data(:author), as: "writer", for: data(:post))
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
end
