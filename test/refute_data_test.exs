defmodule RefuteDataTest do
  use ExUnit.Case
  import JsonApiAssert, only: [refute_data: 2]
  import JsonApiAssert.TestData, only: [data: 1]

  test "will not raise when record is not found" do
    post =
      data(:post)
      |> put_in(["attributes", "title"], "Father of all demos")

    refute_data(data(:payload), post)
  end

  test "will raise when record is found" do
    record = %{
      "id" => "1",
      "type" => "post"
    }

    msg = "did not expect #{inspect record} to be found."

    try do
      refute_data(data(:payload), data(:post))
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    end
  end

  test "will raise when record is found with regex" do
    post =
      data(:post)
      |> put_in(["id"], ~r/\d+/)

    record = %{
      "id" => ~r/\d+/,
      "type" => "post"
    }

    msg = "did not expect #{inspect record} to be found."

    try do
      refute_data(data(:payload), post)
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    end
  end

  test "will raise when matching attribute with regex" do
    post =
      data(:post)
      |> put_in(["attributes", "title"], ~r/^Mother.+$/)

    record = %{
      "id" => "1",
      "type" => "post"
    }

    msg = "did not expect #{inspect record} to be found."

    try do
      refute_data(data(:payload), post)
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    end
  end

  test "will return the original payload" do
    post =
      data(:post)
      |> put_in(["attributes", "title"], "Father of all demos")

    payload = refute_data(data(:payload), post)

    assert payload == data(:payload)
  end

  test "will not raise if we force an id value mis-match and everything else matches" do
    post =
      data(:post)
      |> put_in(["id"], "2")

    refute_data(data(:payload), post)
  end

  test "will not raise if we force an id value mis-match with regex and everything else matches" do
    post =
      data(:post)
      |> put_in(["id"], ~r/^$/)

    refute_data(data(:payload), post)
  end

  test "can refute many records at once" do
    post =
      data(:post)
      |> put_in(["attributes", "title"], "Father of all demos")

    payload = refute_data(data(:payload), [post, data(:post_2)])

    assert payload == data(:payload)
  end

  test "will fail if one of the records is present" do
    record = %{
      "id" => "1",
      "type" => "post"
    }
    msg = "did not expect #{inspect record} to be found."

    try do
      refute_data(data(:payload), [data(:post_2), data(:post)])
    rescue
      error in [ExUnit.AssertionError] ->
        assert msg == error.message
    end
  end
end
