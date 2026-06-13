type Json {
    Null,
    Bool(value: bool),
    Number(value: float),
    String(value: string),
    Array(value: list<Json>),
    Object(fields: list<(string, Json)>)
}

fun escape_string(s: string): string =>
  replace(replace(s, "\\", "\\\\"), "\"", "\\\"")

fun show_number(n: float) : string {
  let s = show(n)
  if contains(s, ".") || contains(s, "e") { s } else { s + ".0" }
}

fun serialize_json(j: Json) : string =>
  match j {
    Null           => "null",
    Bool(b)        => if b { "true" } else { "false" },
    Number(n)      => show_number(n),
    String(s)      => "\"" + escape_string(s) + "\"",
    Array(items)   => "[" + join(map(items, serialize_json), ", ") + "]",
    Object(fields) => "\{" + join(map(fields, (f) => "\"" + escape_string(f.0) + "\": " + serialize_json(f.1)), ", ") + "\}"
  }

// --- Tests ---

test "null serializes correctly" {
    assert(serialize_json(Null) == "null")
}

test "bool serializes correctly" {
    assert(serialize_json(Bool(true)) == "true")
    assert(serialize_json(Bool(false)) == "false")
}

test "string escapes quotes and backslashes" {
  let j = String("say \"hello\" \\n")
  assert(serialize_json(j) == "\"say \\\"hello\\\" \\\\n\"")
}

test "array serializes correctly" {
  let j = Array([Number(1.0), String("a"), Null])
  assert(serialize_json(j) == "[1.0, \"a\", null]")
}

test "object serializes correctly" {
  let j = Object([("name", String("Alice")), ("age", Number(30.0))])
  assert(serialize_json(j) == "\{\"name\": \"Alice\", \"age\": 30.0\}")
}

test "nested structure serializes correctly" {
  let inner = Object([("x", Number(1.0)), ("y", Bool(true))])
  let j     = Array([inner, Null, String("root")])
  assert(serialize_json(j) == "[\{\"x\": 1.0, \"y\": true\}, null, \"root\"]")
}