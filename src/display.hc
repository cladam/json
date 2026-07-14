// display.hc — JSON pretty-printing
import "./json_types"
import "./emit"
import "std/string"

// ============================================================
// Compact display (type name only)
// ============================================================

pub fun json_show(j: Json) : string => match j {
  JNull => "null",
  JBool(b) => if b { "true" } else { "false" },
  JNumber(n) => json_number(n),
  JString(s) => "\"" + s + "\"",
  JArray(items) => "[array:" + show(length(items)) + "]",
  JObject(fields) => "[object:" + show(length(fields)) + "]"
}

// ============================================================
// Pretty-printing
// ============================================================

pub fun make_indent(n: int) : string =>
  if n <= 0 { "" } else { "  " + make_indent(n - 1) }

pub fun json_pretty(j: Json, indent: int) : string {
  let pad = make_indent(indent)
  match j {
    JObject(fields) => {
      let inner = join(map(fields, (f) => {
        make_indent(indent + 1) + "\"" + f.0 + "\": " + json_pretty(f.1, indent + 1)
      }), ",\n")
      "\{" + "\n" + inner + "\n" + pad + "\}"
    },
    JArray(items) => {
      let inner = join(map(items, (i) => {
        make_indent(indent + 1) + json_pretty(i, indent + 1)
      }), ",\n")
      "[\n" + inner + "\n" + pad + "]"
    },
    _ => pad + json_show(j)
  }
}
