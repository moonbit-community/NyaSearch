///|
fn boyer_moore(text : String, pattern : String) -> Int {
  let n = text.length()
  let m = pattern.length()
  if m == 0 || n == 0 || m > n {
    return -1
  }
  let bad_char = compute_bad_char_table(pattern)
  let good_suffix = compute_good_suffix_table(pattern)
  let mut i = 0
  while i <= n - m {
    let mut j = m - 1
    while j >= 0 && pattern[j] == text[i + j] {
      j -= 1
    }
    if j < 0 {
      return i
    } else {
      let bc_shift = bad_char_shift(bad_char, text[i + j], j)
      let gs_shift = good_suffix[j]
      i += @math.maximum(bc_shift, gs_shift)
    }
  }
  -1
}

///|
test "boyer_moore/basic" {
  inspect!(boyer_moore("hello world", "world"), content="6")
  inspect!(boyer_moore("AABAACAADAABAAABAA", "AABA"), content="0")
  inspect!(boyer_moore("THIS IS A TEST TEXT", "TEST"), content="10")
}

///|
test "boyer_moore/pattern_not_found" {
  inspect!(boyer_moore("hello world", "moon"), content="-1")
  inspect!(boyer_moore("AABAACAADAABAAABAA", "ZZZ"), content="-1")
}

///
test "boyer_moore/empty" {
  inspect!(boyer_moore("", ""), content="-1")
  inspect!(boyer_moore("hello world", ""), content="-1")
  inspect!(boyer_moore("", "world"), content="-1")
}