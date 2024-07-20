import chatter_api
import gleam/list
import gleam/option.{Some}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn get_content_type_valid_test() {
  [
    "/some/dir/file.js", "file.css", "file.html", "file.png", "file.jpeg",
    "file.jpg", "file.svg", "/some/dir/favicon.ico",
  ]
  |> list.each(fn(file) {
    file
    |> chatter_api.get_content_type
    |> should.be_some
  })

  "/some/dir/file.txt"
  |> chatter_api.get_content_type
  |> should.equal(Some("text/plain"))
}

pub fn get_content_type_invalid_test() {
  ["/test/file/notpossible", "/test//", "/test", ""]
  |> list.each(fn(file) {
    file
    |> chatter_api.get_content_type
    |> should.be_none
  })

  "/test/file.js/notpossible"
  |> chatter_api.get_content_type
  |> should.equal(Some("text/plain"))
}
