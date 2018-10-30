let badeVand =  [-1, 1, 1, 1, 2, 0, 1 ,-0.1, 0.1, -20, -4, 10];
console.log(badeVand); // Debugging
let numberOfOnesInRow = 0;

//DONE count number of ones IN A ROW:
let setsOfOnes = []; // This is to keep track of multiple sets of ones
for (let i = 0; i < badeVand.length; i++) {
    if (badeVand[i] === 1) {
        numberOfOnesInRow += 1;
    }
    else {
        if (numberOfOnesInRow > 0) {
            setsOfOnes.push(numberOfOnesInRow);
        }
        numberOfOnesInRow = 0;
    }
}

//Output the result to a div
document.getElementById("output").innerHTML = "Antal 1'ere i træk: " + setsOfOnes;


