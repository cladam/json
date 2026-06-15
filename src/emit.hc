// emit.hc — JSON serialization
import "./json_types"
import "std/string"

pub fun hex_digit(n: int) : string =>
  if n == 0 { "0" } else if n == 1 { "1" } else if n == 2 { "2" }
  else if n == 3 { "3" } else if n == 4 { "4" } else if n == 5 { "5" }
  else if n == 6 { "6" } else if n == 7 { "7" } else if n == 8 { "8" }
  else if n == 9 { "9" } else if n == 10 { "a" } else if n == 11 { "b" }
  else if n == 12 { "c" } else if n == 13 { "d" } else if n == 14 { "e" }
  else { "f" }

pub fun to_hex4(n: int) : string =>
  hex_digit((n / 4096) % 16) + hex_digit((n / 256) % 16) +
  hex_digit((n / 16) % 16) + hex_digit(n % 16)

// Escape a single character per the JSON spec (RFC 8259).
// Named escapes for the 7 control characters JSON requires,
// \uXXXX for all other control characters (U+0000–U+001F).
pub fun escape_char(c: char) : string {
  let n = ord(c)
  if n == 34 { "\\\"" }
  else if n == 92 { "\\\\" }
  else if n == 8  { "\\b" }
  else if n == 9  { "\\t" }
  else if n == 10 { "\\n" }
  else if n == 12 { "\\f" }
  else if n == 13 { "\\r" }
  else if n < 32  { "\\u" + to_hex4(n) }
  else { char_to_string(c) }
}

pub fun escape_string(s: string) : string =>
  join(map(chars(s), escape_char), "")

pub fun json_emit(j: Json) : string =>
  match j {
    JNull           => "null",
    JBool(b)        => if b { "true" } else { "false" },
    JNumber(n)      => show_float(n),
    JString(s)      => "\"" + escape_string(s) + "\"",
    JArray(items)   => "[" + join(map(items, json_emit), ", ") + "]",
    JObject(fields) => "\{" + join(map(fields, (f) => "\"" + escape_string(f.0) + "\": " + json_emit(f.1)), ", ") + "\}"
  }
