/*
Øvelse 8 (Bonus)
Gem tilstanden i localstorage med

localStorage.setItem('state', 'Værdi');

og hent den igen når hjemmesiden indlæses - så tilstanden gemmes selvom browseren lukkes.

localStorage.getItem('state');
*/

//TODO: Implementere localStorage (skal sætte mig ind i hvordan det virker).let loginState = false;
let loggedInAs = '';
let passwordLength = 0;

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

function validateLogin() {
    for (let l = 0; l < validLogins.length; l++) {
        if (elUsername.value == validLogins[l][0] && elPassword.value == validLogins[l][1]) {
            loginState = true;
            loggedInAs = elUsername.value;
            passwordLength = elPassword.value.length;
            elUsername.value = '';
            elPassword.value = '';
            break;
        }
        else {
            loginState = false;
        }
    }
    updateGUI();
}

function updateGUI() {
    if (loginState === true) {
        document.getElementById('loggedInAs').innerHTML = loggedInAs;
        document.getElementById('passwordLength').innerHTML = passwordLength;
        elLoggedOut.style.display = 'none';
        elLoggedIn.style.display = 'block';
    }
    else {
        elLoggedOut.style.display = 'table';
        elLoggedIn.style.display = 'none';
    }
}