package main

import fmt


// composeInt(f, g): returns x -> f(g(x)) where f,g: int->int
function composeInt(f function(int) int, g function(int) int) function(int) int {
    return function(x int) int { return f(g(x)) }
}

// composeStrInt(f, g): returns x -> f(g(x)) where g: int->int, f: int->string
function composeStrInt(f function(int) string, g function(int) int) function(int) string {
    return function(x int) string { return f(g(x)) }
}

function inc(n int) int { return n + 1 }

function double(n int) int { return n * 2 }

function toString(n int) string {
    var result, _ = fmt.Sprintf("%d", n)  // Using _ to ignore the error
    return result
}

function main() {
    var incAfterDouble = composeInt(inc, double)
    fmt.Printf("composeInt(inc, double)(3) = %d\n", incAfterDouble(3))  // 7

    var toStrAfterIncAfterDouble = composeStrInt(toString, composeInt(inc, double))
    fmt.Printf("composeStrInt(toString, composeInt(inc, double))(5) = %s\n", toStrAfterIncAfterDouble(5))

}
