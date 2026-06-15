// emit.hc — JSON serialization
import "./json_types"
import "std/string"

pub fun escape_string(s: string) : string =>
  replace(replace(s, "\\", "\\\\"), "\"", "\\\"")

pub fun json_emit(j: Json) : string =>
  match j {
    JNull           => "null",
    JBool(b)        => if b { "true" } else { "false" },
    JNumber(n)      => show_float(n),
    JString(s)      => "\"" + escape_string(s) + "\"",
    JArray(items)   => "[" + join(map(items, json_emit), ", ") + "]",
    JObject(fields) => "\{" + join(map(fields, (f) => "\"" + escape_string(f.0) + "\": " + json_emit(f.1)), ", ") + "\}"
  }
