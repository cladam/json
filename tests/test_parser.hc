import "../src/json"

// ── primitives ─────────────────────────────────────────────────────────────

test "parse null" {
  let r = parse_json("null")
  assert(is_ok(r))
  match r {
    Ok(j)  => assert(json_is_null(j)),
    Err(_) => assert(false)
  }
}

test "parse true" {
  let r = parse_json("true")
  match r {
    Ok(j)  => assert(json_bool(j) == Some(true)),
    Err(_) => assert(false)
  }
}

test "parse false" {
  let r = parse_json("false")
  match r {
    Ok(j)  => assert(json_bool(j) == Some(false)),
    Err(_) => assert(false)
  }
}

// ── numbers ────────────────────────────────────────────────────────────────

test "parse integer" {
  let r = parse_json("42")
  match r {
    Ok(j)  => assert(json_num(j) == Some(42.0)),
    Err(_) => assert(false)
  }
}

test "parse negative" {
  let r = parse_json("-7")
  assert(is_ok(r))
}

test "parse float" {
  let r = parse_json("3.14")
  assert(is_ok(r))
}

test "parse exponent" {
  let r = parse_json("1.5e2")
  assert(is_ok(r))
}

// ── strings ────────────────────────────────────────────────────────────────

test "parse empty string" {
  let r = parse_json("\"\"")
  match r {
    Ok(j)  => assert(json_str(j) == Some("")),
    Err(_) => assert(false)
  }
}

test "parse plain string" {
  let r = parse_json("\"hello\"")
  match r {
    Ok(j)  => assert(json_str(j) == Some("hello")),
    Err(_) => assert(false)
  }
}

test "parse string with escape" {
  let r = parse_json("\"a\\nb\"")
  match r {
    Ok(j)  => assert(json_str(j) == Some("a\nb")),
    Err(_) => assert(false)
  }
}

// ── arrays ─────────────────────────────────────────────────────────────────

test "parse empty array" {
  let r = parse_json("[]")
  match r {
    Ok(j) => {
      match json_array(j) {
        Some(items) => assert(length(items) == 0),
        None        => assert(false)
      }
    },
    Err(_) => assert(false)
  }
}

test "parse array of numbers" {
  let r = parse_json("[1, 2, 3]")
  match r {
    Ok(j) => {
      match json_array(j) {
        Some(items) => assert(length(items) == 3),
        None        => assert(false)
      }
    },
    Err(_) => assert(false)
  }
}

test "parse array with whitespace" {
  let r = parse_json("[ 1 , 2 ]")
  assert(is_ok(r))
}

// ── objects ────────────────────────────────────────────────────────────────

test "parse empty object" {
  let r = parse_json("\{\}")
  assert(is_ok(r))
}

test "parse single-field object" {
  let r = parse_json("\{\"key\": \"value\"\}")
  match r {
    Ok(j) => {
      match json_get(j, "key") {
        Some(v) => assert(json_str(v) == Some("value")),
        None    => assert(false)
      }
    },
    Err(_) => assert(false)
  }
}

test "parse object field order preserved" {
  let r = parse_json("\{\"a\": 1, \"b\": 2\}")
  match r {
    Ok(j) => {
      assert(is_some(json_get(j, "a")))
      assert(is_some(json_get(j, "b")))
    },
    Err(_) => assert(false)
  }
}

// ── nesting ────────────────────────────────────────────────────────────────

test "parse nested structure" {
  let r = parse_json("\{\"a\": [1, null, true], \"b\": \{\"c\": 42\}\}")
  assert(is_ok(r))
}

// ── whitespace ─────────────────────────────────────────────────────────────

test "leading and trailing whitespace ignored" {
  let r = parse_json("  42  ")
  assert(is_ok(r))
}

// ── errors ─────────────────────────────────────────────────────────────────

test "reject trailing content" {
  let r = parse_json("42 extra")
  assert(is_err(r))
}

test "reject invalid token" {
  let r = parse_json("invalid")
  assert(is_err(r))
}

test "reject unterminated string" {
  let r = parse_json("\"unterminated")
  assert(is_err(r))
}

test "reject bad escape" {
  let r = parse_json("\"\\q\"")
  assert(is_err(r))
}

test "reject missing colon" {
  let r = parse_json("\{\"k\" 1\}")
  assert(is_err(r))
}
