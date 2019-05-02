//let plaintext = 'dette bliver helt ulæseligt';
//let month = 4;
//let day = 30;

let block_size = 16;
let column_size = 4;
let row_size = block_size / column_size;

let block_column, iteration3rotation;

function encode_Caesar_cipher(input, shift) {
    // Only work with printable ascii characters.
    let first_ascii = 32; // space
    let last_ascii = 126; // ~
    let unknown_ascii = 63; // ?

    let output = '';
    for (let c = 0; c < input.length; c++) {
        ascii_value = input[c].toString().charCodeAt();
        if (ascii_value < first_ascii || ascii_value > last_ascii) {
            ascii_value = unknown_ascii;
        }
        ascii_rotated = ascii_value + shift;
        if (ascii_rotated > last_ascii) {
            ascii_rotated = ascii_rotated - last_ascii + first_ascii;
        }
        if (ascii_rotated < first_ascii) {
            ascii_rotated = last_ascii - (first_ascii - ascii_rotated);
        }
        char_rotated = String.fromCharCode(ascii_rotated);
        output += char_rotated;
    }
    return output;
}

function decode_Caesar_cipher(input, shift) {
    // Only work with printable ascii characters.
    let first_ascii = 32; // space
    let last_ascii = 126; // ~

    let output = '';
    for (let c = 0; c < input.length; c++) {
        ascii_value = input[c].toString().charCodeAt();
        ascii_rotated = ascii_value - shift;
        if (ascii_rotated < first_ascii) {
            ascii_rotated = last_ascii - (first_ascii - ascii_rotated);
        }
        if (ascii_rotated > last_ascii) {
            ascii_rotated = ascii_rotated - last_ascii + first_ascii;
        }
        char_rotated = String.fromCharCode(ascii_rotated);
        output += char_rotated;
    }
    return output;
}

function encode_transposition_cipher(input, column_key, block_size = 16, column_size = 4) {
    /*
     * Split input into blocks of 16 characters.
     * Pad incomplete blocks with the character 'x'.
     * Each block is 4 columns (and thereby 4 rows; 4x4=16).
     * The first digit of the date/day is the column key. Columns are Zero indexed. Every column is shifted to the right using wrap around.
     */

    let blocks, block, row = [];
    for (let c = 0; c < input.Length; c++) {
        if (!((c + 1) % block_size)) {
            if (block.length > 0) {
                blocks += block;
            }
            block = [];
        }
        if (!(c % 4)) {
            if (row.length > 0) {
                block += row;
            }
            row = [];
        }
        row += input[c];
    }
    return blocks;
}

function encodePlaintext() {
    let plaintext = document.getElementById('plaintext').value;
    console.log(plaintext);
    let date = new Date(document.getElementById('date').value);
    let month = date.getMonth() + 1;
    let day = date.getDate();
    let round1 = month;
    let round2 = (day.toString().length < 2) ? 0 : day.toString()[0];
    let round3 = (day.toString().length > 1) ? day.toString()[1] : day;
    round3 = round3 + 2;

    // First iteration / round
    let caesar = encode_Caesar_cipher(plaintext, round1);
    console.log(caesar);

    // Second iteration / round
    let transposition = encode_transposition_cipher(caesar, round2);
    console.log(transposition);

    // Third iteration / round
    document.getElementById('result').innerText = cipher;
}

function decodeCiphertext() {
    // Third iteration / round
    // Second iteration / round
    // First iteration / round
}
