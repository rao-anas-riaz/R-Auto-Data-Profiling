# Source the files in the correct order to ensure dependencies are met.
source("source/auto_data_profiling_main.R")

# Now, call the main orchestration function with the test dataframe.
generate_data_profile_report(
  df = test_df,                                 
  date_col_name = "order_date",                 
  target_col_name = "price",                
  report_features = NULL,                 
  top_n_cat = 10,                         
  smalls_threshold_pct = 2,                   
  max_value_pct = 98,                   
  binning_threshold = 100,                
  output_dir = "output",                   
  log_file_name = "data_profiler_log.txt",
  summary_csv_name = "feature_summary.csv",
  html_report_name = "feature_report.html",
  generate_plots = TRUE
)

