let fibNext;
let fibPrev = 0;
let fib = 1;

for (let i = 1; i <= 10; i++) {
    document.write(`Fibonacci #${i}: ${fibPrev}<br />`);

    fibNext = fibPrev + fib;
    fibPrev = fib;
    fib = fibNext;
}
