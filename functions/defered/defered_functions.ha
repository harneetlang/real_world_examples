package main

import fmt

function functionA(){
    fmt.Println("starting function")

    defer fmt.Println("this will be printed last")
    fmt.Println("FunctionA end")
}


func main(){
    fmt.Println("Main test start")
    functionA()
}
