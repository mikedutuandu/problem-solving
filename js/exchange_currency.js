
let rates = [
    ['jpy', 'usd', 1],
    ['jpy', 'eur', 2],
    ['usd', 'cad', 3],
    ['usd', 'aud', 4],
    ['usd', 'pond', 5],
    ['pond', 'sfr', 6],
    ['eur', 'sfr', 7]
]

function prepareData(rates){
    let newRates = {};
    for(let i in rates){
        let rate = rates[i];
        if(!(rate[0] in newRates)){
            newRates[rate[0]] = {}
        }
        newRates[rate[0]][rate[1]] = rate[2];

        if(!(rate[1] in newRates)){
            newRates[rate[1]] = {}
        }

        newRates[rate[1]][rate[0]] = Number((1/rate[2]).toFixed(2));
    }

    return newRates;
}

function findRates(data,cur1,cur2,visited=[],result=[],calculated_rates=[1]){
    visited.push(cur1);
    let calculated_rate = calculated_rates.pop();
    for(let cur in data[cur1]){

        let nextValRate = Number((data[cur1][cur] * calculated_rate).toFixed(2));

        if(cur === cur2){
            result.push(nextValRate);

        }else{
            if(!visited.includes(cur)){
                calculated_rates.push(nextValRate);
                findRates(data,cur,cur2,visited,result,calculated_rates);
            }
        }
    }
    return result;
}


let newRates = prepareData(rates);

let result = findRates(newRates,'usd','cad');

console.log(result);

console.log(newRates);
/*
{
   "jpy":{
      "usd":1,
      "eur":2
   },
   "usd":{
      "jpy":1,
      "cad":3,
      "aud":4,
      "pond":5
   },
   "eur":{
      "jpy":0.5,
      "sfr":7
   },
   "cad":{
      "usd":0.33
   },
   "aud":{
      "usd":0.25
   },
   "pond":{
      "usd":0.2,
      "sfr":6
   },
   "sfr":{
      "pond":0.17,
      "eur":0.14
   }
}
*/

let a= 1* 2 * 7 * 0.17 * 0.2;
console.log(a)