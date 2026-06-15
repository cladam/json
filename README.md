# json

A JSON parser and serializer library for [hica](https://github.com/cladam/hica). Parses any valid JSON and provides a pipe-friendly API for navigating and extracting values.

## Installation

Add as a git submodule to your hica project:

```sh
git submodule add https://github.com/cladam/json.git lib/json
```

Then import the library:

```rust
import "./lib/json/src/json"
```

## Supported JSON

- **Null**: `null`
- **Booleans**: `true`, `false`
- **Numbers**: integers, floats, negative, scientific notation (`1e10`, `-3.14`)
- **Strings**: double-quoted with escape sequences (`\"`, `\\`, `\n`, `\r`, `\t`, `\uXXXX`)
- **Arrays**: `[1, "two", true]`, nested, trailing whitespace
- **Objects**: `{"key": value}`, nested, any JSON value as field value
- **Whitespace**: ignored between tokens

## API

### Types

```rust
type Json {
  JNull,
  JBool(value: bool),
  JNumber(value: float),
  JString(value: string),
  JArray(value: list<Json>),
  JObject(fields: list<(string, Json)>)
}
```

### Parsing

```rust
parse_json(input: string) : result<Json, string>
```

### Pipe-friendly navigation

Chain operations with `|>` or `.` to navigate nested JSON:

```rust
let host = parse_json(input)
  |> json_ok
  |> at("database")
  |> at("host")
  |> as_str

// host : maybe<string>
```

Hica supports Uniform Function Call Syntax (UFCS), so you can also write:

```rust
let host = parse_json(input)
  .json_ok
  .at("database")
  .at("host")
  .as_str
```

| Function | Signature | Purpose |
|----------|-----------|---------|
| `json_ok` | `result<Json, string> -> maybe<Json>` | Convert parse result to maybe |
| `at` | `maybe<Json>, string -> maybe<Json>` | Navigate into an object field |
| `nth` | `maybe<Json>, int -> maybe<Json>` | Index into an array |
| `as_str` | `maybe<Json> -> maybe<string>` | Extract string value |
| `as_int` | `maybe<Json> -> maybe<int>` | Extract int value (truncates float) |
| `as_num` | `maybe<Json> -> maybe<float>` | Extract number as float |
| `as_bool` | `maybe<Json> -> maybe<bool>` | Extract bool value |
| `as_array` | `maybe<Json> -> maybe<list<Json>>` | Extract array items |
| `as_object` | `maybe<Json> -> maybe<list<(string, Json)>>` | Extract object fields |

### Defaults

```rust
let port = parse_json(input)
  |> json_ok
  |> at("server")
  |> at("port")
let p = int_or(port, 8080)
```

| Function | Signature |
|----------|-----------|
| `str_or` | `maybe<Json>, string -> string` |
| `int_or` | `maybe<Json>, int -> int` |
| `num_or` | `maybe<Json>, float -> float` |
| `bool_or` | `maybe<Json>, bool -> bool` |

### Inspection

| Function | Signature | Purpose |
|----------|-----------|---------|
| `has_key` | `maybe<Json>, string -> bool` | Check if object has field |
| `keys` | `maybe<Json> -> list<string>` | Get object field names |
| `json_length` | `maybe<Json> -> int` | Count array items or object fields |

### Direct accessors

For when you already have a `Json` value (not wrapped in `maybe`):

| Function | Signature |
|----------|-----------|
| `json_get` | `Json, string -> maybe<Json>` |
| `json_str` | `Json -> maybe<string>` |
| `json_int` | `Json -> maybe<int>` |
| `json_num` | `Json -> maybe<float>` |
| `json_bool` | `Json -> maybe<bool>` |
| `json_array` | `Json -> maybe<list<Json>>` |
| `json_object` | `Json -> maybe<list<(string, Json)>>` |
| `json_is_null` | `Json -> bool` |

### Display

```rust
json_show(j: Json) : string                  // compact one-line (type summary for containers)
json_pretty(j: Json, indent: int) : string   // indented multi-line output
```

### Serialization

Emit compact JSON from `Json` values:

```rust
json_emit(j: Json) : string   // compact single-line JSON
```

Example:

```rust
let data = JObject([("name", JString("myapp")), ("port", JNumber(8080.0))])
println(json_emit(data))
// {"name": "myapp", "port": 8080.0}

println(json_pretty(data, 0))
// {
//   "name": "myapp",
//   "port": 8080.0
// }
```

## Examples

See the [examples/](examples/) directory for runnable programs:

- [basic_parsing.hc](examples/basic_parsing.hc): Parse a JSON string and pretty-print it
- [pipe_navigation.hc](examples/pipe_navigation.hc): Navigate nested values, use defaults, inspect structure

Run an example:

```sh
hica run examples/basic_parsing.hc
```

## Project structure

```sh
src/
  json.hc          # Barrel module — import this
  json_types.hc    # Json type definition
  parser.hc        # Recursive descent JSON parser
  emit.hc          # JSON serialization (json_emit)
  display.hc       # json_show, json_pretty
  api.hc           # Accessors and pipe-friendly API
  main.hc          # Demo program
examples/
  basic_parsing.hc
  pipe_navigation.hc
tests/
  test_parser.hc
  test_emit.hc
  test_api.hc
```
