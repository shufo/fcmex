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
end
