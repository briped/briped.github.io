function circle(x, y, radius, color) {
    let canvas = document.getElementById('mycanvas').getContext('2d');
    canvas.beginPath();
    canvas.arc(x, y, radius, 0, Math.PI*2);
    canvas.fillStyle = color;
    canvas.fill();
    canvas.closePath();
}
circle(20, 20, 10, 'red');
circle(60, 20, 10, 'red');
circle(40, 40, 10, 'red');
circle(20, 60, 10, 'red');
circle(60, 60, 10, 'red');
