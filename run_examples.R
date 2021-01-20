##############
#  FaaS API #
##############

# Load required packages ans functions ================================
source("./aux/load_libs.R")
source("./aux/faas_api.R")

# 1) Load datasets   ====================================================
dataset_1 <- readxl::read_excel("inputs/dataset_1.xlsx")
dataset_2 <- readxl::read_excel("inputs/dataset_2.xlsx")
dataset_3 <- readxl::read_excel("inputs/dataset_3.xlsx")

# Put it inside a list (therefore, a 'data list')
# and name the list element with the name of the target Variable
# Also, specify the date variable and its format ========================

## EXAMPLE 1
data_list <-  list(dataset_1)
names(data_list) <- c("fs_pim")
date_variable <- "DATE_VARIABLE"
date_format <- '%Y-%m-%d' # or'%m/%d/%Y' 

# ## EXAMPLE 2
#data_list <-  list(dataset_1, dataset_1, dataset_1)
#names(data_list) <- c("fs_pim", "fs_pmc", "fs_pib")
#date_variable <- "DATE_VARIABLE"
#date_format <- '%Y-%m-%d' # or'%m/%d/%Y' 

### 2) Basic Modeling Setup ============================================
model_spec <- list(log = TRUE,
                   seas.d = TRUE,
                   n_steps = 1,
                   n_windows = 2,
                   n_best = 20,
                   accuracy_crit = "MAPE",
                   info_crit = "AIC",
                   exclusions = list(c("fs_massa_real", "fs_rend_medio"),
                                     c("fs_pop_ea", "fs_pop_des", "fs_pop_ocu")), 
                   selection_methods = list(
                     lasso = TRUE,
                     rf = TRUE,
                     corr = TRUE,
                     apply.collinear = c("corr","rf","lasso","no_reduction"))
                     )


### 3) Set Project Name  ==========================================================
project_id <- "project_name"

### 4) Set User Email  ============================================================
user_email <- "user@domain.com"

### Send request  ===============================================================
faas_api(data_list, date_variable, date_format, model_spec, project_id, user_email) 
