# Harneet Sample Project with Local Packages

This sample project demonstrates Harneet's **local package system**, showcasing:

- **Local Package Imports**: `./config` and `./color` packages
- **Package Initialization**: `init()` functions that run automatically
- **Configuration Management**: Structured configuration with getter functions
- **Terminal Styling**: ANSI color codes and formatting utilities

## Project Structure

```
sample-project/
├── main.ha         # Main application
├── config/
│   └── config.ha   # Configuration package
├── color/
│   └── color.ha    # Terminal styling package
└── README.md       # This file
```

## No External Dependencies

This project uses **only local packages** - no external modules or go.mod file needed!

## Usage

### Run the Application

```bash
harneet main.ha
```

## Features Demonstrated

### Local Package System
- **Package Imports**: `import "./config" as config`
- **Package Exports**: Functions and variables exported from packages
- **Package Initialization**: `init()` functions run automatically
- **Package Scoping**: Proper variable and function scoping

### Configuration Management
- **Global Configuration**: Centralized config variables
- **Getter Functions**: `GetString()`, `GetInt()`, `GetBool()`
- **Dynamic Updates**: Runtime configuration changes
- **Structured Access**: Organized configuration sections

### Terminal Styling
- **ANSI Color Codes**: Direct terminal color control
- **Utility Functions**: `GreenText()`, `BlueText()`, etc.
- **Convenience Methods**: `Success()`, `Error()`, `Warning()`
- **Print Functions**: `PrintSuccess()`, `PrintError()`, etc.

## Expected Output

When you run the application, you'll see:

```
📋 Initializing configuration package...
🎨 Initializing color package...
🔧 Initializing sample project...
🚀 Harneet Module System Demo with Local Packages
============================================================

📋 Application Configuration:
  Name: Harneet Sample App
  Version: 1.0.0
  Debug Mode: true
  Port: 8080

🗄️ Database Configuration:
  Host: localhost
  Port: 5432
  Database: sample_db
  Username: admin
  SSL Mode: require

🎛️ Feature Configuration:
  Metrics Enabled: true
  Tracing Enabled: false
  Max Connections: 100
  Timeout: 30 seconds

📝 Logging Configuration:
  Level: info
  Format: json
  Output: stdout

🎨 Demonstrating Color Package:
✅ This is a success message
❌ This is an error message
⚠️ This is a warning message
ℹ️ This is an info message

🔑 Individual Configuration Access:
  App Name: Harneet Sample App
  App Version: 1.0.0
  Debug Mode: true
  Port: 8080

📄 Configuration Updates:
ℹ️ Updating configuration values...
📝 Updated configuration: Updated Harneet App on port 9000
  New Name: Updated Harneet App
  New Port: 9000

🏗️ Module System Features:
✅ Local package imports working
✅ Package initialization (init functions)
✅ Exported functions and types
✅ Structured configuration management
✅ Colored terminal output

✅ Module system demonstration complete!
✨ Local packages provide powerful modularity!
```

## Key Concepts Demonstrated

### 1. Local Package Import
```harneet
import "./config" as config
import "./color" as color
```

### 2. Package Initialization
```harneet
function init() {
    // Package setup runs before main()
    fmt.Println("📋 Initializing configuration package...")
}
```

### 3. Configuration Management
```harneet
var appName = config.GetString("app.name")
var port = config.GetInt("app.port")
var debug = config.GetBool("app.debug")
config.UpdateConfig("New App", 9000)
```

### 4. Colored Output
```harneet
color.PrintSuccess("This is a success message")
fmt.Printf("%s Success!\n", color.GreenText("✅"))
```

### 5. Package Structure
```harneet
// config/config.ha
package config

var AppName string = "Harneet Sample App"

function GetString(key string) string {
    if key == "app.name" {
        return AppName
    }
    return ""
}
```

This example shows how Harneet's **local package system** enables clean, modular code organization for real-world applications!
