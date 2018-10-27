// https://developer.mozilla.org/en-US/docs/Web/API/Storage
if (!localStorage.getItem('loginState')) {
    populateStorage(false, '', 0);
}

let validLogins = [];
validLogins.push(['administrator', 'Administrator']);
validLogins.push(['root', 'toor']);
validLogins.push(['backdoor', 'password']);

let elUsername = document.getElementById('username');
let elPassword = document.getElementById('password');
let elLogin = document.getElementById('login');
let elLogout = document.getElementById('logout');
let elLoggedIn = document.getElementById('loggedIn');
let elLoggedOut = document.getElementById('loggedOut');

elLogin.onclick = validateLogin;
elLogout.onclick = validateLogin;

updateGUI();

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
        if (elUsername.value === validLogins[l][0] && elPassword.value === validLogins[l][1]) {
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
    console.log(localStorage); // Debugging
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