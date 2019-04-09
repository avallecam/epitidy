#https://adv-r.hadley.nz/quasiquotation.html
#19.4.1 Unquoting one argument
epi_postadjusted <- function(wm1, ajustado_var,parsimonioso_tidy) {
  
  parsimonioso_tidy <- parsimonioso_tidy
  
  ex0_tidy <- parsimonioso_tidy %>% .[FALSE,]
  
  for (i in 1:length(ajustado_var)) { #i=1
    
    x_var <- sym(ajustado_var[i])
    
    ex1_tidy <- update(wm1, expr(~ . + !!x_var)) %>% 
      epi_tidymodel_pr() %>% slice(-c(1:dim(parsimonioso_tidy)[1]))
    
    ex0_tidy <- union_all(ex0_tidy,ex1_tidy)
    
  }
  
  postadjusted <- ex0_tidy %>% rename_at(.vars = vars(-term),.funs = str_replace, "(.+)","\\1\\_post")
  
  postadjusted %>% return()
  
}
