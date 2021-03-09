
# Função para requisição de modelagem a partir os inputs necesários =============================

#' @data_list: list with datasets
#' @model_spec: modeling and CV setup
#' @project_id: project name
#' @user_email: email to receive the outputs
#' @access_key: user access Key (authentication)
#' @run_local: run localhost [dev purposes only]

faas_api <- function(data_list, date_variable, date_format,
                     model_spec, project_id, user_email, access_key, run_local = FALSE) {  
  
  
  # Checa se o usuário definiu os argumentos necessários ===============================
  if(any(missing(data_list), missing(model_spec), missing(date_variable), missing(date_format), 
         missing(project_id), missing(user_email), missing(access_key))) {
    
    stop("You must declare every argument: 'data_list', 'model_spec', 'project_id', 'user_email', 'date_format', 'date_variable', 'access_key")
    
  }
  
  
  
  # Trata caracteres especiais ===============================
  names(data_list) <- make.names(iconv(names(data_list), to = 'ASCII//TRANSLIT'))
  date_variable <- make.names(iconv(date_variable, to = 'ASCII//TRANSLIT'), unique = TRUE)
  
  if(length(model_spec[["exclusions"]]) > 0) {
    model_spec[["exclusions"]] <- lapply(model_spec[["exclusions"]], 
                                         function(x) make.names(iconv(x,  to = 'ASCII//TRANSLIT'), unique = TRUE))
    
  }
  
  if(length(model_spec[["golden_variables"]]) > 0) {
    model_spec[["golden_variables"]] <- make.names(iconv(model_spec[["golden_variables"]], to = 'ASCII//TRANSLIT'), unique = TRUE)
  }
  
  data_list <- lapply(data_list, function(x) {names(x) <- make.names(iconv(names(x), to = 'ASCII//TRANSLIT'), unique = TRUE)
  x})
  
  
  
  # Force date variable to be called 'data_tidy'  =====================
  # Select and format date variable 
  data_list = base::lapply(data_list, function(x) { 
    names(x)[names(x) == date_variable] <- "data_tidy"
    x$data_tidy <- as.Date(x$data_tidy, format = date_format) 
    x })
  
  
  # Add prefix at Y variables =====================
  y_names <- sapply(seq_along(data_list), function(x) {
    a <- paste0("forecast_", x, "_", names(data_list)[x])
    a})
  names(data_list) <- y_names
  
  
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
    url <- "https://scalling-models-api-pixv2bua7q-uk.a.run.app/cluster" # externo
    
  }
  
  # Define a chave de acesso para poder fazer requisições via API ============
  headers = c(`Authorization` = access_key)
  
  ### Envia requisição POST ==================================================
  response <- httr::RETRY('POST',
                          url,
                          body = list(body = body),
                          httr::add_headers(.headers = headers),
                          encode = "json",
                          times = 5)
  
  
  
  
  if(response$status_code == 200) {
    
    message("HTTP 200:\n", 
            "Request successfully received!\n
             Results will soon be available in your Projects module")
    
  } else {
    
    message("Something went wrong!\nStatus code:", response$status_code)
    
  }  
  
}