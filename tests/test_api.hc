import "../src/json"

// --- Pipe navigation ---

test "pipe at chain" {
  let input = "\{\"database\": \{\"host\": \"localhost\", \"port\": 5432\}\}"
  let doc = parse_json(input) |> json_ok
  let host = doc |> at("database") |> at("host") |> as_str
  assert(host == Some("localhost"))
}

test "pipe at int value" {
  let input = "\{\"database\": \{\"host\": \"localhost\", \"port\": 5432\}\}"
  let doc = parse_json(input) |> json_ok
  let port = doc |> at("database") |> at("port") |> as_int
  assert(port == Some(5432))
}

test "pipe with defaults" {
  let input = "\{\"name\": \"myapp\", \"port\": 8080\}"
  let doc = parse_json(input) |> json_ok
  let name = str_or(doc |> at("name"), "unknown")
  assert(name == "myapp")
  let port = int_or(doc |> at("port"), 3000)
  assert(port == 8080)
  let missing = str_or(doc |> at("missing"), "fallback")
  assert(missing == "fallback")
  let missing_int = int_or(doc |> at("missing"), 42)
  assert(missing_int == 42)
}

test "pipe nth on array" {
  let input = "[\"apple\", \"banana\", \"cherry\"]"
  let doc = parse_json(input) |> json_ok
  let first = doc |> nth(0) |> as_str
  assert(first == Some("apple"))
  let third = doc |> nth(2) |> as_str
  assert(third == Some("cherry"))
  let oob = doc |> nth(5) |> as_str
  assert(oob == None)
}

test "pipe nested array in object" {
  let input = "\{\"fruits\": [\"apple\", \"banana\"]\}"
  let doc = parse_json(input) |> json_ok
  let fruits = doc |> at("fruits")
  let first = fruits |> nth(0) |> as_str
  assert(first == Some("apple"))
  let second = fruits |> nth(1) |> as_str
  assert(second == Some("banana"))
}

test "pipe as_bool" {
  let input = "\{\"active\": true, \"debug\": false\}"
  let doc = parse_json(input) |> json_ok
  let active = doc |> at("active") |> as_bool
  assert(active == Some(true))
  let debug = doc |> at("debug") |> as_bool
  assert(debug == Some(false))
}

test "pipe as_num" {
  let input = "\{\"ratio\": 3.14\}"
  let doc = parse_json(input) |> json_ok
  let r = doc |> at("ratio") |> as_num
  assert(is_some(r))
}

// --- Inspection ---

test "pipe has_key" {
  let input = "\{\"name\": \"test\", \"port\": 80\}"
  let doc = parse_json(input) |> json_ok
  assert(has_key(doc, "name") == true)
  assert(has_key(doc, "missing") == false)
}

test "pipe keys" {
  let input = "\{\"name\": \"test\", \"port\": 80\}"
  let doc = parse_json(input) |> json_ok
  let ks = keys(doc)
  assert(length(ks) == 2)
  let none_keys = keys(doc |> at("nonexistent"))
  assert(length(none_keys) == 0)
}

test "pipe json_length on array" {
  let input = "[1, 2, 3]"
  let doc = parse_json(input) |> json_ok
  assert(json_length(doc) == 3)
}

test "pipe json_length on object" {
  let input = "\{\"a\": 1, \"b\": 2\}"
  let doc = parse_json(input) |> json_ok
  assert(json_length(doc) == 2)
}

// --- Edge cases ---

test "pipe missing key returns None" {
  let input = "\{\"name\": \"test\"\}"
  let doc = parse_json(input) |> json_ok
  let deep = doc |> at("missing") |> at("deep") |> as_str
  assert(deep == None)
}

test "pipe error result" {
  let doc = parse_json("not json") |> json_ok
  let val = doc |> at("anything") |> as_str
  assert(val == None)
}

test "pipe bool_or default" {
  let input = "\{\"flag\": true\}"
  let doc = parse_json(input) |> json_ok
  let flag = bool_or(doc |> at("flag"), false)
  assert(flag == true)
  let missing = bool_or(doc |> at("missing"), false)
  assert(missing == false)
}
