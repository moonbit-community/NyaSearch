///|
fn levenshtein_distance_threshold(
  s : String,
  t : String,
  threshold : Int
) -> Int {
  let m = s.length()
  let n = t.length()
  if (m - n).abs() > threshold {
    return threshold + 1
  }
  let mut prev = Array::make(n + 1, 0)
  let mut curr = Array::make(n + 1, 0)
  for j = 0; j <= n; j = j + 1 {
    prev[j] = j
  }
  for i = 1; i <= m; i = i + 1 {
    curr[0] = i
    let mut row_min = m + n
    for j = 1; j <= n; j = j + 1 {
      if s[i - 1] == t[j - 1] {
        curr[j] = prev[j - 1]
      } else {
        curr[j] = 1 +
          @math.minimum(prev[j - 1], @math.minimum(curr[j - 1], prev[j]))
      }
      row_min = @math.minimum(row_min, curr[j])
    }
    if row_min > threshold {
      return threshold + 1
    }
    let temp = prev
    prev = curr
    curr = temp
  }
  // return if prev[n] <= threshold { prev[n] } else { threshold + 1 }
  prev[n]
}

///|
test "levenshtein_distance_threshold/length_difference_optimization" {
  // 情况 1: 字符串长度差大于阈值，应直接返回 threshold + 1
  //
  // 例如: "abcdef" 和 "a" 的长度差是 5，阈值设为 2
  // 由于 |6-1| = 5 > 2，应直接返回 threshold + 1 = 3
  // 而不需计算实际的编辑距离
  let result1 = levenshtein_distance_threshold("abcdef", "a", 2)
  inspect!(result1, content="3") // threshold + 1 = 3

  // 情况 2: 字符串长度差等于阈值，应计算实际编辑距离
  //
  // 例如: "abc" 和 "a" 的长度差是 2，阈值设为 2
  // 由于 |3-1| = 2 == 2，不会触发早期返回，应计算实际编辑距离
  // 实际编辑距离是 2（需要删除两个字符）
  let result2 = levenshtein_distance_threshold("abc", "a", 2)
  inspect!(result2, content="2")

  // 情况 3: 字符串长度差小于阈值，应计算实际编辑距离
  //
  // 例如: "abc" 和 "ab" 的长度差是 1，阈值设为 2
  // 由于 |3-2| = 1 < 2，不会触发早期返回，应计算实际编辑距离
  // 实际编辑距离是 1（需要删除一个字符）
  let result3 = levenshtein_distance_threshold("abc", "ab", 2)
  inspect!(result3, content="1")

  // 情况 4: 测试空字符串与非空字符串
  //
  // 例如: "" 和 "abcde" 的长度差是 5，阈值设为 3
  // 由于 |0-5| = 5 > 3，应直接返回 threshold + 1 = 4
  let result4 = levenshtein_distance_threshold("", "abcde", 3)
  inspect!(result4, content="4")

  // 情况 5: 测试长度相等但内容差异大于阈值的字符串
  //
  // 例如: "abcde" 和 "vwxyz" 长度相等，长度差是 0，阈值设为 2
  // 虽然长度差小于阈值，但实际编辑距离是 5，大于阈值
  // 函数会计算出实际距离大于阈值，返回 threshold + 1 = 3
  let result5 = levenshtein_distance_threshold("abcde", "vwxyz", 2)
  inspect!(result5, content="3")

  // 情况 6: 测试字符串长度差接近边界条件
  //
  // 例如: "a" 和 "abcd" 的长度差是 3，阈值设为 3
  // 由于 |1-4| = 3 == 3，不会触发早期返回，应计算实际编辑距离
  // 实际编辑距离是 3（需要插入三个字符）
  let result6 = levenshtein_distance_threshold("a", "abcd", 3)
  inspect!(result6, content="3")

  // 情况 7: 测试相同字符串
  //
  // 例如: "same" 和 "same" 的长度差是 0，阈值设为 1
  // 不会触发早期返回，实际编辑距离是 0
  let result7 = levenshtein_distance_threshold("same", "same", 1)
  inspect!(result7, content="0")

  // 情况 8: 测试最终编辑距离大于阈值但不触发提前返回
  //
  // 使用 "abc" 和 "xyz"，长度相等（差为0），阈值为2
  let result10 = levenshtein_distance_threshold("abc", "zzz", 1)
  inspect!(result10, content="2")
}

///|
fn levenshtein(
  text : String,
  pattern : String,
  options : FuzzyOptions
) -> Array[FuzzyMatch] {
  let result = Array::new()
  let n = text.length()
  let m = pattern.length()
  for i = 0; i <= n - m; i = i + 1 {
    let candidate = text.substring(start=i, end=i + m)
    let distance = levenshtein_distance_threshold(
      candidate,
      pattern,
      options.max_distance,
    )
    if distance <= options.max_distance {
      let max_len = @math.maximum(m, candidate.length()).to_float()
      let score = 1.0.to_float() - distance.to_float() / max_len
      if score >= options.threshold {
        result.push(FuzzyMatch::{ position: i, score, length: m })
      }
    }
  }
  result.sort()
  if result.length() > options.max_results {
    return result[0:options.max_results].iter().collect()
  }
  result
}

///|
test "levenshtein_fuzzy_search/basic_matching" {
  let options = FuzzyOptions::{
    threshold: 0.7,
    max_distance: 2,
    case_sensitive: true,
    max_results: 10,
  }
  let result1 = levenshtein("hello world", "hello", options)
  inspect!(result1.length(), content="1")
  if not(result1.is_empty()) {
    inspect!(result1[0].position, content="0")
    inspect!(result1[0].score, content="1")
  }
  let result2 = levenshtein("hello world", "hallo", options)
  inspect!(result2.length() > 0, content="true")
  if not(result2.is_empty()) {
    inspect!(result2[0].position, content="0")
    inspect!(result2[0].score >= 0.8, content="true")
  }
}

///|
/// 测试结果数量限制功能
test "levenshtein_fuzzy_search/max_results_limit" {
  // 创建一个包含多个可能匹配的文本
  let text = "cat bat cat bat cat bat cat bat cat bat"
  let pattern = "cat"

  // 设置较小的 max_results 值，确保触发限制
  let options = FuzzyOptions::{
    threshold: 0.6,
    max_distance: 1, // 允许1个编辑距离，这样"bat"也可能匹配
    case_sensitive: true,
    max_results: 3, // 只要前3个结果
  }

  // 1. 测试在循环中提前退出的限制
  let result = levenshtein(text, pattern, options)

  // 验证结果数量不超过 max_results
  inspect!(result.length() <= options.max_results, content="true")
  inspect!(result.length(), content="3")

  // 确认找到了正确的匹配位置
  if result.length() >= 3 {
    // 第一个"cat"在位置0
    inspect!(result[0].position, content="0")
    // 第二个"cat"在位置8
    inspect!(result[1].position, content="8")
    // 第三个"cat"在位置16
    inspect!(result[2].position, content="16")
  }

  // 2. 测试在长结果数组上的截断逻辑
  // 为此我们临时增加测试
  let temp_result = Array::new()
  for i = 0; i < 5; i = i + 1 {
    temp_result.push(FuzzyMatch::{
      position: i,
      score: (5 - i).to_float() / 5,
      length: pattern.length(),
    })
  }

  // 创建一个临时函数模拟结果处理
  let truncate_results = fn(
    arr : Array[FuzzyMatch],
    max : Int
  ) -> Array[FuzzyMatch] {
    arr.sort()
    if arr.length() > max {
      return arr[0:max].map(fn(x) { x })
    }
    arr
  }
  let truncated = truncate_results(temp_result, 3)
  inspect!(truncated.length(), content="3")
  inspect!(truncated[0].position, content="0") // 分数最高的是第一项
}

///|
/// 测试 max_results 为1的极端情况
test "levenshtein_fuzzy_search/max_results_one" {
  let text = "cat bat cat bat cat"
  let pattern = "cat"

  // 设置 max_results = 1
  let options = FuzzyOptions::{
    threshold: 0.7,
    max_distance: 0,
    case_sensitive: true,
    max_results: 1, // 只要第一个结果
  }
  let result = levenshtein(text, pattern, options)

  // 应该只返回一个结果
  inspect!(result.length(), content="1")
  if result.length() >= 1 {
    inspect!(result[0].position, content="0") // 第一个"cat"
  }
}

///|
/// 测试较大量的数据以确保两个限制条件都被触发
test "levenshtein_fuzzy_search/large_dataset" {
  // 创建一个包含多个匹配和近似匹配的较大文本
  let text = "cat bat rat cat mat sat cat hat cat pat cat lat cat"
  let pattern = "cat"

  // 相似度阈值较低，以匹配更多的词
  let options = FuzzyOptions::{
    threshold: 0.5,
    max_distance: 1, // 允许1个编辑距离
    case_sensitive: true,
    max_results: 4, // 限制结果数
  }
  let result = levenshtein(text, pattern, options)

  // 验证结果被限制在max_results
  inspect!(result.length() <= options.max_results, content="true")
  inspect!(result.length(), content="4")
  for item in result {
    item |> println
  }
}
