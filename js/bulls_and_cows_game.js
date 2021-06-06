/*
You are playing a ‘Bulls and Cows game' with your friend.
You write down a secret number and ask your friend to guess what the number is.
When your friend makes a guess, you provide a hint with the following info:

The number of 'bulls', which are digits in the guess that are in the same position
The number of 'cows', which are digits in the guess that are in your secret number but are located in the wrong position.

Given the secret number and your friend guess, return the hint for your friend's guess.
The hint should be formatted as 'xByC', where x is the number of bulls and y is the number of cows.
For example, 1 bull and 2 cows would be formatted as '1B2C'

Function should be in the form of:
function getHint(secret string, guess string) => string

---

Example 1:

Input:
secret = "1805"
guess  = "6810"

Output:
"1B2C"

Explanation:
'8' is in the same position in both secret and guess = 1 bull
'1', '0' in both secret and guess but in the wrong position = 2 cows

---

Example 2:

Input:
secret = "1123"
guess  = "0111"

Output:
"1B1C"

---

Example 3:

Input:
secret = "1"
guess  = "0"

Output: "0B0C"

*/


function getHint(secret, guess) {
    let numB = 0;
    let numC = 0;
    for(let index in secret){
        console.log(index);
        //count B
        if(secret[index] === guess[index]){
            numB++;
            secret = secret.substr(0,index) + secret.substr(index + 1);
            guess = guess.substr(0,index) + guess.substr(index + 1);

            console.log('sescret:',secret);
            console.log('guest:',guess);
        }

    }
    console.log('sescret1:',secret);
    console.log('guest1:',guess);

    // O(n^2)
    for(let index in secret){
        console.log(index);
        //count C
        //if(secret[index] !== guess[index]){
        if(guess.includes(secret[index])){
            numC++;
            let gIndex = guess.indexOf(secret[index]);
            guess = guess.substr(0,gIndex) + guess.substr(gIndex + 1);
        }
        //}
    }


    console.log('numB:',numB);
    console.log('numC:',numC);
    const output = numB + 'B' + numC + 'C';
    return output;
}

console.log(getHint('1', '0'));
console.log(getHint('11', '01')); // 1B0C
console.log(getHint('1234', '4321')); // 0B4C
