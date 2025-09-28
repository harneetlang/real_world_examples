package color

import fmt

// ANSI color codes
var Reset string = "\033[0m"
var Red string = "\033[31m"
var Green string = "\033[32m"
var Yellow string = "\033[33m"
var Blue string = "\033[34m"
var Purple string = "\033[35m"
var Cyan string = "\033[36m"
var White string = "\033[37m"

// Bold colors
var BoldRed string = "\033[1;31m"
var BoldGreen string = "\033[1;32m"
var BoldYellow string = "\033[1;33m"
var BoldBlue string = "\033[1;34m"

function init() {
    fmt.Println("🎨 Initializing color package...")
}

// Color formatting functions
function RedText(text string) string {
    return Red + text + Reset
}

function GreenText(text string) string {
    return Green + text + Reset
}

function YellowText(text string) string {
    return Yellow + text + Reset
}

function BlueText(text string) string {
    return Blue + text + Reset
}

function BoldRedText(text string) string {
    return BoldRed + text + Reset
}

function BoldGreenText(text string) string {
    return BoldGreen + text + Reset
}

function BoldYellowText(text string) string {
    return BoldYellow + text + Reset
}

function BoldBlueText(text string) string {
    return BoldBlue + text + Reset
}

// Convenience functions with emojis
function Success(text string) string {
    return GreenText("✅ " + text)
}

function Error(text string) string {
    return RedText("❌ " + text)
}

function Warning(text string) string {
    return YellowText("⚠️ " + text)
}

function Info(text string) string {
    return BlueText("ℹ️ " + text)
}

// Print functions
function PrintSuccess(text string) {
    fmt.Println(Success(text))
}

function PrintError(text string) {
    fmt.Println(Error(text))
}

function PrintWarning(text string) {
    fmt.Println(Warning(text))
}

function PrintInfo(text string) {
    fmt.Println(Info(text))
}
