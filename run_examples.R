##############
#  FaaS API #
##############

# Load required packages ans functions ================================
source("./api/load_libs.R")
source("./api/faas_api.R")

# 1) Load datasets   ====================================================
dataset_1 <- readxl::read_excel("inputs/dataset_1.xlsx")
dataset_2 <- readxl::read_excel("inputs/dataset_2.xlsx")
dataset_3 <- readxl::read_excel("inputs/dataset_3.xlsx")

# Put it inside a list (therefore, a 'data list')
# and name the list element with the name of the target Variable
# Also, specify the date variable and its format ========================

## EXAMPLE 1
data_list <-list(dataset_1)
names(data_list) <- c("fs_pim")
date_variable <- "DATE_VARIABLE"
date_format <- '%Y-%m-%d' # or'%m/%d/%Y' 

# ## EXAMPLE 2
#data_list <-  list(dataset_1, dataset_2, dataset_3)
#names(data_list) <- c("fs_pim", "fs_pmc", "fs_pib")
#date_variable <- "DATE_VARIABLE"
#date_format <- '%Y-%m-%d' # or'%m/%d/%Y' 

### 2) Basic Modeling Setup ===========================================
model_spec <- list(
                   n_steps = 1,
                   n_windows = 12
)

### 3) Set Project Name  ========================================================
project_id <- "example_project"

### 4) Set User Email  ==========================================================
user_email <- "user@domain.com"

### 5) Set Access Key ===========================================================
access_key <- "User access key"

# ### Send request  =============================================================
faas_api(data_list, date_variable, date_format,
         model_spec, project_id, user_email,
         access_key)



