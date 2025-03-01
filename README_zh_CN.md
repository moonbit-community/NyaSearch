# 🐱 NyaSearch：高性能文本搜索库

[English](https://github.com/moonbit-community/NyaSearch/blob/main/README.md) | [简体中文](https://github.com/moonbit-community/NyaSearch/blob/main/README_zh_CN.md)

[![Build Status](https://img.shields.io/github/actions/workflow/status/moonbit-community/NyaSearch/ci.yml)](https://github.com/moonbit-community/NyaSearch/actions)
[![License](https://img.shields.io/github/license/moonbit-community/NyaSearch)](LICENSE)

**NyaSearch** 是一个快速高效的文本搜索库，专为在大规模文本数据中执行子串匹配而设计。它支持多种搜索算法，适用于文本编辑器、日志分析和数据处理。

🚀 **主要特性**
- 🔍 **多种算法** – 支持 KMP、Rabin-Karp 和 Boyer-Moore 算法。
- ⚡ **高性能** – 针对快速子串搜索进行了优化。
- 🛠 **易于使用** – 提供简单的 API 便于快速集成。
- ✅ **经过充分测试** – 拥有全面的单元测试。
- 🔄 **开源** – 由 Moonbit 社区积极维护。

---


## 📥 安装

```
moon add xunyoyo/NyaSearch
```

## **🚀 `NyaSearch` 使用指南**

NyaSearch 提供了一个 **强大且灵活的字符串搜索功能**，支持多种算法。你可以选择 **让其自动选择最佳算法** 或 **手动指定算法**。你还可以通过定义文本中的 **搜索范围** 来实现更精确的匹配。

---

### **🔍 基本用法**

最简单的用法是调用 `search!`，它会 **自动选择最优算法**。

```moonbit
@nyasearch.search!("hello world", "world") // 返回：6，使用最佳算法
```

如果你想 **手动选择算法**，只需提供 `option` 参数：

```moonbit
@nyasearch.search!("hello world", "world", option="kmp")         // 返回：6，使用 KMP 方法
@nyasearch.search!("hello world", "world", option="boyer_moore")   // 返回：6，使用 Boyer-Moore 方法
@nyasearch.search!("hello world", "world", option="rabin_karp")      // 返回：6，使用 Rabin-Karp 方法
```

---

### **🎯 在特定范围内搜索**

你可以通过提供 `start` 和 `end` 索引，在文本的特定部分内进行搜索。

```moonbit
@nyasearch.search!("hello world", "o", start=0, end=5)  // 返回：4
@nyasearch.search!("hello world", "o", start=5, end=11) // 返回：7
```
- `start` 索引 **包含**该位置的字符。
- `end` 索引 **不包含**该位置的字符。

---

### **⚡ 自动模式的工作原理**

NyaSearch 的 **自动模式** 根据 **文本** 和 **模式** 的特性智能地选择最合适的搜索算法，从而优化性能。

它会评估：
- **模式长度**
- **文本长度**
- **字符唯一性**
- **重复率**

基于这些因素，`search!(..., option="auto")` 会动态选择最佳算法。

---

#### **🔍 自动模式选择逻辑**

| 条件 | 选择的算法 | 原因 |
| --- | --- | --- |
| 模式长度 ≤ 2 个字符 或 文本长度 ≤ 10 个字符 | brute_force | 短模式或小文本最好使用暴力搜索。 |
| 模式具有较高的字符唯一性（≥ 20）且长度大于 15 | boyer_moore | Boyer-Moore 利用较大的字符集和较长的模式，通过跳过更多字符提高效率。 |
| 模式具有适中字符唯一性（≥ 10）或至少 8 个字符 | 若重复率高 (>30%) 则使用 kmp；若重复率低则使用 rabin_karp | 高重复率时，KMP 能高效处理重复前缀；低重复率时，Rabin-Karp 利用哈希提高效率。 |
| 否则（字符集小或模式短） | kmp | KMP 是一个不错的通用算法。 |

---

#### **🎯 示例**

##### **1️⃣ 短模式或小文本 → 使用暴力搜索**
```moonbit
search!("hello", "o")       // 使用暴力搜索
search!("ab", "b")          // 使用暴力搜索
search!("abcdefgh", "d")    // 使用暴力搜索
```

##### **2️⃣ 长模式且具有大量唯一字符 → 使用 Boyer-Moore**
```moonbit
search!("this is a very long text", "UNIQUEPATTERNXYZ")   // 使用 Boyer-Moore
search!("random words here", "QWERTYASDFGHZXCVBNM")        // 使用 Boyer-Moore
```

##### **3️⃣ 中等模式且重复率高 → 使用 KMP**
```moonbit
search!("abababababababab", "ababab")       // 使用 KMP
search!("aaaaaaaaaaabcaaaaaaa", "aaaaaa")     // 使用 KMP（高重复率）
```

##### **4️⃣ 中等模式且重复率低 → 使用 Rabin-Karp**
```moonbit
search!("abcdefgabcdefgabcdefg", "abcdef")   // 使用 Rabin-Karp（低重复率）
search!("random_data_here", "xyz123")         // 使用 Rabin-Karp
```

---

#### **🎯 为什么使用自动模式？**

✅ **无需手动选择算法。**  
✅ **确保基于模式结构实现最佳性能。**  
✅ **自动适应不同的搜索场景。**

通过使用 `option="auto"`，**NyaSearch 会动态选择最有效的搜索方法**，为你节省时间并确保在所有情况下实现最佳性能！ 🚀

---

### **⚠️ 错误处理**

如果出现问题，`NyaSearch` 将抛出 **有意义的错误信息**。

| 错误 | 原因 |
| --- | --- |
| `EmptyPatternError` | 当搜索模式为空时 |
| `PatternTooLongError` | 如果模式比文本长 |
| `InvalidRangeError` | 如果 `start` 或 `end` 索引无效 |
| `OptionChooseError` | 如果选择了不支持的算法 |

---

### **🛠 完整示例**

```moonbit
let text = "The quick brown fox jumps over the lazy dog"
let pattern = "fox"

// 自动模式（默认）
let index = @nyasearch.search!(text, pattern)
print("找到位置:", index) // 返回：16

// 指定算法
let index_kmp = @nyasearch.search!(text, pattern, option="kmp")
print("KMP 查找到位置:", index_kmp)

// 在范围内搜索
let index_range = @nyasearch.search!(text, pattern, start=10, end=20)
print("范围搜索查找到位置:", index_range)
```

🎉 **现在你已经可以使用 NyaSearch 进行高性能文本搜索了！** 🚀

## 📜 许可证

本项目遵循 Apache-2.0 许可证。详情请参阅 [LICENSE](https://github.com/moonbit-community/NyaSearch/blob/main/LICENSE)。

## 📢 联系与支持

+ Moonbit 社区: [moonbit-community](https://github.com/moonbit-community)
+ GitHub 问题: [报告问题](https://github.com/moonbit-community/NyaSearch/issues)

👋 如果你喜欢这个项目，请给它一个 ⭐！祝编码愉快！ 🚀