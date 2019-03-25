epi_tidynested <- function(add_nested,level=i) {
  add_nested %>% 
    broom::tidy() %>% 
    arrange(p.value) %>% 
    print() %>% 
    rownames_to_column("rank") %>% 
    select(term,df,LRT,p.value,rank) %>% 
    rename_at(.vars = c("rank","LRT","p.value"),.funs = str_replace, "(.+)",paste0("\\1\\_",level))
}
