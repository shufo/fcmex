defmodule Fcmex do
  @moduledoc """
  The Worker of Push Client for Exq
  PushWorker can be used to issue Firebase Downstream Messages.
  """

  alias Fcmex.Request
  require Logger

  @max_concurrent_connection 1000

  def push(to, opts \\ [])

  def push(to, opts) when is_binary(to) do
    Request.perform(to, opts)
  end

  def push(_to = [], _opts), do: {:error}

  def push(to, opts) when is_list(to) do
    to
    |> Enum.reject(&is_nil(&1))
    |> Enum.chunk(1000, 1000, [])
    |> Enum.map(&%{to: &1})
    |> Flow.from_enumerable(stages: @max_concurrent_connection)
    |> Flow.map(&Request.perform(&1.to, opts))
    |> Enum.to_list()
  end

  @doc ~s"""
    Returns true when the given token is unregistered
  """
  @spec unregistered?(binary) :: boolean()
  def unregistered?(token) do
    push(token, data: %{})
    |> extract_results
    |> case do
      ["NotRegistered"] -> true
      _ -> false
    end
  end

  @doc ~s"""
    Returns unregistered tokens
  """
  @spec filter_unregistered_tokens(list) :: list(binary)
  def filter_unregistered_tokens(tokens) when is_list(tokens) do
    tokens
    |> Enum.chunk(1000, 1000, [])
    |> Flow.from_enumerable(stages: @max_concurrent_connection)
    |> Flow.map(&%{tokens: &1, results: Request.perform(&1, data: %{})})
    |> Enum.to_list()
    |> Enum.map(&[&1.tokens, &1.results |> extract_results()])
    |> Enum.map(&(&1 |> Enum.zip()))
    |> Enum.map(&(&1 |> Enum.filter(fn {_k, v} -> v == "NotRegistered" end)))
    |> Enum.flat_map(&(&1 |> Enum.map(fn {k, _v} -> k end)))
  end

  defp extract_results({:ok, results} = _results) do
    results
    |> Map.get("results")
    |> Enum.map(&Map.values(&1))
    |> Enum.map(&List.first(&1))
  end

  defp extract_results({_, _} = _results), do: []
end
