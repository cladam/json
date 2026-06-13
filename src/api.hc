// api.hc — JSON accessors
import "./json_types"

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

pub fun json_is_null(j: Json) : bool => match j {
  JNull => true,
  _ => false
}
