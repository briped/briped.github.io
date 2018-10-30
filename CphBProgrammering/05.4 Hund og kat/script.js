let dog = {
    name: "Fido",
    makeSound: function(){
        document.getElementById("output").innerHTML = "WOOF"
    }
};

let cat = {
    name: "Garfield",
    makeSound: function(){
        document.getElementById("output").innerHTML = "MIAOW"
    }
};

//DONE Add another animal
let fox = {
    name: "Tod",
    makeSound: function(){
        document.getElementById("output").innerHTML = `<iframe width="560" height="315" src="https://www.youtube.com/embed/jofNR_WkoCE?start=40&autoplay=1" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>`;
    }
};