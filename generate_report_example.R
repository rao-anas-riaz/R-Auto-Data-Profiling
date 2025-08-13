# ==============================================================================
# EXAMPLE SCRIPT FOR DATA PROFILING TOOL
# ==============================================================================
#
# This script demonstrates how to generate a comprehensive data profiling report
# using the `generate_data_profile_report` function.
#
# NOTE: This script requires the `feature_profiling.R` script (not provided
# in this public repository) to be loaded into the R session.
#
# ==============================================================================

# Ensure required packages are installed and loaded
required_pkgs <- c("data.table", "lubridate")
for (pkg in required_pkgs) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, repos = "https://cran.r-project.org")
    library(pkg, character.only = TRUE)
  }
}

# ==============================================================================
# Function to generate a comprehensive test dataframe
# ==============================================================================

generate_test_dataframe <- function(n_rows = 1000) {
  set.seed(123)
  base_date <- as.Date("2023-01-01")
  test_df <- data.table(
    primary_key = 1:n_rows,
    date_col = seq(base_date, by = "day", length.out = n_rows),
    numeric_target = runif(n_rows, min = 100, max = 1000),
    integer_rating = sample(1:5, n_rows, replace = TRUE),
    logical_flag = sample(c(TRUE, FALSE), n_rows, replace = TRUE, prob = c(0.7, 0.3)),
    category_moderate = sample(c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J"), n_rows, replace = TRUE),
    category_skewed = sample(c("Dominant_Value", "Rare_1", "Rare_2"), n_rows, replace = TRUE, prob = c(0.9, 0.05, 0.05)),
    category_high_card = paste0("ID_", 1:n_rows),
    mixed_nulls_text = sample(c(
      "Valid", "Value", NA, "N/A", "null", "", " ", "NA"
    ), n_rows, replace = TRUE),
    numeric_with_na = sample(c(runif(n_rows - 50, 0, 100), rep(NA, 50)), n_rows, replace = FALSE),
    datetime_col = seq(lubridate::ymd_hms("2023-01-01 10:00:00"), by = "10 mins", length.out = n_rows),
    character_comments = sample(c("Good", "Bad", "Okay", NA, ""), n_rows, replace = TRUE)
  )
  test_df[sample(1:n_rows, 10), category_skewed := "NULL"]
  test_df[sample(1:n_rows, 10), category_skewed := "N/A"]
  test_df[sample(1:n_rows, 20), integer_rating := NA]
  return(test_df)
}

# ==============================================================================
# Generate the test dataframe and call the profiling function with all parameters
# ==============================================================================
# Assume 'generate_data_profile_report' function is in the environment.

# 1. Generate the test data
test_data <- generate_test_dataframe(n_rows = 1500)

# 2. Call the profiling function with all parameters specified
# The output will be saved in a new directory named 'report_outputs'
generate_data_profile_report(
  df = test_data,
  date_col_name = "date_col",
  target_col_name = "numeric_target",
  report_features = NULL, # Report on all features
  top_n_cat = 15, # Display top 15 categories in summary table
  smalls_threshold_pct = 5, # Categories < 5% get grouped into "smalls"
  max_value_pct = 80, # Exclude plots for features where a single category > 80%
  binning_threshold = 75, # Max 75 bins/categories for high-cardinality features
  output_dir = "report_outputs", # The output directory
  log_file_name = "profiling_log.txt",
  summary_csv_name = "feature_summary.csv",
  html_report_name = "feature_report.html",
  generate_plots = TRUE # Generate the full interactive HTML report
)

cat("Report generation complete. Check the 'report_outputs' directory.\n")