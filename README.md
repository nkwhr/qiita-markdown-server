# Qiita Markdown Server

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/nkwhr/qiita-markdown-server)

A REST API Markdown Server powered by [Qiita::Markdown](https://github.com/increments/qiita-markdown)

## Description

Qiita Markdown Server provides API to render Markdown texts posted via HTTP and responds with rendered HTML elements.
APIs are (mostly) compatible with [GitHub Markdown API](https://developer.github.com/v3/markdown/).

## API Reference

### 1. POST /markdown

This API renders Markdown text in the `text` attribute. Request parameter must be a JSON object.

#### Parameters

Name        | Type    | Description
------------| ------- | -----------------------------
text        | string  | The Markdown text to render (**Required**)
options     | hash    | Context options (see [qiita-markdown#context](https://github.com/increments/qiita-markdown#context) for details)

#### Example

```
$ curl -X POST -H 'Content-Type: application/json' -d '
{
  "text": "Hello my twitter ID is @_nao8 :smile:",
  "options": {
    "asset_root": "https://assets-cdn.github.com/images/icons",
    "base_url": "https://twitter.com"
  }
}' http://localhost:8080/markdown
```

#### Response Header

```
HTTP/1.1 200 OK
Content-Type: text/html;charset=utf-8
Content-Length: 276
Access-Control-Allow-Origin: *
```

#### Response Body

```
<p>Hello my twitter ID is <a href="https://twitter.com/_nao8" class="user-mention" title="_nao8">@_nao8</a> <img class="emoji" title=":smile:" alt=":smile:" src="https://assets-cdn.github.com/images/icons/emoji/unicode/1f604.png" height="20" width="20" align="absmiddle"></p>
```

### 2. POST /markdown/raw

The raw API is for plaintext (`text/plain` or `text/x-markdown`) and renders whole content body.

#### Example
```
$ curl -X POST -H 'Content-Type: text/plain' -d '
# Task List
- [x] task1
- [ ] task2
' http://localhost:8080/markdown/raw
```

#### Response Header

```
HTTP/1.1 200 OK
Content-Type: text/html;charset=utf-8
Content-Length: 342
Access-Control-Allow-Origin: *
```

#### Response Body

```
<h1>
<span id="task-list" class="fragment"></span><a href="#task-list"><i class="fa fa-link"></i></a>Task List</h1>

<ul>
<li class="task-list-item">
<input type="checkbox" class="task-list-item-checkbox" checked disabled>task1</li>
<li class="task-list-item">
<input type="checkbox" class="task-list-item-checkbox" disabled>task2</li>
</ul>
```


## Installation and Usage

### 1. Clone the source
```
$ git clone https://github.com/nkwhr/qiita-markdown-server
```

### 2. Install dependencies
```
$ cd qiita-markdown-server
$ bundle install
```

### 3. Install Emoji (optional)

If you want to serve assets on a same server, you can install Emoji images with [gemoji](https://github.com/github/gemoji).
Run following Rake task to copy images into `public/images/emoji`.

```
$ bundle exec rake -f $(gem contents gemoji | grep 'emoji\.rake') emoji
```
Asset host can be set with environment variable `ASSET_ROOT`.


### 4. Set environment variables (optional)

```
export RACK_ENV=production
export WEB_CONCURRENCY=1                       # worker processes, default: 2
export ASSET_ROOT=http://localhost:8080/images # url for emoji images
export BASE_URL=https://twitter.com            # url for @username
```

You can also use [dotenv](https://github.com/bkeepers/dotenv) if you are going to run app with [foreman](https://github.com/ddollar/foreman).

### 5. Start Application

```
$ bundle exec rackup -s Rhebok -O ConfigFile=config/rhebok.rb -p 8080 config.ru
or
$ PORT=8080 foreman start
```

## Running with Docker

Latest Docker image is available at [nkwhr/qiita-markdown-server](https://registry.hub.docker.com/u/nkwhr/qiita-markdown-server/)

### Example

```
$ docker run \
    --rm \
    --env WEB_CONCURRENCY=$(nproc) \
    --env ASSET_ROOT=https://assets-cdn.github.com/images/icons \
    -p 8080:8080 \
    nkwhr/qiita-markdown-server
```

## See Also

- [Qiita::Markdown](https://github.com/increments/qiita-markdown)


## Author

[nkwhr](https://github.com/nkwhr)
