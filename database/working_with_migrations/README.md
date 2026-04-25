# Database Migrations with SQLite - Complete Guide

This directory contains a comprehensive example of database migrations using SQLite in Harneet, demonstrating both manual migration application and file-based migration management.

## What are Database Migrations?

Database migrations are a way to manage and version your database schema changes over time. They allow you to:

- **Track schema changes** - Keep a history of all database modifications
- **Collaborate safely** - Multiple developers can work on schema changes
- **Roll back changes** - Undo migrations if something goes wrong
- **Deploy consistently** - Apply the same changes across different environments

## Migration Concepts

### Migration Structure
Each migration consists of:
- **Version**: Unique integer identifier (usually timestamp-based)
- **Name**: Descriptive name for the migration
- **Up SQL**: SQL to apply the migration (forward direction)
- **Down SQL**: SQL to reverse the migration (rollback direction)

### Migration States
- **Applied**: Migration has been successfully executed
- **Pending**: Migration is waiting to be applied
- **Failed**: Migration encountered an error during execution

## Example Scenario: Blog Application

We're building a blog application and need to manage the database schema evolution:

1. **Initial schema** - Create users and posts tables
2. **Add user profiles** - Add profile information to users
3. **Add categories** - Create a categories table and link posts to categories
4. **Add tags** - Implement a many-to-many relationship for post tags

## Files in this Directory

- `README.md` - This comprehensive guide
- `migrations/` - Directory containing SQL migration files
  - `001_initial_schema.sql` - Create users and posts tables
  - `002_add_user_profiles.sql` - Add user profile fields
  - `003_add_categories.sql` - Add categories and post-category relationships
  - `004_add_tags.sql` - Add tags and post-tag relationships
- `migrations.json` - JSON configuration for programmatic migration management
- `manual_migrations.ha` - Example using manual migration API
- `file_migrations.ha` - Example using migration files and JSON configuration

## The Dual Migration Approach

This example demonstrates **two complementary approaches** to database migrations, each optimized for different use cases:

### 1. SQL Files (`migrations/` folder) - Human-Centric Development

**Purpose: Development & Documentation**
```sql
-- Migration: Initial Schema - Create users and posts tables
-- Version: 1
-- Name: initial_schema
-- Description: Create the basic tables for a blog application

-- UP: Create users table
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    created_at INTEGER DEFAULT (strftime('%s', 'now')),
    updated_at INTEGER DEFAULT (strftime('%s', 'now'))
);

-- DOWN: Drop tables in reverse dependency order
DROP TABLE posts;
DROP TABLE users;
```

**Advantages:**
- ✅ **Human readable** - Clear SQL with explanatory comments
- ✅ **Self-documenting** - Version, name, description in comments
- ✅ **Git-friendly** - Individual files for version control
- ✅ **Debuggable** - Easy to inspect and modify individual migrations
- ✅ **IDE support** - SQL syntax highlighting and formatting

### 2. JSON Configuration (`migrations.json`) - Machine-Centric Automation

**Purpose: Automation & Deployment**
```json
[
  {
    "version": 1,
    "name": "initial_schema",
    "up": "CREATE TABLE users (id INTEGER PRIMARY KEY...)",
    "down": "DROP TABLE users"
  }
]
```

**Advantages:**
- ✅ **Machine readable** - Structured data for programmatic processing
- ✅ **Deployment ready** - Easy integration with CI/CD pipelines
- ✅ **Validation friendly** - Can validate migration structure before execution
- ✅ **Tool integration** - Works with migration management GUIs/tools
- ✅ **Batch processing** - Easy to analyze and execute multiple migrations

## How They Work Together

### **Development Workflow**
1. **Developer writes SQL files** with detailed comments and metadata
2. **Individual testing** - Run migrations manually to verify
3. **JSON generation** - Convert SQL files to JSON for production (or vice versa)

### **Production Workflow**
1. **Load from JSON** - Automated systems use structured configuration
2. **Batch execution** - Apply multiple migrations programmatically
3. **Rollback planning** - Analyze dependencies and rollback sequences

### **Example Scripts Demonstrate Both**

| Script | Approach | Use Case |
|--------|----------|----------|
| `manual_migrations.ha` | **Direct API** | Development, debugging, fine-grained control |
| `file_migrations.ha` | **File-based** | Production deployment, automation |

**The `file_migrations.ha` script shows both approaches:**
```harneet
// Load from SQL files
var sqlMigrations = loadMigrationsFromSQLDirectory("migrations")

// Load from JSON
var jsonMigrations = loadMigrationsFromJSON("migrations.json")
```

## Running the Examples

### Prerequisites
Make sure you have SQLite installed and the Harneet database module available.

### Manual Migrations Example
```bash
harneet manual_migrations.ha
```

### File-Based Migrations Example
```bash
harneet file_migrations.ha
```

## Migration Best Practices

### 1. Always Write Both Up and Down Migrations
```sql
-- UP: Create the table
CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT);

-- DOWN: Drop the table
DROP TABLE users;
```

### 2. Use Transactions for Complex Migrations
```sql
-- UP
BEGIN TRANSACTION;
CREATE TABLE temp_users AS SELECT * FROM users;
DROP TABLE users;
CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, email TEXT);
INSERT INTO users SELECT id, name FROM temp_users;
DROP TABLE temp_users;
COMMIT;

-- DOWN
ALTER TABLE users DROP COLUMN email;
```

### 3. Test Migrations Thoroughly
- Test up migrations on a copy of production data
- Test down migrations to ensure they work correctly
- Verify data integrity after migration and rollback

### 4. Use Descriptive Names
```sql
-- Good
-- Name: add_user_email_unique_constraint
ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE (email);

-- Avoid
-- Name: update_table
ALTER TABLE users ADD COLUMN email TEXT;
```

### 5. Handle Data Migration Carefully
When changing existing data structures:

```sql
-- UP: Add new column with default
ALTER TABLE users ADD COLUMN status TEXT DEFAULT 'active';

-- Update existing records
UPDATE users SET status = 'active' WHERE status IS NULL;

-- DOWN: Remove column
ALTER TABLE users DROP COLUMN status;
```

## Common Migration Patterns

### Adding a Column
```sql
-- UP
ALTER TABLE users ADD COLUMN phone TEXT;

-- DOWN
ALTER TABLE users DROP COLUMN phone;
```

### Creating a Table with Foreign Key
```sql
-- UP
CREATE TABLE posts (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    FOREIGN KEY(user_id) REFERENCES users(id)
);

-- DOWN
DROP TABLE posts;
```

### Adding an Index
```sql
-- UP
CREATE INDEX idx_users_email ON users(email);

-- DOWN
DROP INDEX idx_users_email;
```

## Error Handling

### Migration Failures
- Always check for errors after each migration
- Log detailed error information
- Consider partial migration recovery

### Rollback on Failure
```harneet
var err = db.MigrateUp(conn, 2, "add_user_profiles",
    "ALTER TABLE users ADD COLUMN age INTEGER")

if err != None {
    // Migration failed, rollback previous migration
    var rollbackErr = db.MigrateDown(conn, 1, "DROP TABLE users")
    if rollbackErr != None {
        fmt.Printf("CRITICAL: Failed to rollback: %v\n", rollbackErr)
    }
    return
}
```

## Production Considerations

### 1. Backup Before Migration
Always backup your database before running migrations in production.

### 2. Migration Locking
Consider implementing migration locks to prevent concurrent migration runs.

### 3. Zero-Downtime Migrations
For large tables, consider strategies like:
- Creating new tables and renaming
- Using shadow tables for data migration
- Blue-green deployment patterns

### 4. Monitoring and Alerting
- Monitor migration execution time
- Alert on migration failures
- Track migration history and versions

## Troubleshooting

### Common Issues

**"table already exists" error**
- Migration was already applied
- Check migration history before applying

**"no such table" error during rollback**
- Table was already dropped
- Migration may have been partially applied

**Foreign key constraint errors**
- Check foreign key relationships before dropping tables
- Drop child tables before parent tables

## Next Steps

After understanding these examples, you can:

1. **Create your own migrations** for your specific application needs
2. **Implement migration management** in your deployment pipeline
3. **Add migration validation** to ensure data integrity
4. **Set up monitoring** for migration health and performance

This migration system provides a solid foundation for managing database schema evolution in your Harneet applications while maintaining data safety and operational reliability.
