
let badeVand =  [-1, 1, 1, 1, 2, 0, 1 ,-0.1, 0.1, -20, -4, 10];

let numberOfOnes = 0;


//DONE count number of ones:
for (i = 0; i < badeVand.length; i++) {
    numberOfOnes += (badeVand === 1) ? 1 : 0;
}

//Output the result to a div
document.getElementById("output").innerHTML = "Antal 1'ere: " + numberOfOnes;
