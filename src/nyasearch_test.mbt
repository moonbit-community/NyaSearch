///|
test "@xunyoyo/NyaSearch.search/basic_functionality_auto" {
  inspect!(@xunyoyo/NyaSearch.search!("hello world", "world"), content="6")
  inspect!(@xunyoyo/NyaSearch.search!("abra cadabra", "cad"), content="5")
  inspect!(@xunyoyo/NyaSearch.search!("moonbit language", "bit"), content="4")
}

///|
test "@xunyoyo/NyaSearch.search/boundary_cases" {
  inspect!(@xunyoyo/NyaSearch.search!("abcd", "abcd"), content="0") // exact match
  inspect!(@xunyoyo/NyaSearch.search!("abcd", "bcd"), content="1") // starting from index 1
  inspect!(@xunyoyo/NyaSearch.search!("abcd", "d"), content="3") // last character match
  inspect!(@xunyoyo/NyaSearch.search!("aaaaa", "aaa"), content="0") // repeating characters
}

///|
test "@xunyoyo/NyaSearch.search/empty_text" {
  // 空文本情况
  inspect!(@xunyoyo/NyaSearch.search!("", "a"), content="-1")
}

///|
test "panic @xunyoyo/NyaSearch.search/invalid_cases" {
  ignore(@xunyoyo/NyaSearch.search!("hello", "")) // empty pattern
}

///|
test "panic @xunyoyo/NyaSearch.search/invalid_cases" {
  ignore(@xunyoyo/NyaSearch.search!("hello", "world", option="invalid")) // invalid option
}

///|
test "panic @xunyoyo/NyaSearch.search/invalid_cases" {
  ignore(@xunyoyo/NyaSearch.search!("hello", "h", start=5, end=3)) // invalid range
}

///|
test "panic @xunyoyo/NyaSearch.search/invalid_cases" {
  ignore(@xunyoyo/NyaSearch.search!("hello", "h", start=-1, end=5)) // start negative
}

///|
test "panic @xunyoyo/NyaSearch.search/invalid_cases" {
  ignore(@xunyoyo/NyaSearch.search!("hello", "h", start=0, end=6)) // end exceeds length
}
