function doSubmit() {
    let input = Number(document.getElementById('input').value);
    let output = document.getElementById('output');
    let hours = 0, minutes = 0;
    hours = Math.floor(input / 60);
    minutes = input % 60;
    output.innerHTML = `${hours} timer, ${minutes} minutter.`;
}
