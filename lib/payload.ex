defmodule Fcmex.Payload do
  @moduledoc ~S"
    Create a payload
  "

  defstruct [
    :to,
    :registration_ids,
    :condition,
    :notification,
    :data,
    :priority,
    :time_to_live,
    :collapse_key,
    :content_available
  ]

  @defaults [
    notification: %{},
    data: %{},
    priority: "high",
    time_to_live: nil,
    collapse_key: nil,
    content_available: nil
  ]

  def create(to, opts) do
    %__MODULE__{}
    |> Map.merge(opts(to, opts))
  end

  def opts(to, opts) do
    @defaults
    |> put_destination(to)
    |> Keyword.merge(opts)
    |> Enum.reject(&(elem(&1, 1) |> is_nil))
    |> Enum.into(%{})
  end

  def put_destination(opts, "CONDITION:" <> to) when is_binary(to), do: opts

  def put_destination(opts, to) when is_binary(to), do: Keyword.merge(opts, to: to)

  def put_destination(opts, to) when is_list(to) and length(to) > 0,
    do: Keyword.merge(opts, registration_ids: to)
end
