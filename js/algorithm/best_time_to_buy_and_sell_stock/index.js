/*
You are given an array prices where prices[i] is the price of a given stock on the i-th day.

You want to maximize your profit by choosing a single day to buy one stock
and choosing a different day in the future to sell that stock.

Return the maximum profit you can achieve from this transaction. If you cannot achieve any profit, return 0.
 */

/* SOLUTION
Your solution keeps track of two things:

The lowest price you've seen so far (like your budget)
The biggest profit you could make (price difference)

As you look at each day's price:

If you find a lower price, remember it (might be a better day to buy!)
Check if selling at today's price would give you more profit
 */


function maxProfit(prices) {
    let lowestPrice = prices[0]

    let largestProfit = 0

    for(let currentPrice of prices){

        if(lowestPrice > currentPrice){
            lowestPrice = currentPrice
        }

        let profit = currentPrice - lowestPrice
        if(profit > largestProfit){
            largestProfit = profit
        }

    }

    return largestProfit
}


// Example usage
const arr = [7,1,5,3,6,4];

const result = maxProfit(arr);

console.log(`Max profit ${result}`);
