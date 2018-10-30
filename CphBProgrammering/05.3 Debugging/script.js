let badeVand = [-1, 1, 1, 1, 2, 0, 1 ,-0.1, 0.1, -20, -4, 10, -10];
console.log(badeVand); // Debugging
let rises = 0;

// The obvious error is the 'badevand' variable should be 'badeVand' (CaSe SeNsiTiVe).
// Also, adding 1 to i directly in the for condition is bad coding (in my opinion) because you then have to keep track
// of that in the code block. Even though the code works, I simply don't like the approach.
//for (let i = 0; i+1 <badevand.length; i++){
for (let i = 0; i + 1 < badeVand.length; i++) {
    //if (badeVand[i]<badeVand[i+1]){
    if (badeVand[i] < badeVand[i + 1]) {
        // So rather than looking behind (into the past), this example looks ahead (into the future). Bad logic when
        // when considering that the task is to compare temperatures. You can't know the temperature of tomorrow.
        // It also shows the the need to keep track of the special "for" condition, otherwise you would never get the
        // value of the last element in the array.
        rises++;
    }

}

document.getElementById("outPut").innerHTML("Antal stigninger: " + rises);