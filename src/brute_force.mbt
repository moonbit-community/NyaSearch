///|
fn brute_force(text : String, pattern : String) -> Int {
  let text_len = text.length()
  let pattern_len = pattern.length()
  for i = 0; i < text_len - pattern_len + 1; i = i + 1 {
    let mut found = true
    for j = 0; j < pattern_len; j = j + 1 {
      if text.charcode_at(i + j) != pattern.charcode_at(j) {
        found = false
        break
      }
    }
    if found {
      return i
    }
  }
  -1
}

///|
test "boyer_moore/basic" {
  inspect(brute_force("hello world", "world"), content="6")
  inspect(brute_force("AABAACAADAABAAABAA", "AABA"), content="0")
  inspect(brute_force("THIS IS A TEST TEXT", "TEST"), content="10")
}

///|
test "boyer_moore/pattern_not_found" {
  inspect(brute_force("hello world", "moon"), content="-1")
  inspect(brute_force("AABAACAADAABAAABAA", "ZZZ"), content="-1")
}
