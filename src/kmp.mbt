///|
fn kmp(text : String, pattern : String) -> Int {
  let n = text.length()
  let m = pattern.length()
  let lps = compute_lps(pattern)
  let mut i = 0
  let mut j = 0
  while i < n {
    if pattern[j] == text[i] {
      i += 1
      j += 1
    }
    if j == m {
      return i - j
    } else if i < n && pattern[j] != text[i] {
      if j != 0 {
        j = lps[j - 1]
      } else {
        i += 1
      }
    }
  }
  -1
}

///|
test "boyer_moore/basic" {
  inspect!(kmp("hello world", "world"), content="6")
  inspect!(kmp("AABAACAADAABAAABAA", "AABA"), content="0")
  inspect!(kmp("THIS IS A TEST TEXT", "TEST"), content="10")
}

///|
test "boyer_moore/pattern_not_found" {
  inspect!(kmp("hello world", "moon"), content="-1")
  inspect!(kmp("AABAACAADAABAAABAA", "ZZZ"), content="-1")
}
