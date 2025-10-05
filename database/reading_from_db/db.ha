/*
    Harneet Programming Language 
    File Name - DB.ha.
    Purpose - provides an example of how to
        1. Validate that the DB file exists (sqlite)
        2. Validate if the connection could be made to the database
        3. Validate if the user table exists.
        4. Insert the record in the user table.
    Purposefuly verbose - so as to show all the functionalities of the language
*/

package main
import fmt, db, file, os,  reflect

const SQLITE_DB = "complete_example_db.db"

var closeConnection = (con) =>  {
    fmt.Println("Will close the connecttion")
    db.Close(con)
    fmt.Println("connection was closed!")
} 

function main() {
    //set up the datbase connection
    //First if the sqlite database file exists in the current location

    ok, err := file.Exists(SQLITE_DB)
    if err != None {
        fmt.Println ("File does not exist.")
        os.Exit(1)
    }     

    // fmt.Println(ok)
    // var result, _ = reflect.TypeOf(ok)
    // fmt.Println(result.kind)

    if ok == false {
        fmt.Println("File does not exist")
        //now let us create the database file
        var _, err = file.Touch(SQLITE_DB)
        if err != None {
            fmt.Println("Database file could not be created")
            os.Exit(1)
        } else {
            fmt.Println("Datbase file was created")
        }
    } else {
        fmt.Println("File exists")
    
    }

    // we have validated that the database file exists. Now we can start the connection details
    var con, err = db.Open("sqlite3", SQLITE_DB)

    if err != None {
        fmt.Println("Could not create a connecttion to the database. Error follows → ", err)
        os.Exit(1)
    } else {
        fmt.Println("Was able to create a connection to the database")
    }


    // we are now able to connect to the database. Let us first check if the table exists.
    var currentusertable, err = db.Query(con, "SELECT name FROM sqlite_master WHERE type='table' AND name='users'")
    if err != None {
        fmt.Println("There was an error reading from the database. The error is → ", err)
        closeConnection(con)
        os.Exit(1)
    }

    if 0 == len(currentusertable){
        fmt.Println("user table does not exist. Will create the user table")
        var _, createErr = db.Exec(con, "CREATE TABLE IF NOT EXISTS users ( id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, email TEXT UNIQUE NOT NULL, age INTEGER, created_at DATETIME DEFAULT CURRENT_TIMESTAMP )")

        if createErr != None {
            fmt.Printf("Create table error: %v\n", createErr)
            closeConnection(con)
            return
        } else {
            fmt.Println("User table created successfully")
        }
    } else {
        fmt.Println("user table exists. Will proceed ahead")
    }

    //table exists. Now add some records.
    var userData = {
        "name": "John Doe",
        "email": "john@example.com",
        "age": 30
    }

    var id, insertErr = db.Create(con, "users", userData)
    if insertErr == None {
        fmt.Printf("✅ Inserted user with ID: %d\n", id)
    } else {
        fmt.Println("Could not insert the record")
        closeConnection(con)
        os.Exit(1)
    }

    // will now validate that the user record was inserted
    var users, queryErr = db.Query(con, "SELECT * FROM users")
    if queryErr == None {
        fmt.Printf("✅ Found %d users in the table\n", len(users))
        for user in users {
            fmt.Printf("  - %s (%s, age: %d)\n",
                user.name, user.email, user.age)
        }
    } else {
        fmt.Println("There was an error reading from the database , error → ", querryErr)
    }
}
    
