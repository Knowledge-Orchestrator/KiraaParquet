// Sources/KiraaParquet/Convert.swift

import Foundation

public enum KiraaParquet {
    @_silgen_name("write_parquet_file")
    static func write_parquet_file(_ csvPath: UnsafePointer<CChar>, _ parquetPath: UnsafePointer<CChar>) -> Void

    public static func convert(csvPath: String, parquetPath: String) {
        csvPath.withCString { csvCStr in
            parquetPath.withCString { pqCStr in
                write_parquet_file(csvCStr, pqCStr)
            }
        }
    }

    public static func csvStats(csvPath: String) {
        print("🔍 Scanning CSV structure...")
        guard let stream = InputStream(fileAtPath: csvPath) else {
            print("⚠️ Failed to open CSV file")
            return
        }

        stream.open()
        defer { stream.close() }

        var rowCount = -1
        var columnCount = 0
        let bufferSize = 4096
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        var leftover = ""

        while stream.hasBytesAvailable {
            let read = stream.read(&buffer, maxLength: bufferSize)
            if read <= 0 { break }
            let chunk = String(bytes: buffer[0..<read], encoding: .utf8) ?? ""
            let lines = (leftover + chunk).components(separatedBy: .newlines)

            for line in lines.dropLast() {
                if rowCount == -1 {
                    columnCount = line.split(separator: ",").count
                }
                rowCount += 1
            }

            leftover = lines.last ?? ""
        }

        print("📊 CSV Stats:")
        print(String(format: "   • Rows:           %6d", rowCount))
        print(String(format: "   • Columns:        %6d", columnCount))
    }

    public static func parquetStats(parquetPath: String, startTime: Date) {
        if let attrs = try? FileManager.default.attributesOfItem(atPath: parquetPath),
           let size = attrs[.size] as? NSNumber {
            print("📦 Parquet Stats:")
            print(String(format: "   • File size:       %6d KB", size.intValue / 1024))
        } else {
            print("⚠️ Unable to determine Parquet file size")
        }

        let duration = Date().timeIntervalSince(startTime)
        let ms = Int((duration * 1000).truncatingRemainder(dividingBy: 1000))
        print(String(format: "   • Elapsed time:   %6.2f seconds (%3d ms)", duration, ms))
    }
}
