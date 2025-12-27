// HTTP Benchmark Tool in Harneet
package main

import cast
import datetime
import fmt
import http
import os
import strings

// Main structure definitions
type BenchmarkConfig struct {
    url string
    total_requests int
    concurrency int
    timeout int
}

type RequestResult struct {
    duration int
    status_code int
    errors string
}

// Entry point
function main() {
    config := parse_args()

    results := run_benchmark(config)

    print_results(results)
}

// Core benchmarking logic
function run_benchmark(config BenchmarkConfig) []RequestResult {
    results_channel := newChannel(config.total_requests)

    requests_per_worker := config.total_requests / config.concurrency

    // Spawn concurrent workers
    workers := [] any {}
    for i in range(config.concurrency) {
        worker_task := do function(worker_id int) {
            worker_func(config.url, requests_per_worker, results_channel, worker_id)
            return worker_id
        }(i)
        workers = append(workers, worker_task)
    }

    // Collect results
    all_results := [] RequestResult {}
    for i in range(config.total_requests) {
        result, ok := receive(results_channel)
        if ok {
            all_results = append(all_results, result)
        }
    }

    // Wait for all workers to complete
    for worker_task in workers {
        await(worker_task)
    }

    closeChannel(results_channel)
    return all_results
}

// Worker function
function worker_func(url string, num_requests int, results_chan any, worker_id int) {
    for i in range(num_requests) {
        fmt.Printf("W%d: req %d\n", worker_id, i)
        var start_time time, _ = datetime.Now()

        var response http.Response, err error = http.Get(url)

        var end_time time, _ = datetime.Now()

        // Calculate elapsed time in milliseconds
        start_ms := start_time.UnixMilli()
        end_ms := end_time.UnixMilli()
        elapsed := end_ms - start_ms

        fmt.Printf("W%d: got response, elapsed=%d\n", worker_id, elapsed)

        var result RequestResult
        if err != None {
            result = RequestResult {
                duration: elapsed,
                status_code: 0,
                errors: err
            }
        } else {
            var status any = response["status"]
            result = RequestResult {
                duration: elapsed,
                status_code: status,
                errors: ""
            }
        }

        fmt.Printf("W%d: sending\n", worker_id)
        send(results_chan, result)
        fmt.Printf("W%d: sent\n", worker_id)
    }
    fmt.Printf("W%d: done\n", worker_id)
}


function returnVal(val int , multiplier float64) float64 {
    var result float64, err error = cast.ToFloat(val * multiplier)
    assert.AssertIsNone(err)
    return result
}
// Stats calculation


function print_results(results []RequestResult) {
    if len(results) == 0 {
        fmt.Println("No results to display")
        return
    }

    total_duration := 0
    successful := 0

    durations := [] int {}

    for r in results {
        total_duration = total_duration + r.duration
        if r.errors == "" {
            successful = successful + 1
            durations = append(durations, r.duration)
        }
    }

    failed := len(results) - successful

    if len(durations) > 0 {
        sorted_durations, _ := sort(durations)

        min_latency := sorted_durations[0]
        max_latency := sorted_durations[len(sorted_durations) - 1]
        avg_latency := total_duration / len(results)

        var p50_f float64 = returnVal(len(sorted_durations) , 0.5)
        var p95_f float64 = returnVal(len(sorted_durations) , 0.95)
        var p99_f float64 = returnVal(len(sorted_durations) , 0.99)

        var p50_index int, _ = cast.ToInt(p50_f)
        var p95_index int, _ = cast.ToInt(p95_f)
        var p99_index int, _ = cast.ToInt(p99_f)

        p50 := sorted_durations[p50_index]
        p95 := sorted_durations[p95_index]
        p99 := sorted_durations[p99_index]

        fmt.Printf(`
        Benchmark Results
        == == == == == == == == =
        Total requests: % d
        Successful: % d
        Failed: % d

        Latency:
        Min: % d ms
        Avg: % d ms
        Max: % d ms
        50th percentile: % d ms
        95th percentile: % d ms
        99th percentile: % d ms
        `, len(results), successful, failed, min_latency, avg_latency, max_latency, p50, p95, p99)
    } else {
        fmt.Printf(`
        Benchmark Results
        == == == == == == == == =
        Total requests: % d
        Successful: 0
        Failed: % d
        All requests failed
        `, len(results), failed)
    }
}

// Arg parsing
function parse_args() BenchmarkConfig {
    var args []string, _ = os.Args()

    // Default values
    var config BenchmarkConfig = BenchmarkConfig {
        url: "",
        total_requests: 100,
        concurrency: 10,
        timeout: 5000
    }

    // Simple argument parsing
    i := 0
    for i < len(args) {
        arg := args[i]

        if arg == "-n" and i + 1 < len(args) {
            var n int, _ = cast.ToInt(args[i + 1])
            config.total_requests = n
            i = i + 2
        } else if arg == "-c" and i + 1 < len(args) {
            var c int, _ = cast.ToInt(args[i + 1])
            config.concurrency = c
            i = i + 2
        } else if arg == "--timeout" and i + 1 < len(args) {
            var t int, _ = cast.ToInt(args[i + 1])
            config.timeout = t
            i = i + 2
        } else {
            var isFlag bool, _ = strings.HasPrefix(arg, "-")
            if arg != "" and !isFlag {
                config.url = arg
            }
            i = i + 1
        }
    }

    if config.url == "" {
        fmt.Println("Usage: benchmark [-n <requests>] [-c <concurrency>] [--timeout <ms>] <url>")
        fmt.Println("Default: -n 100 -c 10 --timeout 5000")
        os.Exit(1)
    }

    return config
}
