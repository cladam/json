// examples/http_json.hc — Using JSON with the HTTP library
//
// Shows the two core patterns:
//   1. GET a JSON response and navigate it with the pipe API
//   2. Build a JSON body with Json values and POST it
//
// Requires the hica http library — add to hica.hml:
//   @koka {
//       include: "./lib/http/src"
//       flags: "--cclib=curl"
//   }

extern import "http"
import "../src/json"

fun main() {
  // ----------------------------------------------------------------
  // Pattern 1: GET → parse → navigate
  // ----------------------------------------------------------------
  println("--- GET and parse JSON ---")

  let resp = http_get("https://httpbin.org/json")

  match parse_json(resp.body) {
    Ok(doc) => {
      let slideshow = Some(doc) |> at("slideshow")
      let title = str_or(slideshow |> at("title"), "<no title>")
      let author = str_or(slideshow |> at("author"), "<no author>")
      println("Title:  " + title)
      println("Author: " + author)
      println("Slides: " + show(json_length(slideshow |> at("slides"))))
    },
    Err(e) => println("Parse error: " + e)
  }

  // ----------------------------------------------------------------
  // Pattern 2: Build JSON → emit → POST
  // ----------------------------------------------------------------
  println("")
  println("--- Build JSON body and POST ---")

  let payload = JObject([
    ("name",    JString("Alice")),
    ("age",     JNumber(30.0)),
    ("active",  JBool(true)),
    ("tags",    JArray([JString("admin"), JString("user")]))
  ])

  let body = json_emit(payload)
  println("Sending: " + body)

  let post_resp = http_post("https://httpbin.org/post", body, content_type="application/json")
  println("Status: " + show(post_resp.status))

  match parse_json(post_resp.body) {
    Ok(echo) => {
      // httpbin echoes the posted JSON under "json"
      let name = Some(echo) |> at("json") |> at("name") |> as_str
      match name {
        Some(n) => println("Server echoed name: " + n),
        None => println("no name in echo")
      }
    },
    Err(e) => println("Parse error: " + e)
  }
}
