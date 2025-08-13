# R Data Profiling Tool

### Project Overview

This project showcases a powerful and flexible R script designed for **comprehensive data profiling**. The tool automatically analyzes a given dataset, providing critical insights into data quality and structure, which are essential for any data science or machine learning project.

The script's primary output is a self-contained, interactive HTML report that visually summarizes key feature characteristics. This includes data types, missing value percentages, unique value counts, and distributions, all in a user-friendly format. The tool also features a stability analysis component, allowing users to track how a dataset's features evolve over time.

### The Script's Functionality

The `generate_data_profile_report` function is a comprehensive and resilient data profiling tool. It's built with professional best practices in mind, incorporating robust features for error handling, logging, and performance.

#### Robustness and Error Handling:
* **Custom Logging Mechanism:** The script utilizes a custom logging function that writes detailed messages to both the console and a specified log file. This is crucial for debugging and monitoring long-running processes. It includes different log levels (`INFO`, `DEBUG`, `ERROR`, `CRITICAL`) to easily filter and diagnose issues.
* **Graceful Failure:** The script is designed to handle potential failures gracefully. If it can't open the log file, it will default to logging messages to the console only, preventing a complete script crash.
* **Input Validation:** Before any processing begins, the script validates that all required R packages are installed and that provided column names (`date_col_name`, `target_col_name`) exist and are of the correct data type.

#### Core Functionalities:
* **Efficient Data Processing:** The script converts all input data to a `data.table` format for superior performance and memory efficiency.
* **Dynamic Data Type Detection:** It intelligently infers a feature's true type from its values, going beyond simple `class()` checks.
* **Detailed Missing Value Analysis:** The script distinguishes between different types of missing values, providing separate metrics for R's `NA`, empty strings, and text-based null representations ("N/A", "NULL").
* **Customizable Binning and Visualization:** Parameters allow you to control how high-cardinality features are plotted, ensuring charts are both meaningful and visually appealing by grouping low-frequency categories and preventing over-plotting.
* **Data Stability Analysis:** For time-series data, users can provide a `date_col_name` to enable stability analysis, generating plots that show how feature distributions and summary statistics change over time.
* **Project Output Management:** The script automates the creation of an output directory and saves all its artifacts (HTML report, summary CSV, and log file) in a single, organized location.

### How to Run the Example

To see the script in action, you can use the provided `generate_report_example.R` file.

1.  Ensure you have your original `feature_profiling.R` script saved locally.
2.  Open both `feature_profiling.R` and `generate_report_example.R` in RStudio.
3.  Run the `generate_report_example.R` script. This will generate a comprehensive test dataframe and call the `generate_data_profile_report` function with the following parameters:

    * `df = test_data`: The test dataframe.
    * `date_col_name = "date_col"`: The column used for stability plots.
    * `target_col_name = "numeric_target"`: The column used for rank stability plots.
    * `report_features = NULL`: All features in the data will be profiled.
    * `top_n_cat = 15`: Displays the top 15 categories for categorical features.
    * `smalls_threshold_pct = 5`: Groups categories with less than 5% of the data into an "other" category in plots.
    * `max_value_pct = 80`: Excludes plots for any feature where a single value accounts for more than 80% of the data.
    * `binning_threshold = 75`: Limits the number of bins/categories to 75 for high-cardinality features.
    * `output_dir = "report_outputs"`: The name of the directory where the output files will be saved.
    * `generate_plots = TRUE`: Ensures the full interactive HTML report is generated.

4.  The script will create a new directory named `report_outputs` and save `feature_report.html`, `feature_summary.csv`, and `profiling_log.txt` inside.

### Showcase: A Look at the Output

To demonstrate the tool's capabilities, a sample report generated from a synthetic dataset is included. The report highlights the script's ability to handle various data types and identify common data quality issues.

**Interactive Report (HTML)**

The core output is an interactive HTML report. You can view a sample of this report to experience the full functionality of the tool.

* [**View Sample Report**](https://rao-anas-riaz.github.io/R-Auto-Data-Profiling/report_outputs/feature_report.html)

**Summary Statistics (CSV)**

A companion CSV file is generated with all the summarized data. This is useful for anyone who needs to programmatically access the profiling results.

* [**View Sample Summary**](https://github.com/rao-anas-riaz/R-Auto-Data-Profiling/blob/main/report_outputs/feature_summary.csv)

### License


This project is made available for informational purposes only. The intellectual property and source code remain the exclusive property of the author. No part of the source code may be copied, distributed, or modified without explicit permission.



