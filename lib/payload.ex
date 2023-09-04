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
    |> Keyword.merge(opts)
    |> Enum.into(%{})
    |> put_destination(to)
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Map.new()
  end



  def put_destination(%{condition: condition} = opts , _to) when is_binary(condition), do: opts

  def put_destination(opts, to) when is_binary(to), do: Map.put(opts, :to, to)

  def put_destination(opts, to) when is_list(to) and length(to) > 0,
    do: Map.put(opts, :registration_ids, to)
end
