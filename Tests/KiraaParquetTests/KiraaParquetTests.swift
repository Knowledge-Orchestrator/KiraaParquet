import Foundation
import Testing
@testable import KiraaParquet

@Test
func testParquetConversion() async throws {
    let input = "/tmp/test_input.csv"
    let output = "/tmp/test_output.parquet"

    // Create a minimal test CSV
    let sampleCSV = "name,age\nAlice,30\nBob,25"
    try sampleCSV.write(toFile: input, atomically: true, encoding: .utf8)

    // Perform conversion
    KiraaParquet.convert(csvPath: input, parquetPath: output)

    // Check if output file exists
    let exists = FileManager.default.fileExists(atPath: output)
    #expect(exists == true)

    // Optionally clean up
    try? FileManager.default.removeItem(atPath: input)
    try? FileManager.default.removeItem(atPath: output)
}
