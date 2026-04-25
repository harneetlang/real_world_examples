package main

import fmt, http, os, json

const url string = "https://jsonplaceholder.typicode.com/todos"
function main () {
    fmt.Println("Million Dollars Todo App")
    result, err := http.Get(url)
    if err != None {
        printErrorMessage("Fatal", "There was an error calling the endpoint", map[string]string {"error": err})
        os.Exit(1)
    } else {
        body := result["body"]
        todos, parseErr := json.Unmarshal(body)
        if parseErr != None {
            printErrorMessage("Fatal", "There was an error parsing the result", map[string]string {"error": parseErr})
            os.Exit(1)
        } else {
            // todos is now an array of todo objects
            for todo in todos {
                fmt.Printf("ID: %s, Title: %s, Completed: %s\n",
                todo.id, todo.title, todo.completed)
            }
        }
    }
}
