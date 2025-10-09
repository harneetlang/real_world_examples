package main

import fmt

function main() {
    var double = (x) => x*2
    var addTwo = x => x + 2
    var half = x => x / 2

    const compose = (f, g, h) => x => h(f(g(x)));
    const finalNumber = compose(addTwo, double, half)
    fmt.Println(finalNumber(5))
    
}
