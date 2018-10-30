let animals = []; //No animals in array yet...

function Animal(type, sound) {
    this.type = type;
    this.makeSound = function(){alert(`the ${type} says: ${sound}`)}
}

//DONE make some more animals and fill them into the array!
animals.push(new Animal("cat", "Miuow"));
animals.push(new Animal("dog", "Woof"));
animals.push(new Animal("cow", "Mooh"));
animals.push(new Animal("sheep", "Baaah"));
animals.push(new Animal("donkey", "Heehaaw"));

//Print something interesting to the DOM
for (let i = 0; i < animals.length; i++) {
    //adds a button with an onclick eventhandler that makes a sound!
    document.getElementById("animaldiv").innerHTML += `<br /><button onclick="animals[${i}].makeSound()">${animals[i].type}</button>`;
}