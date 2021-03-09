FaaS - API modeling
================

![R](https://img.shields.io/badge/R%3E%3D-3.6.0-blue.svg) ![License: MPL
2.0](https://img.shields.io/badge/License-MPL%202.0-brightgreen.svg)

**Repository for running scale modeling on FaaS**

Repository under license [Mozilla Public
Version 2.0](https://www.mozilla.org/en-US/MPL/2.0/).

The script ‘run\_examples.R’ has all the necessary code to run both
examples covered in the tutorial below.

Linux users must ensure that the following libs are installed:

1)  ‘libcurl4-openssl-dev’
2)  ‘libxml2-dev’

## Autentication

An **access key** is required in order to sucessfully send the request.
It will be granted to each user individually.

## I) How it works

You only need two functions to request a job, both inside the “api”
folder. **faas\_api** is the main function. **load\_libs** only load
(and install if necessary) a few external libraries.

Let’s load them:

``` r
source("./api/load_libs.R")
source("./api/faas_api.R")
```

There are some arguments to feed ‘faas\_api’ function. We are going
through all of them in this example and then will call the API.

#### 1\) Data List \[‘data\_list’\]

A list of datasets to perform modeling;

Since we are dealing with time-series, the dataset *must contain a date
column* (its name is not relevant, since we will automatically detect
it).

Moreover, you must name every list element after the Y variable name.

Obs: Variables names (column names) that begin with numeric characters
will be renamed to avoid computational issues. For example, variables
“32”, “156\_y”, “3\_pim” will be displayed as “x32”, “x156\_y” and
“x3\_pim” at the end of the process. To avoid this correction, avoid
beginning columns names with numeric characters;

Let us see two examples of data lists, one with 1 Y’s and the other with
multiple Y’s <br>

##### Example 1 data\_list \[single Y\]:

``` r
# Load a data frame with our data
dataset_1 <- readxl::read_excel("./inputs/dataset_1.xlsx")

# Put it inside a list (therefore, a 'data list')
# and name the list element with the name of the target variable
data_list <-  list(dataset_1)
names(data_list) <- c("fs_pim")

#Also, specify the date variable and its format 
date_variable <- "DATE_VARIABLE"
date_format <- '%Y-%m-%d'
```

<br>

##### Example 2 data\_list \[multiple Ys\]:

``` r
# Load a data frame with our data
dataset_1 <- readxl::read_excel("./inputs/dataset_1.xlsx")
dataset_2 <- readxl::read_excel("./inputs/dataset_2.xlsx")
dataset_3 <- readxl::read_excel("./inputs/dataset_3.xlsx")

# Put it inside a list (therefore, a 'data list')
# and name every list element with the name of the target variable
data_list <-  list(dataset_1, dataset_2, dataset_3)
names(data_list) <- c("fs_pim", "fs_pmc", "fs_pib")

# Also, specify the date variable and its format 
# (must have the same name in all datasets)
date_variable <- "DATE_VARIABLE"
date_format <- '%Y-%m-%d'
```

<br>

#### 2\) **Model Specifications \[‘model\_spec’\]**

Regardless of whether you are modeling one or multiple Ys, the model
spec follows the same logic. A list of desired modeling specification by
the user:

  - **n\_steps**: forecast horizon that will be used in the
    cross-validation (if 3, 3 months ahead; if 12, 12 months ahead,
    etc.);

  - **n\_windows**: how many windows the size of ‘Forecast Horizon’ will
    be evaluated during cross-validation (CV);

  - **seas.d**: if TRUE, it includes seasonal dummies in every
    estimation.

  - **log**: if TRUE apply log transformation to the data;

  - **accuracy\_crit**: which criterion to measure the accuracy of the
    forecast during the CV (can be MPE, MAPE, WMAPE or RMSE);

  - **exclusions**: restrictions on features in the same model;

  - **golden\_variables**: features that must be included in, at least,
    one model (separate or together);

  - **fill\_forecast**: if TRUE, it enables forecasting explanatory
    variables in order to avoid NAs in future values;

  - **cv\_summary**: determines whether ‘mean’ ou ‘median’ will be used
    to calculate the summary statistic of the accuracy measure over the
    CV windows.

<br>

The critical input we expect from users is the CV settings (n\_steps and
n\_windows). In this example, we set our modeling algorithm to perform a
CV, which will evaluate forecasts 1 step ahead (‘n\_steps’), 12 times
(‘n\_windows’).

In this example, we keep other specifications at their default values.
The accuracy criteria used to select the best models will be “MAPE”.
We’ll be using data with log transformation, and proper seasonal
dummies will be used in every estimation. Moreover, we avoid
multicollinearity issues in linear models and apply three distinct
methods of feature selection. In the last section of this file, we
present more advanced settings examples.

``` r
## EXAMPLE 1
model_spec <- list(log = TRUE,
                   seas.d = TRUE,
                   n_steps = 1,
                   n_windows = 12,
                   n_best = 20,
                   accuracy_crit = "MAPE",
                   info_crit = "AIC",
                   exclusions = list(),
                   golden_variables = c(),
                   fill_forecast = FALSE,
                   cv_summary = 'mean',
                   selection_methods = list(
                     lasso = TRUE,
                     rf = TRUE,
                     corr = TRUE,
                     apply.collinear = c("corr","rf","lasso","no_reduction")))
```

<br>

#### 3\) Project ID \[‘project\_id’\]

Define a project name. It accepts character and numeric inputs. Special
characters will be removed.

``` r
project_id <- "example_project"
```

#### 4\) User Email \[‘user\_mail’\]

Set the user email. We are going to use it to let you know when the
modeling is over.

``` r
user_email <- "user@domain.com"
```

### 5\) Access Key

``` r
access_key <- "User access key"
```

#### 6\) Send job request

Everything looks nice? Great\! Now you can send **FaaS API** request:

``` r
faas_api(data_list, date_variable, date_format, model_spec, 
         project_id, user_email, access_key) 
```

## II) Advanced Options

In this section, we change some the default values of the
**model\_spec**. *Only advanced users should edit them: make sure you
understand the implications before changing them.*

The accuracy criteria used to select the best models will be “RMSE”.
We’re not applying log transformation on data. Moreover, we also make
use of the **‘exclusions’**, **golden\_variables**, **fill\_forecast**
and **cv\_summary** options:

``` r
## EXAMPLE 2
model_spec <- list(log = FALSE,
                   seas.d = TRUE,
                   n_steps = 1,
                   n_windows = 12,
                   n_best = 20,
                   accuracy_crit = "RMSE",
                   info_crit = "AIC",
                   exclusions = list(c("fs_massa_real", "fs_rend_medio"),
                                     c("fs_pop_ea", "fs_pop_des", "fs_pop_ocu")),
                   golden_variables = c("fs_pmc", "fs_ici"),
                   fill_forecast = TRUE,
                   cv_summary = 'median',
                   selection_methods = list(
                     lasso = TRUE,
                     rf = TRUE,
                     corr = TRUE,
                     apply.collinear = c("corr","rf","lasso","no_reduction")))
```

<br>

By setting **exclusions** this way, we add the restriction where the
features/variables in a group can not appear together in the same model.
Pay attention to the following lines:

``` r
exclusions = list(c("fs_massa_real", "fs_rend_medio"),
                  c("fs_pop_ea", "fs_pop_des", "fs_pop_ocu"))
```

This list implies that we will never see “fs\_massa\_real” and
“fs\_rend\_medio” in the same model. The same is true for the second
restriction group: we will never estimate models that simultaneously
include “fs\_pop\_ea”, with either “fs\_pop\_des” and “fs\_pop\_ocu”,
and so on.

<br>

With the **golden\_variables** argument, we can guarantee that at least
some of best models contain one or both of the ‘golden’ ones:

``` r
golden_variables = c("fs_pmc", "fs_ici")
```

<br>

With the **fill\_forecast** argument, we forecast explanatory variables
in order to avoid NAs in future values. Warning: For most variables a
simple univariate ARIMA is used in this process (exception: dummy
variables are filled using Random Forest) which may hinder the
performance of the dependent variable forecast.

``` r
fill_forecast = TRUE
```

<br>

Regarding the **cv\_summary** argument, should we calculate the summary
statistic of the accuracy measures using the mean or the median? The
**mean** is the most usual, however, the **median** is more robust to
outliers and might be a better statistic when you think that the cross
validation is affected by extreme situations, such as the Covid 19
pandemic.

``` r
cv_summary = 'median'
```

<br>

The **selection\_methods** determine feature selection algorithms that
will be used when it comes to big datasets (one with a large number of
explanatory features). More precisely, if the number of features in the
dataset exceeds 14, feature selection methods will reduce
dimensionality, guaranteeing the best results in a much more efficient
way. In this example, we turn off the Lasso method and work only with
Random Forestation and the correlation approach.

``` r
selection_methods = list(
  lasso = FALSE,
  rf = TRUE,
  corr = TRUE,
  apply.collinear = "")
```

<br>
