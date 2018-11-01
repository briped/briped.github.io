// Fire på stribe == Connect 4 (c4)

// Board/grid size.
const rows = 6;
const cols = 7;

// Checker size/radius and offset.
const radius = 40;
const offset = 50;

// Colors for the pieces.
const boardColor = 'Yellow';
const player1Color = 'Red';
const player2Color = 'Blue';

// Declare an empty array globally. Will dynamically populate it and modify it.
let c4array = [];

// Declare canvas and context globally, and reference the tag.
let canvas = document.getElementById('connect4');
let ctx = canvas.getContext('2d');

// Resize canvas to fit the board size.
canvas.width = ((offset + radius) * cols) + (offset - radius);
canvas.height = ((offset + radius) * rows) + (offset - radius);
// Set the board color.
canvas.style.backgroundColor = boardColor;

// Ask for player # and checker placement.
// This is not how Connect 4 is played. Player can only decide on the column, and the checker will then be places in the
// lowest (highest number) unoccupied row for that column. But the task asks for X, Y position, so I'll be lazy and do
// only that...
let pickPlayer = Number(prompt('Enter player # (1 - 2):'));
let pickCol = Number(prompt(`Enter column # (0 - ${cols - 1}):`));
let pickRow = Number(prompt(`Enter row # (0 - ${rows - 1}):`));

drawBoardWithPieceAt(pickPlayer, pickCol, pickRow);

function checker(x, y, radius, fillColor = 'white', strokeColor = fillColor) {
    console.log(`function checker(x:${x}, y:${y}, radius:${radius}, fillColor:${fillColor}, strokeColor:${strokeColor})`); // Debugging

    ctx.beginPath();
    ctx.arc(x, y, radius, 0, Math.PI*2);
    ctx.fillStyle = fillColor;
    ctx.fill();
    ctx.strokeStyle = strokeColor;
    ctx.stroke();
    ctx.closePath();
}

function drawBoardWithPieceAt(player, col, row) {
    console.log(`function drawBoardWithPieceAt(player:${player}, col:${col}, row:${row})`); // Debugging

    drawBoard(cols, rows);
    drawPieceAt(player, col, row);
    /*
    drawPieceAt(1, 5, 1);
    drawPieceAt(2, 4, 1);
    drawPieceAt(3, 3, 1);
    drawPieceAt(4, 2, 1);
    drawPieceAt(4, 5, 2);
    drawPieceAt(3, 4, 2);
    drawPieceAt(2, 3, 2);
    drawPieceAt(1, 2, 2);
    */
}

function drawBoard(cols, rows) {
    console.log(`function drawBoard(col:${cols}, row:${rows})`);

    // Iterate through the rows...
    for (let r = 0; r < rows; r++) {
        // Add/push an empty array (row) on the Connect 4 array
        c4array.push([]);
        // For each row, iterate through the columns...
        for (let c = 0; c < cols; c++) {
            // Add/push a blank/empty checker selection on the Connect 4 array, for the current iteration of row and column.
            c4array[r].push(0);

            // Calculate the x and y coordinates for the current iteration of row and column.
            let x = offset + ((offset + radius) * c);
            let y = offset + ((offset + radius) * r);
            console.log(`x(col).y(row): ${x}.${y}`); // Debugging

            // Draw a blank checker.
            checker(x, y, radius, 'white', 'gray');
        }
    }
    console.log(c4array); // Debugging
}

function drawPieceAt(player, col, row) {
    console.log(`function drawPieceAt(player:${player}, col:${col}, row:${row})`); // Debugging

    // Declare the player color. For some reason it doesn't work unless declared outside the. Tried declaring it in each if/else section.
    let color = 'white';
    if (col < cols && row < rows) {
        // We can't place a checker outside the Connect 4 board/grid. So check if something valid was supplied.
        if (player === 1) {
            // Player 1 placed a checker. Update the Connect 4 array to reflect this and set the color to player 1 color.
            c4array[row][col] = 1;
            color = player1Color;
        }
        else if (player === 2) {
            // Player 2 placed a checker. Update the Connect 4 array to reflect this and set the color to player 2 color.
            c4array[row][col] = 2;
            color = player2Color;
        }
        else {
            // Valid location was configured, but neither player 1 nor player 2 was supplied, so resetting checker to blank.
            c4array[row][col] = 0;
            color = 'white';
        }
        // Calculate the x and y coordinates for the checker.
        let x = offset + ((offset + radius) * col);
        let y = offset + ((offset + radius) * row);
        console.log(`x(col).y(row): ${x}.${y}`); // Debugging
        console.log(c4array); // Debugging
        checker(x, y, radius, color, 'gray');
    }
}





//------------------
//TODO Implementeres senere...
function removePieceAt( x,y){

}
//TODO Implementeres senere...
function showScore(player1Score, player2Score){

}
//TODO Implementeres senere...
function showWinner(playerName){

}