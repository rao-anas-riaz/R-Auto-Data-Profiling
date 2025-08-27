# Automated Data Profiling & Visualization Report Generator for R

<p align="center">
  <img src="https://img.shields.io/badge/Language-R-blue.svg" alt="Language R">
</p>

An advanced, one-click R solution for performing comprehensive data profiling and generating a beautiful, interactive, self-contained HTML report. Move from a raw dataframe to deep, actionable insights in seconds.

***

## Table of Contents
* [Why Use This Profiler?](#why-use-this-profiler-benefits--use-cases)
* [Detailed Workflow Diagram](#detailed-workflow-diagram)
* [Core Functions & Logic](#️core-functions-and-logic)
* [Parameter Deep Dive](#️parameter-deep-dive)
* [Understanding the Outputs](#understanding-the-outputs)
* [Getting Started](#getting-started)
* [Dependencies](#dependencies)

***

## Why Use This Profiler? Benefits & Use Cases

This script is more than just a summary tool; it's a powerful accelerator for any data-driven project. It automates the tedious, time-consuming, and critical first step of any analysis: understanding your data.

### For Data Scientists & Analysts
* **Accelerate Exploratory Data Analysis (EDA):** The most time-consuming phase of a project is often the initial data exploration. This script automates 90% of that work, delivering rich visualizations and statistics instantly. This frees you up to focus on hypothesis generation and feature engineering rather than boilerplate plotting code.
* **Rapid Data Quality Assessment:** Quickly identify critical data quality issues that can derail a project:
    * **Completeness:** The summary report highlights the percentage of nulls in various forms (`NA`, `""`, `"null"`), allowing you to spot incomplete features immediately.
    * **Cardinality:** Instantly see which features are constants, binary, or have thousands of unique values.
    * **Anomalies:** Visualizations like histograms and density plots make it easy to spot skewed distributions, outliers, and potential data entry errors.
* **Enhance Communication:** The interactive HTML report is the perfect artifact for sharing insights with both technical and non-technical stakeholders. It provides a common ground for discussing data quality and feature characteristics without anyone needing to run code.
* **Foundation for Feature Engineering:** By understanding the raw distributions, null patterns, and data types, you can make much more informed decisions about how to clean, transform, and engineer features for machine learning models.

### For Data & Analytics Engineers 
* **ETL & Data Pipeline Validation:** Use the profiler at different stages of your ETL/ELT process to validate that data transformations are happening as expected and that no data is being lost or corrupted.
* **Data Drift & Quality Monitoring:** By running the profiler on the same data source over time (e.g., daily or weekly), you can use the generated reports to monitor for data drift. The stability plots are especially powerful for this, showing exactly when the distribution of a feature or its relationship with a target variable begins to change.
* **Automated Data Dictionary:** The generated `feature_summary.csv` serves as an excellent, up-to-date data dictionary that can be shared with the entire organization, promoting a common understanding of available data assets.

### For Project Managers & Business Stakeholders 
* **Empower Data-Driven Decisions:** The interactive HTML report provides a clear, accessible window into the state of your project's data. You can explore feature distributions and understand data quality without needing technical expertise, leading to more informed planning and decision-making.
* **Increase Project Velocity:** By automating the foundational analysis step, this tool reduces the time to insight, shortens project timelines, and allows the data team to deliver value faster.

***

## Detailed Workflow Diagram

The script executes a sophisticated, multi-stage pipeline to transform a raw dataframe into a polished report. This diagram illustrates the flow of data and the function responsible at each step.

```
                  [Input: Original DataFrame (df)]
                                |
                                V
+--------------------------------------------------------------------------+
| PHASE 1-4: SETUP, ANALYSIS & SUMMARY                                     |
|                                                                          |
|  [auto_data_profiling_main.R] -> Sets up logging, libs, and params.      |
|                 |                                                        |
|                 +-> [process_data.R] -> Orchestrates analysis.           |
|                         |                                                |
|                         +-> [detect_data_types.R] -> Infers column types.|
|                         |                                                |
|                         L-> [summarize_feature.R] -> Calculates stats.   |
|                                                                          |
|  [Output: Master Summary Table (summary_dt)]                             |
+--------------------------------------------------------------------------+
                                |
                                V
+-----------------------------------------------------------------------------+
| PHASE 6: PLOTTING PREPARATION (Data Simplification)                         |
|                                                                             |
|  [exclude_features.R] -> Filters `summary_dt` to get a list of features     |
|                          to plot, removing lists, all-nulls, etc.           |
|                                |                                            |
|  +-----------------------------+-------------------------------------+      |
|  |                             |                                     |      |
|  V                             V                                     V      |
| [create_binned_dataframe.R] | [create_smalls_dataframe.R]    | (Original df)|
|  Uses `summary_dt`          |  Uses `df_binned` to group     |              |
|  to intelligently bin       |  rare categories into "smalls".|              |
|  high-cardinality features. |  L-> [Output: df_smalls]       |              |
|  L-> [Output: df_binned]    |                                |              |
|                                                                             |
|                                                                             |
+-----------------------------------------------------------------------------+
                                |
                                V
+--------------------------------------------------------------------------+
| PHASE 7: VISUALIZATION & REPORT ASSEMBLY                                 |
|                                                                          |
|  [generate_html_report.R] -> Main assembly function. Loops through each  |
|                              plottable feature...                        |
|                 |                                                        |
|                 +-> [generate_feature_visualizations.R]                  |
|                         |   (Takes df, df_binned, df_smalls)             |
|                         |                                                |
|                         +-> Generates Histogram, Pie, Details Table      |
|                         |                                                |
|                         +-> Generates Specific Plot (Density, Mosaic...) |
|                         |                                                |
|                         L-> [generate_stability_plots.R] -> Creates      |
|                                 time-series stability plots.             |
|                                                                          |
|  [Output: Assembled HTML Object]                                         |
+--------------------------------------------------------------------------+
                                |
                                V
+--------------------------------------------------------------------------+
| PHASE 8: FINAL OUTPUTS                                                   |
|                                                                          |
|  +-> [Output File: feature_summary.csv]                                  |
|  +-> [Output File: feature_report.html]                                  |
|  +-> [Output File: data_profiler_log.txt]                                |
|  L-> [Output File: removed_features.txt]                                 |
|                                                                          |
+--------------------------------------------------------------------------+
```

***

## Core Functions and Logic

The project's power comes from its modular design, where each script has a distinct and important role.

* `auto_data_profiling_main.R`
    This is the **orchestrator**. It's the main entry point that you call. It handles all the setup (logging, libraries), parameter validation, and calls all other helper functions in the correct sequence. It manages the flow of data from one step to the next.

* `process_data.R`, `detect_data_types.R`, `summarize_feature.R`
    This trio forms the **analysis engine**. `process_data` iterates through the dataframe columns. For each column, it calls `detect_data_types` to heuristically determine if it's numeric, character, date, etc. Then, it calls `summarize_feature` to calculate key statistics like null percentages, unique value counts, and top categories. The final output is the master `summary_dt` table.

* `exclude_features.R`
    This function acts as a **gatekeeper for visualization**. Not all features are useful or possible to plot. This script takes the `summary_dt` and filters out features that are lists, nearly 100% empty, or have a single category that is so dominant (e.g., >99% of values) that a plot would be uninformative.

* `create_binned_dataframe.R`
    This is the **primary visualization prepper**. A plot with 10,000 unique categories is unreadable. This function solves that by creating a new `_binned` column for each feature. It's smart about it:
    * **Numeric:** It creates human-readable bins like `[10.00 to 20.00]`.
    * **Character:** It takes the top N most frequent categories and groups the rest into a single "others" category.
    * **Date:** It intelligently groups dates into intervals like days, weeks, months, or years depending on the time span of the data.

* `create_smalls_dataframe.R`
    This is the **secondary visualization prepper**. After binning, some bins might still be very rare (e.g., representing only 0.1% of the data). This function takes the `_binned` columns and groups these infrequent bins into a single "smalls" category, further de-noising the final plots.

* `generate_feature_visualizations.R`, `generate_stability_plots.R`
    This is the **visualization factory**. `generate_feature_visualizations` is called for every single feature that passes the exclusion step. It uses the `_smalls` and `_binned` columns to create a suite of Plotly visuals: histogram, pie chart, a details table, and a special plot tailored to the data type. If a date column is available, it calls `generate_stability_plots` to produce the powerful time-series visualizations.

* `generate_html_report.R`
    This is the **final assembler**. It takes all the individual plot objects and summary tables generated in the previous step and masterfully weaves them into a single, cohesive, and interactive HTML file with a tabbed navigation structure.

***

## Parameter Deep Dive

The main function `generate_data_profile_report` is highly tunable. Understanding these parameters is key to tailoring the report to your specific needs.

| Parameter              | Description & Pro-Tips                                                                                                                                                                                                                                                                                                             | Default Value             |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| `df`                   | The input `data.frame` or `data.table`. **Pro-Tip:** The script works best with `data.table` for performance, but will handle `data.frame` automatically.                                                                                                                                                                          | **Required**              |
| `date_col_name`        | Name of the primary date column. **How it affects output:** Providing this unlocks the powerful "Stability Plot" tab for every feature, showing how its distribution changes over time.                                                                                                                                            | `NULL`                    |
| `target_col_name`      | Name of a numeric target variable (e.g., price, conversion_flag). **How it affects output:** This adds Mean Target and Rank Stability plots to the Stability tab, showing if a feature's predictive power is consistent over time.                                                                                                 | `NULL`                    |
| `report_features`      | A list of specific column names to analyze. **Pro-Tip:** Use this to focus the report on a subset of important features, making it faster and more targeted. If `NULL`, all columns are used.                                                                                                                                      | `NULL`                    |
| `top_n_cat`            | The number of top categories to list in the `feature_summary.csv` and the "Summary" tab. **Pro-Tip:** This does not affect plots, only the summary tables.                                                                                                                                                                         | `10`                      |
| `smalls_threshold_pct` | The volume percentage below which a category is grouped into "smalls" for plotting. **How it affects output:** A higher value (e.g., `5`) will group more categories, simplifying plots. A lower value (e.g., `1`) will show more detail.                                                                                          | `2`                       |
| `max_value_pct`        | If a feature's single most common category exceeds this %, it will be **excluded from all plots**. **Pro-Tip:** Set this to `99` or `99.5` to automatically hide features that are nearly constant and would produce uninteresting plots.                                                                                          | `NULL`                    |
| `binning_threshold`    | The maximum number of unique categories to show in a plot before binning/grouping is triggered. **How it affects output:** This is the main control for readability. Lowering it (e.g., to `20`) will make plots for high-cardinality features simpler by grouping more values into "others" or creating wider numeric bins.       | `100`                     |
| `output_dir`           | The folder where all output files will be saved.                                                                                                                                                                                                                                                                                   | `getwd()`                 |
| `generate_plots`       | A master switch to enable or disable the HTML report generation. **Pro-Tip:** Set to `FALSE` if you only need the `feature_summary.csv` for a quick statistical overview.                                                                                                                                                          | `TRUE`                    |

***

## Understanding the Outputs

The script generates a set of highly useful files in your specified `output_dir`:

1.  **`feature_report.html`**
    This is the main deliverable. It's a single, self-contained HTML file that can be opened in any web browser.
    * **Main Navigation:** A set of tabs at the top, one for each analyzed feature.
    * **Sub-Navigation:** Within each feature's tab, there are sub-tabs:
        * **Summary:** A table of all the statistics calculated for that feature (from the `summary_dt`).
        * **Details:** A frequency table for categorical features or a descriptive statistics table (min, max, mean, quartiles) for numeric features.
        * **Histogram & Pie Chart:** Interactive Plotly charts showing the distribution of the feature's categories (with "smalls" and "others" grouping applied).
        * **Stability Plot:** If `date_col_name` was provided, this shows how the feature's distribution and relationship with the target evolve over time. Invaluable for detecting data drift.
        * **Specific Plot:** A special plot tailored to the data type:
            * **Numeric/Integer:** A Density Plot of the original values.
            * **Character/Logical:** A Mosaic Plot showing the relative frequencies.
            * **Date/POSIXct:** A Calendar Heatmap showing activity over time.

2.  **`feature_summary.csv`**
    A detailed CSV file containing the full statistical summary for every column in the input data. This is a machine-readable version of the data displayed in the "Summary" tabs of the report and is perfect for programmatic analysis or as a data dictionary.

3.  **`data_profiler_log.txt`**
    A verbose log file that records every step of the script's execution, including INFO, DEBUG, WARNING, and ERROR messages with timestamps. Essential for debugging any issues.

4.  **`removed_features.txt`**
    A simple text file that lists which features were excluded from plotting and the reason why (e.g., "List type", "Near 100% NULL", "Top category volume exceeds threshold").

***

## Getting Started

1.  **File Structure**: Place all the downloaded `.R` script files into a sub-directory named `source` within your project folder. Your main script should be in the root of the project folder.

    ```
    /my_project
        |- my_analysis_script.R
        └- /source
            |- auto_data_profiling_main.R
            |- create_binned_dataframe.R
            |- ... (all other .R files)
    ```

2.  **Run Script**: In `my_analysis_script.R`, load your data, source the main profiler script, and call the main function.

    ```R
    # my_analysis_script.R

    # 1. Load your dataset
    my_data <- read.csv("path/to/your/data.csv")

    # 2. Source the main profiler script (it will source all others)
    source("source/auto_data_profiling_main.R")

    # 3. Run the report generator!
    # Simple example:
    generate_data_profile_report(
      df = my_data,
      output_dir = "profiling_report_basic"
    )

    # Advanced example with more parameters:
    generate_data_profile_report(
      df = my_data,
      date_col_name = "order_date",
      target_col_name = "sale_amount",
      report_features = c("customer_segment", "product_category", "sale_amount", "order_date"),
      smalls_threshold_pct = 1.5,
      binning_threshold = 30,
      max_value_pct = 99,
      output_dir = "profiling_report_advanced"
    )
    ```
    After running, check the `profiling_report...` folder for your HTML report and other outputs.
	

### Showcase: A Look at the Output

To demonstrate the tool's capabilities, a sample report generated from a synthetic dataset is included. The report highlights the script's ability to handle various data types and identify common data quality issues.

**Interactive Report (HTML)**

The core output is an interactive HTML report. You can view a sample of this report to experience the full functionality of the tool.

* [**View Sample Report**](https://rao-anas-riaz.github.io/R-Auto-Data-Profiling/report_outputs/feature_report.html)

**Summary Statistics (CSV)**

A companion CSV file is generated with all the summarized data. This is useful for anyone who needs to programmatically access the profiling results.

* [**View Sample Summary**](https://github.com/rao-anas-riaz/R-Auto-Data-Profiling/blob/main/report_outputs/feature_summary.csv)

## Dependencies
The script will automatically check for and offer to install the following required R packages:
- `data.table`
- `dplyr`
- `ggplot2`
- `plotly`
- `lubridate`
- `stringr`
- `htmltools`
- `htmlwidgets`
- `uuid`
- `vcd`
- `vcdExtra`
- `RColorBrewer`
- `base64enc`

### License
This project is made available for informational purposes only. The intellectual property and source code remain the exclusive property of the author. No part of the source code may be copied, distributed, or modified without explicit permission.



