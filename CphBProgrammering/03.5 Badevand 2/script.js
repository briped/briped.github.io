let temp = [-1, 1, 1, 1, 2, 0, 1 , -0.1, 0.1, -20, -4, 10];
let tempPrevious = temp[0]; // Sidste temperatur kender vi ikke, så logisk set er sidste temperatur samme som først målte temperatur
let tempIncrease = 0;
for (let i = 0; i < temp.length; i++) {
    tempIncrease += (temp[i] > tempPrevious) ? 1 : 0;
    tempPrevious = temp[i];
}
document.write(tempIncrease);