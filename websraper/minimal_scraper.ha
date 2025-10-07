/*
    Harneet Programming Language 
    File Name - minimal_scraper.ha.
    Purpose - provides an example of how to
        1. Perform Webscraping in Harneet Programming language
    Purposefuly verbose - so as to show all the functionalities of the language
*/

package main

import fmt
import http
import cast, os
import strings as str

fmt.Println("=== Minimal Web Scraper ===")

function main() {
    var url = "https://httpbin.org/html"
    fmt.Printf("Fetching: %s\n", url)

    var result, err = http.Get(url)
    if err != None {
        fmt.Println("An error was encountered while getting the URL information. Error follows → ", err)
        os.Exit(1)
    }else {
        fmt.Println("No errors were found")
    }

    fmt.Println(result)
    var response = result.body

    fmt.Println(result.status)

    if result.status != 200 {
        fmt.Printf("HTTP Error: %d %s\n", response["status"], response["statusText"])
        return
    }

    var html, _ = cast.ToString(result.body)
    fmt.Printf("Fetched %d bytes\n", len(html))

    // Simple title extraction
    var titleStart,_ = str.Index(html, "<title>")
    var titleEnd,_ = str.Index(html, "</title>")

    fmt.Println(titleStart)
    fmt.Println(titleEnd)
    
    if titleStart != -1 and titleEnd != -1 {
        var title = str.Substring(html, titleStart + 7, titleEnd)
        fmt.Printf("Title: %s\n", title)
    } else {
        fmt.Println("No title found")
    }
}
