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
