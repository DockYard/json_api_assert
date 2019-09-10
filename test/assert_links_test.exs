defmodule AssertLinksTest do
  use ExUnit.Case
  import JsonApiAssert, only: [assert_links: 2]
  import JsonApiAssert.TestData, only: [data: 1]

  test "will return original payload" do
    payload = Map.merge(data(:payload), data(:links))

    assert payload == assert_links(payload, path: [data(:links)])
  end

  test "will raise if `path:` is not passed" do
    msg = "you must pass `path:` to the links object"

    try do
      assert_links(data(:payload), data(:payload))
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    else
      _ -> flunk """

      Expected Exception

      #{msg}

      """
    end
  end

  test "will raise if links object is not a map" do
    msg = "the value of each links member MUST be an object"

    try do
      put_in(data(:payload)["data"], %{"links" => []})
      |> assert_links(path: [:data, %{"links" => []}])
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    else
      _ -> flunk """

      Expected Exception

      #{msg}

      """
    end

    try do
      Map.merge(data(:payload), %{"links" => ""})
      |> assert_links(path: [%{"links" => ""}])
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    else
      _ -> flunk """

      Expected Exception

      #{msg}

      """
    end
  end

  test "will raise when links object contains an invalid link object" do
    msg = """
    A link MUST be represented as either a string or a map containing only `href` and `meta` objects

    The value for key `related` must be a string or map
    """

    try do
      put_in(data(:payload)["data"]["relationships"]["comments"], data(:invalid_member_2))
      |> assert_links(path: [:data, :relationships, :comments, data(:invalid_member_2)])
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    else
      _ -> flunk """

      Expected Exception

      #{msg}

      """
    end
  end

  test "will raise when link object contains an invalid member" do
    msg = """
    A link MUST be represented as either a string or a map containing only `href` and `meta` objects

    Invalid keys: also_invalid, invalid
    """

    try do
      Map.merge(data(:payload), data(:invalid_member_1))
      |> assert_links(path: [data(:invalid_member_1)])
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    else
      _ -> flunk """

      Expected Exception

      #{msg}

      """
    end
  end

  test "will not raise when members match" do
    Map.merge(data(:payload), data(:valid_members))
    |> assert_links(path: [data(:valid_members)])
  end

  test "will raise when members do not match" do
    msg = "Assertion with == failed"

    try do
      Map.merge(data(:payload), data(:valid_members))
      |> assert_links(path: [data(:links)])
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    else
      _ -> flunk """

      Expected Exception

      #{msg}

      """
    end
  end

  test "will not raise when link object is found in given path" do
    put_in(data(:payload)["data"]["relationships"]["comments"], data(:valid_members))
    |> assert_links(path: ["data", "relationships", "comments", data(:valid_members)])
  end

  test "will not raise when passed atoms for path" do
    put_in(data(:payload)["data"]["relationships"]["comments"], data(:valid_members))
    |> assert_links(path: [:data, :relationships, :comments, data(:valid_members)])
  end
end
