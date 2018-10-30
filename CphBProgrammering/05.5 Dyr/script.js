function Animal(name, makeSoundFunction) {
    this.name = name;
    this.makeSound = makeSoundFunction;
}

let dog = new Animal("Fido", function() {
    document.getElementById("output").innerHTML = "WOOF"
});

let cat = new Animal("Garfield", function() {
    document.getElementById("output").innerHTML = "MIAOW"
});

//DONE Add another animal
let fox = new Animal("Tod", function(){
    document.getElementById("output").innerHTML = `<iframe width="560" height="315" src="https://www.youtube.com/embed/jofNR_WkoCE?start=40&autoplay=1" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>`
});

//More clever solution below:
function Animal2(name,sound){
    this.name = name;
    this.sound = sound;
    this.makeSound = function(){
        document.getElementById("output").innerHTML = this.sound;
    }
}

let dog2 = new Animal2("Rex", "WROOF");