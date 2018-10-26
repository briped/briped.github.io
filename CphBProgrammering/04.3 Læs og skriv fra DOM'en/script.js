//DONE: læs teksten "Læs denne tekst" og indsæt den hvor der står "Og overskriv denne tekst"
let elInput = document.getElementById('input');
let elOutput = document.getElementById('output');
console.log(`Original indhold af input: ${elInput.innerHTML}`);
console.log(`Original indhold af output: ${elOutput.innerHTML}`);
elOutput.innerHTML = elInput.innerHTML;