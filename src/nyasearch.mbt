pub fn search(text : String, pattern : String) -> String!Error {
  if pattern.is_empty() {
    raise EmptyPatternError("")
  } else if pattern.length() > text.length() {
    raise PatternTooLongError("")
  } else if text.is_empty() {
    return ""
  }
  ""
}