package main

import cast
import db
import file
import fmt
import json
import path
import strings

// File-Based Database Migrations Example
// Demonstrates loading and executing migrations from files and JSON configuration
// This approach is ideal for production deployments and team collaboration

// Load migrations from JSON configuration file
function loadMigrationsFromJSON(filepath string) []string {
    fmt.Printf("Loading migrations from JSON file: %s\n", filepath)

    var content string, readErr error = file.ReadFile(filepath)
    if readErr != None {
        fmt.Printf("ERROR: Failed to read migrations file: %v\n", readErr)
        return []string{}
    }

    migrations, parseErr := json.Unmarshal(content)
    if parseErr != None {
        fmt.Printf("ERROR: Failed to parse migrations JSON: %v\n", parseErr)
        return []string {}
    }

    fmt.Printf("✓ Loaded %d migrations from JSON\n", len(migrations))
    return migrations
}

// Load migrations from SQL files in a directory
function loadMigrationsFromSQLDirectory(dirpath string) []string{
    fmt.Printf("Loading migrations from SQL directory: %s\n", dirpath)

    var files []string, err error = path.Glob(dirpath + "/* .sql")
    if err != None {
        fmt.Printf("ERROR: Failed to list migration files: %v\n", err)
        return []string{}
    }

    var migrations []string = []string{}
    var fileCount int = 0

    for filepath in files {
        var migration = parseSQLMigrationFile(filepath)
        if migration["version"] > 0 {
            migrations = migrations + [migration]
            fileCount = fileCount + 1
        }
    }

    // Sort migrations by version
    migrations = sortMigrationsByVersion(migrations)

    fmt.Printf("✓ Loaded %d migrations from %d SQL files\n", len(migrations), fileCount)
    return migrations
}
// Parse a SQL migration file with metadata comments


function parseSQLMigrationFile(filepath string) map {
    var content, readErr = file.ReadFile(filepath)
    if readErr != None {
        fmt.Printf("ERROR: Failed to read file %s: %v\n", filepath, readErr)
        var emptyMap = {}
        return emptyMap
    }

    var lines = strings.Split(content, "\n")
    var version = 0
    var name = ""
    var description = ""
    var upSQL = ""
    var downSQL = ""
    var inUpSection = false
    var inDownSection = false

    for line in lines {
        var trimmed = strings.TrimSpace(line)

        if strings.HasPrefix(trimmed, "-- Version:") {
            var parts = strings.Split(trimmed, ":")
            if len(parts) == 2 {
                var versionStr = strings.TrimSpace(parts[1])
                version = cast.ToInt(versionStr)
            }
        } else if strings.HasPrefix(trimmed, "-- Name:") {
            var parts = strings.Split(trimmed, ":")
            if len(parts) == 2 {
                name = strings.TrimSpace(parts[1])
            }
        } else if strings.HasPrefix(trimmed, "-- Description:") {
            var parts = strings.Split(trimmed, ":")
            if len(parts) == 2 {
                description = strings.TrimSpace(parts[1])
            }
        } else if trimmed == "-- UP" {
            inUpSection = true
            inDownSection = false
        } else if trimmed == "-- DOWN" {
            inUpSection = false
            inDownSection = true
        } else if trimmed != "" {
            if !strings.HasPrefix(trimmed, "--") {
                if inUpSection {
                    if upSQL != "" {
                        upSQL = upSQL + "\n"
                    }
                    upSQL = upSQL + trimmed
                } else if inDownSection {
                    if downSQL != "" {
                        downSQL = downSQL + "\n"
                    }
                    downSQL = downSQL + trimmed
                }
            }
        }
    }

    var result = {
        "version": version,
        "name": name,
        "description": description,
        "up": upSQL,
        "down": downSQL
    }
    return result
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

            var err = db.MigrateUp(conn, version, migration["name"], migration["up"])
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
    var conn, err = db.Open("sqlite3", "blog_file_migrations.db")
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

    // Load migrations from SQL files
    fmt.Println("3. Loading migrations from SQL files...")
    var sqlMigrations = loadMigrationsFromSQLDirectory("migrations")
    fmt.Println()

    // Load migrations from JSON file
    fmt.Println("4. Loading migrations from JSON configuration...")
    var jsonMigrations = loadMigrationsFromJSON("migrations.json")
    fmt.Println()

    // Apply migrations up to version 2
    fmt.Println("5. Applying migrations up to version 2...")
    var migrateErr = migrateUpToVersion(conn, sqlMigrations, 2)
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
    fmt.Println("6. Testing database with sample data...")

    // Insert a user
    var _, insertUserErr = db.Exec(conn,
    "INSERT INTO users (username, email) VALUES (?, ?)",
    "bob_coder", "bob@example.com")

    if insertUserErr != None {
        fmt.Printf("ERROR: Failed to insert user: %v\n", insertUserErr)
    } else {
        fmt.Println("✓ User inserted successfully")
    }

    // Insert a post
    var _, insertPostErr = db.Exec(conn,
    "INSERT INTO posts (user_id, title, content) VALUES (?, ?, ?)",
    1, "Database Migrations Rock!", "Learning about database migrations with SQLite and Harneet.")

    if insertPostErr != None {
        fmt.Printf("ERROR: Failed to insert post: %v\n", insertPostErr)
    } else {
        fmt.Println("✓ Post inserted successfully")
    }
    fmt.Println()

    // Demonstrate rollback by going back to version 1
    fmt.Println("7. Rolling back to version 1...")
    var rollbackErr = db.MigrateToVersion(conn, 1, sqlMigrations)
    if rollbackErr != None {
        fmt.Printf("ERROR: Failed to rollback: %v\n", rollbackErr)
    } else {
        fmt.Println("✓ Successfully rolled back to version 1")
    }

    var finalVersion, _ = db.GetMigrationVersion(conn)
    fmt.Printf("Final database version: %d\n", finalVersion)
    fmt.Println()

    // Show migration history
    fmt.Println("8. Migration history...")
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
    fmt.Println("9. Closing database...")
    db.Close(conn)
    fmt.Println("✓ Database closed")
    fmt.Println()

    fmt.Println("=== File-Based Migrations Example Complete!===")
    fmt.Println()
    fmt.Println("Database file: blog_file_migrations.db")
    fmt.Println("Migration files in: migrations/")
    fmt.Println("JSON config: migrations.json")
}
