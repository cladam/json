import "../src/json"

test "null serializes correctly" {
  assert(json_emit(JNull) == "null")
}

test "bool serializes correctly" {
  assert(json_emit(JBool(true)) == "true")
  assert(json_emit(JBool(false)) == "false")
}

test "string escapes quotes and backslashes" {
  let j = JString("say \"hello\" \\n")
  assert(json_emit(j) == "\"say \\\"hello\\\" \\\\n\"")
}

test "array serializes correctly" {
  let j = JArray([JNumber(1.0), JString("a"), JNull])
  assert(json_emit(j) == "[1.0, \"a\", null]")
}

test "object serializes correctly" {
  let j = JObject([("name", JString("Alice")), ("age", JNumber(30.0))])
  assert(json_emit(j) == "\{\"name\": \"Alice\", \"age\": 30.0\}")
}

test "nested structure serializes correctly" {
  let inner = JObject([("x", JNumber(1.0)), ("y", JBool(true))])
  let j     = JArray([inner, JNull, JString("root")])
  assert(json_emit(j) == "[\{\"x\": 1.0, \"y\": true\}, null, \"root\"]")
}
