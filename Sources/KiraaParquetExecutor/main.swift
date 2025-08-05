/*
 ╔══════════════════════════════════════════════════════════════════════╗
 ║                      Kiraa Parquet Dataframe Converter               ║
 ║----------------------------------------------------------------------║
 ║  Description:                                                        ║
 ║  This Swift script converts a CSV file into a Parquet file using a   ║
 ║  native C++ bridge via @_silgen_name. It prints informative stats    ║
 ║  about the CSV and Parquet output, including elapsed time, and uses  ║
 ║  a spinner to indicate progress.                                     ║
 ║                                                                      ║
 ║  Usage:                                                              ║
 ║     ./ArrowDemo input.csv output.parquet                             ║
 ║     (if no arguments, defaults to /tmp/dataframe.csv → .parquet)    ║
 ║                                                                      ║
 ║  Requirements:                                                       ║
 ║     - Arrow C++ compiled with Parquet and CSV support                ║
 ║     - Local libarrow.a and libparquet.a linked via SwiftPM bridge    ║
 ╚══════════════════════════════════════════════════════════════════════╝
 */


import Foundation
import KiraaParquet


print("╭───────────────────────────────────────────────╮")
print("│       Kiraa Parquet Dataframe Converter       │")
print("╰───────────────────────────────────────────────╯\n")

let startTime = Date()

// Declare the Swift-to-C++ bridge function for Parquet writing.
@_silgen_name("write_parquet_file")
func write_parquet_file(_ csvPath: UnsafePointer<CChar>, _ parquetPath: UnsafePointer<CChar>) -> Void

// Parse command-line arguments: use user-supplied or default file paths.
let args = CommandLine.arguments
let csvPath: String
let parquetPath: String

if args.count == 3 {
    csvPath = args[1]
    parquetPath = args[2]
    print("📝 Using provided file paths:")
} else {
    csvPath = "/tmp/dataframe.csv"
    parquetPath = "/tmp/dataframe.parquet"
    print("🧪 Using default paths:")
}

print("   • Source CSV:    \(csvPath)")
print("   • Target Parquet:\(parquetPath)")

// Check file existence before doing anything else
guard FileManager.default.fileExists(atPath: csvPath) else {
    print("❌ CSV file not found at \(csvPath)")
    exit(1)
}

// Show CSV file stats before conversion.
KiraaParquet.csvStats(csvPath: csvPath)

print("───────────────────────────────────────────────")

print("📄 Starting Parquet conversion:")
print("   • Source CSV:    \(csvPath)")
print("   • Target Parquet:\(parquetPath)")

// Start a simple spinner in the background to show progress.
let queue = DispatchQueue(label: "spinner")
var isRunning = true

print("───────────────────────────────────────────────")


// Call the C++ bridge to perform the conversion.
csvPath.withCString { csvCStr in
    parquetPath.withCString { pqCStr in
        write_parquet_file(csvCStr, pqCStr)
    }
}
isRunning = false
print("")

print("✅ Parquet file successfully written → \(parquetPath)")

// Print stats about the generated Parquet file (size, time).
func printParquetStats(parquetPath: String) {
    // Attempt to get file size using FileManager.
    if let attrs = try? FileManager.default.attributesOfItem(atPath: parquetPath),
       let size = attrs[.size] as? NSNumber {
        print("📦 Parquet Stats:")
        print(String(format: "   • File size:       %6d KB", size.intValue / 1024))
    } else {
        print("⚠️ Unable to determine Parquet file size")
    }
    // Compute and print elapsed time for conversion.
    let duration = Date().timeIntervalSince(startTime)
    let ms = Int((duration * 1000).truncatingRemainder(dividingBy: 1000))
    print(String(format: "   • Elapsed time:   %6.2f seconds (%3d ms)", duration, ms))
}

// Show Parquet file stats after conversion.
printParquetStats(parquetPath: parquetPath)
