# Fcmex

[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/shufo/fcmex/CI)](https://github.com/shufo/fcmex/actions?query=workflow%3ACI)
[![Hex.pm](https://img.shields.io/hexpm/v/fcmex.svg)](https://hex.pm/packages/fcmex)
[![Hex Docs](https://img.shields.io/badge/hex-docs-9768d1.svg)](https://hexdocs.pm/fcmex)
[![Coverage Status](https://coveralls.io/repos/github/shufo/fcmex/badge.svg?branch=master)](https://coveralls.io/github/shufo/fcmex?branch=master)

A Firebase Cloud Message client for Elixir

## Installation

Add to dependencies

```elixir
def deps do
  [{:fcmex, "~> 0.5.0"}]
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

* Send notification message to a device

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

* Send messsage to the topic

```elixir
{:ok, body} = Fcmex.push("/topics/topic_name",
  notification: %{
    title: "foo",
    body: "bar",
    click_action: "open_foo",
    icon: "new",
  }
)
```

* Send data message to a device. Difference between notification message and data message is decribed in [here](https://firebase.google.com/docs/cloud-messaging/concept-options#notifications_and_data_messages).

```elixir
{:ok, body} = Fcmex.push("user_token",
  data: %{
    nick: "Mario",
    body: "great match!",
    room: "PortugalVSDenmark",
  }
)
```

* You can use notification, and data as custom key-value store

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

* Send message to multiple devices

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

If one of request goes something wrong (e.g. timeout, server error), then fcmex returns results with `:error` keyword.

```elixir
[ok: result, error: result2, ...]
```

* Topic subscription

```elixir
# create a subscription
{:ok, result} = Fcmex.Subscription.subscribe("topic_name", "fcm_token")

# get subscription information related with specified token
{:ok, result} = Fcmex.Subscription.get("fcm_token")
iex> result
 %{
   "application" => "application_name",
   "applicationVersion" => "3.6.1",
   "authorizedEntity" => "1234567890",
   "platform" => "IOS",
   "rel" => %{"topics" => %{"test_topic" => %{"addDate" => "2018-05-03"}}},
   "scope" => "*"
 }}

# create multiple subscriptions
{:ok, result} = Fcmex.Subscription.subscribe("topic_name", ["fcm_token", "fcm_token2"])

# unsubscribe a topic
{:ok, result} = Fcmex.Subscription.unsubscribe("topic_name", "fcm_token")

# batch unsubscribe from a topic
{:ok, result} = Fcmex.Subscription.unsubscribe("topic_name", ["fcm_token", "fcm_token2"])
```

* Check if token is unregistered or not

```elixir
iex> Fcmex.unregistered?(token)
true

iex> tokens = ["token1", "token2", ...]
iex> Fcmex.filter_unregistered_tokens(tokens)
["token1"]
```

### Options

You can use these options as well.

* `priority`: `default: "high"`
* `collapse_key`: `default: nil`
* `time_to_live`: `default: nil`
* `content_available`: `default: nil`

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
  time_to_live: 1000,
  content_available: true
)
```

A more detail of parameters are available on [Firebase doc page](https://firebase.google.com/docs/cloud-messaging/concept-options).

### Configuration

You can set httpoison option as below.

```elixir
config :fcmex,
  fcm_server_key: {:system, "FCM_SERVER_KEY"} || System.get_env("FCM_SERVER_KEY"),
  httpoison_options: [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]
```

## Testing

If you start contributing and you want to run mix test, first you need to export FCM_SERVER_KEY environment variable in the same shell as the one you will be running mix test in.

```bash
export FCM_SERVER_KEY="yourkey"
mix test
```

## Contributing

1.  Fork it
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create new Pull Request

## Contributors

<!-- readme: collaborators,contributors -start -->
<table>
<tr>
    <td align="center">
        <a href="https://github.com/shufo">
            <img src="https://avatars.githubusercontent.com/u/1641039?v=4" width="100;" alt="shufo"/>
            <br />
            <sub><b>Shuhei Hayashibara</b></sub>
        </a>
    </td>
    <td align="center">
        <a href="https://github.com/nukosuke">
            <img src="https://avatars.githubusercontent.com/u/17716649?v=4" width="100;" alt="nukosuke"/>
            <br />
            <sub><b>Nukosuke</b></sub>
        </a>
    </td>
    <td align="center">
        <a href="https://github.com/nietaki">
            <img src="https://avatars.githubusercontent.com/u/140347?v=4" width="100;" alt="nietaki"/>
            <br />
            <sub><b>Jacek Królikowski</b></sub>
        </a>
    </td>
    <td align="center">
        <a href="https://github.com/qgadrian">
            <img src="https://avatars.githubusercontent.com/u/489004?v=4" width="100;" alt="qgadrian"/>
            <br />
            <sub><b>Adrián Quintás</b></sub>
        </a>
    </td>
    <td align="center">
        <a href="https://github.com/Fabi755">
            <img src="https://avatars.githubusercontent.com/u/4510679?v=4" width="100;" alt="Fabi755"/>
            <br />
            <sub><b>Fabian Keunecke</b></sub>
        </a>
    </td>
    <td align="center">
        <a href="https://github.com/mbramson">
            <img src="https://avatars.githubusercontent.com/u/6462927?v=4" width="100;" alt="mbramson"/>
            <br />
            <sub><b>Mathew Bramson</b></sub>
        </a>
    </td></tr>
</table>
<!-- readme: collaborators,contributors -end -->

## License

MIT
