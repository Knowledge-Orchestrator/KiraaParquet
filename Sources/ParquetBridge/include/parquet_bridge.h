#ifndef PARQUET_BRIDGE_H
#define PARQUET_BRIDGE_H

#ifdef __cplusplus
extern "C" {
#endif

// Returns void (print‑to‑stderr on error).  Feel free to change to `int` or
// propagate an Arrow status code if you need richer error handling in Swift.
void write_parquet_file(const char *csv_path, const char *parquet_path);

#ifdef __cplusplus
}
#endif
#endif // PARQUET_BRIDGE_H
