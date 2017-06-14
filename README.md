# Fcmex

[![Build Status](https://travis-ci.org/shufo/fcmex.svg?branch=master)](https://travis-ci.org/shufo/fcmex)
[![Hex.pm](https://img.shields.io/hexpm/v/fcmex.svg)](https://hex.pm/packages/fcmex)
[![Hex Docs](https://img.shields.io/badge/hex-docs-9768d1.svg)](https://hexdocs.pm/fcmex)

A Firebase Cloud Message client for Elixir

## Installation

Add to dependencies

```elixir
def deps do
  [{:fcmex, "~> 0.1.0"}]
end
```

```bash
mix deps.get
```

## Usage

Fcmex by default reading FCM server key from your environment variable `FCM_SERVER_KEY` on runtime.

If `FCM_SERVER_KEY` is not found in your environment, it fallbacks to search following line.

```elixir
config :fcmex,
  server_key: "a_example_key"
```


- Send notification message to a device

```elixir
{:ok, body} = Fcmex.push("user_token",
  notification: %{
    title: "foo",
    body: "bar",
    click_action: "open_foo",
    icon: "new",
  }
)
```

- Send messsage to the topic

```elixir
{:ok, body} = Fcmex.push("/topic_name",
  notification: %{
    title: "foo",
    body: "bar",
    click_action: "open_foo",
    icon: "new",
  }
)
```

- Send data message to a device. Difference between notification message and data message is decribed in [here](https://developers.google.com/cloud-messaging/concept-options#notifications_and_data_messages).

```elixir
{:ok, body} = Fcmex.push("user_token",
  data: %{
    nick: "Mario",
    body: "great match!",
    room: "PortugalVSDenmark",
  }
)
```

- You can use notification, and data as custom key-value store

```elixir
{:ok, body} = Fcmex.push("user_token",
  notification: %{
    title: "foo",
    body: "bar",
    click_action: "open_foo",
    icon: "new",
  },
  data: %{
    nick: "Mario",
    body: "great match!",
    room: "PortugalVSDenmark",
  }
)
```

- Send message to multiple devices

```elixir
[ok: body] = Fcmex.push(["user_token", "user_token_2"],
  notification: %{
    title: "foo",
    body: "bar",
    click_action: "open_foo",
    icon: "new",
  }
)
```

As the FCM limitation of multiple send at once is up to 1000, Fcmex chunks tokens to list of 1000 tokens.

If specified tokens is over than 1000 tokens, then response is returned by keyword list chunked by every 1000 requests. (order is not guaranteed)

```elixir
[ok: result, ok: result2, ...]
```

If one of request goes something wrong (e.g. timeout, server error),  then fcmex returns results with `:error` keyword.

```elixir
[ok: result, error: result2, ...]
```

### Options

You can use these options as well.

- `priority`: `default: "high"`
- `collapse_key`: `default: nil`
- `time_to_live`: `default: nil`

```elixir
Fcmex.push(["user_token", "user_token_2"],
  notification: %{
    title: "foo",
    body: "bar",
    click_action: "open_foo",
    icon: "new",
  },
  priority: "normal",
  collapse_key: "data",
  time_to_live: 1000
)
```

A more detail of parameters are available on [Firebase doc page](https://firebase.google.com/docs/cloud-messaging/concept-options).
