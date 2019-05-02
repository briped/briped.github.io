let plaintext = 'dette bliver helt ulæseligt';
let month = 4;
let day = 30;

let iteration1rotation = month;
let iteration2size = 16;

let block_column, iteration3rotation;

if (day.toString().length < 2) {
    block_column = 0;
    iteration3rotation = day;
}
else {
    block_column = day.toString()[0];
    iteration3rotation = day.toString[1];
}

let first_ascii = 32;
let last_ascii = 255;

let ciphertext = '';

for (let c = 0; c < plaintext.length; c++) {
    ascii_value = c.charCodeAt(0);
    ascii_rotated = ascii_value + iteration1rotation;
    if (ascii_rotated < first_ascii) {
        ascii_rotated = ascii_rotated - last_ascii + first_ascii
    }
    ciphertext += String.fromCharCode(ascii_rotated);
}

console.log(ciphertext);