/*
Binary Search is a fast way to find an item in a sorted list.
It works by checking the middle item in the list first.
If the middle item is the target, you’re done!
If the target is smaller, search the left half.
If the target is bigger, search the right half.
Keep cutting the list in half until you find the target or the list is empty.
*/

function binarySearch(arr, target){
    let low = 0
    let high = arr.length

    while (low < high){
        let mid = Math.floor((low + high)/2)

        if(arr[mid] === target){
            return mid
        }

        if(arr[mid] > target) {
            high = mid - 1
        }else{
            low = mid + 1
        }
    }

    return -1
}

// Example usage
const arr = [1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21];
const target = 11;

const result = binarySearch(arr, target);

if (result !== -1) {
    console.log(`Element ${target} found at index ${result}`);
} else {
    console.log(`Element ${target} not found in the array`);
}