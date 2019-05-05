// Shamelessly stolen from Stackoverflow to automatically prefill the date input.
Date.prototype.toDateInputValue = (function () {
    var local = new Date(this);
    local.setMinutes(this.getMinutes() - this.getTimezoneOffset());
    return local.toJSON().slice(0, 10);
});
document.getElementById('date').value = new Date().toDateInputValue();


function encode_Caesar_cipher(input, shift) {
    console.log('input: ' + input);
    console.log('shift: ' + shift);

    // Only work with printable ascii characters.
    let first_ascii = 32; // space
    let last_ascii = 126; // ~
    let unknown_ascii = 63; // ?

    /*
    first_ascii = 97; // a
    last_ascii = 122; // z
    unknown_ascii = 120; // x
    input = input.toString().toLowerCase();
    */

    let output = '';
    for (let c = 0; c < input.length; c++) {
        // Iterate through each character in the input string.
        ascii_value = input[c].toString().charCodeAt(); // Convert to ASCII value.
        if (ascii_value < first_ascii || ascii_value > last_ascii) {
            // The character is not within the allowed ASCII range.
            ascii_value = unknown_ascii;
        }
        console.log('ascii_value: ' + ascii_value);
        ascii_rotated = ascii_value + shift; // Calculate the shifted ASCII value.
        console.log('ascii_rotated: ' + ascii_rotated);
        if (ascii_rotated > last_ascii) {
            // The rotated / shifted ASCII value is outside (bigger) than the allowed ASCII values.
            ascii_rotated = ascii_rotated - last_ascii + first_ascii;
        }
        if (ascii_rotated < first_ascii) {
            // The rotated / shifted ASCII value is outside (smaller) than the allowed ASCII values.
            ascii_rotated = last_ascii - (first_ascii - ascii_rotated);
        }
        console.log('ascii_rotated modified: ' + ascii_rotated);
        char_rotated = String.fromCharCode(ascii_rotated);
        console.log('char_rotated: ' + char_rotated);
        output += char_rotated;
    }
    return output;
}

function decode_Caesar_cipher(input, shift) {
    console.log('input: ' + input);
    console.log('shift: ' + shift);

    // Only work with printable ascii characters.
    let first_ascii = 32; // space
    let last_ascii = 126; // ~

    /*
    first_ascii = 97; // a
    last_ascii = 122; // z
    */

    let output = '';
    for (let c = 0; c < input.length; c++) {
        // Iterate through each character in the input string.
        ascii_value = input[c].toString().charCodeAt(); // Convert to ASCII value.
        console.log('ascii_value: ' + ascii_value);
        ascii_rotated = ascii_value - shift; // Calculate the shifted ASCII value.
        console.log('ascii_rotated: ' + ascii_rotated);
        if (ascii_rotated < first_ascii) {
            // The rotated / shifted ASCII value is outside (smaller) than the allowed ASCII values.
            ascii_rotated = last_ascii - (first_ascii - ascii_rotated);
        }
        if (ascii_rotated > last_ascii) {
            // The rotated / shifted ASCII value is outside (bigger) than the allowed ASCII values.
            ascii_rotated = ascii_rotated - last_ascii + first_ascii;
        }
        console.log('ascii_rotated modified: ' + ascii_rotated);
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

    console.log('input: ' + input);
    console.log('column_key: ' + column_key);
    console.log('block_size: ' + block_size);
    console.log('column_size: ' + column_size);
    let padding = block_size - (input.length % block_size);
    for (let i = 0; i < padding; i++) {
        input += 'x';
    }
    console.log('padded input: ' + input);

    let row = [];
    let block = [];
    let row_size = block_size / column_size;
    let column;
    let output = '';
    for (let i = 0; i < input.length; i++) {
        // Iterate through each character in the input string.
        row.push(input[i]); // Push each character to the active row array.
        if (((i + 1) % column_size) === 0) {
            // Column size is reached.
            block.push(row); // Push the active row onto the block array.
            row = []; // Reset / empty the row array in preparation for the next row.
            if (((i + 1) % block_size) === 0) {
                // Block size is reached.
                for (let c = 0; c < column_size; c++) {
                    // Iterated through each column in the block array.
                    column = c + column_key; // Add our column key, so we know which column is the active column (to be read first).
                    if (column > (column_size - 1)) {
                        // The active column is bigger than the max. column size. Calculate the new active column.
                        column = column - column_size;
                    }
                    for (let r = 0; r < row_size; r++) {
                        // Iterate through each row and read the active column.
                        output += block[r][column];
                    }
                }
                block = [];
            }
        }
    }
    return output;
}

function decode_transposition_cipher(input, column_key, block_size = 16, column_size = 4) {
    let row_size = block_size / column_size;
    let blocks = input.length / block_size;
    let column;
    let output = '';

    let block_template = [];
    // Create the block array. This is so I can start writing the ciphertext beyond index 0.
    for (let r = 0; r < row_size; r++) {
        block_template[r] = [];
        for (let c = 0; c < column_size; c++) {
            block_template[r][c] = null;
        }
    }

    let i = 0;
    for (let b = 0; b < blocks; b++) {
        // Iterate through the number of blocks.
        block = block_template; // Reset the block.
        for (let c = 0; c < column_size; c++) {
            // Iterate through each column for the block array.
            column = c + column_key; // Add our column key, so we know which column is the active column (to be written first).
            if (column > (column_size - 1)) {
                // The active column is bigger than the max. column size. Calculate the new active column.
                column = column - column_size;
            }
            for (let r = 0; r < row_size; r++) {
                // Iterate through each row for the block array and add the current character.
                block[r][column] = input[i];
                i++;
            }
        }
        for (r = 0; r < block.length; r++) {
            for (c = 0; c < block[r].length; c++) {
                output += block[r][c];
            }
        }
    }
    return output;
}


function encodePlaintext() {
    let plaintext = document.getElementById('plaintext').value.replace(/[\r\n]/g, '');
    console.log('input plaintext: ' + plaintext);
    let date = new Date(document.getElementById('date').value);
    let month = date.getMonth() + 1;
    let day = date.getDate();
    let round1 = month;
    let round2 = (day.toString().length < 2) ? 0 : Number(day.toString()[0]);
    let round3 = (day.toString().length > 1) ? Number(day.toString()[1]) : day;
    round3 = (round3 + 2) * -1; // Multiply by -1 to flip from a positive number to a negative number (in order to shift left instead of right).

    let ciphertext;
    // First iteration / round
    ciphertext = encode_Caesar_cipher(plaintext, round1);
    console.log('encode round 1: ' + ciphertext);
    document.getElementById('rounds').innerHTML = 'Round 1: ' + ciphertext + '<br />';

    // Second iteration / round
    ciphertext = encode_transposition_cipher(ciphertext, round2);
    console.log('encode round 2: ' + ciphertext);
    document.getElementById('rounds').innerHTML += 'Round 2: ' + ciphertext + '<br />';

    // Third iteration / round
    //ciphertext = plaintext;
    ciphertext = encode_Caesar_cipher(ciphertext, round3);
    console.log('encode round 3: ' + ciphertext);
    document.getElementById('rounds').innerHTML += 'Round 3: ' + ciphertext + '<br />';

    // Output the ciphertext.
    document.getElementById('result').innerText = ciphertext;
}

function decodeCiphertext() {
    let ciphertext = document.getElementById('ciphertext').value.replace(/[\r\n]/g, '');
    console.log('input ciphertext: ' + ciphertext);
    let date = new Date(document.getElementById('date').value);
    let month = date.getMonth() + 1;
    let day = date.getDate();
    let round1 = month;
    let round2 = (day.toString().length < 2) ? 0 : Number(day.toString()[0]);
    let round3 = (day.toString().length > 1) ? Number(day.toString()[1]) : day;
    round3 = (round3 + 2) * -1; // Multiply by -1 to flip from a positive number to a negative number (in order to shift left instead of right).

    let plaintext;
    // Third iteration / round
    ciphertext = decode_Caesar_cipher(ciphertext, round3);
    console.log('decode round 3: ' + ciphertext);
    document.getElementById('rounds').innerHTML = 'Round 3: ' + ciphertext + '<br />';
    //plaintext = ciphertext;

    // Second iteration / round
    ciphertext = decode_transposition_cipher(ciphertext, round2);
    console.log('decode round 2: ' + ciphertext);
    document.getElementById('rounds').innerHTML += 'Round 2: ' + ciphertext + '<br />';

    // First iteration / round
    plaintext = decode_Caesar_cipher(ciphertext, round1);
    console.log('decode round 1: ' + plaintext);
    document.getElementById('rounds').innerHTML += 'Round 1: ' + plaintext + '<br />';

    // Output the ciphertext.
    document.getElementById('result').innerText = plaintext;
}
