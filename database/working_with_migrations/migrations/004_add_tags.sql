-- Migration: Add Tags - Create tags system with many-to-many relationship to posts
-- Version: 4
-- Name: add_tags
-- Description: Add tags system for flexible post categorization

-- UP: Create tags table
CREATE TABLE tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    color TEXT DEFAULT '#007acc',
    created_at INTEGER DEFAULT (strftime('%s', 'now'))
);

-- UP: Create post_tags junction table for many-to-many relationship
CREATE TABLE post_tags (
    post_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    created_at INTEGER DEFAULT (strftime('%s', 'now')),
    PRIMARY KEY(post_id, tag_id),
    FOREIGN KEY(post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY(tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

-- UP: Insert some default tags
INSERT INTO tags (name, slug, color) VALUES
    ('JavaScript', 'javascript', '#f7df1e'),
    ('Python', 'python', '#3776ab'),
    ('Web Development', 'web-development', '#e34f26'),
    ('Database', 'database', '#336791'),
    ('Tutorial', 'tutorial', '#ff6b6b'),
    ('News', 'news', '#4ecdc4');

-- UP: Create indexes for better performance
CREATE INDEX idx_tags_slug ON tags(slug);
CREATE INDEX idx_post_tags_post_id ON post_tags(post_id);
CREATE INDEX idx_post_tags_tag_id ON post_tags(tag_id);

-- DOWN: Drop tables and indexes in reverse order
DROP INDEX IF EXISTS idx_post_tags_tag_id;
DROP INDEX IF EXISTS idx_post_tags_post_id;
DROP INDEX IF EXISTS idx_tags_slug;
DROP TABLE post_tags;
DROP TABLE tags;
