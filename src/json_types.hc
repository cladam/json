// json_types.hc — Core JSON types

pub type Json {
    JNull,
    JBool(value: bool),
    JNumber(value: float),
    JString(value: string),
    JArray(value: list<Json>),
    JObject(fields: list<(string, Json)>)
}