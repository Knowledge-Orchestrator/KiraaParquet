# 🧪 KiraaParquet

A Swift-based Parquet file generator for tabular CSV data. 
Built with a native bridge to Apache Arrow C++ for high-performance data conversion.

---

## 🚀 Overview

This library and command-line tool converts a CSV file into a Parquet file using:

- 🧠 Swift for orchestration
- ⚙️ Apache Arrow C++ compiled statically
- 🧩 A C++ bridge (`write_parquet_file`) callable from Swift

---


## 📦 Project Structure

---

## 🧪 CLI Usage

The included `KiraaParquetExecutor` executable allows you to convert a CSV file to Parquet directly from the command line.

### 🧭 Command

```bash
swift run KiraaParquetExecutor [input.csv] [output.parquet]
```

- If no arguments are provided, it defaults to:

```bash
swift run KiraaParquetExecutor
# → /tmp/dataframe.csv → /tmp/dataframe.parquet
```

### 🧪 Examples

Convert a local CSV file into a Parquet file in the same directory:

```bash
swift run KiraaParquetExecutor ./mydata.csv ./mydata.parquet
```

Convert a CSV in Downloads and save to Desktop:

```bash
swift run KiraaParquetExecutor ~/Downloads/data.csv ~/Desktop/data.parquet
```

You’ll see CSV stats, a spinning progress indicator during conversion, and final output stats including file size and elapsed time.
