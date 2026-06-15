// parser.hc — Recursive descent JSON parser
import "./json_types"

struct Cursor { s: string, pos: int }

pub fun make_cursor(s: string) : Cursor =>
  Cursor { s: s, pos: 0 }

pub fun peek(c: Cursor) : maybe<string> =>
  if c.pos < length(c.s) { Some(c.s[c.pos:c.pos+1]) } else { None }

pub fun advance(c: Cursor, n: int) : Cursor =>
  Cursor { s: c.s, pos: c.pos + n }

pub fun is_eof(c: Cursor) : bool =>
  c.pos >= length(c.s)

pub fun skip_ws(c: Cursor) : Cursor {
  var cur = c
  while !is_eof(cur) && contains(" \t\n\r", cur.s[cur.pos:cur.pos+1]) {
    cur = advance(cur, 1)
  }
  cur
}

pub fun parse_json(s: string) : result<Json, string> {
  let start = skip_ws(make_cursor(s))
  match parse_value(start) {
    Ok((j, rest)) => {
      let tail = skip_ws(rest)
      if is_eof(tail) { Ok(j) } else { Err("unexpected trailing content") }
    },
    Err(e) => Err(e)
  }
}

pub fun parse_value(c: Cursor) : result<(Json, Cursor), string> {
  let ws = skip_ws(c)
  match peek(ws) {
    Some("\"") =>
      parse_string_val(ws) |> map_result((pair) => match pair { (str, nc) => (JString(str), nc) }),
    Some("\{") =>
      parse_object(ws) |> map_result((pair) => match pair { (fields, nc) => (JObject(fields), nc) }),
    Some("[") =>
      parse_array(ws) |> map_result((pair) => match pair { (items, nc) => (JArray(items), nc) }),
    Some("t")  => parse_literal(ws, "true", JBool(true)),
    Some("f")  => parse_literal(ws, "false", JBool(false)),
    Some("n")  => parse_literal(ws, "null", JNull),
    Some(ch) if contains("0123456789-", ch) => parse_number(ws),
    None       => Err("unexpected end of input"),
    Some(ch)   => Err("unexpected character: " + ch)
  }
}

pub fun parse_literal(c: Cursor, lit: string, val: Json) : result<(Json, Cursor), string> {
  let end = c.pos + length(lit)
  if end > length(c.s) { Err("unexpected end of input") }
  else if c.s[c.pos:end] == lit { Ok((val, advance(c, length(lit)))) }
  else { Err("expected " + lit) }
}

pub fun parse_string_val(c: Cursor) : result<(string, Cursor), string> =>
  match peek(c) {
    Some("\"") => parse_string_inner(advance(c, 1), ""),
    _          => Err("expected '\"'")
  }

pub fun parse_escape(c: Cursor) : result<(string, Cursor), string> =>
  match peek(c) {
    Some("\"") => Ok(("\"", advance(c, 1))),
    Some("\\") => Ok(("\\", advance(c, 1))),
    Some("/")  => Ok(("/",  advance(c, 1))),
    Some("b")  => Ok(("\b", advance(c, 1))),
    Some("f")  => Ok(("\f", advance(c, 1))),
    Some("n")  => Ok(("\n", advance(c, 1))),
    Some("r")  => Ok(("\r", advance(c, 1))),
    Some("t")  => Ok(("\t", advance(c, 1))),
    Some(esc)  => Err("invalid escape: \\" + esc),
    None       => Err("unexpected end of input in escape")
  }

pub fun parse_string_inner(c: Cursor, acc: string) : result<(string, Cursor), string> =>
  match peek(c) {
    Some("\"") => Ok((acc, advance(c, 1))),
    Some("\\") =>
      match parse_escape(advance(c, 1)) {
        Ok((ch, nc)) => parse_string_inner(nc, acc + ch),
        Err(e)       => Err(e)
      },
    Some(ch)   => parse_string_inner(advance(c, 1), acc + ch),
    None       => Err("unexpected end of string")
  }

pub fun parse_number(c: Cursor) : result<(Json, Cursor), string> {
  let start = c.pos
  var cur = c
  if peek(cur) == Some("-") { cur = advance(cur, 1) }
  while !is_eof(cur) && contains("0123456789", cur.s[cur.pos:cur.pos+1]) {
    cur = advance(cur, 1)
  }
  if !is_eof(cur) && peek(cur) == Some(".") {
    cur = advance(cur, 1)
    while !is_eof(cur) && contains("0123456789", cur.s[cur.pos:cur.pos+1]) {
      cur = advance(cur, 1)
    }
  }
  if !is_eof(cur) && (peek(cur) == Some("e") || peek(cur) == Some("E")) {
    cur = advance(cur, 1)
    if !is_eof(cur) && (peek(cur) == Some("+") || peek(cur) == Some("-")) {
      cur = advance(cur, 1)
    }
    while !is_eof(cur) && contains("0123456789", cur.s[cur.pos:cur.pos+1]) {
      cur = advance(cur, 1)
    }
  }
  let num_str = cur.s[start:cur.pos]
  match parse_float(num_str) {
    Some(n) => Ok((JNumber(n), cur)),
    None    => Err("invalid number: " + num_str)
  }
}

pub fun parse_array(c: Cursor) : result<(list<Json>, Cursor), string> {
  match peek(c) {
    Some("[") => {
      match parse_array_items(skip_ws(advance(c, 1)), []) {
        Ok((items, nc)) => Ok((reverse(items), nc)),
        Err(e)          => Err(e)
      }
    },
    _ => Err("expected '['")
  }
}

pub fun parse_array_items(c: Cursor, acc: list<Json>) : result<(list<Json>, Cursor), string> {
  let ws = skip_ws(c)
  match peek(ws) {
    Some("]") => Ok((acc, advance(ws, 1))),
    _ => {
      match parse_value(ws) {
        Ok((item, nc)) => {
          let ws2 = skip_ws(nc)
          match peek(ws2) {
            Some(",") => parse_array_items(advance(ws2, 1), [item] + acc),
            Some("]") => Ok(([item] + acc, advance(ws2, 1))),
            _         => Err("expected ',' or ']' in array")
          }
        },
        Err(e) => Err(e)
      }
    }
  }
}

pub fun parse_object(c: Cursor) : result<(list<(string, Json)>, Cursor), string> {
  match peek(c) {
    Some("\{") => {
      match parse_object_fields(skip_ws(advance(c, 1)), []) {
        Ok((fields, nc)) => Ok((reverse(fields), nc)),
        Err(e)           => Err(e)
      }
    },
    _ => Err("expected '\{'")
  }
}

pub fun parse_object_fields(c: Cursor, acc: list<(string, Json)>) : result<(list<(string, Json)>, Cursor), string> {
  let ws = skip_ws(c)
  match peek(ws) {
    Some("\}") => Ok((acc, advance(ws, 1))),
    _ => {
      match parse_string_val(ws) {
        Ok((key, nc)) => {
          let ws1 = skip_ws(nc)
          match peek(ws1) {
            Some(":") => {
              match parse_value(advance(ws1, 1)) {
                Ok((val, nc2)) => {
                  let ws2 = skip_ws(nc2)
                  match peek(ws2) {
                    Some(",") => parse_object_fields(advance(ws2, 1), [(key, val)] + acc),
                    Some("\}") => Ok(([(key, val)] + acc, advance(ws2, 1))),
                    _         => Err("expected ',' or '\}' in object")
                  }
                },
                Err(e) => Err(e)
              }
            },
            _ => Err("expected ':' after key")
          }
        },
        Err(e) => Err(e)
      }
    }
  }
}