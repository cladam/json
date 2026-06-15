// api.hc — JSON accessors and pipe-friendly navigation
import "./json_types"

// ============================================================
// Direct accessors
// ============================================================

pub fun json_get(j: Json, key: string) : maybe<Json> => match j {
  JObject(fields) => fields
    |> find((f) => f.0 == key)
    |> map_maybe((f) => f.1),
  _ => None
}

pub fun json_str(j: Json) : maybe<string> => match j {
  JString(v) => Some(v),
  _ => None
}

pub fun json_int(j: Json) : maybe<int> => match j {
  JNumber(v) => Some(round(v)),
  _ => None
}

pub fun json_num(j: Json) : maybe<float> => match j {
  JNumber(v) => Some(v),
  _ => None
}

pub fun json_bool(j: Json) : maybe<bool> => match j {
  JBool(v) => Some(v),
  _ => None
}

pub fun json_array(j: Json) : maybe<list<Json>> => match j {
  JArray(v) => Some(v),
  _ => None
}

pub fun json_object(j: Json) : maybe<list<(string, Json)>> => match j {
  JObject(fields) => Some(fields),
  _ => None
}

pub fun json_is_null(j: Json) : bool => match j {
  JNull => true,
  _ => false
}

// ============================================================
// Pipe-friendly API
// ============================================================
// Usage: json_parse(input) |> json_ok |> at("db") |> at("host") |> as_str

pub fun json_ok(r: result<Json, string>) : maybe<Json> => match r {
  Ok(j) => Some(j),
  Err(_) => None
}

pub fun at(m: maybe<Json>, key: string) : maybe<Json> => match m {
  Some(j) => json_get(j, key),
  None => None
}

pub fun nth(m: maybe<Json>, index: int) : maybe<Json> => match m {
  Some(JArray(items)) => list_nth(items, index),
  _ => None
}

pub fun list_nth(xs: list<Json>, i: int) : maybe<Json> => match xs {
  [] => None,
  [x, ..rest] => if i == 0 { Some(x) } else { list_nth(rest, i - 1) }
}

pub fun as_str(m: maybe<Json>) : maybe<string> => match m {
  Some(j) => json_str(j),
  None => None
}

pub fun as_int(m: maybe<Json>) : maybe<int> => match m {
  Some(j) => json_int(j),
  None => None
}

pub fun as_num(m: maybe<Json>) : maybe<float> => match m {
  Some(j) => json_num(j),
  None => None
}

pub fun as_bool(m: maybe<Json>) : maybe<bool> => match m {
  Some(j) => json_bool(j),
  None => None
}

pub fun as_array(m: maybe<Json>) : maybe<list<Json>> => match m {
  Some(j) => json_array(j),
  None => None
}

pub fun as_object(m: maybe<Json>) : maybe<list<(string, Json)>> => match m {
  Some(j) => json_object(j),
  None => None
}

// ============================================================
// Defaults
// ============================================================

pub fun str_or(m: maybe<Json>, fallback: string) : string => match as_str(m) {
  Some(v) => v,
  None => fallback
}

pub fun int_or(m: maybe<Json>, fallback: int) : int => match as_int(m) {
  Some(v) => v,
  None => fallback
}

pub fun num_or(m: maybe<Json>, fallback: float) : float => match as_num(m) {
  Some(v) => v,
  None => fallback
}

pub fun bool_or(m: maybe<Json>, fallback: bool) : bool => match as_bool(m) {
  Some(v) => v,
  None => fallback
}

// ============================================================
// Inspection
// ============================================================

pub fun has_key(m: maybe<Json>, key: string) : bool => match m {
  Some(j) => is_some(json_get(j, key)),
  None => false
}

pub fun keys(m: maybe<Json>) : list<string> => match m {
  Some(JObject(fields)) => map(fields, (f) => f.0),
  _ => []
}

pub fun json_length(m: maybe<Json>) : int => match m {
  Some(JArray(items)) => length(items),
  Some(JObject(fields)) => length(fields),
  _ => 0
}
