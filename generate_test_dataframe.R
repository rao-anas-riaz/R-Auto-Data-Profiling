# ==============================================================================
# SCRIPT: generate_test_dataframe.R
# ==============================================================================
# This script generates a synthetic dataframe with 5000 rows designed to test
# all functionalities of the auto_feature_binning pipeline. It includes various
# data types, distributions, and missing value formats.
# ==============================================================================

# --- Load necessary libraries ---
# install.packages(c("data.table", "stringi"))
library(data.table)
library(stringi)

# --- Configuration ---
N_ROWS <- 5000
set.seed(42) # for reproducibility

# ==============================================================================
# 1. Create Core Columns: Date and Target
# ==============================================================================
# Create a date column with a range of dates, ensuring multiple entries per date
# for meaningful stability analysis.
order_date <- seq(as.Date("2024-01-01"), as.Date("2024-04-10"), by="day")
order_date <- sample(order_date, N_ROWS, replace = TRUE)

# The target variable 'price' will be constructed at the end based on the features.
# Initialize it for now.
price <- rep(100, N_ROWS)

# Create the initial data.table
test_df <- data.table(order_date, price)

# ==============================================================================
# 2. Helper function to create feature columns
# ==============================================================================
# This function generates a column with specified characteristics.
create_feature_column <- function(name, type, distribution, n_unique = 100) {
  
  # --- Generate unique categories ---
  if (type == "character") {
    categories <- stri_rand_strings(n_unique, length = 8, pattern = "[A-Za-z0-9]")
  } else if (type == "numeric") {
    categories <- round(runif(n_unique, 10, 1000), 2)
  } else if (type == "integer") {
    categories <- as.integer(runif(n_unique, 10, 1000))
  }
  
  # --- Define probability distribution for sampling ---
  probs <- switch(distribution,
                  "dominant" = { # One category > 90%
                    p <- c(0.92, runif(n_unique - 1))
                    p / sum(p)
                  },
                  "all_high" = { # All categories > 2% (only works for n_unique < 50)
                    p <- runif(n_unique, min=0.03, max=0.1)
                    p / sum(p)
                  },
                  "some_low" = { # ~10 categories below 0.5%
                    p <- c(runif(10, 0.001, 0.004), runif(n_unique - 10, 0.02, 0.1))
                    p / sum(p)
                  },
                  "random" = { # uniform random
                    NULL
                  }
  )
  
  # --- Sample and create the column ---
  feature_col <- sample(categories, N_ROWS, replace = TRUE, prob = probs)
  
  # --- Add various types of missing values ---
  n_missing <- N_ROWS * 0.10 # 10% missing values
  missing_indices <- sample(1:N_ROWS, n_missing)
  
  # Split missing indices to assign different null types
  idx_na <- missing_indices[1:floor(n_missing/4)]
  idx_empty <- missing_indices[(floor(n_missing/4)+1):floor(n_missing/2)]
  idx_space <- missing_indices[(floor(n_missing/2)+1):floor(n_missing*3/4)]
  idx_char_null <- missing_indices[(floor(n_missing*3/4)+1):n_missing]
  
  feature_col[idx_na] <- NA
  feature_col[idx_empty] <- ""
  feature_col[idx_space] <- " "
  feature_col[idx_char_null] <- sample(c("NA", "null", "N/A", "none"), length(idx_char_null), replace = TRUE)
  
  return(feature_col)
}

# ==============================================================================
# 3. Generate Feature Columns for Each Type and Distribution
# ==============================================================================
data_types_to_generate <- c("character", "numeric", "integer")
distributions_to_generate <- c("dominant", "all_high", "some_low", "random")

# --- High Cardinality Features ---
# Create 4 columns for each data type (char, num, int) with different distributions.
# Total = 3 data types * 4 distributions = 12 columns
for (dtype in data_types_to_generate) {
  for (dist in distributions_to_generate) {
    col_name <- paste0(dtype, "_", dist)
    n_unique_vals <- sample(50:300, 1)
    
    # The 'all_high' case only works mathematically if n_unique is not too large
    if(dist == "all_high") n_unique_vals <- 30
    
    cat("Generating column:", col_name, "with", n_unique_vals, "unique values\n")
    test_df[, (col_name) := create_feature_column(col_name, dtype, dist, n_unique_vals)]
  }
}

# --- Low Cardinality (Binary) Features ---
# Create 1 binary column for each data type.
# Total = 3 columns
test_df[, char_binary := sample(c("Active", "Inactive", " ", NA, "null"), N_ROWS, replace = TRUE, prob = c(0.45, 0.45, 0.04, 0.03, 0.03))]
test_df[, num_binary := sample(c(1.0, 0.0, NA, 999), N_ROWS, replace = TRUE, prob = c(0.5, 0.4, 0.05, 0.05))] # Using 999 to represent a "missing" code, which will be treated as numeric
test_df$num_binary[test_df$num_binary == 999] <- " " # Convert some to empty strings
test_df[, int_binary := sample(c(1L, 0L, NA, -1L), N_ROWS, replace = TRUE, prob = c(0.6, 0.3, 0.05, 0.05))] # -1 as a special value

# --- Datetime Feature ---
# Create a datetime column to test the date-to-numeric conversion.
test_df[, registration_date := sample(seq(as.Date("2023-01-01"), as.Date("2023-12-31"), by="day"), N_ROWS, replace = TRUE)]
# Add some missing values
test_df$registration_date[sample(1:N_ROWS, N_ROWS * 0.05)] <- NA

# ==============================================================================
# 4. Create a Realistic Target Variable ('price')
# ==============================================================================
# Make 'price' dependent on some of the features so rpart can find meaningful splits.

# Convert some features to numeric for the formula
numeric_vals_for_price <- data.table(
  # A dominant feature should have a strong effect
  dominant_effect = as.numeric(test_df$character_dominant == unique(na.omit(test_df$character_dominant))[1]) * 50,
  # A numeric feature should have a linear effect
  numeric_effect = as.numeric(test_df$numeric_random),
  # A binary feature should have an effect
  binary_effect = ifelse(test_df$char_binary == "Active", 25, -10),
  # An integer feature with some low volume categories
  int_low_effect = as.numeric(test_df$integer_some_low)
)
# Handle NAs by replacing them with the column mean for this calculation
for (j in seq_along(numeric_vals_for_price)) {
  set(numeric_vals_for_price, i = which(is.na(numeric_vals_for_price[[j]])), j = j, value = mean(numeric_vals_for_price[[j]], na.rm = TRUE))
}

# Create the final price with some random noise
test_df$price <- 200 +
  numeric_vals_for_price$dominant_effect +
  (numeric_vals_for_price$numeric_effect * 0.1) +
  numeric_vals_for_price$binary_effect -
  (numeric_vals_for_price$int_low_effect * 0.05) +
  rnorm(N_ROWS, mean = 0, sd = 20) # Add noise

# Ensure price is positive
test_df$price[test_df$price < 0] <- 10

cat("\n--- Test DataFrame Generation Complete ---\n")
cat("Dimensions:", dim(test_df), "\n")
print(head(test_df, 5))
cat("...\n")
print(tail(test_df, 5))

# You can now save this dataframe to a CSV to use with your main script
# fwrite(test_df, "test_dataset_for_binning.csv")