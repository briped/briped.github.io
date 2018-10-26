let height = Number(prompt("Hvor høj skal trekanten være?"));

for (let i = 0; i < height; i++) {
    let layer = (i < 1) ? '\\' : 'o'.repeat(i) + '\\';
    console.log(layer);
    documentLog(layer);
}

//Christians hjemmebryggede log-funktion til hjemmsiden
function documentLog(string){
    document.getElementById("pyramide").innerHTML += string + "<BR>";
}