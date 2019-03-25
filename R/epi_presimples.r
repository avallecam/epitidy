epi_presimples <- function(glm.null,todo_var) {
  
  sm0_tidy <- parsimonioso_tidy %>% .[FALSE,]
  nul_tidy <- glm.null %>% epi_tidymodel_pr()
  
  for (i in 1:length(todo_var)) {
    
    x_var <- sym(todo_var[i])
    
    sm1 <- update(glm.null, expr(~ . + !!x_var)) %>% 
      epi_tidymodel_pr()
    
    sm0_tidy <- union_all(sm0_tidy,sm1)
    
  }
  
  simples_tidy <- sm0_tidy %>% 
    filter(term!="(Intercept)") %>% 
    union_all(nul_tidy) %>% 
    rename_at(.vars = vars(-term),.funs = str_replace, "(.+)","\\1\\_simple")
  
  simples_tidy %>% return()
  
}
