package main

import errors
import file
import fmt
import os
import path
import strings

// Site configuration
type SiteConfig struct {
    title string
    description string
    author string
    baseUrl string
    outputDir string
    contentDir string
    templateDir string
    theme string
}

// Page metadata
type PageMetadata struct {
    title string
    description string
    author string
    date string
    tags string
    layout string
}

// Parsed page content
type Page struct {
    metadata PageMetadata
    content string
    htmlContent string
    slug string
    outputPath string
}

// Main entry point
function main() {
    fmt.Println("=== Harneet Static Site Generator ===")
    fmt.Println("")
    
    // Initialize configuration
    var config SiteConfig = createDefaultConfig()
    
    // Setup directories
    var setupErr error = setupDirectories(config)
    if setupErr != None {
        fmt.Println("Error setting up directories:", setupErr)
        return
    }
    
    // Generate the site
    var genErr error = generateSite(config)
    if genErr != None {
        fmt.Println("Error generating site:", genErr)
        return
    }
    
    fmt.Println("")
    fmt.Println("✓ Site generated successfully!")
    fmt.Printf("Output directory: %s\\n", config.outputDir)
}

// Create default configuration
function createDefaultConfig() SiteConfig {
    var config SiteConfig = SiteConfig{
        title: "My Harneet Blog",
        description: "A blog generated with Harneet Static Site Generator",
        author: "Harneet Developer",
        baseUrl: "https://example.com",
        outputDir: "dist",
        contentDir: "content",
        templateDir: "templates",
        theme: "default"
    }
    return config
}

// Setup necessary directories
function setupDirectories(config SiteConfig) error {
    // Create output directory
    var outputErr error = os.MkdirAll(config.outputDir)
    if outputErr != None {
        return outputErr
    }
    
    // Create content directory if it doesn't exist
    var contentExists bool, contentExistsErr error = file.Exists(config.contentDir)
    if contentExistsErr != None {
        return contentExistsErr
    }
    
    if !contentExists {
        return errors.New("Content directory '" + config.contentDir + "' not found. Please create it and add .md files.")
    }
    
    // Create template directory if it doesn't exist
    var templateExists bool, templateExistsErr error = file.Exists(config.templateDir)
    if templateExistsErr != None {
        return templateExistsErr
    }
    
    if !templateExists {
        var templateErr error = os.MkdirAll(config.templateDir)
        if templateErr != None {
            return templateErr
        }
    }
    
    return None
}

// Generate the entire site
function generateSite(config SiteConfig) error {
    fmt.Println("Generating site...")
    
    // List all content files
    var contentFiles []string, listErr error = file.List(config.contentDir)
    if listErr != None {
        return listErr
    }
    

    
    // Create templates if they don't exist
    var templateErr error = ensureTemplates(config)
    if templateErr != None {
        return templateErr
    }
    
    // Process each content file
    var pages []Page = []Page{}
    var i int = 0
    for i < len(contentFiles) {
        var filename string = contentFiles[i]
        
        // Only process .md files
        var hasSuffix bool, suffixErr error = strings.HasSuffix(filename, ".md")
        if suffixErr == None and hasSuffix {
            fmt.Printf("Processing: %s\\n", filename)
            
            var contentPath string, pathErr error = path.Join(config.contentDir, filename)
            if pathErr != None {
                fmt.Println("Error joining path:", pathErr)
                i = i + 1
                continue
            }
            
            var page Page, pageErr error = processContentFile(contentPath, config)
            if pageErr != None {
                fmt.Printf("Error processing %s: %v\\n", filename, pageErr)
                i = i + 1
                continue
            }
            
            pages = append(pages, page)
        }
        
        i = i + 1
    }
    
    // Generate index page
    var indexErr error = generateIndexPage(pages, config)
    if indexErr != None {
        return indexErr
    }
    
    // Copy static assets
    var assetsErr error = copyStaticAssets(config)
    if assetsErr != None {
        return assetsErr
    }
    
    fmt.Printf("Generated %d pages\\n", len(pages))
    
    return None
}

// Process a single content file
function processContentFile(filepath string, config SiteConfig) (Page, error) {
    // Read the file
    var content string, readErr error = file.Read(filepath)
    if readErr != None {
        var emptyPage Page = Page{}
        return emptyPage, readErr
    }
    
    // Parse frontmatter and content
    var metadata PageMetadata, bodyContent string, parseErr error = parseFrontmatter(content)
    if parseErr != None {
        var emptyPage Page = Page{}
        return emptyPage, parseErr
    }
    
    // Convert markdown to HTML
    var htmlContent string = markdownToHtml(bodyContent)
    
    // Generate slug from filename
    var basename string, basenameErr error = path.Base(filepath)
    if basenameErr != None {
        var emptyPage Page = Page{}
        return emptyPage, basenameErr
    }
    
    var slug string, slugErr error = strings.TrimSuffix(basename, ".md")
    if slugErr != None {
        var emptyPage Page = Page{}
        return emptyPage, slugErr
    }
    
    // Create output path
    var outputFilename string = slug + ".html"
    var outputPath string, outputPathErr error = path.Join(config.outputDir, outputFilename)
    if outputPathErr != None {
        var emptyPage Page = Page{}
        return emptyPage, outputPathErr
    }
    
    // Create page object
    var page Page = Page{
        metadata: metadata,
        content: bodyContent,
        htmlContent: htmlContent,
        slug: slug,
        outputPath: outputPath
    }
    
    // Render and write the page
    var renderErr error = renderPage(page, config)
    if renderErr != None {
        var emptyPage Page = Page{}
        return emptyPage, renderErr
    }
    
    return page, None
}

// Parse frontmatter from content
function parseFrontmatter(content string) (PageMetadata, string, error) {
    var metadata PageMetadata = PageMetadata{
        title: "Untitled",
        description: "",
        author: "",
        date: "",
        tags: "",
        layout: "default"
    }
    
    // Check if content starts with ---
    var hasPrefix bool, prefixErr error = strings.HasPrefix(content, "---")
    if prefixErr != None or !hasPrefix {
        return metadata, content, None
    }
    
    // Find the closing ---
    var lines []string, splitErr error = strings.Split(content, "\n")
    if splitErr != None {
        return metadata, content, splitErr
    }
    
    var frontmatterEnd int = -1
    var i int = 1
    for i < len(lines) {
        var trimmed string, trimErr error = strings.TrimSpace(lines[i])
        if trimErr == None and len(trimmed) > 0 {
            var isSeparator bool, sepErr error = strings.HasPrefix(trimmed, "---")
            if sepErr == None and isSeparator {
                frontmatterEnd = i
                break
            }
        }
        i = i + 1
    }
    
    if frontmatterEnd == -1 {
        // No closing separator found
        return metadata, content, None
    }
    
    // Parse frontmatter lines inline
    var j int = 1
    for j < frontmatterEnd {
        var line string, lineErr error = strings.TrimSpace(lines[j])
        if lineErr == None and len(line) > 0 {
            // Parse key:value pair
            var parts []string, splitErr error = strings.Split(line, ":")
            if splitErr == None and len(parts) >= 2 {
                var key string, keyErr error = strings.TrimSpace(parts[0])
                var value string, valueErr error = strings.TrimSpace(parts[1])
                
                if keyErr == None and valueErr == None {
                    var keyLower string, lowerErr error = strings.Lower(key)
                    if lowerErr == None {
                        if keyLower == "title" {
                            metadata.title = value
                        } else if keyLower == "description" {
                            metadata.description = value
                        } else if keyLower == "author" {
                            metadata.author = value
                        } else if keyLower == "date" {
                            metadata.date = value
                        } else if keyLower == "layout" {
                            metadata.layout = value
                        }
                    }
                }
            }
        }
        j = j + 1
    }
    
    // Extract body content (everything after frontmatter)
    var bodyLines []string = []string{}
    var k int = frontmatterEnd + 1
    for k < len(lines) {
        bodyLines = append(bodyLines, lines[k])
        k = k + 1
    }
    
    var bodyContent string, joinErr error = strings.Join(bodyLines, "\n")
    if joinErr != None {
        return metadata, content, joinErr
    }
    
    return metadata, bodyContent, None
}

// Convert markdown to HTML (simplified)
function markdownToHtml(markdown string) string {
    var html string = markdown
    
    // Headers (### -> h3, ## -> h2, # -> h1)
    html, _ = strings.Replace(html, "### ", "<h3>")
    html, _ = strings.Replace(html, "## ", "<h2>")
    html, _ = strings.Replace(html, "# ", "<h1>")
    
    // Bold **text** -> <strong>text</strong>
    // Italic *text* -> <em>text</em>
    // Note: This is a simplified implementation
    
    // Paragraphs - split by double newline
    var paragraphs []string, splitErr error = strings.Split(html, "\n\n")
    if splitErr == None {
        var processedParas []string = []string{}
        var i int = 0
        for i < len(paragraphs) {
            var para string, trimErr error = strings.TrimSpace(paragraphs[i])
            if trimErr == None and len(para) > 0 {
                // Don't wrap headers in <p> tags
                var isHeader bool, h1Err error = strings.HasPrefix(para, "<h")
                if h1Err == None and isHeader {
                    processedParas = append(processedParas, para)
                } else {
                    var wrappedPara string = "<p>" + para + "</p>"
                    processedParas = append(processedParas, wrappedPara)
                }
            }
            i = i + 1
        }
        html, _ = strings.Join(processedParas, "\n")
    }
    
    return html
}

// Render page with template
function renderPage(page Page, config SiteConfig) error {
    // Load template
    var templatePath string, pathErr error = path.Join(config.templateDir, "page.html")
    if pathErr != None {
        return pathErr
    }
    
    var template string, readErr error = file.Read(templatePath)
    if readErr != None {
        return readErr
    }
    
    // Replace template variables
    var rendered string = template
    rendered, _ = strings.Replace(rendered, "{{SITE_TITLE}}", config.title)
    rendered, _ = strings.Replace(rendered, "{{SITE_DESCRIPTION}}", config.description)
    rendered, _ = strings.Replace(rendered, "{{SITE_AUTHOR}}", config.author)
    rendered, _ = strings.Replace(rendered, "{{PAGE_TITLE}}", page.metadata.title)
    rendered, _ = strings.Replace(rendered, "{{PAGE_DESCRIPTION}}", page.metadata.description)
    rendered, _ = strings.Replace(rendered, "{{PAGE_CONTENT}}", page.htmlContent)
    rendered, _ = strings.Replace(rendered, "{{PAGE_DATE}}", page.metadata.date)
    
    // Write to output file
    var _, writeErr error = file.Write(page.outputPath, rendered)
    if writeErr != None {
        return writeErr
    }
    
    fmt.Printf("  ✓ Generated: %s\\n", page.outputPath)
    
    return None
}

// Generate index page with list of all pages
function generateIndexPage(pages []Page, config SiteConfig) error {
    fmt.Println("Generating index page...")
    
    // Load index template
    var templatePath string, pathErr error = path.Join(config.templateDir, "index.html")
    if pathErr != None {
        return pathErr
    }
    
    var template string, readErr error = file.Read(templatePath)
    if readErr != None {
        return readErr
    }
    
    // Build page list HTML
    var pageListHtml string = `<div class="post-list">`
    var i int = 0
    for i < len(pages) {
        var page Page = pages[i]
        var pageHtml string = `<article class="post-preview">`
        var linkHtml string = "<h2><a href=\"" + page.slug + ".html\">" + page.metadata.title + "</a></h2>"
        pageHtml = pageHtml + linkHtml
        
        if len(page.metadata.description) > 0 {
            var descHtml string = `<p class="description">` + page.metadata.description + "</p>"
            pageHtml = pageHtml + descHtml
        }
        
        if len(page.metadata.date) > 0 {
            var dateHtml string = "<time>" + page.metadata.date + "</time>"
            pageHtml = pageHtml + dateHtml
        }
        
        pageHtml = pageHtml + "</article>"
        pageListHtml = pageListHtml + pageHtml
        
        i = i + 1
    }
    pageListHtml = pageListHtml + "</div>"
    
    // Replace template variables
    var rendered string = template
    rendered, _ = strings.Replace(rendered, "{{SITE_TITLE}}", config.title)
    rendered, _ = strings.Replace(rendered, "{{SITE_DESCRIPTION}}", config.description)
    rendered, _ = strings.Replace(rendered, "{{SITE_AUTHOR}}", config.author)
    rendered, _ = strings.Replace(rendered, "{{PAGE_LIST}}", pageListHtml)
    
    // Write index.html
    var indexPath string, indexPathErr error = path.Join(config.outputDir, "index.html")
    if indexPathErr != None {
        return indexPathErr
    }
    
    var _, writeErr error = file.Write(indexPath, rendered)
    if writeErr != None {
        return writeErr
    }
    
    fmt.Printf("  ✓ Generated: %s\\n", indexPath)
    
    return None
}

// Ensure templates exist
function ensureTemplates(config SiteConfig) error {
    // Check if page template exists
    var pageTemplatePath string, pagePathErr error = path.Join(config.templateDir, "page.html")
    if pagePathErr != None {
        return pagePathErr
    }
    
    var pageExists bool, pageExistsErr error = file.Exists(pageTemplatePath)
    if pageExistsErr != None {
        return pageExistsErr
    }
    
    if !pageExists {
        var createErr error = createDefaultPageTemplate(pageTemplatePath)
        if createErr != None {
            return createErr
        }
    }
    
    // Check if index template exists
    var indexTemplatePath string, indexPathErr error = path.Join(config.templateDir, "index.html")
    if indexPathErr != None {
        return indexPathErr
    }
    
    var indexExists bool, indexExistsErr error = file.Exists(indexTemplatePath)
    if indexExistsErr != None {
        return indexExistsErr
    }
    
    if !indexExists {
        var createErr error = createDefaultIndexTemplate(indexTemplatePath)
        if createErr != None {
            return createErr
        }
    }
    
    return None
}

// Create default page template
function createDefaultPageTemplate(filepath string) error {
    var template string = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="{{PAGE_DESCRIPTION}}">
    <title>{{PAGE_TITLE}} | {{SITE_TITLE}}</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <nav>
            <a href="index.html" class="logo">{{SITE_TITLE}}</a>
            <ul>
                <li><a href="index.html">Home</a></li>
                <li><a href="about.html">About</a></li>
            </ul>
        </nav>
    </header>
    
    <main>
        <article>
            <header class="article-header">
                <h1>{{PAGE_TITLE}}</h1>
                <time>{{PAGE_DATE}}</time>
            </header>
            
            <div class="content">
                {{PAGE_CONTENT}}
            </div>
        </article>
    </main>
    
    <footer>
        <p>&copy; 2026 {{SITE_AUTHOR}}. Built with Harneet Static Site Generator.</p>
    </footer>
</body>
</html>`
    
    var _, writeErr error = file.Write(filepath, template)
    return writeErr
}

// Create default index template
function createDefaultIndexTemplate(filepath string) error {
    var template string = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="{{SITE_DESCRIPTION}}">
    <title>{{SITE_TITLE}}</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <nav>
            <a href="index.html" class="logo">{{SITE_TITLE}}</a>
            <ul>
                <li><a href="index.html">Home</a></li>
                <li><a href="about.html">About</a></li>
            </ul>
        </nav>
    </header>
    
    <main>
        <div class="hero">
            <h1>{{SITE_TITLE}}</h1>
            <p>{{SITE_DESCRIPTION}}</p>
        </div>
        
        <section class="posts">
            <h2>Latest Posts</h2>
            {{PAGE_LIST}}
        </section>
    </main>
    
    <footer>
        <p>&copy; 2026 {{SITE_AUTHOR}}. Built with Harneet Static Site Generator.</p>
    </footer>
</body>
</html>`
    
    var _, writeErr error = file.Write(filepath, template)
    return writeErr
}

// Create sample content


// Copy static assets (CSS, images, etc.)
function copyStaticAssets(config SiteConfig) error {
    // Create style.css
    var stylePath string, stylePathErr error = path.Join(config.outputDir, "style.css")
    if stylePathErr != None {
        return stylePathErr
    }
    
    var css string = `/* Harneet Static Site Generator - Default Theme */

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

:root {
    --primary-color: #667eea;
    --secondary-color: #764ba2;
    --text-color: #2d3748;
    --text-light: #718096;
    --bg-color: #ffffff;
    --bg-light: #f7fafc;
    --border-color: #e2e8f0;
    --shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
    line-height: 1.6;
    color: var(--text-color);
    background: var(--bg-color);
}

header {
    background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
    color: white;
    padding: 1rem 0;
    box-shadow: var(--shadow);
}

nav {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 2rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

nav .logo {
    font-size: 1.5rem;
    font-weight: bold;
    color: white;
    text-decoration: none;
}

nav ul {
    list-style: none;
    display: flex;
    gap: 2rem;
}

nav a {
    color: white;
    text-decoration: none;
    transition: opacity 0.3s;
}

nav a:hover {
    opacity: 0.8;
}

main {
    max-width: 1200px;
    margin: 2rem auto;
    padding: 0 2rem;
}

.hero {
    text-align: center;
    padding: 4rem 2rem;
    background: linear-gradient(135deg, var(--bg-light), white);
    border-radius: 12px;
    margin-bottom: 3rem;
}

.hero h1 {
    font-size: 3rem;
    margin-bottom: 1rem;
    background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

.hero p {
    font-size: 1.25rem;
    color: var(--text-light);
}

.posts {
    margin-top: 3rem;
}

.posts h2 {
    font-size: 2rem;
    margin-bottom: 2rem;
    color: var(--text-color);
}

.post-list {
    display: grid;
    gap: 2rem;
}

.post-preview {
    background: white;
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 2rem;
    transition: transform 0.3s, box-shadow 0.3s;
}

.post-preview:hover {
    transform: translateY(-4px);
    box-shadow: var(--shadow);
}

.post-preview h2 {
    font-size: 1.75rem;
    margin-bottom: 0.5rem;
}

.post-preview h2 a {
    color: var(--text-color);
    text-decoration: none;
}

.post-preview h2 a:hover {
    color: var(--primary-color);
}

.post-preview .description {
    color: var(--text-light);
    margin-bottom: 1rem;
}

.post-preview time {
    color: var(--text-light);
    font-size: 0.875rem;
}

article {
    background: white;
    border-radius: 12px;
    padding: 3rem;
    box-shadow: var(--shadow);
}

.article-header {
    border-bottom: 2px solid var(--border-color);
    padding-bottom: 1.5rem;
    margin-bottom: 2rem;
}

.article-header h1 {
    font-size: 2.5rem;
    margin-bottom: 0.5rem;
    background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

.article-header time {
    color: var(--text-light);
    font-size: 0.875rem;
}

.content {
    line-height: 1.8;
}

.content h1, .content h2, .content h3 {
    margin-top: 2rem;
    margin-bottom: 1rem;
    color: var(--text-color);
}

.content h1 {
    font-size: 2rem;
}

.content h2 {
    font-size: 1.75rem;
}

.content h3 {
    font-size: 1.5rem;
}

.content p {
    margin-bottom: 1rem;
}

.content ul, .content ol {
    margin-left: 2rem;
    margin-bottom: 1rem;
}

.content code {
    background: var(--bg-light);
    padding: 0.25rem 0.5rem;
    border-radius: 4px;
    font-family: 'Courier New', monospace;
    font-size: 0.875rem;
}

.content pre {
    background: var(--bg-light);
    padding: 1rem;
    border-radius: 8px;
    overflow-x: auto;
    margin-bottom: 1rem;
}

.content pre code {
    background: none;
    padding: 0;
}

footer {
    background: var(--bg-light);
    border-top: 1px solid var(--border-color);
    text-align: center;
    padding: 2rem;
    margin-top: 4rem;
    color: var(--text-light);
}

@media (max-width: 768px) {
    .hero h1 {
        font-size: 2rem;
    }
    
    nav {
        flex-direction: column;
        gap: 1rem;
    }
    
    article {
        padding: 1.5rem;
    }
    
    .article-header h1 {
        font-size: 2rem;
    }
}`
    
    var _, cssWriteErr error = file.Write(stylePath, css)
    if cssWriteErr != None {
        return cssWriteErr
    }
    
    fmt.Println("✓ Created stylesheet")
    
    return None
}
