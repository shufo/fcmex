defmodule Fcmex.Subscription do
  @moduledoc """
  This module manages subscritioins
  """

  use Retry
  alias Fcmex.{Config, Util}

  @base_url "https://iid.googleapis.com/iid"

  @endpoint "/info"
  def get(token) do
    request(fn ->
      HTTPoison.get(
        "#{@base_url}#{@endpoint}/#{token}?details=true",
        Config.new(),
        Config.httpoison_options()
      )
    end)
  end

  @endpoint "/v1"
  def subscribe(topic, token) when is_binary(token) do
    request(fn ->
      HTTPoison.post(
        "#{@base_url}#{@endpoint}/#{token}/rel/topics/#{topic}",
        "",
        Config.new(),
        Config.httpoison_options()
      )
    end)
  end

  @endpoint "/v1"
  def subscribe(topic, tokens) when is_list(tokens) and length(tokens) > 0 do
    body = %{
      to: "/topics/#{topic}",
      registration_tokens: tokens
    }

    request(fn ->
      HTTPoison.post(
        "#{@base_url}#{@endpoint}:batchAdd",
        body |> Config.json_library().encode!(),
        Config.new(),
        Config.httpoison_options()
      )
    end)
  end

  @endpoint "/v1"
  def unsubscribe(topic, token) when is_binary(token) do
    body = %{
      to: "/topics/#{topic}",
      registration_tokens: [token]
    }

    url = "#{@base_url}#{@endpoint}:batchRemove"

    request(fn ->
      HTTPoison.post(
        url,
        body |> Config.json_library().encode!(),
        Config.new(),
        Config.httpoison_options()
      )
    end)
  end

  @endpoint "/v1"
  def unsubscribe(topic, tokens) when is_list(tokens) and length(tokens) > 0 do
    body = %{
      to: "/topics/#{topic}",
      registration_tokens: tokens
    }

    url = "#{@base_url}#{@endpoint}:batchRemove"

    request(fn ->
      HTTPoison.post(
        url,
        body |> Config.json_library().encode!(),
        Config.new(),
        Config.httpoison_options()
      )
    end)
  end

  defp request(func) do
    retry with: exponential_backoff() |> randomize |> expiry(10_000) do
      func.()
    after
      result -> Util.parse_result(result)
    else
      error -> error
    end
  end
end
