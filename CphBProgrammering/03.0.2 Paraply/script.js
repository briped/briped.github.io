let time = Number(prompt('Hvad er klokken (i hele timer)'));
let sunny = prompt('Skinner solen?');
let rainy = prompt('Regner det?');

let optYes = ['y', 'j', 'ja', 'yes'];
let highSun = (time > 12 && time < 15) ? true : false;

sunny = (optYes.indexOf(sunny) >= 0) ? true : false;
rainy = (optYes.indexOf(rainy) >= 0) ? true : false;

if (rainy || (sunny && highSun)) {
    document.write('Du har brug for din paraply!');
}
else {
    document.write('Du har ikke brug for din paraply!');
}