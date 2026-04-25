package main

import db
import fmt
import os

// ============================================================================
// COMPREHENSIVE SQLITE MIGRATION EXAMPLE
// ============================================================================
// This example demonstrates:
// 1. Creating a complete database schema with multiple migrations
// 2. Applying migrations (up)
// 3. Rolling back migrations (down)
// 4. Using MigrateToVersion for complex migration scenarios
// 5. Error handling and best practices
// ============================================================================

function main() {
    fmt.Println("🚀 SQLite Migration Example - Up and Down Migrations")
    fmt.Println("===================================================")
    fmt.Println()

    // Database file path
    var dbPath = "example_migrations.db"

    // Clean up previous test database if it exists
    if os.Exists(dbPath) {
        os.Remove(dbPath)
    }

    // ============================================================================
    // STEP 1: OPEN DATABASE CONNECTION
    // ============================================================================
    fmt.Println("📂 Step 1: Opening SQLite database...")
    var conn, openErr = db.Open("sqlite3", dbPath)
    if openErr != None {
        fmt.Printf("❌ ERROR: Failed to open database: %v\n", openErr)
        return
    }
    fmt.Printf("✅ Connected to: %s\n", dbPath)
    fmt.Println()

    // ============================================================================
    // STEP 2: DEFINE MIGRATIONS
    // ============================================================================
    fmt.Println("📋 Step 2: Defining database migrations...")

    // Define a comprehensive set of migrations that demonstrate:
    // - Table creation
    // - Column additions
    // - Index creation
    // - Data seeding
    // - Complex schema changes
    var migrations = [
        {
            "version": 1,
            "name": "create_users_table",
            "up": `
                CREATE TABLE users (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    username TEXT NOT NULL UNIQUE,
                    email TEXT NOT NULL UNIQUE,
                    full_name TEXT NOT NULL,
                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
                )`,
            "down": "DROP TABLE IF EXISTS users"
        },
        {
            "version": 2,
            "name": "create_posts_table",
            "up": `
                CREATE TABLE posts (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_id INTEGER NOT NULL,
                    title TEXT NOT NULL,
                    content TEXT NOT NULL,
                    published BOOLEAN DEFAULT FALSE,
                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
                )`,
            "down": "DROP TABLE IF EXISTS posts"
        },
        {
            "version": 3,
            "name": "add_user_profile_fields",
            "up": `
                ALTER TABLE users ADD COLUMN bio TEXT;
                ALTER TABLE users ADD COLUMN avatar_url TEXT;
                ALTER TABLE users ADD COLUMN last_login_at DATETIME`,
            "down": `
                ALTER TABLE users DROP COLUMN bio;
                ALTER TABLE users DROP COLUMN avatar_url;
                ALTER TABLE users DROP COLUMN last_login_at`
        },
        {
            "version": 4,
            "name": "create_categories_table",
            "up": `
                CREATE TABLE categories (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL UNIQUE,
                    description TEXT,
                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
                )`,
            "down": "DROP TABLE IF EXISTS categories"
        },
        {
            "version": 5,
            "name": "add_post_category_relationship",
            "up": `
                CREATE TABLE post_categories (
                    post_id INTEGER NOT NULL,
                    category_id INTEGER NOT NULL,
                    PRIMARY KEY (post_id, category_id),
                    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
                    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
                )`,
            "down": "DROP TABLE IF EXISTS post_categories"
        },
        {
            "version": 6,
            "name": "create_indexes",
            "up": `
                CREATE INDEX idx_posts_user_id ON posts(user_id);
                CREATE INDEX idx_posts_published ON posts(published);
                CREATE INDEX idx_posts_created_at ON posts(created_at);
                CREATE INDEX idx_users_email ON users(email);
                CREATE INDEX idx_users_username ON users(username)`,
            "down": `
                DROP INDEX IF EXISTS idx_posts_user_id;
                DROP INDEX IF EXISTS idx_posts_published;
                DROP INDEX IF EXISTS idx_posts_created_at;
                DROP INDEX IF EXISTS idx_users_email;
                DROP INDEX IF EXISTS idx_users_username`
        },
        {
            "version": 7,
            "name": "seed_initial_data",
            "up": `
                INSERT INTO categories (name, description) VALUES
                ('Technology', 'Posts about technology and programming'),
                ('Travel', 'Travel stories and experiences'),
                ('Food', 'Recipes and food reviews'),
                ('Personal', 'Personal thoughts and reflections');

                INSERT INTO users (username, email, full_name, bio) VALUES
                ('alice_dev', 'alice@example.com', 'Alice Developer', 'Software engineer passionate about clean code'),
                ('bob_traveler', 'bob@example.com', 'Bob Traveler', 'World traveler and photographer');

                INSERT INTO posts (user_id, title, content, published) VALUES
                (1, 'Getting Started with Harneet', 'Harneet is a powerful programming language with Go-like syntax...', true),
                (1, 'Database Best Practices', 'When working with databases, always use transactions...', true),
                (2, 'My Trip to Japan', 'Japan was absolutely amazing! The culture, food, and people were incredible...', true)`,
            "down": `
                DELETE FROM posts WHERE user_id IN (1, 2);
                DELETE FROM users WHERE id IN (1, 2);
                DELETE FROM categories WHERE name IN ('Technology', 'Travel', 'Food', 'Personal')`
        }
    ]

    fmt.Printf("✅ Defined %d migrations\n", len(migrations))
    for mig in migrations {
        fmt.Printf("   📄 v%d: %s\n", mig["version"], mig["name"])
    }
    fmt.Println()

    // ============================================================================
    // STEP 3: CHECK INITIAL STATE
    // ============================================================================
    fmt.Println("🔍 Step 3: Checking initial database state...")

    var initialVersion, initialErr = db.GetMigrationVersion(conn)
    if initialErr != None {
        fmt.Printf("❌ ERROR: Failed to get initial version: %v\n", initialErr)
        db.Close(conn)
        return
    }
    fmt.Printf("📊 Initial migration version: %d\n", initialVersion)

    var initialHistory, historyErr = db.GetMigrationHistory(conn)
    if historyErr != None {
        fmt.Printf("❌ ERROR: Failed to get migration history: %v\n", historyErr)
        db.Close(conn)
        return
    }
    fmt.Printf("📚 Applied migrations: %d\n", len(initialHistory))
    fmt.Println()

    // ============================================================================
    // STEP 4: APPLY MIGRATIONS (UP)
    // ============================================================================
    fmt.Println("⬆️  Step 4: Applying migrations (UP)...")

    // Apply migrations one by one
    for i in range(len(migrations)) {
        var mig = migrations[i]
        var version = mig["version"]
        var name = mig["name"]
        var upSQL = mig["up"]

        fmt.Printf("⬆️  Applying migration v%d: %s...\n", version, name)

        var migrateErr = db.MigrateUp(conn, version, name, upSQL)
        if migrateErr != None {
            fmt.Printf("❌ ERROR applying v%d: %v\n", version, migrateErr)
            break
        }

        fmt.Printf("✅ Migration v%d applied successfully\n", version)

        // Show current version after each migration
        var currentVersion, _ = db.GetMigrationVersion(conn)
        fmt.Printf("   📊 Current version: %d\n", currentVersion)
        fmt.Println()
    }

    // ============================================================================
    // STEP 5: TEST THE DATABASE
    // ============================================================================
    fmt.Println("🧪 Step 5: Testing the database after migrations...")

    // Test users table
    fmt.Println("📋 Testing users table...")
    var users, usersErr = db.Query(conn, "SELECT id, username, email, full_name FROM users")
    if usersErr != None {
        fmt.Printf("❌ ERROR querying users: %v\n", usersErr)
    } else {
        fmt.Printf("✅ Found %d users:\n", len(users))
        for user in users {
            fmt.Printf("   👤 %s (%s) - %s\n", user["username"], user["email"], user["full_name"])
        }
    }
    fmt.Println()

    // Test posts table
    fmt.Println("📝 Testing posts table...")
    var posts, postsErr = db.Query(conn, "SELECT id, title, published FROM posts")
    if postsErr != None {
        fmt.Printf("❌ ERROR querying posts: %v\n", postsErr)
    } else {
        fmt.Printf("✅ Found %d posts:\n", len(posts))
        for post in posts {
            var status = "Draft"
            if post["published"] {
                status = "Published"
            }
            fmt.Printf("   📄 %s [%s]\n", post["title"], status)
        }
    }
    fmt.Println()

    // Test categories table
    fmt.Println("🏷️  Testing categories table...")
    var categories, catErr = db.Query(conn, "SELECT id, name, description FROM categories")
    if catErr != None {
        fmt.Printf("❌ ERROR querying categories: %v\n", catErr)
    } else {
        fmt.Printf("✅ Found %d categories:\n", len(categories))
        for cat in categories {
            fmt.Printf("   🏷️  %s - %s\n", cat["name"], cat["description"])
        }
    }
    fmt.Println()

    // ============================================================================
    // STEP 6: ROLLBACK MIGRATIONS (DOWN)
    // ============================================================================
    fmt.Println("⬇️  Step 6: Rolling back migrations (DOWN)...")

    // Rollback the last migration (seed data)
    fmt.Println("⬇️  Rolling back migration v7 (removing seed data)...")
    var downErr7 = db.MigrateDown(conn, 7, `
        DELETE FROM posts WHERE user_id IN (1, 2);
        DELETE FROM users WHERE id IN (1, 2);
        DELETE FROM categories WHERE name IN ('Technology', 'Travel', 'Food', 'Personal')`)

    if downErr7 != None {
        fmt.Printf("❌ ERROR rolling back v7: %v\n", downErr7)
    } else {
        fmt.Println("✅ Migration v7 rolled back successfully")
    }

    // Check state after rollback
    var versionAfterRollback, _ = db.GetMigrationVersion(conn)
    fmt.Printf("📊 Version after rollback: %d\n", versionAfterRollback)
    fmt.Println()

    // Verify data was removed
    var usersAfter, _ = db.Query(conn, "SELECT COUNT(*) as count FROM users")
    var postsAfter, _ = db.Query(conn, "SELECT COUNT(*) as count FROM posts")
    var catsAfter, _ = db.Query(conn, "SELECT COUNT(*) as count FROM categories")

    fmt.Println("📊 Data counts after rollback:")
    fmt.Printf("   👤 Users: %d\n", usersAfter[0]["count"])
    fmt.Printf("   📄 Posts: %d\n", postsAfter[0]["count"])
    fmt.Printf("   🏷️  Categories: %d\n", catsAfter[0]["count"])
    fmt.Println()

    // ============================================================================
    // STEP 7: USE MIGRATETOVERSION FOR COMPLEX SCENARIOS
    // ============================================================================
    fmt.Println("🎯 Step 7: Using MigrateToVersion for complex migration scenarios...")

    // Re-apply the seed data migration
    fmt.Println("⬆️  Re-applying migration v7 (seed data) using MigrateToVersion...")
    var reapplyErr = db.MigrateToVersion(conn, 7, migrations)
    if reapplyErr != None {
        fmt.Printf("❌ ERROR re-applying to v7: %v\n", reapplyErr)
    } else {
        fmt.Println("✅ Successfully migrated to version 7")
    }

    var finalVersion, _ = db.GetMigrationVersion(conn)
    fmt.Printf("📊 Final version: %d\n", finalVersion)
    fmt.Println()

    // ============================================================================
    // STEP 8: SHOW FINAL MIGRATION HISTORY
    // ============================================================================
    fmt.Println("📚 Step 8: Final migration history...")

    var finalHistory, finalHistoryErr = db.GetMigrationHistory(conn)
    if finalHistoryErr != None {
        fmt.Printf("❌ ERROR getting final history: %v\n", finalHistoryErr)
    } else {
        fmt.Printf("✅ Applied migrations (%d total):\n", len(finalHistory))
        for mig in finalHistory {
            var appliedAt = mig["applied_at"]
            fmt.Printf("   📄 v%d: %s (applied: %s)\n", mig["version"], mig["name"], formatTimestamp(appliedAt))
        }
    }
    fmt.Println()

    // ============================================================================
    // STEP 9: DEMONSTRATE MIGRATION TO SPECIFIC VERSION
    // ============================================================================
    fmt.Println("🎯 Step 9: Demonstrating migration to specific version...")

    // Migrate back to version 3 (remove categories and posts tables)
    fmt.Println("⬇️  Migrating back to version 3 (removing posts and categories)...")
    var backToV3Err = db.MigrateToVersion(conn, 3, migrations)
    if backToV3Err != None {
        fmt.Printf("❌ ERROR migrating to v3: %v\n", backToV3Err)
    } else {
        fmt.Println("✅ Successfully migrated to version 3")
    }

    var v3Version, _ = db.GetMigrationVersion(conn)
    fmt.Printf("📊 Version after migration to v3: %d\n", v3Version)
    fmt.Println()

    // Show what's left in the database
    var remainingUsers, _ = db.Query(conn, "SELECT COUNT(*) as count FROM users")
    var remainingPosts, _ = db.Query(conn, "SELECT COUNT(*) as count FROM posts")
    var remainingCats, _ = db.Query(conn, "SELECT COUNT(*) as count FROM categories")

    fmt.Println("📊 Database state after migration to v3:")
    fmt.Printf("   👤 Users: %d\n", remainingUsers[0]["count"])
    fmt.Printf("   📄 Posts: %d\n", remainingPosts[0]["count"])
    fmt.Printf("   🏷️  Categories: %d\n", remainingCats[0]["count"])
    fmt.Println()

    // ============================================================================
    // STEP 10: CLEAN UP
    // ============================================================================
    fmt.Println("🧹 Step 10: Cleaning up...")

    // Close the database connection
    db.Close(conn)
    fmt.Println("✅ Database connection closed")

    // Optionally remove the test database file
    if os.Exists(dbPath) {
        os.Remove(dbPath)
        fmt.Printf("✅ Test database file removed: %s\n", dbPath)
    }

    fmt.Println()
    fmt.Println("🎉 Migration example completed successfully!")
    fmt.Println("📚 Key concepts demonstrated:")
    fmt.Println("   ✅ Database connection management")
    fmt.Println("   ✅ Migration definition and structure")
    fmt.Println("   ✅ Applying migrations (up)")
    fmt.Println("   ✅ Rolling back migrations (down)")
    fmt.Println("   ✅ Using MigrateToVersion for complex scenarios")
    fmt.Println("   ✅ Error handling and best practices")
    fmt.Println("   ✅ Database testing and verification")
    fmt.Println("   ✅ Migration history tracking")
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

// formatTimestamp converts Unix timestamp to readable format
function formatTimestamp(timestamp int) string {
    // This is a simplified timestamp formatter
    // In a real application, you might use a proper datetime library
    return "timestamp_" + timestamp
}
