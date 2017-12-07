defmodule FcmexTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  alias Fcmex.Payload

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    ExVCR.Config.filter_request_headers("Authorization")
    ExVCR.Config.filter_sensitive_data(~s("[a-zA-Z0-9:_-]{20,4000}?"), ~s("FCM_TOKEN"))

    HTTPoison.start()

    token = "FCM_TOKEN"
    invalid_registration_token = "invalid_registration_token"
    not_registered_token = "not_registered_token"

    {
      :ok,
      token: token,
      invalid_registration_token: invalid_registration_token,
      not_registered_token: not_registered_token
    }
  end

  test "request with single token", context do
    use_cassette "single_token" do
      assert {:ok, body} = Fcmex.push(context.token, data: %{foo: "bar"})
      assert body["success"] == 1
      assert body["failure"] == 0
    end
  end

  test "request with single invalid registration token", context do
    use_cassette "single_token_invalid_registration" do
      assert {:ok, body} =
               Fcmex.push(context.invalid_registration_token, data: %{
                 foo: "bar"
               })

      assert body["success"] == 0
      assert body["failure"] == 1
      assert body["results"] |> List.first() == %{"error" => "InvalidRegistration"}
    end
  end

  test "request with single not registered token", context do
    use_cassette "single_token_not_registered" do
      assert {:ok, body} =
               Fcmex.push(context.not_registered_token, data: %{
                 foo: "bar"
               })

      assert body["success"] == 0
      assert body["failure"] == 1
      assert body["results"] |> List.first() == %{"error" => "NotRegistered"}
    end
  end

  test "request with multiple token", context do
    use_cassette "multiple_token" do
      # assert all tokens are valid
      assert [ok: body] =
               Fcmex.push(
                 [
                   context.token,
                   context.token
                 ],
                 data: %{
                   foo: "bar"
                 }
               )

      assert body["success"] == 2
      assert body["failure"] == 0
      assert body["results"] |> Enum.count(&(&1["message_id"] != nil)) == 2
    end
  end

  test "request with multiple token including invalid key", context do
    use_cassette "multiple_token_with_invalid_key" do
      assert [ok: body] =
               Fcmex.push(
                 [
                   context.token,
                   context.not_registered_token,
                   context.invalid_registration_token
                 ],
                 data: %{
                   foo: "bar"
                 }
               )

      # assert success and error count
      assert body["success"] == 1
      assert body["failure"] == 2
      assert body["results"] |> Enum.count(&(&1["message_id"] != nil)) == 1
      assert body["results"] |> Enum.count(&(&1["error"] != nil)) == 2

      # assert results is ordered by requested token
      assert body["results"] |> List.first() |> Map.get("message_id") != nil
      assert body["results"] |> List.pop_at(1) |> elem(0) |> Map.get("error") == "NotRegistered"
      assert body["results"] |> List.last() |> Map.get("error") == "InvalidRegistration"
    end
  end

  test "request notification message", context do
    use_cassette "single_token_with_notification_message" do
      assert {:ok, body} =
               Fcmex.push(context.token, notification: %{
                 title: "foo",
                 body: "bar",
                 click_action: "open_app",
                 icon: "new"
               })

      # assert success and error count
      assert body["success"] == 1
      assert body["failure"] == 0
    end
  end

  test "request notification message with custom data", context do
    use_cassette "single_token_with_notification_and_data" do
      assert {:ok, body} =
               Fcmex.push(
                 context.token,
                 notification: %{
                   title: "foo",
                   body: "bar",
                   click_action: "open_app",
                   icon: "new"
                 },
                 data: %{
                   first_name: "Sophia",
                   last_name: "McGuire"
                 }
               )

      # assert success and error count
      assert body["success"] == 1
      assert body["failure"] == 0
    end
  end

  test "request notification message with other options", context do
    use_cassette "single_token_with_notification_and_data" do
      assert {:ok, body} =
               Fcmex.push(
                 context.token,
                 notification: %{
                   title: "foo",
                   body: "bar",
                   click_action: "open_app",
                   icon: "new"
                 },
                 priority: "normal",
                 time_to_live: 1000,
                 collapse_key: "data",
                 mutable_content: true
               )

      # assert success and error count
      assert body["success"] == 1
      assert body["failure"] == 0
    end
  end

  test "request 1000+ more messages", context do
    use_cassette "over_thousand_messages", match_requests_on: [:query, :request_body] do
      tokens = for _ <- 1..1500, do: context.token

      [ok: body, ok: body2] =
        Fcmex.push(tokens, data: %{
          first_name: "Sophia",
          last_name: "McGuire"
        })

      # assert success and error count
      assert body["success"] == 1000 || 500
      assert body2["success"] == 1500 - body["success"]

      # request 11000 messages
      tokens = for _ <- 1..11_000, do: context.token

      result =
        Fcmex.push(tokens, data: %{
          first_name: "Sophia",
          last_name: "McGuire"
        })

      assert Enum.count(result) == 11
    end
  end

  @tag :payload
  test "payload test" do
    payload = Payload.create(["test"], priority: "high")
    refute Map.has_key?(payload, :mutable_content)

    payload = Payload.create(["test"], priority: "high", mutable_content: true)
    assert payload.mutable_content == true
  end
end
