// Size of the Connect 4 board
const rows = 6;
const columns = 7;

// Global variables
let gameArray, currentPlayer, browserLanguage, board = document.getElementById('board');

// Start the game
resetGame();

function detectLanguage() {
    console.log(`function detectLanguage()...`); // Debugging
    browserLanguage = 'en'; // Default language i no other is found...
    for (let l = 0; l < navigator.languages.length; l++) {
        for (let key in lang) {
            if (lang.hasOwnProperty(key) && key === navigator.languages[l]) {
                browserLanguage = key;
                break;
            }
        }
    }
}

function resetGame() {
    console.log(`function resetGame()...`); // Debugging
    gameArray = [];
    for (let r = 0; r < rows; r++) {
        gameArray[r] = [];
        for (let c = 0; c < columns; c++) {
            gameArray[r][c] = 0;
        }
    }
    currentPlayer = 1;
    detectLanguage();
    document.getElementsByTagName('title')[0].innerHTML = lang[browserLanguage].title;
    document.getElementById('title').innerHTML = lang[browserLanguage].title;
    document.getElementById('currentPlayer').className = `circle${currentPlayer}`;
    document.getElementById('currentPlayer').innerHTML = currentPlayer.toString();
    document.getElementById('player1').innerHTML = `${lang[browserLanguage].Player} 1: <span>0</span>`;
    document.getElementById('player2').innerHTML = `${lang[browserLanguage].Player} 2: <span>0</span>`;
    document.getElementById('resetGame').innerHTML = lang[browserLanguage].newGame;
    drawBoard();
}

function updatePlayer() {
    console.log(`function updatePlayer()...`); // Debugging
    currentPlayer = (currentPlayer === 1) ? 2 : 1;
    document.getElementById('currentPlayer').className = `circle${currentPlayer}`;
    document.getElementById('currentPlayer').innerHTML = currentPlayer.toString();
}

function insertChecker(e) {
    console.log(`function insertChecker(e: ${e.id})...`); // Debugging
    let col = Number(e.id.substr(e.id.indexOf('c', 0) + 1));
    //let row = Number(e.id.substr(e.id.indexOf('r', 0) + 1, e.id.length - e.id.indexOf('c', 0) - 1));
    //console.log(`col: ${col}. row: ${row}.`); // Debugging

    if (updateArray(currentPlayer, col)) {
        updatePlayer();
    }
    drawBoard();
    checkConnect4();
}

function checkConnect4() {
    //TODO: Check if there's 4 connected. Vertically or Horizontally or Diagonally.
    let count1h = 0;
    let count1v = 0;
    let count1d = 0;
    let count2h = 0;
    let count2v = 0;
    let count2d = 0;
    for (let r = 0; r < gameArray.length; r++) {
        for (let c = 0; c < gameArray[r].length; c++) {

        }
    }
}

function drawBoard() {
    console.log(`function drawBoard()...`); // Debugging
    board.innerHTML = '';
    for (let r = 0; r < gameArray.length; r++) {
        let rowHTML = '';
        let rowHeader = '';
        for (let c = 0; c < gameArray[r].length; c++) {
            if (r === 0) {
                rowHeader += `<button id="c${c}" class="player${currentPlayer}" onclick="insertChecker(this);">${c + 1}</button>`;
            }
            rowHTML += `<div id="r${r}c${c}" class="circle${gameArray[r][c]}" onclick="insertChecker(this);"></div>`;
        }
        board.innerHTML += (r === 0) ? rowHeader + rowHTML: rowHTML;
    }
}

function updateArray(player = -1, col = -1) {
    console.log(`function updateArray(player:${player}, col:${col})...`); // Debugging
    if (col < 0 || col >= columns) {
        return false; // Supplied column isn't valid.
    }
    player = (player >= 0 && player <= 2) ? player : 0;
    for (let r = gameArray.length; r > 0; r--) {
        if (gameArray[r-1][col] === 0) {
            gameArray[r-1][col] = player;
            return true;
        }
    }
}