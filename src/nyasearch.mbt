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
/// // basic
/// assert_eq(search("hello world", "world"), 6) // using auto method.
/// assert_eq(search("hello world", "world", option="kmp"), 6) // using kmp method.
///
/// // range
/// assert_eq(search("hello world", "o", start=0, end=5), 4)
/// ```
pub fn search(
  text : String,
  pattern : String,
  option~ : String = "auto",
  start~ : Int = 0,
  end? : Int
) -> Int raise Error {
  let end = end.or(text.length())
  if pattern.is_empty() {
    raise EmptyPatternError("Empty search pattern is not allowed")
  } else if text.is_empty() {
    return -1
  } else if pattern.length() > text.length() {
    raise PatternTooLongError("Search pattern cannot be longer than the text")
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
  inspect(search("hello world", "world"), content="6")
  inspect(search("hello world", "world", option="kmp"), content="6")
  inspect(search("hello world", "world", option="rabin_karp"), content="6")
  inspect(search("hello world", "world", option="boyer_moore"), content="6")
}

///|
test "search/range" {
  inspect(search("hello world", "o", start=0, end=5), content="4")
  inspect(search("hello world", "o", start=5, end=11), content="7")
  inspect(search("hello world", "l", start=3, end=5), content="3")
}

///|
test "panic search/invalid" {
  let _ = search("hello", "")
  let _ = search("hello", "world", option="invalid")
  let _ = search("hello", "h", start=5, end=3)
  let _ = search("hello", "h", start=-1, end=5)
  let _ = search("hello", "h", start=0, end=6)

}

///|
test "search/basic" {
  inspect(search("hello world", "world"), content="6")
  inspect(search("AABAACAADAABAAABAA", "AABA"), content="0")
  inspect(search("THIS IS A TEST TEXT", "TEST"), content="10")
}

///|
test "search/pattern_not_found" {
  inspect(search("hello world", "moon"), content="-1")
  inspect(search("AABAACAADAABAAABAA", "ZZZ"), content="-1")
}

///|
test "panic search/empty_pattern" {
  ignore(search("hello world", ""))
}

///|
test "panic search/pattern_too_long" {
  ignore(search("hello", "hello world"))
}

///|
test "panic search/invalid_range" {
  ignore(search("hello world", "world", start=5, end=1))
  ignore(search("hello world", "world", start=-1, end=5))
  ignore(search("hello world", "world", start=0, end=12))
}

///|
/// Performs a fuzzy search for a pattern within a text, allowing for approximate
/// matches based on string similarity.
///
/// Parameters:
///
/// * `text` : The text to search in.
/// * `pattern` : The pattern to search for.
/// * `algorithm` : The fuzzy matching algorithm to use. Currently supports 
/// "levenshtein" and "jaro_winkler". Defaults to "levenshtein".
/// * `options` : Configuration options for the fuzzy search:
///  * `threshold` : Minimum similarity score (between 0 and 1) for a match to be
/// considered valid. Defaults to 0.7.
///  * `max_distance` : Maximum allowed edit distance between pattern and
/// potential matches. Defaults to 2.
///  * `case_sensitive` : Whether the search should be case-sensitive. Defaults
/// to false.
///  * `max_results` : Maximum number of matches to return. Defaults to 10.
/// * `start` : The starting index in the text to begin the search (inclusive).
/// Defaults to 0.
/// * `end` : The ending index in the text to end the search (exclusive).
/// Defaults to the length of the text.
///
/// Returns an array of `FuzzyMatch` objects, each containing:
///
/// * `position` : The starting position of the match in the text
/// * `score` : The similarity score of the match (higher is better)
/// * `length` : The length of the matched substring
///
/// Throws:
///
/// * `EmptyPatternError` if the search pattern is empty
/// * `InvalidRangeError` if the search range is invalid (start > end, start < 0,
/// or end > text length)
/// * `OptionChooseError` if an invalid algorithm option is provided
///
/// Example:
///
/// ```moonbit
/// let options = FuzzyOptions::{
///   threshold: 0.8,
///   max_distance: 1,
///   case_sensitive: false,
///   max_results: 5
/// }
/// inspect(fuzzy_search("Hello World", "helo", options~), content="[]")
/// ```
pub fn fuzzy_search(
  text : String,
  pattern : String,
  algorithm~ : String = "levenshtein",
  options~ : FuzzyOptions = {
    threshold: 0.7,
    max_distance: 2,
    case_sensitive: false,
    max_results: 10,
  },
  start~ : Int = 0,
  end? : Int
) -> Array[FuzzyMatch] raise Error {
  let end = end.or(text.length())
  if pattern.is_empty() {
    raise EmptyPatternError("Empty search pattern is not allowed")
  } else if text.is_empty() {
    return []
  } else if start > end || start < 0 || end > text.length() {
    raise InvalidRangeError(
      "Invalid search range: ensure start <= end and both are within text bounds",
    )
  }
  let search_text = if options.case_sensitive {
    text.substring(start~, end~)
  } else {
    text.substring(start~, end~).to_lower()
  }
  let search_pattern = if options.case_sensitive {
    pattern
  } else {
    pattern.to_lower()
  }
  match algorithm {
    "levenshtein" => levenshtein(search_text, search_pattern, options)
    "jaro_winkler" => jaro_winkler(search_text, search_pattern, options)
    _ =>
      raise OptionChooseError(
        "Invalid search algorithm option. Available options: 'auto', 'kmp', 'rabin_karp', 'boyer_moore'",
      )
  }
}

///|
test "fuzzy_search/basic" {
  let options = FuzzyOptions::{
    threshold: 0.8,
    max_distance: 1,
    case_sensitive: true,
    max_results: 5,
  }
  let result = fuzzy_search("Hello World", "Hello", options~)
  inspect(result.length(), content="1")
  if not(result.is_empty()) {
    inspect(result[0].position, content="0")
    inspect(result[0].score >= 0.8, content="true")
  }
}

///|
test "fuzzy_search/range" {
  let options = FuzzyOptions::{
    threshold: 0.7,
    max_distance: 2,
    case_sensitive: false,
    max_results: 10,
  }
  let result = fuzzy_search("Hello World Hello", "hello", options~, start=6)
  inspect(result.length(), content="1")
  if not(result.is_empty()) {
    inspect(result[0].position, content="6")
  }
}

///|
test "panic fuzzy_search/invalid" {
  let options = FuzzyOptions::{
    threshold: 0.7,
    max_distance: 2,
    case_sensitive: false,
    max_results: 10,
  }
  // Test empty pattern
  ignore(fuzzy_search("hello", "", options~))
  // Test invalid range
  ignore(fuzzy_search("hello", "h", options~, start=5, end=3))
  // Test invalid algorithm
  ignore(fuzzy_search("hello", "h", algorithm="invalid", options~))
}

///|
test "fuzzy_search/basic" {
  let options = FuzzyOptions::{
    threshold: 0.7,
    max_distance: 2,
    case_sensitive: false,
    max_results: 10,
  }
  let result = fuzzy_search("hello world", "hello", options~)
  inspect(result.length(), content="1")
  inspect(result[0].position, content="0")
  inspect(result[0].score, content="1")
  let result = fuzzy_search(
    "hello world",
    "hello",
    algorithm="jaro_winkler",
    options~,
  )
  // println(result)
  inspect(result[0].position, content="0")
  inspect(result[0].score, content="1")
}

///|
test "panic fuzzy_search/boundary_case_empty_pattern" {
  let options = FuzzyOptions::{
    threshold: 0.7,
    max_distance: 2,
    case_sensitive: false,
    max_results: 10,
  }
  ignore(fuzzy_search("hello world", "", options~))
}

///|
test "panic fuzzy_search/boundary_case_invalid_range" {
  let options = FuzzyOptions::{
    threshold: 0.7,
    max_distance: 2,
    case_sensitive: false,
    max_results: 10,
  }
  ignore(fuzzy_search("hello world", "hello", options~, start=5, end=2))
}

///|
test "fuzzy_search/text_empty" {
  let options = FuzzyOptions::{
    threshold: 0.8,
    max_distance: 1,
    case_sensitive: true,
    max_results: 5,
  }
  let result = fuzzy_search("", "Hello", options~)
  inspect(result, content="[]")
}

///|
test "panic fuzzy_search/algorithm_error" {
  let options = FuzzyOptions::{
    threshold: 0.8,
    max_distance: 1,
    case_sensitive: true,
    max_results: 5,
  }
  let result = fuzzy_search("12453", "Hello", algorithm="other", options~)
  inspect(result, content="[]")
}
