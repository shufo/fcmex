defmodule Fcmex.Util do
  @moduledoc ~S"
    Utils for Fcmex
  "

  alias HTTPoison.Response

  @success_status 200..299
  @client_error_status 400..499
  @server_error_status 500..599

  def parse_result({:ok, %Response{status_code: status, body: body}}) when status in @success_status, do: {:ok, Poison.decode!(body)}
  def parse_result({:ok, %Response{status_code: status, body: body}}) when status in @client_error_status do
    body
    |> Poison.decode
    |> case do
      {:ok, decoded} -> {:error, decoded}
      {:error, _}    -> {:error, body}
    end
  end
  def parse_result({:ok, %Response{status_code: status, body: body}}) when status in @server_error_status, do: body
  def parse_result({_, %Response{status_code: _, body: _} = response}), do: response
end
