
# Função para requisição de modelagem a partir os inputs necesários =============================

#' @data_list: list with datasets
#' @model_spec: modeling and CV setup
#' @project_id: project name
#' @user_email: email to receive the outputs
#' @run_local: run localhost [dev purposes only]

faas_api <- function(data_list, date_variable, date_format, 
                     model_spec, project_id, user_email, run_local = FALSE) {
  
# Select and format date variable 
  
  data_list = base::lapply(data_list, function(x) { 
    names(x)[names(x) == date_variable] <- "data_tidy"
    x$data_tidy <- as.Date(x$data_tidy, format = date_format) 
    x })

  # Checa se o usuário definiu um horizonte de projeções
  if(any(missing(data_list), missing(model_spec))) {
    
    stop("You must declare every argument: 'data_list', 'model_spec', 'project_id', 'user_email'")
    
  }
  
  
  # Force first column to be the Y variable
  for(i in seq_along(data_list)){
    
    y_column <- names(data_list)[[i]]
    
    
    tryCatch(
      expr = { 
        data_list[[i]] =  data_list[[i]][ , c(y_column, setdiff(colnames(data_list[[i]]), y_column))]
      },
      error = function(e) {
        stop("API input error: 'data_list' element does not exist in the dataset. Please, change the 'names(data_list)' input and send the request again.")
      }  
    )
  }
  
  
  ### Criando uma lista que agrega todas as infos 
  ### necessárias para a requisição via API. Depois
  ### comprime tudo em json e base64 ========================================
  body <- list(data_list = data_list,  
               model_spec = model_spec,
               user_email = user_email,
               project_id = project_id)
  
  
  # Comprime a lista em 'json' e depois em 'base64' ========================
  body <- caTools::base64encode(base::memCompress(jsonlite::toJSON(body), type = "gzip"))
  
  if(run_local == TRUE) {
    
    ### Rodar local =========================================================
    url <- "http://localhost:8000/cluster"
    
  } else {
    
    ### Seta o endpoint para a requisição ===================================
    url <- "https://scalling-models-api-pixv2bua7q-uk.a.run.app/cluster"
    
  }
  
  
  
  ### Envia requisição POST =================================================
  response <- httr::POST(url, body = list(body = body), encode = "json", verbose(data_out = FALSE))
  
}
