/*
Write a function to find the longest common prefix string amongst an array of strings.

If there is no common prefix, return an empty string "".



Example 1:

Input: strs = ["flower","flow","flight"]
Output: "fl"
Example 2:

Input: strs = ["dog","racecar","car"]
Output: ""
Explanation: There is no common prefix among the input strings.


Constraints:

1 <= strs.length <= 200
0 <= strs[i].length <= 200
strs[i] consists of only lowercase English letters.
*/

/*
SOLUTION:

 */

function longestCommonPrefix(strs){
    if(strs.length === 1){
        return strs[0]
    }

    let i = 0;
    let j = 0;
    let count = 0;
    let output = ""

    while(i < strs.length - 1){
        let str = strs[i]
        let nextStr = strs[i+1]

        if(str.length === 0){
            return output
        }

        if(str.length <= j || nextStr.length <= j) {
            return output
        }

        if(str[j] === nextStr[j]){
            count++;
        }

        i++;

        if(count === strs.length - 1){
            output = output + str[j]
            i = 0;
            count = 0;
            j++;
        }
    }

    return output
}