const fs = require('fs').promises;
const fss = require('fs');

let letterValues = {
    A: 1,
    B: 2,
    C: 3,
    D: 4,
    E: 5,
    F: 6,
    G: 7,
    H: 8,
    I: 9,
    J: 10,
    K: 11,
    L: 12,
    M: 13,

    N: 14,
    O: 15,
    P: 16,
    Q: 17,
    R: 18,
    S: 19,
    T: 20,
    U: 21,
    V: 22,
    W: 23,
    X: 24,
    Y: 25,
    Z: 26,
}

async function getListWord() {

    let path = 'words.txt';
    let stats = fss.statSync(path);
    let length = stats.size;

    const fh = await fs.open(path, 'r');
    const buffer = Buffer.alloc(length, 0);
    const {bytesRead} = await fh.read(buffer, 0, length);

    const lines = buffer.toString('utf-8', 0, bytesRead).split('\n');
    let result = [];
    for (let line of lines) {
        if (isCorrectWord(line)) {
            result.push(line)
        }
    }

    return result
}

function isCorrectWord(value, needTotal = 100) {

    let sum = 0
    for (let char of value) {
        sum += letterValues[char.toUpperCase()];
    }
    if (sum === needTotal) {
        return true;
    }
    return false
}

//RUN
try {
    getListWord().then((result) =>{
        console.log(result);
    });
} catch (e) {

}

