/**
 * Created by Christian on 14-02-2018.
 */
let tal1 = Number(prompt("Indtast et tal"));
let tal2 = Number(prompt("Indtast et tal"));
let tal3 = Number(prompt("Indtast et tal"));

if (tal1 > tal2 && tal1 > tal3) {
    document.write("Det største tal er: " );
    document.write(tal1);
}
else if (tal2 > tal1 && tal2 > tal3) {
    document.write("Det største tal er: " );
    document.write(tal2);
}
else if (tal3 > tal1 && tal3 > tal1) {
    document.write("Det største tal er: " );
    document.write(tal3);
}
else {
    document.write("Der var ingen store tal" );
}