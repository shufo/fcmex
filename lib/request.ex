defmodule Fcmex.Request do
  @moduledoc ~S"
    Perform request to FCM
  "

  use Retry
  alias Fcmex.{Util, Config, Payload}

  @fcm_endpoint "https://fcm.googleapis.com/fcm/send"

  def perform(to, opts) do
    with payload <- Payload.create(to, opts),
         result <- post(payload) do
      Util.parse_result(result)
    end
  end

  defp post(%Payload{} = payload) do
    retry with: exp_backoff() |> randomize |> expiry(10_000) do
      HTTPoison.post(@fcm_endpoint, payload |> Poison.encode!(), Config.new())
    after
      result -> result
    else
      error -> error
    end
  end
end
