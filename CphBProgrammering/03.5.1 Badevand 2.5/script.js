function doUpdate() {
    let temp = []; // Create empty array.
    let tempIncrease = 0;
    let tempSubZero = 0;
    let tempPrevious;
    let input = document.getElementById('temperatures').value.split('\n'); // Read the textarea.
    for (let i = 0; i < input.length; i++) {
        let tempDotDecimal = Number(input[i].replace(',', '.')); // Ensure we use period for decimal separator.
        if (!isNaN(tempDotDecimal)) {
            temp.push(tempDotDecimal);
            if (isNaN(tempPrevious)) {
                tempPrevious = temp[0];
            }
            tempSubZero += (tempDotDecimal < 0) ? 1 : 0;
            tempIncrease += (tempDotDecimal > tempPrevious) ? 1 : 0;
            tempPrevious = tempDotDecimal;
        }
    }
    let total = temp.length;
    document.getElementById('output').innerHTML = `Total measurements: ${total}.<br /># days below zero: ${tempSubZero}.<br /># days temperature increased: ${tempIncrease}.`;
}