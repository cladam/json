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

// --- Number formatting -----------------------------------------------------
// JSON numbers are printed with json_number, which emits the SHORTEST decimal
// string that round-trips back to the same float64. This keeps 9.99 as "9.99"
// instead of the runtime's noisy "9.9900000000000002". Whole numbers keep a
// ".0" suffix so they stay valid JSON floats; very large or very small
// magnitudes fall back to the runtime's exponent form unchanged.

pub fun pow10f(k: int) : float => if k <= 0 { 1.0 } else { 10.0 * pow10f(k - 1) }

pub fun ipow10(k: int) : int => if k <= 0 { 1 } else { 10 * ipow10(k - 1) }

// Left-pad with zeros to at least k characters.
pub fun zpad(s: string, k: int) : string =>
  if str_length(s) >= k { s } else { zpad("0" + s, k) }

// Format n with exactly k fractional digits (rounded), building the decimal
// string by hand so the output is free of binary-representation noise.
pub fun fmt_fixed(n: float, k: int) : string {
  let neg    = n < 0.0
  let a      = if neg { 0.0 - n } else { n }
  let scaled = round(a * pow10f(k))
  let p      = ipow10(k)
  let ip     = scaled / p
  let fr     = scaled % p
  let sign   = if neg { "-" } else { "" }
  sign + show(ip) + "." + zpad(show(fr), k)
}

// Try increasing fractional precision until the string parses back to n.
pub fun find_shortest(n: float, k: int, fallback: string) : string =>
  if k > 15 { fallback }
  else {
    let cand = fmt_fixed(n, k)
    match parse_float(cand) {
      Some(v) => if v == n { cand } else { find_shortest(n, k + 1, fallback) },
      None    => find_shortest(n, k + 1, fallback)
    }
  }

pub fun json_number(n: float) : string {
  let s = show(n)
  if contains(s, "e") || contains(s, "E") { s }
  else if !contains(s, ".") { s + ".0" }
  else { find_shortest(n, 1, s) }
}

pub fun json_emit(j: Json) : string =>
    match j {
      JNull           => "null",
      JBool(b)        => if b { "true" } else { "false" },
      JNumber(n)      => json_number(n),
      JString(s)      => "\"" + escape_string(s) + "\"",
      JArray(items)   => "[" + join(map(items, json_emit), ", ") + "]",
      JObject(fields) => "\{" + join(map(fields, (f) => "\"" + escape_string(f.0) + "\": " + json_emit(f.1)), ", ") + "\}"
    }
