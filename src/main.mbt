// 一个简单的加法函数
fn add(a: Int, b: Int) -> Int {
  return a + b
}

///|
test "add" {
  inspect!(add(0, 0), content="0")
  inspect!(add(1, 2), content="3")
  inspect!(add(-1, 1), content="0")
  inspect!(add(-5, -3), content="-8")
}

///|
test "add/edge_cases" {
  inspect!(add(@int.max_value, 0), content="\{@int.max_value}")
  inspect!(add(@int.min_value, 0), content="\{@int.min_value}")
  inspect!(add(0, @int.max_value), content="\{@int.max_value}")
  inspect!(add(0, @int.min_value), content="\{@int.min_value}")
}

// 提供一个包含默认值的加法函数
fn add_with_default(a: Int, b~: Int = 0) -> Int {
  return a + b
}

///|
test "add_with_default" {
  inspect!(add_with_default(5), content="5")
  inspect!(add_with_default(-10), content="-10")
  inspect!(add_with_default(0), content="0")
}

///|
test "add_with_default/with_optional_argument" {
  inspect!(add_with_default(5, b=10), content="15")
  inspect!(add_with_default(-10, b=-5), content="-15")
  inspect!(add_with_default(0, b=0), content="0")
}

///|
test "add_with_default/edge_cases" {
  inspect!(add_with_default(@int.max_value, b=0), content="\{@int.max_value}")
  inspect!(add_with_default(@int.min_value, b=0), content="\{@int.min_value}")
  inspect!(add_with_default(0, b=@int.max_value), content="\{@int.max_value}")
  inspect!(add_with_default(0, b=@int.min_value), content="\{@int.min_value}")
}