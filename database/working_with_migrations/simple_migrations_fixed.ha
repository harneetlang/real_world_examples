package main

import db
import fmt

function main() {
    fmt.Println("=== Simple Database Migrations Demo ===")
    
    // Open database
    var conn, err = db.Open("sqlite3", "simple_migrations_demo.db")
    if err != None {
        fmt.Printf("ERROR: %v\n", err)
        return
    }
    
    // Define migrations inline (no external files)
    var migrations = [
        {
            "version": 1,
            "name": "create_users_table",
            "up": "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT NOT NULL, email TEXT UNIQUE)",
            "down": "DROP TABLE users"
        }
    ]
    
    // Apply migration
    var _, applyErr = db.MigrateUp(conn, 1, "create_users_table", 
        "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT NOT NULL, email TEXT UNIQUE)")
    if applyErr != None {
        fmt.Printf("ERROR applying migration: %v\n", applyErr)
    } else {
        fmt.Println("✓ Migration applied successfully")
    }
    
    // Test the table
    var _, insertErr = db.Exec(conn, "INSERT INTO users (name, email) VALUES (?, ?)", "Alice", "alice@example.com")
    if insertErr != None {
        fmt.Printf("ERROR inserting user: %v\n", insertErr)
    } else {
        fmt.Println("✓ User inserted successfully")
    }
    
    // Show migration history
    var history, histErr = db.GetMigrationHistory(conn)
    if histErr != None {
        fmt.Printf("ERROR getting history: %v\n", histErr)
    } else {
        fmt.Printf("Applied %d migrations\n", len(history))
    }
    
    db.Close(conn)
    fmt.Println("✓ Demo complete")
}
