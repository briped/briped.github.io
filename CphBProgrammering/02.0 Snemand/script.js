let temperature = Number(prompt("Indtast temperaturen:"));
let sunshine = confirm("Lad solen skinne?"); //confirm returnerer true eller false;

// Deklarer canvas som global variabel så man ikke behøver at angive den i hver eneste funktion.
var canvas = document.getElementById("snowcanvas");
var ctx = canvas.getContext('2d');
// Sæt baggrundsfarven på canvas til en fin himmelblå farve.
canvas.style = 'background-color: #e2edff;';

// Lidt vejrvariabler
let sunX, sunY, sunR, skyOffsetX;
// Tegn solen
sunX = canvas.width - 120;
sunY = 60;
sunR = 50;
circle(sunX, sunY, sunR, '#f9db2c');
skyOffsetX = (sunshine) ? 0 : sunX - (sunR * 2);
// Tegn skyen
circle(skyOffsetX + 50,  sunY,      20, '#ffffff', '#ffffff');
circle(skyOffsetX + 70,  sunY - 15, 20, '#ffffff', '#ffffff');
circle(skyOffsetX + 70,  sunY + 15, 20, '#ffffff', '#ffffff');
circle(skyOffsetX + 100, sunY,      40, '#ffffff', '#ffffff');
circle(skyOffsetX + 140, sunY - 15, 20, '#ffffff', '#ffffff');
circle(skyOffsetX + 140, sunY + 15, 20, '#ffffff', '#ffffff');
circle(skyOffsetX + 160, sunY,      20, '#ffffff', '#ffffff');


// Bund
circle(200, 500, 100, '#fefefe', '#fefefe');
// Midte
circle(200, 350, 75, '#fefefe', '#fefefe');

let faceX, faceY, faceR;
faceX = 200;
faceY = 240;
faceR = 50;
// Hoved + arme
if ((sunshine && temperature > -5) || temperature > 0) {
    face(faceX, faceY, faceR, false);
    arms(200, 350, 70, false);
}
else {
    face(faceX, faceY, faceR, true);
    arms(200, 350, 70, true);
}


// Tegn hatten
hat(faceX - faceR, faceY - faceR, faceR * 2, faceR * 2.5);

writeTemperature(temperature);

function writeTemperature (temperature) {
    ctx.beginPath();
    ctx.font = "30px Arial";
    ctx.fillStyle = (temperature <= 0) ? 'blue' : 'red';
    ctx.textAlign = 'right';
    ctx.fillText(temperature + '°C', canvas.width - 50, canvas.height - 50, 100);
    ctx.closePath();
}

function arms(x, y, offset, happy) {
    ctx.beginPath();
    if (happy) {
        ctx.moveTo(x - offset, y);
        ctx.lineTo(x - (offset * 2), y - offset);
        ctx.stroke();
        ctx.moveTo(x + offset, y);
        ctx.lineTo(x + (offset * 2), y - offset);
        ctx.stroke();
    }
    else {
        ctx.moveTo(x - offset, y);
        ctx.lineTo(x - (offset * 2), y + offset);
        ctx.stroke();
        ctx.moveTo(x + offset, y);
        ctx.lineTo(x + (offset * 2), y + offset);
        ctx.stroke();
    }
    ctx.strokeStyle = '#000000';
    ctx.lineWidth = 3;
    ctx.closePath();
}

function face(x, y, radius, happy = true) {
    circle(x, y, radius);
    circle(x - (radius / 3), y - (radius / 3), radius / 4, '#444444');
    circle(x + (radius / 3), y - (radius / 3), radius / 4, '#444444');
    mouth(x, y - (radius / 10), radius * 0.6, happy)
}

function circle(x, y, radius, fillColor = '#fefefe', strokeColor = '#fefefe') {
    ctx.beginPath();
    ctx.arc(x, y, radius, 0, Math.PI*2);
    ctx.fillStyle = fillColor;
    ctx.fill();
    ctx.strokeStyle = strokeColor;
    ctx.stroke();
    ctx.closePath();
}

function hat(x, y, headSize, rimSize){
    ctx.beginPath();
    ctx.rect(x - ((rimSize - headSize) / 2), y, rimSize, 8);
    ctx.rect(x + ((headSize - (headSize * 0.8)) / 2), y-60, headSize * 0.8, 60);
    ctx.fillStyle = '#000000';
    ctx.fill();
    ctx.closePath();
}
/**
 *
 * @param x - angiver x placeringen
 * @param y - angiver y placeringen
 * @param size - angiver mundens bredde
 * @param happy - angiver om det er en glad eller sur mund
 */
function mouth(x, y, size, happy) {
    ctx.beginPath();
    if (happy) {
        ctx.arc(x, y, size, (1/4) * Math.PI, (3 / 4) * Math.PI)
    } else {
        ctx.arc(x, y + (5/3) * size, size, (-3/4) * Math.PI, (-1 / 4) * Math.PI)
    }
    ctx.strokeStyle = '#000000';
    ctx.lineWidth = 3;
    ctx.stroke();
    ctx.closePath();
}