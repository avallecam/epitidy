#library(dplyr)
#library(moments)
#https://speakerdeck.com/hadley/tidy-evaluation-programming-with-ggplot2-and-dplyr?slide=42

epi_summary_group <- function(df, g, x) {
  
  g_var <- enquo(g)
  x_var <- enquo(x)
  
  df %>% 
    group_by(!!g_var) %>% 
    summarise(n_obs=n(),
              min=min(!!x_var,na.rm = T),
              max=max(!!x_var,na.rm = T),
              mean=mean(!!x_var,na.rm = T) %>% signif(.,
                                                    digits = str_length(str_replace(.,"(.+)\\.(.+)","\\1")) + 2),
              sd=sd(!!x_var,na.rm = T),
              q25=quantile(!!x_var,probs = 0.25,na.rm = T),
              q50=median(!!x_var,na.rm = T),
              q75=quantile(!!x_var,probs = 0.75,na.rm = T),
              skewness=skewness(!!x_var,na.rm = T),
              kurtosis=kurtosis(!!x_var,na.rm = T)
              )
}