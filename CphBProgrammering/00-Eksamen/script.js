// Size of the Connect 4 board
const rows = 6;
const columns = 7;

// Global variables
let gameArray, gameWon, currentPlayer, player1score = 0, player2score = 0, browserLanguage, debug = false, board = document.getElementById('board');

// Start the game
resetGame();

function detectLanguage() {
    if (debug === true) console.log(`function detectLanguage()...`); // Debugging
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

function showHideDebug() {
    if (debug === true) console.log(`function showHideDebug()...`);
        debug = (debug !== true);
    let elDebug = document.getElementsByClassName('debug');
    for (let e = 0; e < elDebug.length; e++) {
        elDebug[e].style.display = (debug === true) ? 'block' : 'none';
    }
}

function resetGame() {
    if (debug === true) console.log(`function resetGame()...`);
    gameArray = [];
    for (let r = 0; r < rows; r++) {
        gameArray[r] = [];
        for (let c = 0; c < columns; c++) {
            gameArray[r][c] = 0;
        }
    }
    gameWon = 0;
    currentPlayer = 1;
    hideOverlay();
    detectLanguage();
    document.getElementsByTagName('title')[0].innerHTML = lang[browserLanguage].title;
    document.getElementById('title').innerHTML = lang[browserLanguage].title;
    document.getElementById('player1').getElementsByClassName('score')[0].innerHTML = player1score;
    document.getElementById('player2').getElementsByClassName('score')[0].innerHTML = player2score;
    document.getElementById('resetGame').innerHTML = lang[browserLanguage].newGame;
    drawBoard();
}

function updatePlayer() {
    if (debug === true) console.log(`function updatePlayer()...`); // Debugging
    currentPlayer = (currentPlayer === 1) ? 2 : 1;
}

function insertChecker(e) {
    if (debug === true) console.log(`function insertChecker(e: ${e.id})...`); // Debugging
    let col = Number(e.id.substr(e.id.indexOf('c', 0) + 1));
    //let row = Number(e.id.substr(e.id.indexOf('r', 0) + 1, e.id.length - e.id.indexOf('c', 0) - 1));

    if (updateArray(currentPlayer, col)) {
        gameWon = checkForWinner();
        if (gameWon !== 0) {
            player1score = (currentPlayer === 1) ? player1score + 1 : player1score;
            player2score = (currentPlayer === 2) ? player2score + 1 : player2score;
            document.getElementById('player1').getElementsByClassName('score')[0].innerHTML = player1score;
            document.getElementById('player2').getElementsByClassName('score')[0].innerHTML = player2score;
            document.getElementById('overlayText').innerHTML = `${lang[browserLanguage].Player} ${gameWon}<br />${lang[browserLanguage].WON}`;
            document.getElementById('overlay').style.display = 'block';
        }
        updatePlayer();
        drawBoard();
    }
}

function hideOverlay() {
    if (debug === true) console.log(`function hideOverlay()...`);
    document.getElementById('overlay').style.display = 'none';
}

function checkForWinner(length = 4) {
    if (debug === true) console.log(`function checkForWinner(length: ${length})...`); // Debugging
    let checkersInRow;
    //TODO: Change to store winning indexes, so to be able to mark the winning checkers.
    // Checking vertical
    checkersInRow = 0;
    for (let c = 0; c < gameArray[gameArray.length - 1].length; c++) {
        for (let r = 0; r < gameArray.length; r++) {
            checkersInRow = (gameArray[r][c] === currentPlayer) ? checkersInRow + 1 : 0;
            if (debug === true) console.log(`p${currentPlayer} c${c} vertical: ${checkersInRow}`);
            if (checkersInRow >= length) {
                return currentPlayer;
            }
        }
        checkersInRow = 0;
    }
    // Checking horizontal
    checkersInRow = 0;
    for (let r = 0; r < gameArray.length; r++) {
        for (let c = 0; c < gameArray[r].length; c++) {
            checkersInRow = (gameArray[r][c] === currentPlayer) ? checkersInRow + 1 : 0;
            if (debug === true) console.log(`p${currentPlayer} r${r} horizontal: ${checkersInRow}`);
            if (checkersInRow >= length) {
                return currentPlayer;
            }
        }
        checkersInRow = 0;
    }
    // Checking diagonal ascending
    checkersInRow = 0;
    for (let r = length - 1; r < gameArray.length; r++) {
        for (let c = 0; c < gameArray[r].length - length + 1; c++) {
            for (let o = 0; o < length; o++) {
                checkersInRow = (gameArray[r - o][c + o] === currentPlayer) ? checkersInRow + 1 : 0;
                if (debug === true) console.log(`p${currentPlayer} r${r - o}c${c + o} diagonal ascending: ${checkersInRow}`);
                if (checkersInRow >= length) {
                    return currentPlayer;
                }
            }
            checkersInRow = 0;
        }
    }
    // Checking diagonal descending
    checkersInRow = 0;
    for (let r = length - 1; r < gameArray.length; r++) {
        for (let c = length - 1; c < gameArray[r].length; c++) {
            for (let o = 0; o < length; o++) {
                checkersInRow = (gameArray[r - o][c - o] === currentPlayer) ? checkersInRow + 1 : 0;
                if (debug === true) console.log(`p${currentPlayer} r${r - o}c${c - o} diagonal descending: ${checkersInRow}`);
                if (checkersInRow >= length) {
                    return currentPlayer;
                }
            }
            checkersInRow = 0;
        }
    }
    return 0;
}

function drawBoard() {
    if (debug === true) console.log(`function drawBoard()...`); // Debugging
    board.innerHTML = '';
    for (let r = 0; r < gameArray.length; r++) {
        let rowHTML = '';
        let rowHeader = '';
        for (let c = 0; c < gameArray[r].length; c++) {
            if (r === 0) {
                rowHeader += `<button id="c${c}" class="player${currentPlayer}" onclick="insertChecker(this);">${c + 1}</button>`;
            }
            rowHTML += `<div id="r${r}c${c}" class="circle${gameArray[r][c]}" onclick="insertChecker(this);"><span class="debug" style="display: ${(debug === true) ? 'block' : 'none'};">[${r}][${c}]</span></div>`;
        }
        board.innerHTML += (r === 0) ? rowHeader + rowHTML: rowHTML;
    }
}

function updateArray(player = -1, col = -1) {
    if (debug === true) console.log(`function updateArray(player:${player}, col:${col})...`); // Debugging
    if (col < 0 || col >= columns || gameWon !== 0) {
        return false;
    }
    player = (player >= 0 && player <= 2) ? player : 0;
    for (let r = gameArray.length; r > 0; r--) {
        if (gameArray[r-1][col] === 0) {
            gameArray[r-1][col] = player;
            return true;
        }
    }
}