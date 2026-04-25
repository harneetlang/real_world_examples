-- Migration: Add Categories - Create categories table and post-category relationships
-- Version: 3
-- Name: add_categories
-- Description: Add categories system with many-to-many relationship to posts

-- UP: Create categories table
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at INTEGER DEFAULT (strftime('%s', 'now'))
);

-- UP: Create post_categories junction table for many-to-many relationship
CREATE TABLE post_categories (
    post_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    created_at INTEGER DEFAULT (strftime('%s', 'now')),
    PRIMARY KEY(post_id, category_id),
    FOREIGN KEY(post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE CASCADE
);

-- UP: Insert some default categories
INSERT INTO categories (name, slug, description) VALUES
    ('Technology', 'technology', 'Posts about technology and programming'),
    ('Travel', 'travel', 'Travel stories and guides'),
    ('Food', 'food', 'Recipes and food reviews'),
    ('Personal', 'personal', 'Personal thoughts and experiences');

-- UP: Create indexes for better performance
CREATE INDEX idx_categories_slug ON categories(slug);
CREATE INDEX idx_post_categories_post_id ON post_categories(post_id);
CREATE INDEX idx_post_categories_category_id ON post_categories(category_id);

-- DOWN: Drop tables and indexes in reverse order
DROP INDEX IF EXISTS idx_post_categories_category_id;
DROP INDEX IF EXISTS idx_post_categories_post_id;
DROP INDEX IF EXISTS idx_categories_slug;
DROP TABLE post_categories;
DROP TABLE categories;
