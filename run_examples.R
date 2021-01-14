##############
#  FaaS API #
##############


# Load required packages ans functions ================================
source("./aux/load_libs.R")
source("./aux/faas_api.R")

# 1) Load datasets   =====================================================
dataset_1 <- readxl::read_excel("inputs/dataset_1.xlsx")
dataset_2 <- readxl::read_excel("inputs/dataset_2.xlsx")
dataset_3 <- readxl::read_excel("inputs/dataset_3.xlsx")


# Put it inside a list (therefore, a 'data list')
# and name the list element with the name of the 
# target variable ======================================================

## EXAMPLE 1
data_list <-  list(dataset_1)
names(data_list) <- c("fs_pim")

# ## EXAMPLE 2
# data_list <-  list(dataset_1, dataset_2, dataset_3)
# names(data_list) <- c("fs_pim", "fs_pmc", "fs_pib")

### 2) Basic Modeling Setup ============================================
model_spec <- list(log = TRUE,
                   seas.d = TRUE,
                   n_steps = 1,
                   n_windows = 12,
                   n_best = 20,
                   accuracy_crit = "MAPE",
                   info_crit = "AIC",
                   exclusions = list(),
                   golden_variables = "",
                   selection_methods = list(
                     lasso = TRUE,
                     rf = TRUE,
                     corr = TRUE,
                     apply.collinear = c("corr","rf","lasso","no_reduction")))


### 3) Set Project Name  ==========================================================
project_id <- "project_example"

### 4) Set User Email  ============================================================
user_email <- "example@example.com"


### Send request  ===============================================================
faas_api(data_list, model_spec, project_id, user_email)



