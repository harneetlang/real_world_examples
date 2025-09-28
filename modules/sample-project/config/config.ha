package config

import fmt

// Global configuration values (using simple variables instead of structs)
var AppName string = "Harneet Sample App"
var AppVersion string = "1.0.0"
var AppDebug bool = true
var AppPort int = 8080

var DatabaseHost string = "localhost"
var DatabasePort int = 5432
var DatabaseUsername string = "admin"
var DatabasePassword string = "secret123"
var DatabaseName string = "sample_db"
var DatabaseSSLMode string = "require"

var LoggingLevel string = "info"
var LoggingFormat string = "json"
var LoggingOutput string = "stdout"

var FeaturesEnableMetrics bool = true
var FeaturesEnableTracing bool = false
var FeaturesMaxConnections int = 100
var FeaturesTimeoutSeconds int = 30

// Initialize configuration with defaults
function init() {
    fmt.Println("📋 Initializing configuration package...")
}

// Update configuration values (simulating config file loading)
function UpdateConfig(appName string, appPort int) {
    AppName = appName
    AppPort = appPort
    fmt.Printf("📝 Updated configuration: %s on port %d\n", appName, appPort)
}

// Get configuration value by key path
function GetString(key string) string {
    if key == "app.name" {
        return AppName
    }
    if key == "app.version" {
        return AppVersion
    }
    if key == "database.host" {
        return DatabaseHost
    }
    if key == "database.database" {
        return DatabaseName
    }
    if key == "database.username" {
        return DatabaseUsername
    }
    if key == "database.ssl_mode" {
        return DatabaseSSLMode
    }
    if key == "logging.level" {
        return LoggingLevel
    }
    if key == "logging.format" {
        return LoggingFormat
    }
    if key == "logging.output" {
        return LoggingOutput
    }
    return ""
}

function GetInt(key string) int {
    if key == "app.port" {
        return AppPort
    }
    if key == "database.port" {
        return DatabasePort
    }
    if key == "features.max_connections" {
        return FeaturesMaxConnections
    }
    if key == "features.timeout_seconds" {
        return FeaturesTimeoutSeconds
    }
    return 0
}

function GetBool(key string) bool {
    if key == "app.debug" {
        return AppDebug
    }
    if key == "features.enable_metrics" {
        return FeaturesEnableMetrics
    }
    if key == "features.enable_tracing" {
        return FeaturesEnableTracing
    }
    return false
}

// Display configuration in a formatted way
function DisplayConfig() {
    fmt.Println("📋 Application Configuration:")
    fmt.Printf("  Name: %s\n", AppName)
    fmt.Printf("  Version: %s\n", AppVersion)
    fmt.Printf("  Debug Mode: %t\n", AppDebug)
    fmt.Printf("  Port: %d\n", AppPort)
    
    fmt.Println()
    fmt.Println("🗄️ Database Configuration:")
    fmt.Printf("  Host: %s\n", DatabaseHost)
    fmt.Printf("  Port: %d\n", DatabasePort)
    fmt.Printf("  Database: %s\n", DatabaseName)
    fmt.Printf("  Username: %s\n", DatabaseUsername)
    fmt.Printf("  SSL Mode: %s\n", DatabaseSSLMode)
    
    fmt.Println()
    fmt.Println("🎛️ Feature Configuration:")
    fmt.Printf("  Metrics Enabled: %t\n", FeaturesEnableMetrics)
    fmt.Printf("  Tracing Enabled: %t\n", FeaturesEnableTracing)
    fmt.Printf("  Max Connections: %d\n", FeaturesMaxConnections)
    fmt.Printf("  Timeout: %d seconds\n", FeaturesTimeoutSeconds)
    
    fmt.Println()
    fmt.Println("📝 Logging Configuration:")
    fmt.Printf("  Level: %s\n", LoggingLevel)
    fmt.Printf("  Format: %s\n", LoggingFormat)
    fmt.Printf("  Output: %s\n", LoggingOutput)
}
