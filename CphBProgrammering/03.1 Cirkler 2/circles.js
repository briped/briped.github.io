var canvas = document.getElementById("mycanvas");
var ctx = canvas.getContext('2d');
let antalCirkler = Number(prompt("Indtast antal cirkler"));
for (let i = 1; i <= antalCirkler; i++) {
    circle(10 * (i * 10), 10 * (i * 10), 10, 'red', 'blue')
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
