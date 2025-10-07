/*
    Harneet Programming Language 
    File Name - webscraper.ha.
    Purpose - provides a detailed example of how to
        1. Perform Webscraping in Harneet Programming language
    Purposefuly verbose - so as to show all the functionalities of the language
*/

package main
import fmt
import http
import regex
import cast

fmt.Println("=== Harneet Web Scraping Examples ===")
fmt.Println("🌐 Using HTTP module for requests and regex for HTML parsing")

// Test the scraper
var testUrl = "https://www.wikipedia.org/"
fmt.Println("\n==================================================")
fmt.Println("🚀 Testing web scraper")

fmt.Println("\n🌍 Scraping webpage")
fmt.Printf("Fetching: %s\n", testUrl)

var response, err = http.Get(testUrl)
if err != None {
    fmt.Printf("❌ Error fetching page: %s\n", err)
} else {
    var status = response["status"]
    if status != 200 {
        var statusText = response["statusText"]
        fmt.Printf("❌ HTTP error: %d %s\n", status, statusText)
    } else {
        var body = response["body"]
        var html, cast_err = cast.ToString(body)
        if cast_err != None {
            fmt.Printf("❌ Error converting body to string: %s\n", cast_err)
        } else {
            fmt.Printf("✅ Successfully fetched %d bytes of HTML\n", len(html))
            
            // Extract page title
            fmt.Println("\n📄 Extracting page title")
            var titleMatches, titleErr = regex.FindStringSubmatch("<title[^>]*>([^<]*)</title>", html)
            if titleErr != None {
                fmt.Printf("❌ Error extracting title: %s\n", titleErr)
            } else {
                if titleMatches == None {
                    fmt.Println("❌ No title found")
                } else {
                    if len(titleMatches) > 1 {
                        fmt.Printf("✅ Title found: '%s'\n", titleMatches[1])
                    } else {
                        fmt.Println("❌ No title capture group found")
                    }
                }
            }
            
            // Extract first link
            fmt.Println("\n🔗 Extracting first link")
            var linkMatches, linkErr = regex.FindStringSubmatch("<a[^>]+href=[\"']([^\"']+)[\"'][^>]*>", html)
            if linkErr != None {
                fmt.Printf("❌ Error extracting link: %s\n", linkErr)
            } else {
                if linkMatches == None {
                    fmt.Println("❌ No links found")
                } else {
                    if len(linkMatches) > 1 {
                        fmt.Printf("✅ Found link: %s\n", linkMatches[1])
                    } else {
                        fmt.Println("❌ No link capture group found")
                    }
                }
            }
            
            fmt.Println("\n📊 Scraping Summary:")
            fmt.Println("   📄 Page successfully scraped")
            fmt.Println("   🔗 Regex patterns applied")
        }
    }
}

fmt.Println("\n==================================================")
fmt.Println("🎉 Web scraping example completed!")
fmt.Println("\n💡 Tips for production web scraping:")
fmt.Println("   • Add delays between requests")
fmt.Println("   • Handle rate limiting and retries")
fmt.Println("   • Check robots.txt before scraping")
fmt.Println("   • Use proper User-Agent headers")
