package main

import fmt
import "./config" as config
import "./color" as color

function init() {
    fmt.Println("🔧 Initializing sample project...")
}

function main() {
    fmt.Printf("%s\n", color.BoldGreenText("🚀 Harneet Module System Demo with Local Packages"))
    fmt.Println("============================================================")
    
    // Display configuration using our local config package
    config.DisplayConfig()
    
    fmt.Println()
    
    // Demonstrate colored output
    fmt.Printf("%s Demonstrating Color Package:\n", color.BlueText("🎨"))
    color.PrintSuccess("This is a success message")
    color.PrintError("This is an error message")
    color.PrintWarning("This is a warning message")
    color.PrintInfo("This is an info message")
    
    fmt.Println()
    
    // Show individual configuration values
    fmt.Printf("%s Individual Configuration Access:\n", color.BlueText("🔑"))
    fmt.Printf("  App Name: %s\n", color.GreenText(config.GetString("app.name")))
    fmt.Printf("  App Version: %s\n", color.GreenText(config.GetString("app.version")))
    
    var debugStr, _ = fmt.Sprintf("%t", config.GetBool("app.debug"))
    fmt.Printf("  Debug Mode: %s\n", color.YellowText(debugStr))
    
    var portStr, _ = fmt.Sprintf("%d", config.GetInt("app.port"))
    fmt.Printf("  Port: %s\n", color.BlueText(portStr))
    
    fmt.Println()
    
    // Demonstrate configuration updates
    fmt.Printf("%s Configuration Updates:\n", color.BlueText("📄"))
    color.PrintInfo("Updating configuration values...")
    config.UpdateConfig("Updated Harneet App", 9000)
    fmt.Printf("  New Name: %s\n", color.GreenText(config.GetString("app.name")))
    
    var newPortStr, _ = fmt.Sprintf("%d", config.GetInt("app.port"))
    fmt.Printf("  New Port: %s\n", color.BlueText(newPortStr))
    
    fmt.Println()
    
    // Show module system capabilities
    fmt.Printf("%s Module System Features:\n", color.BoldBlueText("🏗️"))
    color.PrintSuccess("Local package imports working")
    color.PrintSuccess("Package initialization (init functions)")
    color.PrintSuccess("Exported functions and types")
    color.PrintSuccess("Structured configuration management")
    color.PrintSuccess("Colored terminal output")
    
    fmt.Println()
    color.PrintSuccess("Module system demonstration complete!")
    fmt.Printf("%s Local packages provide powerful modularity!\n", color.BoldGreenText("✨"))
}
