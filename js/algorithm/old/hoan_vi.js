function findMin(input,minArr=[],usedChars = []) {
    var i, ch, chars = input.split("");
    for (i = 0; i < chars.length; i++) {
        ch = chars.splice(i, 1);
        usedChars.push(ch);
        if (chars.length === 0){
            let strTmp = usedChars.join("")
            if(strTmp[0] !== '0'){
                let numActual = Number(strTmp);
                if(minArr.length===0){
                    minArr.push(numActual)
                }else{
                    let min = minArr.pop()
                    if(min > numActual){
                        minArr.push(numActual)
                    }else{
                        minArr.push(min)
                    }
                }
            }
        }
        findMin(chars.join(""),minArr,usedChars);
        chars.splice(i, 0, ch);
        usedChars.pop();
    }
    return minArr[0]
};
let a= findMin("11201200")
console.log(a)

function findMinV1(permutation,minArr=[]) {
    permutation = permutation.split("")
    var length = permutation.length,
        c = new Array(length).fill(0),
        i = 1, k, p;
    checkMin(permutation,minArr)
    while (i < length) {
        if (c[i] < i) {
            k = i % 2 && c[i];
            p = permutation[i];
            permutation[i] = permutation[k];
            permutation[k] = p;
            ++c[i];
            i = 1;
            checkMin(permutation,minArr)

        } else {
            c[i] = 0;
            ++i;
        }
    }
    return minArr.pop();
}

function checkMin(arrNum,minArr){
    let strTmp = arrNum.join("")
    if(strTmp[0] !== '0'){
        let numActual = Number(strTmp);
        if(minArr.length===0){
            minArr.push(numActual)
        }else{
            let min = minArr.pop()
            if(min > numActual){
                minArr.push(numActual)
            }else{
                minArr.push(min)
            }
        }
    }
}


console.log(findMin("8840810935771860"));
