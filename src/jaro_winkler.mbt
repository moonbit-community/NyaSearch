///|
fn jaro_winkler_similarity(
  s1 : String,
  s2 : String,
  prefix_scale~ : Float = 0.1,
  prefix_max~ : Int = 4
) -> Float {
  let len1 = s1.length()
  let len2 = s2.length()
  let match_window = @math.maximum(0, @math.maximum(len1, len2) / 2 - 1)
  let match1 = Array::make(len1, false)
  let match2 = Array::make(len2, false)
  let mut matches = 0
  for i = 0; i < len1; i = i + 1 {
    let start = @math.maximum(0, i - match_window)
    let end = @math.minimum(len2, i + match_window + 1)
    for j = start; j < end; j = j + 1 {
      if not(match2[j]) && s1[i] == s2[j] {
        match1[i] = true
        match2[j] = true
        matches = matches + 1
        break
      }
    }
  }
  if matches == 0 {
    return 0.0
  }
  let mut transpositions = 0
  let mut j = 0
  for i = 0; i < len1; i = i + 1 {
    if match1[i] {
      while not(match2[j]) {
        j = j + 1
      }
      if s1[i] != s2[j] {
        transpositions = transpositions + 1
      }
      j = j + 1
    }
  }
  transpositions = transpositions / 2
  let m = matches.to_float()
  let jaro = (
      m / len1.to_float() +
      m / len2.to_float() +
      (m - transpositions.to_float()) / m
    ) /
    3.0
  let mut prefix_len = 0
  let max_prefix = @math.minimum(prefix_max, @math.minimum(len1, len2))
  for i = 0; i < max_prefix; i = i + 1 {
    if s1[i] == s2[i] {
      prefix_len = prefix_len + 1
    } else {
      break
    }
  }
  jaro + prefix_len.to_float() * prefix_scale * (1.0.to_float() - jaro)
}

///|
test "jaro_winkler_similarity/prefix_calculation" {
  // 测试完全不同的字符串 (没有共同前缀)
  let score1 = jaro_winkler_similarity("abc", "xyz")
  let base_score1 = jaro_winkler_similarity("abc", "xyz", prefix_scale=0.0) // 不计算前缀加成
  inspect!(score1 == base_score1, content="true") // 前缀长度为0，不应有加成
  
  // 测试部分前缀匹配
  let score2 = jaro_winkler_similarity("abcdef", "abcxyz")
  let base_score2 = jaro_winkler_similarity("abcdef", "abcxyz", prefix_scale=0.0)
  inspect!(score2 > base_score2, content="true") // 有3字符共同前缀，应该有加成
  
  // 测试最大前缀限制 (默认 prefix_max=4)
  let score3 = jaro_winkler_similarity("abcdefghi", "abcdefxyz")
  let score4 = jaro_winkler_similarity("abcdefghi", "abcdefxyz", prefix_max=6)
  inspect!(score3 < score4, content="true") // 增加最大前缀限制应提高分数
  
  // 测试完全相同前缀，但后面不同
  let score5 = jaro_winkler_similarity("hello world", "hello moon")
  let base_score5 = jaro_winkler_similarity("hello world", "hello moon", prefix_scale=0.0)
  inspect!(score5 > base_score5, content="true") // "hello "是共同前缀
  
  // 测试空字符串和空前缀情况
  let score6 = jaro_winkler_similarity("", "abc")
  inspect!(score6, content="0") // 空字符串应返回0
  
  let score7 = jaro_winkler_similarity("xyz", "abc")
  let base_score7 = jaro_winkler_similarity("xyz", "abc", prefix_scale=0.0)
  inspect!(score7 == base_score7, content="true") // 无共同前缀
}

///|
/// 使用Jaro-Winkler算法执行模糊搜索
///
/// 参数:
///   * text: 要搜索的文本
///   * pattern: 要搜索的模式
///   * options: 搜索配置选项
///
/// 返回:
///   符合阈值要求的匹配结果数组
fn jaro_winkler(
  text : String,
  pattern : String,
  options : FuzzyOptions
) -> Array[FuzzyMatch] {
  let result = Array::new()
  let n = text.length()
  let m = pattern.length()
  let max_window = m + options.max_distance
  for i = 0; i <= n - m; i = i + 1 {
    let exact_candidate = text.substring(start=i, end=i + m)
    if exact_candidate == pattern {
      result.push(FuzzyMatch::{ position: i, score: 1.0, length: m })
      continue
    }
    let window_end = @math.minimum(i + max_window, n)
    let candidate = text.substring(start=i, end=window_end)
    let similarity = jaro_winkler_similarity(candidate, pattern)
    if similarity >= options.threshold {
      result.push(FuzzyMatch::{ position: i, score: similarity, length: m })
    }
  }
  result.sort()
  if result.length() > options.max_results {
    return result[0:options.max_results].iter().collect()
  }
  return result
}

///|
test "jaro_winkler/exact_matches" {
  let options = FuzzyOptions::{
    threshold: 0.8,
    max_distance: 2,
    case_sensitive: true,
    max_results: 6,
  }
  let result = jaro_winkler("hello world hello", "hello", options)
  if result.length() >= 2 {
    // First match should be at position 0
    inspect!(result[0].position, content="0")
    inspect!(result[0].score, content="1")
    // Second match should be at position 6
    inspect!(result[1].position, content="12")
    inspect!(result[1].score, content="1")
  }
}

///|
test "jaro_winkler/max_results_limit" {
  let options = FuzzyOptions::{
    threshold: 0.5,
    max_distance: 3,
    case_sensitive: true,
    max_results: 2,
  }
  // Text contains three occurrences of "hello" but max_results is 2
  let result = jaro_winkler("hello world hello moon hello", "hello", options)
  // Should only return first two matches due to max_results limit
  inspect!(result.length(), content="2")
}

///|
test "jaro_winkler/max_results_limit(all different)" {
  let options = FuzzyOptions::{
    threshold: 0.5,
    max_distance: 3,
    case_sensitive: true,
    max_results: 2,
  }
  // Text contains three occurrences of "hello" but max_results is 2
  let result = jaro_winkler("abc", "def", options)
  // Should only return first two matches due to max_results limit
  inspect!(result.length(), content="0")
}
