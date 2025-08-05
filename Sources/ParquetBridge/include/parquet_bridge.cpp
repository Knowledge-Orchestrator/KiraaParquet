// parquet_bridge.cpp
#include "parquet_bridge.h"

// We should not compile this TU with ARROW_STATIC when linking against
// the Homebrew‑supplied *dynamic* libarrow / libparquet.  The macro changes
// the visibility/export rules and can lead to duplicate singletons and
// memory‑management mismatches (manifesting as “pointer being freed was not
// allocated”).  Undefine it defensively in case the build system set it.
#ifdef ARROW_STATIC
#undef ARROW_STATIC
#endif

#include <arrow/api.h>
#include <arrow/memory_pool.h>   // for system_memory_pool()
#include <arrow/csv/api.h>
#include <arrow/io/api.h>
#include <parquet/arrow/writer.h>

#include <cstdlib>      // setenv
#include <iostream>     // std::cerr
#include <memory>
#include <string>
#include <utility>      // std::move

/// C‑compatible wrapper so Swift (or any other language) can call it
extern "C" void write_parquet_file(const char *csv_path,
                                   const char *parquet_path) {
    // Guard against null pointers coming from Swift
    if (csv_path == nullptr || parquet_path == nullptr) {
        std::cerr << "[ParquetBridge] Received null path.\n";
        return;
    }


    // Convert to C++ strings for convenience
    std::string csvPathStr(csv_path);
    std::string parquetPathStr(parquet_path);
    std::cerr << "[ParquetBridge] BEGIN convert CSV → Parquet\n"
              << "    CSV path: " << csvPathStr << "\n"
              << "    PQ  path: " << parquetPathStr << std::endl;

    // ---------------------------------------------------------------------
    // 1. OPEN CSV FILE
    // ---------------------------------------------------------------------
    auto input_result = arrow::io::ReadableFile::Open(csvPathStr);
    if (!input_result.ok()) {
        std::cerr << "[ParquetBridge] Failed to open CSV file: "
                  << input_result.status().ToString() << '\n';
        return;
    }
    auto input = std::move(input_result).ValueOrDie();
    std::cerr << "[ParquetBridge] CSV file opened successfully.\n";

    std::cerr << "[ParquetBridge] Creating CSV TableReader...\n";
    // Build a TableReader with default options (tweak if necessary)
    auto reader_result = arrow::csv::TableReader::Make(
        arrow::io::default_io_context(),
        input,
        arrow::csv::ReadOptions::Defaults(),
        arrow::csv::ParseOptions::Defaults(),
        arrow::csv::ConvertOptions::Defaults());

    if (!reader_result.ok()) {
        std::cerr << "[ParquetBridge] Failed to create CSV reader: "
                  << reader_result.status().ToString() << '\n';
        return;
    }
    auto reader = std::move(reader_result).ValueOrDie();
    std::cerr << "[ParquetBridge] TableReader created.\n";

    std::cerr << "[ParquetBridge] Reading CSV into Arrow Table...\n";
    auto table_result = reader->Read();
    if (!table_result.ok()) {
        std::cerr << "[ParquetBridge] Failed to read CSV: "
                  << table_result.status().ToString() << '\n';
        return;
    }
    auto table = std::move(table_result).ValueOrDie();
    std::cerr << "[ParquetBridge] CSV converted to Arrow Table "
              << "(rows=" << table->num_rows()
              << ", cols=" << table->num_columns() << ").\n";

    // ---------------------------------------------------------------------
    // 2. OPEN PARQUET FILE FOR WRITING
    // ---------------------------------------------------------------------
    auto out_file_result = arrow::io::FileOutputStream::Open(parquetPathStr);
    if (!out_file_result.ok()) {
        std::cerr << "[ParquetBridge] Failed to open Parquet file: "
                  << out_file_result.status().ToString() << '\n';
        return;
    }
    auto out_file = std::move(out_file_result).ValueOrDie();
    std::cerr << "[ParquetBridge] Parquet output file opened for writing.\n";

    // ---------------------------------------------------------------------
    // 3. WRITE TABLE → PARQUET
    // ---------------------------------------------------------------------
    std::cerr << "[ParquetBridge] Writing Arrow Table to Parquet (chunk_size = 1024)...\n";
    arrow::Status write_status = parquet::arrow::WriteTable(
        *table,
        arrow::system_memory_pool(),    // avoid env‑var lookup crash
        out_file,
        /*chunk_size=*/1024);           // rows per RowGroup

    if (!write_status.ok()) {
        std::cerr << "[ParquetBridge] Failed to write Parquet file: "
                  << write_status.ToString() << '\n';
    } else {
        std::cerr << "[ParquetBridge] Parquet file written successfully.\n";
    }
    std::cerr << "[ParquetBridge] END convert CSV → Parquet\n";
}
