let temp = [-1, 1, 1, 1, 2, 0, 1 , -0.1, 0.1, -20, -4, 10];
let subZero = 0;
for (let i = 0; i < temp.length; i++) {
    subZero += (temp[i] < 0) ? 1 : 0;
}
document.write(subZero);