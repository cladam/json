// examples/pipe_navigation.hc — Navigate nested JSON with the pipe API
import "../src/json"

fun main() {
  let input = "\{\"database\": \{\"host\": \"localhost\", \"port\": 5432, \"replicas\": [\"db1\", \"db2\"]\}, \"app\": \{\"name\": \"myapp\", \"debug\": false\}\}"

  let doc = parse_json(input) |> json_ok

  // Navigate to nested values
  let host = doc |> at("database") |> at("host") |> as_str
  match host {
    Some(h) => println("Host: " + h),
    None => println("no host")
  }

  // Use defaults for missing or optional values
  let port = int_or(doc |> at("database") |> at("port"), 3306)
  println("Port: " + show(port))

  let timeout = int_or(doc |> at("database") |> at("timeout"), 30)
  println("Timeout (default): " + show(timeout))

  // Index into arrays
  let first_replica = doc |> at("database") |> at("replicas") |> nth(0) |> as_str
  match first_replica {
    Some(r) => println("First replica: " + r),
    None => println("no replicas")
  }

  // Inspect structure
  let db = doc |> at("database")
  println("Has port? " + show(has_key(db, "port")))
  println("Replica count: " + show(json_length(db |> at("replicas"))))
}
