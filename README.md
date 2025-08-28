# **incubyte_string_calculator**

### **Incubyte TDD Assessment**

**Careers** | **Software Craftsmanship** | **TDD**  
_By Abhishek Keshri, Tuesday, September 21, 2021_

---

## **Welcome to the Incubyte TDD Kata!**

This assessment is the **first step** in our recruiting process, followed by **two pair programming/discussion sessions**.

---

## **What We’re Looking For**

A **Software Craftsperson** at Incubyte is someone who:
- Has a **strong commitment** to the craft of software development
- Is **passionate** about software
- **Knows their tools** well and uses them effectively
- Creates **carefully crafted software**
- Is **self-motivated** to learn and grow
- Has a **strong sense** of what they are doing

**TDD** is a core practice at Incubyte.  
We believe that **well-written software** is more valuable than software that is hacked together (even if it works!).

Through this assessment, we want to evaluate:
- **Readability** and **testability** of your code
- Your qualities as a **Software Craftsperson**

**Searching the internet** is encouraged—use it as a tool for effective problem solving.  
You may visit our **inspiration page** for useful talks and references.

---

## **Things to Keep in Mind**

1. **Host your solution** on a public **GitHub/GitLab repository**
2. **Follow best practices** for TDD  
   - Watch [this video](https://www.youtube.com/watch?v=qkblc5WRn-U) to understand TDD better
3. **Commit changes frequently**, ideally after every change, to show code evolution
4. Use the **programming language and tools** best suited for the role
5. **Do not rush**—take your time to show your best work
6. **Send us the repo link** once satisfied  
   - Include **screenshots** and other relevant information

---

## **String Calculator TDD Kata**

### **Tips**
- Start with the **simplest test case** (empty string), then move to one and two numbers
- **Solve problems simply** to force yourself to write unexpected tests
- **Refactor** after each passing test

### **Steps**

1. **Create a simple String calculator** with the method signature:

   ```c++
   int add(string numbers)
   ```

   - **Input:** a string of comma-separated numbers
   - **Output:** an integer (sum of the numbers)

2. **Examples:**
   - Input: `""` → Output: `0`
   - Input: `"1"` → Output: `1`
   - Input: `"1,5"` → Output: `6`

3. **Requirements:**
   - The `add` method should handle **any amount of numbers**
   - The `add` method should handle **new lines** between numbers (e.g., `"1\n2,3"` should return `6`)
   - **Support different delimiters:**
     - To change the delimiter, begin the string with:  
       `"//[delimiter]\n[numbers…]"`
     - Example: `"//;\n1;2"` (delimiter is `;`) should return `3`
   - **Negative numbers:**  
     - Calling `add` with a negative number should **throw an exception:**  
       `"negative numbers not allowed <negative_number>"`
     - If there are **multiple negative numbers**, show all in the exception message, separated by commas