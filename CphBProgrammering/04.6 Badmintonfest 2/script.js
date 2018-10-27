function checkAccess(){
    //TODO: get variables from DOM and write result back
    let age = Number(document.getElementById('age').value);
    let dress = document.getElementById('dress').value;

    let minAge = 18;
    let maxAge = 25;
    let allowedCostumes = ['Cowboy', 'Astronaut', 'Playboy'];

    document.getElementById('resultat').innerHTML = (age >= minAge && age <= maxAge && allowedCostumes.indexOf(dress) > -1) ? 'JA! Du komme ind til festen.' : 'NEJ! Du er IKKE velkommen.';
}
