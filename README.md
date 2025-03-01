# 🐱 NyaSearch: A High-Performance Text Search Library

[English](https://github.com/moonbit-community/NyaSearch/blob/main/README.md) | [简体中文](https://github.com/moonbit-community/NyaSearch/blob/main/README_zh_CN.md)

[![Build Status](https://img.shields.io/github/actions/workflow/status/moonbit-community/NyaSearch/ci.yml)](https://github.com/moonbit-community/NyaSearch/actions)
[![License](https://img.shields.io/github/license/moonbit-community/NyaSearch)](LICENSE)


**NyaSearch** is a fast and efficient text search library designed to perform substring matching in large-scale text data. It supports multiple search algorithms, making it suitable for text editors, log analysis, and data processing.

🚀 **Key Features**
- 🔍 **Multiple Algorithms** – Supports KMP, Rabin-Karp, and Boyer-Moore.
- ⚡ **High Performance** – Optimized for fast substring searching.
- 🛠 **Easy to Use** – Simple API for quick integration.
- ✅ **Well-Tested** – Comes with comprehensive unit tests.
- 🔄 **Open-Source** – Actively maintained by the Moonbit Community.

---

## 📥 Installation

```
moon add xunyoyo/NyaSearch
```

## **🚀 Usage Guide for `NyaSearch`**
NyaSearch provides a **powerful and flexible string search function** that supports multiple algorithms. You can either **let it automatically choose the best algorithm** or **manually specify one**. You can also define a **search range** within the text for more precise matching.

---

### **🔍 Basic Usage**
The simplest way to use `NyaSearch` is to call `search`, which will **automatically select the most efficient algorithm** based on the pattern and text.

```moonbit
@NyaSearch.search?("hello world", "world") // Returns: Ok(6), using the best algorithm
```

If you want to **manually choose an algorithm**, simply provide the `option` parameter:

```moonbit
@NyaSearch.search?("hello world", "world", option="kmp") // Returns: Ok(6), using the KMP method
@NyaSearch.search?("hello world", "world", option="boyer_moore") // Returns: Ok(6), using Boyer-Moore
@NyaSearch.search?("hello world", "world", option="rabin_karp") // Returns: Ok(6), using Rabin-Karp
```

---

### **🎯 Searching Within a Specific Range**
You can **search within a specific part of the text** by providing `start` and `end` indices.

```moonbit
@NyaSearch.search!("hello world", "o", start=0, end=5) // Returns: Ok(4)
@NyaSearch.search!("hello world", "o", start=5, end=11) // Returns: Ok(7)
```
- The `start` index **includes** the character at that position.
- The `end` index **excludes** the character at that position.

---

### **⚡ How "Auto" Mode Works**
NyaSearch's **Auto Mode** intelligently selects the most suitable search algorithm based on the characteristics of the **text** and **pattern** to optimize performance.

It evaluates:
- **Pattern length**
- **Text length**
- **Character uniqueness**
- **Repetition ratio**

Based on these factors, `search(..., option="auto")` will choose the best algorithm dynamically.

---

#### **🔍 Auto Mode Selection Logic**
| **Condition** | **Selected Algorithm** | **Reason** |
|--------------|----------------------|------------|
| **Pattern ≤ 2 characters** OR **Text ≤ 10 characters** | `brute_force` | Short patterns or small text are best handled by brute force. |
| **Pattern has a high number of unique characters (≥ 20) & is longer than 15** | `boyer_moore` | Boyer-Moore benefits from large alphabets and long patterns by skipping more characters. |
| **Pattern has a moderate number of unique characters (≥ 10) or is at least 8 characters long** | - If **repetition ratio** (same character repeating) is high (>30%), use `kmp`.  | - **KMP** handles patterns with repeating prefixes efficiently. |
| | - If repetition is low, use `rabin_karp`. | - **Rabin-Karp** benefits from hashing unique sequences. |
| **Otherwise** (small alphabet or short pattern) | `kmp` | KMP is a good general-purpose algorithm. |

---

#### **🎯 Examples**
##### **1️⃣ Short pattern or small text → Uses brute force**
```moonbit
search("hello", "o")  // Uses brute force
search("ab", "b")     // Uses brute force
search("abcdefgh", "d") // Uses brute force
```

##### **2️⃣ Long pattern with many unique characters → Uses Boyer-Moore**
```moonbit
search("this is a very long text", "UNIQUEPATTERNXYZ") // Uses Boyer-Moore
search("random words here", "QWERTYASDFGHZXCVBNM") // Uses Boyer-Moore
```

##### **3️⃣ Medium pattern with high repetition → Uses KMP**
```moonbit
search("abababababababab", "ababab") // Uses KMP
search("aaaaaaaaaaabcaaaaaaa", "aaaaaa") // Uses KMP (high repetition ratio)
```

##### **4️⃣ Medium pattern with low repetition → Uses Rabin-Karp**
```moonbit
search("abcdefgabcdefgabcdefg", "abcdef") // Uses Rabin-Karp (low repetition)
search("random_data_here", "xyz123") // Uses Rabin-Karp
```
---

#### **🎯 Why Auto Mode?**
✅ **Eliminates the need to manually select algorithms.**  
✅ **Ensures optimal performance based on pattern structure.**  
✅ **Automatically adapts to different search scenarios.**  

By using `option="auto"`, **NyaSearch dynamically chooses the most efficient search method**, saving you time and ensuring optimal performance in all cases! 🚀

---

### **⚠️ Error Handling**
If something goes wrong, `NyaSearch` will raise a **meaningful error message**.

| Error | Reason |
|-------|--------|
| `EmptyPatternError` | When the search pattern is empty |
| `PatternTooLongError` | If the pattern is longer than the text |
| `InvalidRangeError` | If `start` or `end` indices are invalid |
| `OptionChooseError` | If an unsupported algorithm is chosen |


---

### **🛠 Full Example**
```moonbit
let text = "The quick brown fox jumps over the lazy dog"
let pattern = "fox"

// Auto mode (default)
let index = @NyaSearch.search?(text, pattern)
print("Found at:", index) // Found at: Ok(16)

// Specify an algorithm
let index_kmp = @NyaSearch.search?(text, pattern, option="kmp")
print("KMP found at:", index_kmp)

// Search within a range
let index_range = @NyaSearch.search?(text, pattern, start=10, end=20)
print("Range search found at:", index_range)
```

🎉 **Now you’re ready to use NyaSearch for high-performance text searching!** 🚀

## 📜 License
This project is licensed under the Apache-2.0 License. See [LICENSE](https://github.com/moonbit-community/NyaSearch/blob/main/LICENSE) for details.

## 📢 Contact & Support
+ Moonbit Community: [moonbit-community](https://github.com/moonbit-community)
+ GitHub Issues: [Report an issue](https://github.com/moonbit-community/NyaSearch/issues)

👋 If you like this project, give it a ⭐! Happy coding! 🚀