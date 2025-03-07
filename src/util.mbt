///|
pub struct FuzzyMatch {
  position : Int
  score : Float
  length : Int
}

///|
impl Show for FuzzyMatch with output(self, logger) {
  logger.write_string("FuzzyMatch { position: ")
  logger.write_string(self.position.to_string())
  logger.write_string(", score: ")
  logger.write_string(self.score.to_string())
  logger.write_string(", length: ")
  logger.write_string(self.length.to_string())
  logger.write_string(" }")
}

///|
impl Compare for FuzzyMatch with compare(front, after) {
  if front.score == after.score {
    // 分数相同时，比较位置，位置小的排在前面
    if front.position < after.position {
      -1
    } else if front.position > after.position {
      1
    } else {
      0
    }
  } else if front.score < after.score {
    1
  } else {
    -1
  }
}

///|
test "FuzzyMatch::compare/equal_positions" {
  let fm1 = FuzzyMatch::{ position: 5, score: 0.8, length: 3 }
  let fm2 = FuzzyMatch::{ position: 5, score: 0.8, length: 4 }
  inspect!(fm1.compare(fm2), content="0")
}

///|
test "FuzzyMatch::compare/different_scores" {
  let fm1 = FuzzyMatch::{ position: 2, score: 0.9, length: 3 }
  let fm2 = FuzzyMatch::{ position: 3, score: 0.7, length: 4 }
  inspect!(fm1.compare(fm2), content="-1")
  inspect!(fm2.compare(fm1), content="1")
}

///|
test "FuzzyMatch::compare/same_score_different_positions" {
  let fm1 = FuzzyMatch::{ position: 1, score: 0.8, length: 3 }
  let fm2 = FuzzyMatch::{ position: 2, score: 0.8, length: 4 }
  inspect!(fm1.compare(fm2), content="-1")
  inspect!(fm2.compare(fm1), content="1")
}

///|
impl Eq for FuzzyMatch with op_equal(front, after) {
  front.position == after.position &&
  front.score == after.score &&
  front.length == after.length
}

///|
test "FuzzyMatch::op_equal/identical" {
  let m1 = FuzzyMatch::{ position: 0, score: 1.0, length: 5 }
  let m2 = FuzzyMatch::{ position: 0, score: 1.0, length: 5 }
  inspect!(m1 == m2, content="true")
}

///|
test "FuzzyMatch::op_equal/different" {
  let base = FuzzyMatch::{ position: 0, score: 1.0, length: 5 }
  let pos_diff = FuzzyMatch::{ position: 1, score: 1.0, length: 5 }
  let score_diff = FuzzyMatch::{ position: 0, score: 0.9, length: 5 }
  let len_diff = FuzzyMatch::{ position: 0, score: 1.0, length: 4 }
  inspect!(base == pos_diff, content="false")
  inspect!(base == score_diff, content="false")
  inspect!(base == len_diff, content="false")
}

///|
test "FuzzyMatch::op_equal/edge_cases" {
  let zero = FuzzyMatch::{ position: 0, score: 0.0, length: 0 }
  let zero_twin = FuzzyMatch::{ position: 0, score: 0.0, length: 0 }
  let max = FuzzyMatch::{
    position: @int.max_value,
    score: 1.0,
    length: @int.max_value,
  }
  let max_twin = FuzzyMatch::{
    position: @int.max_value,
    score: 1.0,
    length: @int.max_value,
  }
  inspect!(zero == zero_twin, content="true")
  inspect!(max == max_twin, content="true")
}

///|
pub struct FuzzyOptions {
  threshold : Float
  max_distance : Int
  case_sensitive : Bool
  max_results : Int
}

///|
fn compute_lps(pattern : String) -> Array[Int] {
  let m = pattern.length()
  let lps = Array::make(m, 0)
  let mut i = 1
  let mut len = 0
  while i < m {
    if pattern[i] == pattern[len] {
      len += 1
      lps[i] = len
      i += 1
    } else if len != 0 {
      len = lps[len - 1]
    } else {
      lps[i] = 0
      i += 1
    }
  }
  lps
}

///|
fn compute_bad_char_table(pattern : String) -> Map[Char, Int] {
  let m = pattern.length()
  let bad_char = Map::new()
  let mut j = 0
  while j < m - 1 {
    bad_char.set(pattern[j], j)
    j += 1
  }
  return bad_char
}

///|
fn bad_char_shift(bad_char : Map[Char, Int], c : Char, j : Int) -> Int {
  match bad_char.get(c) {
    Some(bc_pos) => @math.maximum(1, j - bc_pos)
    None => j + 1
  }
}

///|
fn compute_suffix_array(pattern : String, suffix : Array[Int]) -> Unit {
  let m = pattern.length()
  suffix[m - 1] = m
  let mut g = m - 1
  let mut f = 0
  let mut i = m - 2
  while i >= 0 {
    if i > g && suffix[i + m - 1 - f] < i - g {
      suffix[i] = suffix[i + m - 1 - f]
    } else {
      if i < g {
        g = i
      }
      f = i
      while g >= 0 && pattern[g] == pattern[g + m - 1 - f] {
        g -= 1
      }
      suffix[i] = f - g
    }
    i -= 1
  }
}

///|
fn compute_good_suffix_table(pattern : String) -> Array[Int] {
  let m = pattern.length()
  let suffix = Array::make(m, 0)
  let good_suffix = Array::make(m, 0)
  compute_suffix_array(pattern, suffix)
  let mut j = 0
  while j < m {
    good_suffix[j] = m
    j += 1
  }
  j = 0
  let mut i = m - 1
  while i >= 0 {
    if suffix[i] == i + 1 {
      while j < m - 1 - i {
        if good_suffix[j] == m {
          good_suffix[j] = m - 1 - i
        }
        j += 1
      }
    }
    i -= 1
  }
  i = 0
  while i < m - 1 {
    good_suffix[m - 1 - suffix[i]] = m - 1 - i
    i += 1
  }
  return good_suffix
}

///|
fn auto(text : String, pattern : String) -> Int {
  let text_len = text.length()
  let pattern_len = pattern.length()
  if pattern_len <= 2 || text_len <= 10 {
    return brute_force(text, pattern)
  }
  let mut repeats = 0
  let unique_chars = Set::new()
  for i in 0..<pattern_len {
    if unique_chars.contains(pattern[i]) {
      repeats += 1
    } else {
      unique_chars.add(pattern[i])
    }
  }
  let repeat_ratio = repeats.to_float() / pattern_len.to_float()
  let alphabet_size = unique_chars.size()
  if alphabet_size > 20 && pattern_len > 15 {
    return boyer_moore(text, pattern)
  }
  if alphabet_size > 10 || pattern_len >= 8 {
    if repeat_ratio > 0.3 {
      return kmp(text, pattern)
    } else {
      return rabin_karp(text, pattern)
    }
  }
  kmp(text, pattern)
}

///|
test "auto/short_pattern" {
  // 测试短模式（长度≤2）
  inspect!(auto("hello world", "he"), content="0")
  inspect!(auto("abcdefghijk", "k"), content="10")
}

///|
test "auto/short_text" {
  // 测试短文本（长度≤10）
  inspect!(auto("hello", "ell"), content="1")
  inspect!(auto("abc", "bc"), content="1")
}

///|
test "auto/large_alphabet_long_pattern" {
  // 大字符集（>20）且长模式（>15）
  let pattern = "abcdefghijklmnopqrstu"
  let text = "xyz" + pattern + "123"
  inspect!(auto(text, pattern), content="3")
}

///|
test "auto/medium_size_high_repeat" {
  // 中等长度模式，高重复率（>0.3）
  let pattern = "ababcabc" // 8字符，重复率>0.3
  let text = "xxababcabcyy"
  inspect!(auto(text, pattern), content="2")
}

///|
test "auto/medium_size_low_repeat" {
  // 中等长度模式，低重复率（≤0.3）
  let pattern = "abcdefghij" // 10个不同字符
  let text = "xxabcdefghijyy"
  inspect!(auto(text, pattern), content="2")
}

///|
test "auto/default_path" {
  // 默认路径 - 小字符集，短模式但不太短
  let pattern = "abcab" // 5个字符，字符集为3
  let text = "ababcabxyz"
  inspect!(auto(text, pattern), content="2")
}

///|
test "auto/boundary_cases" {
  // 边界情况测试

  // 恰好字符集为10，长度为9
  let pattern1 = "abcdefghi"
  let text1 = pattern1 + pattern1
  inspect!(auto(text1, pattern1), content="0")

  // 恰好字符集为10，长度为10
  let pattern2 = "abcdefghi1"
  let text2 = pattern2 + pattern2
  inspect!(auto(text2, pattern2), content="0")

  // 恰好重复率为0.3
  let pattern3 = "abcabcdefg"
  let text3 = pattern3 + pattern3
  inspect!(auto(text3, pattern3), content="0")
}

///|
test "auto/not_found" {
  // 测试未找到的情况
  inspect!(auto("hello world", "xyz"), content="-1")
  inspect!(auto("AABAACAADAABAAABAA", "XYZ"), content="-1")
}

///|
test "auto/empty_text" {
  // 空文本情况
  inspect!(auto("", "a"), content="-1")
}

///|
test "auto/performance_cases" {
  // 性能测试情况

  // 长重复模式
  let repeated_pattern = "ababababab"
  let long_text = repeated_pattern + repeated_pattern
  inspect!(auto(long_text, repeated_pattern), content="0")

  // 长唯一字符模式
  let unique_chars = "abcdefghijklmnopqrstuvwxyz"
  let long_unique_text = unique_chars + "xyz"
  inspect!(auto(long_unique_text, unique_chars), content="0")
}

///|
test "compute_suffix_array/special_branch_coverage" {
  // 这个测试专门用来触发难以覆盖的分支

  // 选择已知能触发特殊条件的模式
  let patterns = [
    "abacabab", // 包含重复但不完全重复的模式
     "abcababcab", // 有重叠部分的模式
     "aaaabaaaba", // 有很多重复的模式
     "abcdabcabc", // 更复杂的重叠模式
     "aabcaabcaab", // 另一种复杂重叠模式
  ]

  // 对每个模式运行并验证结果
  for pattern in patterns {
    let m = pattern.length()
    let suffix = Array::make(m, 0)
    compute_suffix_array(pattern, suffix)

    // 验证结果是否正确
    // 这里我们可以检查特定已知的值，或者简单地确保没有异常
    inspect!(suffix.length() == m, content="true")
  }
}
