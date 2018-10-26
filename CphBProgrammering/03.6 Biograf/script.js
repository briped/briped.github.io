let cinema = []; // Declare global array.

function createCinema() {
    //let cinema = [];
    let rows = Number(document.getElementById('rows').value);
    let seats = Number(document.getElementById('seats').value)
    let tableRows = '';
    for (let r = 0; r < rows; r++) {
        cinema.push([]); // Create the 'row'.
        let tableCols = '';
        for (let c = 0; c < seats; c++) {
            cinema[r].push(true); // Add a seat/column to the current row.
            tableCols += `<td><button id="r${r}c${c}" style="background-color: green;" onclick="bookSeat(this); return false;">${r}.${c}</button></td>`;
        }
        tableRows += '<tr>' + tableCols + '</tr>';
    }
    document.getElementById('room').innerHTML = tableRows;
    document.getElementById('availabilityUI').style.visibility = 'visible';
}

function bookSeat(element) {
    let seatCoordinates = element.innerText.split('.');
    let seatRow = seatCoordinates[0];
    let seatCol = seatCoordinates[1];
    cinema[seatRow][seatCol] = (cinema[seatRow][seatCol] === true) ? false : true;
    element.style.backgroundColor = (element.style.backgroundColor == 'red') ? 'green' : 'red';
}

function listSeats(state) {
    let output = '';
    let seatsFound = 0;
    for (let r = 0; r < cinema.length; r++) {
        for (let c = 0; c < cinema[r].length; c++) {
            if (cinema[r][c] === true && (state =='all' || state == 'available')) {
                output += (seatsFound > 0) ? ', ' : '';
                output +=  `<span style="color: green;">${r}.${c}</span>`;
                seatsFound++;
            }
            if (cinema[r][c] === false && (state =='all' || state == 'unavailable')) {
                output += (seatsFound > 0) ? ', ' : '';
                output +=  `<span style="color: red;">${r}.${c}</span>`;
                seatsFound++;
            }
        }
    }
    document.getElementById('seatList').innerHTML = output;
}