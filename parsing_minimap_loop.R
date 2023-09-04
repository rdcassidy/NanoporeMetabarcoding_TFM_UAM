# Get a list of all .txt files in the working directory
txt_files <- list.files(pattern = "\\.txt$")

# Loop through the list of .txt files and read each file
for (file in txt_files) {
  # Read the .txt file
  data <- read.table(file, header = FALSE) # Use read.csv() if the file is in CSV format
  
  # Assign appropriate column names
  col_name <- gsub("\\.txt$", "", file) # Extract the basename without ".txt"
  colnames(data) <- c("Query", col_name)
  
  # Assign the data frame to an object with the same name as the basename
  assign(col_name, data)
}

#clean up env#

rm(data)
rm(col_name)
rm(txt_files)
rm(file)


library(dplyr)


###sometimes minimap2 makes two primary assignments. here's a loop to find duplicates and keep the only the highest match

dataframe_names <- ls()
for (df_name in dataframe_names) {
  df <- get(df_name)  # Get the dataframe by its name
  
  
  # Apply the transformation and update the dataframe in place
  df <- df %>%
    group_by(Query) %>%
    arrange(desc(.[[2]])) %>%
    slice(1)
  
  # Update the dataframe in your environment
  assign(df_name, df)
}


# Initialize the merged dataframe
merged_df <- NULL

for (df_name in dataframe_names) {
  df <- get(df_name)  # Get the dataframe by its name
  
  if (!is.null(df)) {
    if ("Query" %in% colnames(df)) {
      if (is.null(merged_df)) {
        merged_df <- df
      } else {
        merged_df <- merge(merged_df, df, by = 'Query', all = TRUE)
      }
    } else {
      warning(paste("DataFrame", df_name, "doesn't have a 'Query' column. Skipping..."))
    }
  }
}


#get the maximum matches#


merged_df$Max_Value_Row <- apply(merged_df[, -1], 1, max)

hist(merged_df$Max_Value_Row)

#separate reads below and above our data frame for closed/open ref clustering#
keep_df <- merged_df[merged_df$Max_Value_Row >= 0.97, ]

denovo_df <- merged_df[merged_df$Max_Value_Row < 0.97, ]


#separate rows with more than 1 maximum match and bin them in separate df (ASSIGN THESE THE LCA OF THE MULTIPLE MATCHES)

keep_df <- keep_df %>%
  rowwise() %>%
  mutate(Max_Value_Count = sum(c_across(-c(1, 22)) == Max_Value_Row))

keep_df <- na.omit(keep_df)

multimatch_df <- keep_df[keep_df$Max_Value_Count > 1, ]

keep_df <- keep_df[keep_df$Max_Value_Count == 1,]



keep_df <- keep_df[, !(names(keep_df) %in% c("Max_Value_Row", "Max_Value_Count"))]

#create column indicating corresponding reference for highest match#

# Assuming 'df' is the name of your dataframe
keep_df$RefAssignment <- apply(keep_df[, -1], 1, function(x) names(keep_df)[-1][which.max(x)])

#visualize clusters#
library(ggplot2)

name_counts <- table(keep_df$RefAssignment)

# Create the bar plot
ggplot(data = data.frame(Name = names(name_counts), Count = as.numeric(name_counts)),
       aes(x = Name, y = Count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Relative Read Abundance (Closed Reference)",
       x = "Reference",
       y = "Read Count") +
  theme_minimal()
