defmodule Fcmex.Payload do
  @moduledoc ~S"
    Create a payload
  "

  defstruct [
    :to,
    :registration_ids,
    :notification,
    :data,
    :priority,
    :time_to_live,
    :collapse_key
  ]

  @defaults [
    notification: %{},
    data: %{},
    priority: "high",
    time_to_live: nil,
    collapse_key: nil,
  ]

  def create(to, opts) do
    %__MODULE__{}
    |> Map.merge(opts(to, opts))
  end

  def opts(to, opts) do
    @defaults
    |> put_destination(to)
    |> Keyword.merge(opts |> Keyword.take(Keyword.keys(@defaults)))
    |> Enum.reject(& elem(&1, 1) |> is_nil)
    |> Enum.into(%{})
  end

  def put_destination(opts, to) when is_binary(to), do: Keyword.merge(opts, to: to)
  def put_destination(opts, to) when is_list(to) and length(to) > 0, do: Keyword.merge(opts, registration_ids: to)
end
