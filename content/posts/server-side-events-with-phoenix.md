+++

title = "Server-Side Events (SSE) with Phoenix/Elixir"
description = "Using Phoenix to Send Server-Side Events (SSE)"
date = "2024-08-29"
draft = false

[taxonomies]
tags = ["elixir", "sse", "phoenix"]
categories = ["Phoenix"]


[extra]
lang = "en"
toc = true

+++

## Understanding Server-Sent Events

Server-Sent Events (SSE) is a powerful technology that allows servers to push data to web clients over HTTP connections. It provides a way for servers to send real-time updates to clients without the need for long-polling or WebSockets. This makes SSE an excellent choice for scenarios where you need one-way communication from the server to the client, such as live updates, notifications, or streaming data.

While Phoenix has traditionally leaned towards WebSockets for real-time, bidirectional communication, SSE offers a simpler, unidirectional approach that's particularly well-suited for certain use cases. In this post, we'll explore how to implement SSE using [Plug](https://hexdocs.pm/plug/readme.html) in Phoenix, with the help of `send_chunked/2`, `chunk/2`, and `EventSource`.


## Setting Up the Controller

First, we need to set up a controller action that will handle our SSE connection:

```elixir
def sse(conn, _params) do
  conn
  |> put_resp_header("cache-control", "no-cache")
  |> put_resp_content_type("text/event-stream")
  |> send_chunked(200)
end
```

Let's examine this code:

- We set the response content type to `"text/event-stream"`, which is crucial for SSE.
- We use `send_chunked(200)` to initiate a chunked response with a 200 status code.

## Using `send_chunked`

The `send_chunked/2` function is key to implementing SSE in Plug. It does two important things:

1. It sends the HTTP headers to the client, indicating that the response will be sent in chunks.
2. It switches the connection to chunked mode, allowing us to send data in multiple chunks over time.

## Sending Events with `chunk`

Once we've initiated a chunked response, we can use the `chunk/2` function to send data to the client:

```elixir
defp send_events(conn) do
  Enum.reduce_while(mock_llm_response(), conn, fn chunk, conn ->
    case chunk(conn, chunk) do
      {:ok, conn} ->
        Process.sleep(100)
        {:cont, conn}
      {:error, :closed} ->
        {:halt, conn}
    end
  end)
end
```

In this example:

- We iterate over a list of mock responses.
- For each chunk, we use `chunk(conn, chunk)` to send the data.
- We handle the result of `chunk/2`:
  - If it's successful (`{:ok, conn}`), we continue the loop.
  - If there's an error (e.g., the connection is closed), we halt the loop.
- In the last step conn is returned
## Formatting the Event Data

For SSE to work correctly, each event should be formatted as follows:

```
data: Your event data here\n\n
```

Note the double newline at the end - this is crucial for separating events. In our example, we format the data like this:

```elixir
|> Enum.map(&"data: #{&1}\n\n")
```

[Read more about the format here](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#examples)

## Client-Side: Using EventSource

On the client side, you can use the EventSource API to receive these server-sent events:

```javascript
const eventSource = new EventSource("/sse");

eventSource.onmessage = (event) => {
  console.log("Received data:", event.data);
};
```

The EventSource API automatically handles reconnection and parsing of the event stream, making it easy to work with SSE on the client side.

## MIME Support

When implementing SSE in Phoenix, you might encounter a Phoenix.NotAcceptableError related to MIME types. This error occurs when Phoenix doesn't recognize the text/event-stream MIME type. This is because Phoenix only accepts certain headers that are controlled by plug :accepts, [].

The fix is straightforward. Add the following to your configuration:

```elixir
# In config/config.exs
config :mime, :types, %{
  "text/event-stream" => ["sse"]
}

# In your router.ex
plug :accepts, ["html", "sse"]
```

## Full Source Code 

- Copy the snippet and save into file.
- Run with `elixir file_name.exs` or `iex file_name.exs`
- Copy of code available at [Github Gist](https://gist.github.com/theshapguy/c0567433a862bb0d8dc727ca30606016)


```elixir
#!/usr/bin/env elixir
Mix.install(
  [
    {:phoenix_playground, "~> 0.1.5"},
    {:jason, "~> 1.3"}
  ],
  config: [
    mime: [
      types: %{
        "text/event-stream" => ["sse"]
      }
    ]
  ]
  # force: true
)

defmodule SSEController do
  use Phoenix.Controller, formats: [:html, :sse]
  use Phoenix.Component
  plug(:put_layout, false)
  plug(:put_view, __MODULE__)

  def index(conn, _params) do
    render(conn, :index)
  end

  def index(assigns) do
    ~H"""
    <div style="padding:16px;max-width:400px;margin:auto">
    <p style="font-family:sans-serif"><b>Hello Sever-Side Events (SSE)</b></p>
    <br/>

    <div id="response" style="font-family:sans-serif;"></div>
    </div>

    <script>
        const eventSource = new EventSource('/sse');
        const responseDiv = document.getElementById('response');

        eventSource.onmessage = function(event) {
          console.log(event.data);
          responseDiv.innerHTML = responseDiv.innerHTML + event.data;
        };

        eventSource.addEventListener('done', function(event) {
            console.log('Stream complete');
            eventSource.close();
        });

        eventSource.onerror = function(error) {
            console.error('EventSource failed:', error);
            eventSource.close();
        };
    </script>
    """
  end

  def sse(conn, _params) do
    conn
    |> put_resp_content_type("text/event-stream")
    |> put_resp_header("cache-control", "no-cache")
    |> send_chunked(200)
    |> send_events()
  end

  defp send_events(conn) do
    Enum.reduce_while(mock_llm_response(), conn, fn chunk, conn ->
      case Plug.Conn.chunk(conn, chunk) do
        {:ok, conn} ->
          # Mimicing for ChatGPT style response
          Process.sleep(100)
          {:cont, conn}

        {:error, :closed} ->
          {:halt, conn}
      end
    end)
  end

  defp mock_llm_response do
    ~s([{"model":"llama3.1","created_at":"2024-08-29T05:10:21.143675Z","response":"Here","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:21.198081Z","response":" is","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:21.252113Z","response":" a","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:21.306116Z","response":" two","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:21.360078Z","response":"-line","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:21.415174Z","response":" summary","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:21.468991Z","response":" about","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:21.523294Z","response":" the","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:21.577272Z","response":" planets","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:21.631504Z","response":":\\n\\n","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:21.686003Z","response":" Our","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:21.74176Z","response":" solar","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:21.797425Z","response":" system","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:21.85169Z","response":" consists","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:21.907339Z","response":" of","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:21.961274Z","response":" eight","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:22.016623Z","response":" planets","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:22.0705Z","response":",","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:22.124703Z","response":" each","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:22.178571Z","response":" with","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:22.232894Z","response":" its","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:22.286941Z","response":" own","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:22.341096Z","response":" unique","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:22.395072Z","response":" size","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:22.4492Z","response":",","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:22.503167Z","response":" composition","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:22.557346Z","response":",","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:22.611345Z","response":" and","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:22.6654Z","response":" features","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:22.720629Z","response":",","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:22.774724Z","response":" ranging","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:22.831603Z","response":" from","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:22.886015Z","response":" tiny","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:22.941614Z","response":" Mercury","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:22.99643Z","response":" to","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:23.050478Z","response":" massive","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:23.104922Z","response":" gas","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:23.159261Z","response":" giant","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:23.214676Z","response":" Jupiter","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:23.270369Z","response":".","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:23.32482Z","response":" The","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:23.379032Z","response":" planets","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:23.433923Z","response":" are","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:23.488128Z","response":" categorized","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:23.543358Z","response":" into","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:23.597931Z","response":" two","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:23.653839Z","response":" main","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:23.709756Z","response":" groups","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:23.764332Z","response":":","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:23.818894Z","response":" rocky","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:23.874536Z","response":" inner","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:23.93003Z","response":" planets","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:23.98419Z","response":" like","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:24.0399Z","response":" Earth","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:24.095414Z","response":" and","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:24.14959Z","response":" Mars","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:24.205239Z","response":",","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:24.259446Z","response":" and","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:24.313489Z","response":" g","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:24.367633Z","response":"ase","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:24.42172Z","response":"ous","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:24.476205Z","response":" outer","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:24.53165Z","response":" planets","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:24.585701Z","response":" like","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:24.639802Z","response":" Saturn","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:24.695259Z","response":" and","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:24.749622Z","response":" Uran","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:24.805156Z","response":"us","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:24.859499Z","response":".","done":false},
    {"model":"llama3.1","created_at":"2024-08-29T05:10:24.913578Z","response":"","done":true,"done_reason":"stop"}])
    |> Jason.decode!()
    # Making it working well for EventSource; \n \n line structure
    |> Enum.map(&Map.get(&1, "response"))
    |> Enum.map(&"data: #{&1}\n\n")
  end
end

defmodule SSERouter do
  use Phoenix.Router
  # import Phoenix.LiveView.Router

  pipeline :browser do
    plug(:accepts, ["html", "sse"])
    plug(:fetch_session)
    plug(:put_root_layout, html: {PhoenixPlayground.Layout, :root})
    plug(:put_secure_browser_headers)
  end

  scope "/" do
    pipe_through(:browser)

    get("/", SSEController, :index)
    get("/sse", SSEController, :sse)
    # Just to get rid of errors
    get("/favicon.ico", SSEController, :index)
  end
end

PhoenixPlayground.start(plug: SSERouter)
```





