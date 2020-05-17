defmodule Fcmex.Util do
  @moduledoc ~S"
    Utils for Fcmex
  "

  alias HTTPoison.Response
  alias HTTPoison.Error

  @success_status 200..299
  @client_error_status 400..499
  @server_error_status 500..599

  @doc ~S"""
  Parses the given FCM response.

  ## Examples

      iex> Fcmex.Util.parse_result({:ok, %HTTPoison.Response{status_code: 200, body: "{\"a\": 1}"}})
      {:ok, Poison.decode!("{\"a\": 1}")}

      iex> Fcmex.Util.parse_result({:error, %HTTPoison.Error{id: 1, reason: "something goes wrong"}})
      {:error, %HTTPoison.Error{id: 1, reason: "something goes wrong"}}
  """
  def parse_result({:ok, %Response{status_code: status, body: body}})
      when status in @success_status,
      do: {:ok, Poison.decode!(body)}

  def parse_result({:ok, %Response{status_code: status, body: body}})
      when status in @client_error_status do
    body
    |> Poison.decode()
    |> case do
         {:ok, decoded} -> {:error, decoded}
         {:error, _} -> {:error, body}
       end
  end

  def parse_result({:ok, %Response{status_code: status, body: body}})
      when status in @server_error_status,
      do: body

  def parse_result({:error, %Error{id: _, reason: _} = response}), do: {:error, response}
  def parse_result({:error, response}), do: {:error, response}
  def parse_result({_, %Response{status_code: _, body: _} = response}), do: response
end
