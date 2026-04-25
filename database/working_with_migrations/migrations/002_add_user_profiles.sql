-- Migration: Add User Profiles - Add profile fields to users table
-- Version: 2
-- Name: add_user_profiles
-- Description: Add profile information fields to the users table

-- UP: Add profile columns to users table
ALTER TABLE users ADD COLUMN first_name TEXT;
ALTER TABLE users ADD COLUMN last_name TEXT;
ALTER TABLE users ADD COLUMN bio TEXT;
ALTER TABLE users ADD COLUMN avatar_url TEXT;
ALTER TABLE users ADD COLUMN location TEXT;
ALTER TABLE users ADD COLUMN website TEXT;

-- UP: Update existing records to have default values
UPDATE users SET first_name = '', last_name = '', bio = '' WHERE first_name IS NULL;

-- UP: Create index for full name search
CREATE INDEX idx_users_full_name ON users(first_name, last_name);

-- DOWN: Remove profile columns (in reverse order)
DROP INDEX IF EXISTS idx_users_full_name;
ALTER TABLE users DROP COLUMN website;
ALTER TABLE users DROP COLUMN location;
ALTER TABLE users DROP COLUMN avatar_url;
ALTER TABLE users DROP COLUMN bio;
ALTER TABLE users DROP COLUMN last_name;
ALTER TABLE users DROP COLUMN first_name;
