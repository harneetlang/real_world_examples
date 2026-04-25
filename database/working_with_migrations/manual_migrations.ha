package main

import db
import fmt
import os

// Manual Database Migrations Example
// Demonstrates using Harneet's database migration API directly
// This approach gives you full control over migration execution

function main() {
    fmt.Println("=== Manual Database Migrations Example ===")
    fmt.Println()

    // Open SQLite database
    fmt.Println("1. Opening SQLite database...")
    var conn, err = db.Open("sqlite3", "blog_manual_migrations.db")
    if err != None {
        fmt.Printf("ERROR: Failed to open database: %v\n", err)
        return
    }
    fmt.Println("✓ Database opened successfully")
    fmt.Println()

    // Check current migration version
    fmt.Println("2. Checking current migration version...")
    var currentVersion, vErr = db.GetMigrationVersion(conn)
    if vErr != None {
        fmt.Printf("ERROR: Failed to get migration version: %v\n", vErr)
        db.Close(conn)
        return
    }
    fmt.Printf("✓ Current database version: %d\n", currentVersion)
    fmt.Println()

    // Apply migration v1: Initial schema
    if currentVersion < 1 {
        fmt.Println("3. Applying migration v1: Initial schema...")
        var err1 = db.MigrateUp(conn, 1, "initial_schema",
            "CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL UNIQUE, email TEXT NOT NULL UNIQUE); " +
            "CREATE TABLE posts (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, title TEXT NOT NULL, content TEXT, FOREIGN KEY(user_id) REFERENCES users(id))")

        if err1 != None {
            fmt.Printf("ERROR: Failed to apply migration v1: %v\n", err1)
            db.Close(conn)
            return
        }
        fmt.Println("✓ Migration v1 applied successfully")
    } else {
        fmt.Println("3. Migration v1 already applied, skipping...")
    }
    fmt.Println()

    // Check version after migration
    var version1, _ = db.GetMigrationVersion(conn)
    fmt.Printf("Current version after migration: %d\n", version1)
    fmt.Println()

    // Apply migration v2: Add user profiles
    if currentVersion < 2 {
        fmt.Println("4. Applying migration v2: Add user profiles...")
        var err2 = db.MigrateUp(conn, 2, "add_user_profiles",
            "ALTER TABLE users ADD COLUMN first_name TEXT; ALTER TABLE users ADD COLUMN last_name TEXT")

        if err2 != None {
            fmt.Printf("ERROR: Failed to apply migration v2: %v\n", err2)
            db.Close(conn)
            return
        }
        fmt.Println("✓ Migration v2 applied successfully")
    } else {
        fmt.Println("4. Migration v2 already applied, skipping...")
    }
    fmt.Println()

    // Check version after migration
    var version2, _ = db.GetMigrationVersion(conn)
    fmt.Printf("Current version after migration: %d\n", version2)
    fmt.Println()

    // Test the database by inserting some data
    fmt.Println("5. Testing database with sample data...")

    // Insert a user
    var _, insertUserErr = db.Exec(conn,
        "INSERT INTO users (username, email, first_name, last_name) VALUES (?, ?, ?, ?)",
        "alice_dev", "alice@example.com", "Alice", "Developer")

    if insertUserErr != None {
        fmt.Printf("ERROR: Failed to insert user: %v\n", insertUserErr)
    } else {
        fmt.Println("✓ User inserted successfully")
    }

    // Insert a post
    var _, insertPostErr = db.Exec(conn,
        "INSERT INTO posts (user_id, title, content) VALUES (?, ?, ?)",
        1, "Hello World!", "This is my first blog post about database migrations.")

    if insertPostErr != None {
        fmt.Printf("ERROR: Failed to insert post: %v\n", insertPostErr)
    } else {
        fmt.Println("✓ Post inserted successfully")
    }
    fmt.Println()

    // Demonstrate rollback - roll back to version 1
    fmt.Println("6. Demonstrating rollback - rolling back to version 1...")
    var rollbackErr = db.MigrateDown(conn, 2, "ALTER TABLE users DROP COLUMN last_name; ALTER TABLE users DROP COLUMN first_name")
    if rollbackErr != None {
        fmt.Printf("ERROR: Failed to rollback migration: %v\n", rollbackErr)
    } else {
        fmt.Println("✓ Migration v2 rolled back successfully")
    }

    // Check version after rollback
    var rollbackVersion, _ = db.GetMigrationVersion(conn)
    fmt.Printf("Current version after rollback: %d\n", rollbackVersion)
    fmt.Println()

    // Get migration history
    fmt.Println("7. Getting migration history...")
    var history, hErr = db.GetMigrationHistory(conn)
    if hErr != None {
        fmt.Printf("ERROR: Failed to get migration history: %v\n", hErr)
    } else {
        fmt.Printf("✓ Applied migrations (%d total):\n", len(history))
        for migration in history {
            fmt.Printf("  - v%d: %s\n", migration["version"], migration["name"])
        }
    }
    fmt.Println()

    // Demonstrate MigrateToVersion - migrate to a specific version
    fmt.Println("8. Using MigrateToVersion to migrate to version 1...")
    var migrateErr = db.MigrateToVersion(conn, 1, [
        {
            "version": 1,
            "name": "initial_schema",
            "up": "CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL UNIQUE, email TEXT NOT NULL UNIQUE); CREATE TABLE posts (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, title TEXT NOT NULL, content TEXT, FOREIGN KEY(user_id) REFERENCES users(id))",
            "down": "DROP TABLE posts; DROP TABLE users"
        },
        {
            "version": 2,
            "name": "add_user_profiles",
            "up": "ALTER TABLE users ADD COLUMN first_name TEXT; ALTER TABLE users ADD COLUMN last_name TEXT",
            "down": "ALTER TABLE users DROP COLUMN last_name; ALTER TABLE users DROP COLUMN first_name"
        }
    ])

    if migrateErr != None {
        fmt.Printf("ERROR: Failed to migrate to version: %v\n", migrateErr)
    } else {
        fmt.Println("✓ Successfully migrated to version 1")
    }

    var finalVersion, _ = db.GetMigrationVersion(conn)
    fmt.Printf("Final database version: %d\n", finalVersion)
    fmt.Println()

    // Close database connection
    fmt.Println("9. Closing database...")
    db.Close(conn)
    fmt.Println("✓ Database closed")
    fmt.Println()

    fmt.Println("=== Manual Migrations Example Complete! ===")
    fmt.Println()
    fmt.Println("Database file: blog_manual_migrations.db")
    fmt.Println("You can inspect it with: sqlite3 blog_manual_migrations.db '.schema'")
}
