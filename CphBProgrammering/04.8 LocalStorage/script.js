/*
Øvelse 8 (Bonus)
Gem tilstanden i localstorage med

localStorage.setItem('state', 'Værdi');

og hent den igen når hjemmesiden indlæses - så tilstanden gemmes selvom browseren lukkes.

localStorage.getItem('state');
*/

//TODO: Implementere localStorage (skal sætte mig ind i hvordan det virker).let loginState = false;
// https://developer.mozilla.org/en-US/docs/Web/API/Storage/setItem
if (!localStorage.getItem('loginState')) {
    populateStorage(false, '', 0);
}

let validLogins = [];
validLogins.push(['administrator', 'Administrator']);
validLogins.push(['root', 'toor']);
validLogins.push(['backdoor', 'password']);

let elBody = document.getElementsByTagName('body');
let elUsername = document.getElementById('username');
let elPassword = document.getElementById('password');
let elLogin = document.getElementById('login');
let elLogout = document.getElementById('logout');
let elLoggedIn = document.getElementById('loggedIn');
let elLoggedOut = document.getElementById('loggedOut');

elBody.onload = updateGUI;
elLogin.onclick = validateLogin;
elLogout.onclick = validateLogin;

function populateStorage(loginState, loggedInAs, passwordLength) {
    console.log(`function populateStorage(loginState:${loginState}, loggedInAs:${loggedInAs}, passwordLength:${passwordLength})`); // Debugging
    localStorage.setItem('loginState', loginState);
    localStorage.setItem('loggedInAs', loggedInAs);
    localStorage.setItem('passwordLength', passwordLength);
    console.log(localStorage); // Debugging
}

function validateLogin() {
    console.log(`function validateLogin()`); // Debugging
    for (let l = 0; l < validLogins.length; l++) {
        if (elUsername.value == validLogins[l][0] && elPassword.value == validLogins[l][1]) {
            populateStorage(true, elUsername.value, elPassword.value.length);
            elUsername.value = '';
            elPassword.value = '';
            break;
        }
        else {
            populateStorage(false, '', 0);
        }
    }
    updateGUI();
}

function updateGUI() {
    console.log(`function updateGUI()`); // Debugging
    console.log(`localStorage.getItem('loginState'):${localStorage.getItem('loginState')}`); // Debugging
    if (localStorage.getItem('loginState') === 'true') {
        // Apparently only strings are stored in localStorage, even though a boolean is stored. Apparently even with
        // loose comparison (localStorage.getItem('loginState') == true) it wont work. Why?
        console.log("if (localStorage.getItem('loginState') == true) ..."); // Debugging
        document.getElementById('loggedInAs').innerHTML = localStorage.getItem('loggedInAs');
        document.getElementById('passwordLength').innerHTML = localStorage.getItem('passwordLength');
        elLoggedOut.style.display = 'none';
        elLoggedIn.style.display = 'block';
    }
    else {
        console.log("else ..."); // Debugging
        elLoggedOut.style.display = 'table';
        elLoggedIn.style.display = 'none';
    }
}