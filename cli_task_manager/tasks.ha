// CLI Task Manager — written in Harneet
// Usage:
// harneet tasks.ha add "Buy groceries"
// harneet tasks.ha list
// harneet tasks.ha done 1
// harneet tasks.ha delete 2
// harneet tasks.ha clear
// harneet tasks.ha help

package main

import cast
import file
import fmt
import json
import os
import strings

type Task struct {
    id int
    title string
    done bool
}


var TASKS_FILE string = "tasks.json"

// Load all tasks from disk. Returns empty list if file doesn't exist.
function loadTasks() []Task {
    var exists bool, existsErr error = file.Exists(TASKS_FILE)
    if existsErr != None {
        return []Task {}
    }
    if !exists {
        return []Task {}
    }

    var raw string, readErr error = file.Read(TASKS_FILE)
    if readErr != None {
        fmt.Println("Warning: could not read tasks file:", readErr)
        return []Task {}
    }

    var data any, parseErr error = json.Unmarshal(raw)
    if parseErr != None {
        fmt.Println("Warning: could not parse tasks file:", parseErr)
        return []Task {}
    }

    var tasks []Task = []Task {}
    var items []any = data
    var i int = 0
    for i < len(items) {
        var item map[string]any = items[i]
        var id int, _ = cast.ToInt(item["id"])
        var title string, _ = cast.ToString(item["title"])
        var done bool, _ = cast.ToBool(item["done"])
        var t Task = Task {id: id, title: title, done: done}
        tasks = append(tasks, t)
        i = i + 1
    }
    return tasks
}

// Persist tasks array to disk as JSON.
function saveTasks(tasks []Task) error {
    var items []map[string]any = []map[string]any {}
    var i int = 0
    for i < len(tasks) {
        var t Task = tasks[i]
        var item map[string]any = map[string]any {
            "id": t.id,
            "title": t.title,
            "done": t.done
        }
        items = append(items, item)
        i = i + 1
    }

    var jsonStr string, marshalErr error = json.Marshal(items)
    if marshalErr != None {
        return marshalErr
    }

    var writeErr error, _ = file.Write(TASKS_FILE, jsonStr)
    return writeErr
}
// Return the next available task ID.


function nextId(tasks []Task) int {
    var max int = 0
    var i int = 0
    for i < len(tasks) {
        if tasks[i].id > max {
            max = tasks[i].id
        }
        i = i + 1
    }
    return max + 1
}


function cmdAdd(tasks []Task, title string) {
    if strings.TrimSpace(title) == "" {
        fmt.Println("Error: task title cannot be empty.")
        return
    }

    var t Task = Task {id: nextId(tasks), title: title, done: false}
    tasks = append(tasks, t)

    var saveErr error = saveTasks(tasks)
    if saveErr != None {
        fmt.Println("Error saving task:", saveErr)
        return
    }
    fmt.Printf("✓ Added task #%d: %s\n", t.id, t.title)
}


function cmdList(tasks []Task) {
    if len(tasks) == 0 {
        fmt.Println("No tasks yet. Add one with: tasks.ha add \"Your task\"")
        return
    }

    fmt.Println("")
    fmt.Println("  ID  Status  Title")
    fmt.Println("  ──  ──────  ─────────────────────────────────────")

    var i int = 0
    for i < len(tasks) {
        var t Task = tasks[i]
        var status string = "[ ]"
        if t.done {
            status = "[x]"
        }
        fmt.Printf("  %-3d %s     %s\n", t.id, status, t.title)
        i = i + 1
    }

    // Summary line
    var total int = len(tasks)
    var done int = 0
    var j int = 0
    for j < len(tasks) {
        if tasks[j].done {
            done = done + 1
        }
        j = j + 1
    }
    fmt.Println("")
    fmt.Printf("  %d/%d tasks completed\n", done, total)
    fmt.Println("")
}


function cmdDone(tasks []Task, idStr string) {
    var id int, castErr error = cast.ToInt(idStr)
    if castErr != None {
        fmt.Println("Error: invalid task ID:", idStr)
        return
    }

    var found bool = false
    var i int = 0
    for i < len(tasks) {
        if tasks[i].id == id {
            if tasks[i].done {
                fmt.Printf("Task #%d is already completed.\n", id)
                return
            }
            tasks[i].done = true
            found = true
        }
        i = i + 1
    }

    if !found {
        fmt.Printf("Error: no task with ID %d.\n", id)
        return
    }

    var saveErr error = saveTasks(tasks)
    if saveErr != None {
        fmt.Println("Error saving:", saveErr)
        return
    }
    fmt.Printf("✓ Marked task #%d as done.\n", id)
}


function cmdDelete(tasks []Task, idStr string) {
    var id int, castErr error = cast.ToInt(idStr)
    if castErr != None {
        fmt.Println("Error: invalid task ID:", idStr)
        return
    }

    var newTasks []Task = []Task {}
    var found bool = false
    var i int = 0
    for i < len(tasks) {
        if tasks[i].id == id {
            found = true
        } else {
            newTasks = append(newTasks, tasks[i])
        }
        i = i + 1
    }

    if !found {
        fmt.Printf("Error: no task with ID %d.\n", id)
        return
    }

    var saveErr error = saveTasks(newTasks)
    if saveErr != None {
        fmt.Println("Error saving:", saveErr)
        return
    }
    fmt.Printf("✓ Deleted task #%d.\n", id)
}


function cmdClear(tasks []Task) {
    var saveErr error = saveTasks([]Task {})
    if saveErr != None {
        fmt.Println("Error clearing tasks:", saveErr)
        return
    }
    fmt.Printf("✓ Cleared all %d tasks.\n", len(tasks))
}


function cmdHelp() {
    fmt.Println("")
    fmt.Println("  Harneet Task Manager")
    fmt.Println("  ════════════════════")
    fmt.Println("")
    fmt.Println("  Usage: harneet tasks.ha <command> [args]")
    fmt.Println("")
    fmt.Println("  Commands:")
    fmt.Println("    add <title>    Add a new task")
    fmt.Println("    list           List all tasks")
    fmt.Println("    done <id>      Mark a task as completed")
    fmt.Println("    delete <id>    Delete a task")
    fmt.Println("    clear          Delete all tasks")
    fmt.Println("    help           Show this help message")
    fmt.Println("")
    fmt.Println("  Examples:")
    fmt.Println("    harneet tasks.ha add \"Write unit tests\"")
    fmt.Println("    harneet tasks.ha list")
    fmt.Println("    harneet tasks.ha done 1")
    fmt.Println("    harneet tasks.ha delete 2")
    fmt.Println("")
}


function main() {
    var args []string, argsErr error = os.Args()
    if argsErr != None {
        fmt.Println("Error reading args:", argsErr)
        return 1
    }

    // args[0] = interpreter, args[1] = script path, args[2] = command
    if len(args) == 0  {
        fmt.Println("I am here , ", len(args))
        cmdHelp()
        return 0
    }

    var command string = args[0]
    var tasks []Task = loadTasks()

    match command {
        "add" => {
            if len(args[1]) < 1 {
                fmt.Println("Error: add requires a task title.")
                fmt.Println("Usage: harneet tasks.ha add \"Your task title\"")
                return 1
            }
            printInfoMessage("Add", "Adding Tasks", map[string]bool {"Task": args[1]})

            cmdAdd(tasks, args[1])
        },
        "list", "ls" => {
            cmdList(tasks)
        },
        "done", "complete", "check" => {
            if len(args) < 1 {
                fmt.Println("Error: done requires a task ID.")
                fmt.Println("Usage: harneet tasks.ha done <id>")
                return 1
            }
            cmdDone(tasks, args[1])
        },
        "delete", "del", "rm", "remove" => {
            if len(args) < 1 {
                fmt.Println("Error: delete requires a task ID.")
                fmt.Println("Usage: harneet tasks.ha delete <id>")
                return 1
            }
            cmdDelete(tasks, args[1])
        },
        "clear" => {
            cmdClear(tasks)
        },
        "help", "--help", "-h" => {
            cmdHelp()
        },
        _ => {
            fmt.Printf("Unknown command: %s\n", command)
            fmt.Println("Run 'harneet tasks.ha help' for usage.")
            return 1
        }
    }

    return 0
}
