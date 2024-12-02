/*
Given a string s consisting of words and spaces, return the length of the last word in the string.

A word is a maximal
substring
 consisting of non-space characters only.



Example 1:

Input: s = "Hello World"
Output: 5
Explanation: The last word is "World" with length 5.
Example 2:

Input: s = "   fly me   to   the moon  "
Output: 4
Explanation: The last word is "moon" with length 4.
Example 3:

Input: s = "luffy is still joyboy"
Output: 6
Explanation: The last word is "joyboy" with length 6.


Constraints:

1 <= s.length <= 104
s consists of only English letters and spaces ' '.
There will be at least one word in s.
*/

/*
SOLUTION:

 */


function lengthOfLastWord(s: string): number{
    let count = 0

    // Start from the end of the string
    for(let i= s.length-1; i >= 0; i-- ){

        // If current character is not a space, increment count
        if(s[i] !== ' '){
            count++
        }

        // If we've counted some characters and we encounter a space
        // (checking i-1 to avoid array out of bounds)
        if(count > 0 && i - 1 >= 0 && s[i-1] === ' '){
            break
        }
    }

    return count
}


// Test cases
console.log(lengthOfLastWord("Hello World")); // Output: 5
console.log(lengthOfLastWord("   fly me   to   the moon  ")); // Output: 4
console.log(lengthOfLastWord("luffy is still joyboy")); // Output: 6