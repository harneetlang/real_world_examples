package main

import db
import fmt
import json
import file
import path
import strings
import cast

// Load migrations from JSON configuration file
function loadMigrationsFromJSON(filepath string) array {
    fmt.Printf("Loading migrations from JSON file: %s\n", filepath)
    
    var content, readErr = file.ReadFile(filepath)
    if readErr != None {
        fmt.Printf("ERROR: Failed to read migrations file: %v\n", readErr)
        return []
    }
    
    var migrations, parseErr = json.Unmarshal(content)
    if parseErr != None {
        fmt.Printf("ERROR: Failed to parse migrations JSON: %v\n", parseErr)
        return []
    }
    
    fmt.Printf("✓ Loaded %d migrations from JSON\n", len(migrations))
    return migrations
}

// Load migrations from SQL files in a directory (simplified version)
function loadMigrationsFromSQLDirectory(dirpath string) array {
    fmt.Printf("Loading migrations from SQL directory: %s\n", dirpath)
    
    // For this demo, we'll return a simple migration array
    // In a real implementation, you would parse .sql files
    var migrations = [
        {
            "version": 1,
            "name": "create_users_table",
            "up": "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT NOT NULL, email TEXT UNIQUE)",
            "down": "DROP TABLE users"
        },
        {
            "version": 2,
            "name": "add_user_profiles", 
            "up": "ALTER TABLE users ADD COLUMN age INTEGER",
            "down": "ALTER TABLE users DROP COLUMN age"
        }
    ]
    
    fmt.Printf("✓ Loaded %d migrations from directory\n", len(migrations))
    return migrations
}

// Sort migrations by version number
function sortMigrationsByVersion(migrations) array {
    // Simple bubble sort for demonstration
    var n = len(migrations)
    for i in range(n) {
        for j in range(0, n - i - 1) {
            if migrations[j]["version"] > migrations[j + 1]["version"] {
                var temp = migrations[j]
                migrations[j] = migrations[j + 1]
                migrations[j + 1] = temp
            }
        }
    }
    return migrations
}

// Apply migrations up to a specific version
function migrateUpToVersion(conn any, migrations array, targetVersion int) any {
    fmt.Printf("Migrating up to version %d...\n", targetVersion)

    var currentVersion, _ = db.GetMigrationVersion(conn)
    var appliedCount = 0

    for migration in migrations {
        var version = migration["version"]
        if version > currentVersion && version <= targetVersion {
            fmt.Printf("  Applying migration v%d: %s\n", version, migration["name"])

            var _, err = db.MigrateUp(conn, version, migration["name"], migration["up"])
            if err != None {
                fmt.Printf("  ERROR: Failed to apply migration v%d: %v\n", version, err)
                return err
            }

            appliedCount = appliedCount + 1
        }
    }

    if appliedCount > 0 {
        fmt.Printf("✓ Applied %d migrations\n", appliedCount)
    } else {
        fmt.Println("✓ No migrations to apply")
    }

    return None
}

// Main function demonstrating file-based migrations
function main() {
    fmt.Println("=== File-Based Database Migrations Example ===")
    fmt.Println()

    // Open SQLite database
    fmt.Println("1. Opening SQLite database...")
    var conn, err = db.Open("sqlite3", "blog_migrations_demo.db")
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

    // Load migrations from JSON file
    fmt.Println("3. Loading migrations from JSON configuration...")
    var jsonMigrations = loadMigrationsFromJSON("migrations.json")
    fmt.Println()

    // Apply migrations up to version 2
    fmt.Println("4. Applying migrations up to version 2...")
    var migrateErr = migrateUpToVersion(conn, jsonMigrations, 2)
    if migrateErr != None {
        fmt.Printf("ERROR: Migration failed: %v\n", migrateErr)
        db.Close(conn)
        return
    }
    fmt.Println()

    // Check version after migration
    var version2, _ = db.GetMigrationVersion(conn)
    fmt.Printf("Current version after migration: %d\n", version2)
    fmt.Println()

    // Test the database with sample data
    fmt.Println("5. Testing database with sample data...")

    // Insert a user
    var _, insertUserErr = db.Exec(conn,
        "INSERT INTO users (name, email) VALUES (?, ?)",
        "Alice Developer", "alice@example.com")

    if insertUserErr != None {
        fmt.Printf("ERROR: Failed to insert user: %v\n", insertUserErr)
    } else {
        fmt.Println("✓ User inserted successfully")
    }
    fmt.Println()

    // Show migration history
    fmt.Println("6. Migration history...")
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

    // Close database connection
    fmt.Println("7. Closing database...")
    db.Close(conn)
    fmt.Println("✓ Database closed")
    fmt.Println()

    fmt.Println("=== File-Based Migrations Example Complete! ===")
    fmt.Println()
    fmt.Println("Database file: blog_migrations_demo.db")
    fmt.Println("JSON config: migrations.json")
}
