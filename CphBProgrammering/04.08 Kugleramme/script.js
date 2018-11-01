//Applikationens tilstand
let sum = 0;

function addToSum(){
    let sumSpan = document.getElementById("sumSpan");
    //Opdater summen og vis den
    sumSpan.innerHTML = Number(sumSpan.innerHTML) + Number(document.getElementById('numberInput').value);
}

function resetSum(){
    let sumSpan = document.getElementById("sumSpan");
    //Opdater summen og vis den
    sumSpan.innerHTML = sum;
}
