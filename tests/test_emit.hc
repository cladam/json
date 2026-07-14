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

test "string escapes newline" {
  let j = JString("line1\nline2")
  assert(json_emit(j) == "\"line1\\nline2\"")
}

test "string escapes tab" {
  let j = JString("col1\tcol2")
  assert(json_emit(j) == "\"col1\\tcol2\"")
}

test "string escapes carriage return" {
  let j = JString("a\rb")
  assert(json_emit(j) == "\"a\\rb\"")
}

test "JInt serializes without decimal" {
  assert(json_emit(JInt(7)) == "7")
  assert(json_emit(JInt(0)) == "0")
  assert(json_emit(JInt(-42)) == "-42")
}

test "array serializes correctly" {
  let j = JArray([JNumber(1.0), JString("a"), JNull])
  assert(json_emit(j) == "[1.0, \"a\", null]")
}

test "array with JInt serializes correctly" {
  let j = JArray([JInt(1), JString("a"), JNull])
  assert(json_emit(j) == "[1, \"a\", null]")
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

test "object key with special chars escaped" {
  let j = JObject([("ke\ny", JString("v"))])
  assert(json_emit(j) == "\{\"ke\\ny\": \"v\"\}")
}

// --- Number formatting (shortest round-trip) ---

test "decimal number emits without binary noise" {
  assert(json_emit(JNumber(9.99)) == "9.99")
}

test "whole number keeps a .0 suffix" {
  assert(json_emit(JNumber(1.0)) == "1.0")
  assert(json_emit(JNumber(100.0)) == "100.0")
  assert(json_emit(JNumber(1000000.0)) == "1000000.0")
}

test "negative and rounding-carry values format cleanly" {
  assert(json_emit(JNumber(0.0 - 7.5)) == "-7.5")
  assert(json_emit(JNumber(9.999)) == "9.999")
  assert(json_emit(JNumber(2.675)) == "2.675")
}

test "zero formats as 0.0" {
  assert(json_emit(JNumber(0.0)) == "0.0")
}


