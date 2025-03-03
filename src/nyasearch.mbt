///|
/// Searches for a pattern within a text using various string matching
/// algorithms.
///
/// Parameters:
///
/// * `text` : The text to search in.
/// * `pattern` : The pattern to search for.
/// * `algorithm` (optional, labeled as `option`) : The search algorithm to use.
/// Available options are:
///  * `"auto"` (default): Automatically selects the most suitable algorithm
/// based on pattern characteristics
///  * `"kmp"`: Knuth-Morris-Pratt algorithm
///  * `"rabin_karp"`: Rabin-Karp algorithm
///  * `"boyer_moore"`: Boyer-Moore algorithm
/// * `start` (optional): The starting index in the text to begin the search
/// (inclusive). Defaults to 0.
/// * `end` (optional): The ending index in the text to end the search
/// (exclusive). Defaults to the length of the text.
///
/// Returns the index of the first occurrence of the pattern in the text within
/// the specified range, or -1 if the pattern is not found.
///
/// Throws:
///
/// * `EmptyPatternError` if the pattern is empty
/// * `PatternTooLongError` if the pattern is longer than the text
/// * `InvalidRangeError` if the search range is invalid (start > end, start < 0,
/// or end > text length)
/// * `OptionChooseError` if an invalid algorithm option is provided
///
/// Examples:
///
/// ```moonbit
/// ///|
/// /// basic
/// search!("hello world", "world") // content = 6, using auto method.
/// search!("hello world", "world", option="kmp") // content = 6, using kmp method.
///
/// ///|
/// /// range
/// search!("hello world", "o", start=0, end=5) // content = 4
/// ```
pub fn search(
  text : String,
  pattern : String,
  option~ : String = "auto",
  start~ : Int = 0,
  end~ : Int = text.length()
) -> Int!Error {
  if pattern.is_empty() {
    raise EmptyPatternError("Empty search pattern is not allowed")
  } else if pattern.length() > text.length() {
    raise PatternTooLongError("Search pattern cannot be longer than the text")
  } else if text.is_empty() {
    return -1
  } else if start > end || start < 0 || end > text.length() {
    raise InvalidRangeError(
      "Invalid search range: ensure start <= end and both are within text bounds",
    )
  }
  let subtext = text.substring(start~, end~)
  let idx = match option {
    "auto" => auto(subtext, pattern)
    "kmp" => kmp(subtext, pattern)
    "rabin_karp" => rabin_karp(subtext, pattern)
    "boyer_moore" => boyer_moore(subtext, pattern)
    _ =>
      raise OptionChooseError(
        "Invalid search algorithm option. Available options: 'auto', 'kmp', 'rabin_karp', 'boyer_moore'",
      )
  }
  if idx == -1 {
    -1
  } else {
    idx + start
  }
}

///|
test "search/basic" {
  inspect!(search!("hello world", "world"), content="6")
  inspect!(search!("hello world", "world", option="kmp"), content="6")
  inspect!(search!("hello world", "world", option="rabin_karp"), content="6")
  inspect!(search!("hello world", "world", option="boyer_moore"), content="6")
}

///|
test "search/range" {
  inspect!(search!("hello world", "o", start=0, end=5), content="4")
  inspect!(search!("hello world", "o", start=5, end=11), content="7")
  inspect!(search!("hello world", "l", start=3, end=5), content="3")
}

///|
test "panic search/invalid" {
  let _ = search!("hello", "")
  let _ = search!("hello", "world", option="invalid")
  let _ = search!("hello", "h", start=5, end=3)
  let _ = search!("hello", "h", start=-1, end=5)
  let _ = search!("hello", "h", start=0, end=6)

}

///|
test "search/basic" {
  inspect!(search!("hello world", "world"), content="6")
  inspect!(search!("AABAACAADAABAAABAA", "AABA"), content="0")
  inspect!(search!("THIS IS A TEST TEXT", "TEST"), content="10")
}

///|
test "search/pattern_not_found" {
  inspect!(search!("hello world", "moon"), content="-1")
  inspect!(search!("AABAACAADAABAAABAA", "ZZZ"), content="-1")
}

///|
test "panic search/empty_pattern" {
  ignore(search!("hello world", ""))
}

///|
test "panic search/pattern_too_long" {
  ignore(search!("hello", "hello world"))
}

///|
test "panic search/invalid_range" {
  ignore(search!("hello world", "world", start=5, end=1))
  ignore(search!("hello world", "world", start=-1, end=5))
  ignore(search!("hello world", "world", start=0, end=12))
}