defmodule JsonApiAssert.TestData do
  def data(name) do
    apply(__MODULE__, name, [])
  end

  def post do
    %{
      "id" => 1,
      "type" => "post",
      "attributes" => %{
        "title" => "Mother of all demos"
      }
    }
  end

  def author do
    %{
      "id" => 1,
      "type" => "author",
      "attributes" => %{
        "first-name" => "Douglas",
        "last-name" => "Engelbart"
      }
    }
  end

  def payload do
    %{
      "jsonapi" => %{
        "version" => "1.0"
      },
      "data" => %{
        "id" => 1,
        "type" => "post",
        "attributes" => %{
          "title" => "Mother of all demos"
        },
        "relationships" => %{
          "author" => %{
            "data" => %{ "type" => "author", "id" => 1 }
          },
          "comments" => %{
            "data" => [
              %{ "type" => "comment", "id" => 1 },
              %{ "type" => "comment", "id" => 2 }
            ]
          }
        }
      },
      "included" => [
        %{
          "id" => 1,
          "type" => "author",
          "attributes" => %{
            "first-name" => "Douglas",
            "last-name" => "Engelbart"
          },
          "relationships" => %{
            "posts" => %{
              "data" => [
                %{ "type" => "post", "id" => 1 }
              ]
            }
          }
        }, %{
          "id" => 1,
          "type" => "comment",
          "attributes" => %{
            "body" => "This is great!"
          },
          "relationships" => %{
            "post" => %{
              "data" => %{ "type" => "post", "id" => 1 }
            }
          }
        }, %{
          "id" => 2,
          "type" => "comment",
          "attributes" => %{
            "body" => "This is horrible!"
          },
          "relationships" => %{
            "post" => %{
              "data" => %{ "type" => "post", "id" => 1 }
            }
          }
        }
      ]
    }
  end

  def deep_merge(left, right) when is_map(left) and is_map(right) do
    Enum.into right, left, fn({key, value}) ->
      if Map.has_key?(left, key) do
        {key, deep_merge(left[key], value)}
      else
        {key, value}
      end
    end
  end

  def deep_merge(left, right) when is_list(left) and is_list(right) do
    Enum.reduce right, left, fn({key, value}, data) ->
      tuple = if Keyword.has_key?(data, key) do
        {key, deep_merge(left[key], value)}
      else
        {key, value}
      end

      Keyword.merge(data, Keyword.new([tuple]))
    end
  end

  def deep_merge(_left, right), do: right
end
