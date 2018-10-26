let pyramidHeight = Number(prompt('Hvor høj skal pyramiden være?'));

// Beregn bredden på pyramidens base. Skal bruges senere.
let pyramidWidth = (pyramidHeight * 2) - 1;

// Loop gennem hvert lag af pyramiden.
for (let l = 1; l <= pyramidHeight; l++) {
    // Nulstil padding og bricks ved starten af hver iteration.
    let padding = '';
    let bricks = '';

    // Beregn bricks nødvendigt i layer.
    let numBricks = (l * 2) - 1;

    // Beregn padding på hver side af pyramiden i layer.
    let numPadding = ((pyramidWidth - numBricks) === 0) ? 0 : (pyramidWidth - numBricks) / 2;

    // Lav padding/luften på hver side af pyramiden. Gider ikke en løkke når nu det kan gøres simplere med .repeat().
    padding = ' '.repeat(numPadding); // Overrasket over at det lykkedes med mellemrum i HTML, eftersom jeg mente det ville kræve &nbsp; Vælger i stedet for punktum fordi det er pænere.
    // Lav selve pyramidens lag. Gider ikke en løkke når nu det kan gøres simplere med .repeat().
    bricks = 'A'.repeat((l * 2) - 1);
    // Sammensæt layer.
    let layer = padding + bricks + padding;
    // Skriv til konsollen
    console.log(layer);
    // Brug den eksisterende funktion til at skrive til websiden
    documentLog(layer);
}

//Christians hjemmebryggede log-funktion til hjemmsiden
function documentLog(string){
    document.getElementById("pyramide").innerHTML += string + "<BR>";
}