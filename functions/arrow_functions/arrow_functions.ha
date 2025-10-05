package main

import fmt

var adder = (a, b)=> a+b // notice there is no usage of the return keyword

var multiplier = (a,b) => {
    return a *b  // here we are using the return keyword
}

function main() {
    fmt.Println(adder(3,4))
    fmt.Println(multiplier(3,4))
}
