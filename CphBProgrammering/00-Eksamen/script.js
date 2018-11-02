const rows = 6;
const columns = 7;

/*
const radius = 40;
const offset = 50;

const boardColor = 'Yellow';
const playerColor = ['white', 'blue', 'red'];
*/

let c4board = document.getElementById('c4board');
let currentPlayer = 1;

let c4array;
updateArray();
drawBoard();

function updatePlayer() {
    //console.log(`function updatePlayer()...`); // Debugging
    currentPlayer = (currentPlayer === 1) ? 2 : 1;
}

function insertChecker(e) {
    //console.log(`function insertChecker(e: ${e.id})...`); // Debugging
    let col = Number(e.id.substr(e.id.indexOf('c', 0) + 1));
    let row = Number(e.id.substr(e.id.indexOf('r', 0) + 1, e.id.length - e.id.indexOf('c', 0) - 1));
    //console.log(`col: ${col}. row: ${row}.`); // Debugging

    if (updateArray(row, col, currentPlayer)) {
        updatePlayer();
    }
    drawBoard();
    checkConnect4();
}

function checkConnect4() {
    //TODO: Check if there's 4 connected. Vertically or Horizontally or Diagonally.
}

function drawBoard() {
    //console.log(`function drawBoard()...`); // Debugging
    c4board.innerHTML = '';
    for (let r = 0; r < c4array.length; r++)
    {
        let rowHTML = '';
        let rowHeader = '';
        for (let c = 0; c < c4array[r].length; c++)
        {
            if (r === 0)
            {
                rowHeader += `<button id="c${c}" class="player${currentPlayer}" onclick="insertChecker(this);">${c + 1}</button>`;
            }
            rowHTML += `<div id="r${r}c${c}" class="circle${c4array[r][c]}" onclick="insertChecker(this);"></div>`;
        }
        c4board.innerHTML += (r === 0) ? rowHeader + rowHTML: rowHTML;
    }
}

function updateArray(row = -1, col = -1, player = -1) {
    //TODO: Modify so adding by column, and row will always be highest row index available (if any).
    console.log(`function updateArray(row: ${row}, col: ${col}, player: ${player})...`); // Debugging
    let arrayChanged = false;
    player = (row === -1 && col === -1 && player === -1) ? 0 : player;
    c4array = ((row === -1 && col === -1 && player === -1) || c4array === undefined) ? [] : c4array;
    for (let r = 0; r < rows; r++) {
        if (c4array[r] === undefined) {
            c4array[r] = [];
        }
        for (let c = 0; c < columns; c++) {
            if (c4array[r][c] === undefined) {
                c4array[r][c] = 0;
            }
            if (row === r && col === c && c4array[r][c] === 0) {
                c4array[r][c] = player;
                arrayChanged = true;
            }
        }
    }
    return (arrayChanged === true);
}

function drawCircle(player = 0) {
    console.log(`function drawCircle(player: ${player})...`); // Debugging
    c4board.innerHTML += `<span class="0"></span>`;
}
