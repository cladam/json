// examples/basic_parsing.hc — Parse a JSON string and print it
import "../src/json"

fun main() {
  let input = "\{\"name\": \"my-project\", \"version\": 1, \"enabled\": true, \"tags\": [\"cli\", \"json\"]\}"

  match parse_json(input) {
    Ok(doc) => {
      println("Parsed successfully!\n")
      println(json_pretty(doc, 0))
    },
    Err(e) => println("Parse error: " + e)
  }
}
