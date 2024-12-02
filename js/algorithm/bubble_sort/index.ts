/*
Bubble Sort, which is one of the easiest sorting algorithms to understand:

Bubble Sort goes through the list and compares each pair of items.
If two items are in the wrong order, it swaps them.
It keeps doing this until the list is completely sorted.
With each pass through the list, the biggest items "bubble up" to the end.
*/


function BubbleSort(arr: number[]){
    let n = arr.length

    for(let i = 0; i < n-1; i++){

        for(let j=0;j < n-i-1; j++ ){

            if(arr[j] > arr[j+1]){
                let tmp = arr[j+1]
                arr[j+1] = arr[j];
                arr[j] = tmp
            }

        }

    }

}


// Example usage
const arr = [64, 34, 25, 12, 22, 11, 90];
console.log("Original array:", arr);
BubbleSort(arr);
console.log("Sorted array:", arr);