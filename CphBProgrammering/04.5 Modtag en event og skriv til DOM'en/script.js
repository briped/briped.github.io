// https://developer.mozilla.org/en-US/docs/Web/API/GlobalEventHandlers/onclick
// Undlod at lave ændringer i 'index.html'

let elInput = document.getElementById('input');
let elOutput = document.getElementById('output');
elInput.onclick = myEventHandler;
elInput.oncontextmenu = myEventHandler;

elInput.onkeypress = myEventHandler;
elInput.onkeydown = myEventHandler;
elInput.onkeyup = myEventHandler;

elInput.onfocus = myEventHandler;
elInput.onblur = myEventHandler;

function myEventHandler(e) {
    elOutput.innerHTML += `Event: ${e.type}<br />`;
    if (['keyup', 'keydown', 'keypress'].indexOf(e.type) > -1) {
        elOutput.innerHTML += `You pressed ${e.key}<br />`;
    }
    if (e.type === 'blur') {
        elOutput.innerHTML += `You removed focus from element.<br />`;
    }
    if (e.type === 'focus') {
        elOutput.innerHTML += `You focused on element.<br />`;
    }
    console.log(e); // Debugging
}