/*
2 way to run ts file
+ First way
    tsc index.ts
    node index.js
+ Second way
    ts-node index.ts
 */

/*
JavaScript handles object keys when defining an object,
so let's clarify the difference between obj1 and obj2 in your example:

obj1 = {"key1": "val1"}:

In this case, "key1" is a string key.
The key is explicitly written in quotes,
which is completely valid in JavaScript.
This is commonly used when you want to ensure the key is treated as a string,

obj2 = {key1: "val1"}:

Here, key1 is implicitly treated as a string key,
even though it's not wrapped in quotes.
So in this case, key1 is automatically interpreted as the string "key1".

Conclusion:
In both cases, obj1 and obj2 are equivalent because, in JavaScript,
if the key is a valid identifier, you can omit the quotes,and the key will still be treated as a string.
 */


let num: number = 2;
console.log(num);

let obj1 = {"key1": "val1"};
let obj2 = {key1: "val1"};

console.log(obj1); // Output: { key1: 'val1' }
console.log(obj2); // Output: { key1: 'val1' }