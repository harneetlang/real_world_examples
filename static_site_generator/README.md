# Harneet Static Site Generator

A fully-functional static site generator built entirely in the Harneet programming language. This tool demonstrates Harneet's capabilities for file I/O, string manipulation, template processing, and error handling.

## Features

✨ **Markdown-like Content** - Write your content in simple markdown format with frontmatter metadata  
🎨 **Template System** - Use HTML templates with variable substitution  
📝 **Frontmatter Support** - Add metadata like title, description, author, and date to your posts  
🎯 **Auto-generation** - Automatically generates index pages listing all your posts  
💅 **Beautiful Default Theme** - Modern, responsive CSS with gradient accents  
🚀 **Zero Dependencies** - Uses only Harneet's built-in standard library  

## Quick Start

### 1. Run the Generator

```bash
cd examples/static_site_generator
harneet generator.ha
```

The generator will:
- Create necessary directories (`content/`, `templates/`, `dist/`)
- Generate sample content if none exists
- Create default templates
- Build your static site in the `dist/` directory

### 2. View Your Site

Open `dist/index.html` in your browser to see your generated site!

## Directory Structure

```
static_site_generator/
├── generator.ha          # Main generator program
├── README.md            # This file
├── content/             # Your markdown content files (auto-created)
│   ├── welcome.md
│   ├── building-with-harneet.md
│   └── about.md
├── templates/           # HTML templates (auto-created)
│   ├── index.html       # Home page template
│   └── page.html        # Individual page template
└── dist/                # Generated static site (output)
    ├── index.html
    ├── welcome.html
    ├── building-with-harneet.html
    ├── about.html
    └── style.css
```

## Writing Content

Create `.md` files in the `content/` directory with the following format:

```markdown
---
title: My Blog Post Title
description: A brief description of the post
author: Your Name
date: 2026-01-29
layout: default
---

# Main Heading

Your content here in markdown-like format.

## Subheading

- Bullet points
- More content
- **Bold text** supported

## Another Section

Paragraphs are automatically wrapped in `<p>` tags.
```

### Frontmatter Fields

- **title**: Page title (appears in `<h1>` and `<title>`)
- **description**: Meta description for SEO
- **author**: Author name
- **date**: Publication date
- **layout**: Template layout (currently only "default")

## Template Variables

Templates support the following variables:

### Site-wide Variables
- `{{SITE_TITLE}}` - Site title from configuration
- `{{SITE_DESCRIPTION}}` - Site description
- `{{SITE_AUTHOR}}` - Site author

### Page-specific Variables
- `{{PAGE_TITLE}}` - Individual page title
- `{{PAGE_DESCRIPTION}}` - Page description
- `{{PAGE_CONTENT}}` - Rendered HTML content
- `{{PAGE_DATE}}` - Page publication date
- `{{PAGE_LIST}}` - List of all pages (index template only)

## Customization

### Modify Site Configuration

Edit the `createDefaultConfig()` function in `generator.ha`:

```harneet
function createDefaultConfig() SiteConfig {
    var config SiteConfig = SiteConfig{
        title: "Your Site Title",
        description: "Your site description",
        author: "Your Name",
        baseUrl: "https://yoursite.com",
        outputDir: "dist",
        contentDir: "content",
        templateDir: "templates",
        theme: "default"
    }
    return config
}
```

### Customize Templates

Modify `templates/page.html` and `templates/index.html` to change the HTML structure.

### Customize Styles

Edit `dist/style.css` or modify the `copyStaticAssets()` function to change the CSS:

```css
:root {
    --primary-color: #667eea;      /* Change to your brand color */
    --secondary-color: #764ba2;    /* Change gradient end color */
    --text-color: #2d3748;
}
```

## How It Works

### 1. Content Processing
- Scans the `content/` directory for `.md` files
- Parses frontmatter (YAML-like metadata between `---` separators)
- Extracts body content

### 2. Markdown to HTML Conversion
- Converts headers (`#`, `##`, `###` → `<h1>`, `<h2>`, `<h3>`)
- Wraps paragraphs in `<p>` tags
- Handles basic formatting

### 3. Template Rendering
- Loads HTML templates
- Replaces template variables with actual content
- Generates complete HTML pages

### 4. Asset Generation
- Creates index page with post listing
- Copies CSS stylesheet
- Outputs all files to `dist/` directory

## Code Highlights

This static site generator showcases several Harneet language features:

### Structs
```harneet
struct SiteConfig {
    title string
    description string
    author string
    baseUrl string
    outputDir string
    contentDir string
    templateDir string
    theme string
}
```

### Error Handling with Tuples
```harneet
var content string, readErr error = file.Read(filepath)
if readErr != None {
    return readErr
}
```

### File Operations
```harneet
var _, writeErr error = file.Write(filepath, content)
var files []string, listErr error = file.List(directory)
var exists bool, existsErr error = file.Exists(path)
```

### String Manipulation
```harneet
var hasPrefix bool, prefixErr error = strings.HasPrefix(content, "---")
var parts []string, splitErr error = strings.Split(line, ":")
var replaced string, replaceErr error = strings.Replace(text, "old", "new")
```

### Loops and Arrays
```harneet
var i int = 0
for i < len(contentFiles) {
    var filename string = contentFiles[i]
    // Process file
    i = i + 1
}
```

## Deployment

The generated site in the `dist/` directory is ready to deploy to any static hosting service:

- **GitHub Pages**: Push the `dist/` folder to your repo
- **Netlify**: Drag and drop the `dist/` folder
- **Vercel**: Deploy the `dist/` directory
- **Any web server**: Copy `dist/` contents to your web root

## Future Enhancements

Potential features to add:

- [ ] Full markdown support (links, images, code blocks)
- [ ] RSS feed generation
- [ ] Sitemap generation
- [ ] Tag and category pages
- [ ] Pagination for large blogs
- [ ] Syntax highlighting for code
- [ ] Image optimization
- [ ] Multiple theme support
- [ ] Watch mode for development
- [ ] Live reload server

## Contributing

This is an example project demonstrating Harneet's capabilities. Feel free to:
- Extend the functionality
- Add new features
- Improve the markdown parser
- Create new themes
- Fix bugs

## License

This example is part of the Harneet language examples and follows the same license as the Harneet project.

## Learn More

- [Harneet Language Documentation](https://harneetlang.com)
- [More Harneet Examples](../README.md)
- [File Module Reference](../../docs/stdlib/file.md)
- [String Module Reference](../../docs/stdlib/strings.md)

---

Built with ❤️ using the Harneet Programming Language
