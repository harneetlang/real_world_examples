package main

import fmt

function main() {
    var double function(int) int = (x int) int => x * 2
    var addTwo function(int) int = (x int) int => x + 2
    var half function(int) int = (x int) int => x / 2

    var compose function(function(int) int, function(int) int, function(int) int) function(int) int = (f function(int) int, g function(int) int, h function(int) int) function(int) int => (x int) int => h(f(g(x)))
    var finalNumber function(int) int = compose(addTwo, double, half)
    const result int = finalNumber(5)
    const d int = 0x7FFFFFFF
    fmt.Println(d)
    fmt.Println(result)
}
