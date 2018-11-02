// Size of the Connect 4 board
const rows = 6;
const columns = 7;

// Global variables
let gameArray, gameWon, currentPlayer, player1score = 0, player2score = 0, browserLanguage, board = document.getElementById('board');

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
    gameWon = 0;
    currentPlayer = 1;
    detectLanguage();
    document.getElementsByTagName('title')[0].innerHTML = lang[browserLanguage].title;
    document.getElementById('title').innerHTML = lang[browserLanguage].title;
    document.getElementById('currentPlayer').className = `circle${currentPlayer}`;
    document.getElementById('currentPlayer').innerHTML = currentPlayer.toString();
    document.getElementById('player1').innerHTML = `${lang[browserLanguage].Player} 1: <span>${player1score}</span>`;
    document.getElementById('player2').innerHTML = `${lang[browserLanguage].Player} 2: <span>${player2score}</span>`;
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
        gameWon = checkForWinner();
        if (gameWon !== 0) {
            player1score = (currentPlayer === 1) ? player1score + 1 : player1score;
            player2score = (currentPlayer === 2) ? player2score + 1 : player2score;
            document.getElementById('player1').innerHTML = `${lang[browserLanguage].Player} 1: <span>${player1score}</span>`;
            document.getElementById('player2').innerHTML = `${lang[browserLanguage].Player} 2: <span>${player2score}</span>`;
            alert(`Player ${currentPlayer} wins!`);
        }
        updatePlayer();
        drawBoard();
    }
}

function checkForWinner(length = 4) {
    console.log(`function checkForWinner(length: ${length})...`); // Debugging
    //TODO: Check if there's 4 connected. Vertically or Horizontally or Diagonally.
    // Horizontal check seems to work. Vertical check doesn't seem to work. Haven't worked on diagonally yet.
    let horizontal = 0;
    let vertical = 0;
    let diagonalTopDown = 0;
    let diagonalDownTop = 0;
    let r, c;
    console.log(gameArray);
    for (r = gameArray.length - 1; r > 0; r--) {
        console.log(`... for (r = gameArray.length(${gameArray.length}) - 1{${gameArray.length - 1}; r(${r}) > 0; r++)...`);
        if (r === gameArray.length - 1) {
            vertical = 0;
        }
        for (c = 0; c < gameArray[r].length; c++) {
            console.log(`... for (c = 0; c(${c}) < gameArray[r].length(${gameArray[r].length}); c++)...`);
            if (c === 0) {
                horizontal = 0;
            }
            horizontal = (gameArray[r][c] === currentPlayer) ? horizontal + 1 : 0;
            console.log(`horizontal: ${horizontal}`);
            if (horizontal >= length) {
                return currentPlayer;
            }
        }
        vertical = (gameArray[r][c] === currentPlayer) ? vertical + 1 : 0;
        console.log(`vertical: ${vertical}`);
        if (vertical >= length) {
            return currentPlayer;
        }
    }
    return 0;
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
    if (col < 0 || col >= columns || gameWon !== 0) {
        return false; // Supplied column isn't valid, or the game have already been won.
    }
    player = (player >= 0 && player <= 2) ? player : 0;
    for (let r = gameArray.length; r > 0; r--) {
        if (gameArray[r-1][col] === 0) {
            gameArray[r-1][col] = player;
            return true;
        }
    }
}