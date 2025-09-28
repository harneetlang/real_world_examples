package main

import fmt, http, os, json


var url = "https://jsonplaceholder.typicode.com/todos"
function main () {
    fmt.Println("Million Dollars Todo App")
    result, err := http.Get(url)
    if err != None {
        fmt.Println("there was an error ")
        fmt.Println(err)
        os.Exit(1)
    } else {
        var body = result["body"]
        var todos, parseErr = json.Unmarshal(body)
        if parseErr != None {
            fmt.Println("Failed to parse JSON:", parseErr)
            os.Exit(1)
        } else {
            // todos is now an array of todo objects
            for todo in todos {
                fmt.Printf("ID: %s, Title: %s, Completed: %s\n", 
                    todo["id"], todo["title"], todo["completed"])
            }
        }
    }
}

