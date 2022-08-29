defmodule Fcmex.Config do
  @moduledoc ~S"
    A configuration for FCM
  "

  def new do
    [
      {"Content-Type", "application/json"},
      {"Authorization", "key=#{server_key()}"}
    ]
  end

  def server_key do
    Application.get_env(:fcmex, :server_key) || retrieve_on_run_time("FCM_SERVER_KEY") ||
      raise "FCM Server key is not found on your environment variables"
  end

  def retrieve_on_run_time(key) do
    System.get_env(key)
  end

  def httpoison_options() do
    Application.get_env(:fcmex, :httpoison_options, [])
  end

  def json_library do
    Application.get_env(:fcmex, :json_library, Poison)
  end
end
