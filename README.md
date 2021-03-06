
<!-- README.md is generated from README.Rmd. Please edit that file -->

# epitidy

<!-- badges: start -->

[![DOI](https://zenodo.org/badge/177627370.svg)](https://zenodo.org/badge/latestdoi/177627370)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/epitidy)](https://cran.r-project.org/package=epitidy)
<!-- badges: end -->

The goal of epitidy is to provide a workflow to **summarise**, **tidy
up** model outputs and **generate** clean tables in a
Epidemiologist-way.

## Installation

<!-- You can install  -->

<!-- the released version of epitidy from [CRAN](https://CRAN.R-project.org) with: -->

<!-- ``` r -->

<!-- install.packages("epitidy") -->

<!-- ``` -->

<!-- And  -->

<!-- the development version from [GitHub](https://github.com/) with: -->

You can install the development version from
[GitHub](https://github.com/) with:

``` r
if(!require("remotes")) install.packages("remotes")
remotes::install_github("avallecam/epitidy")
```

## Example

This is a basic example which shows you how to solve a common problem:

### core functions

  - `epi_tidymodel_*`: summmarize core estimates for OR, RR, PR
    regression models and linear regression coefficients.
  - `epi_tidymodel_up`: update raw models to generate various simple
    models or adjusted by one parsimous model
  - all of these are based on
    [`broom`](https://broom.tidyverse.org/index.html)

### reproducible workflow

Here we show how to:

1.  import a dataset from the `mosaicData` R package
2.  clean it to create variables using `dplyr::mutate`
3.  create a classic table 1 and table 2 with `compareGroups::create*`
4.  create a null regression model using `epitidy::epi_tidymodel_rr`
5.  create a simple model by scratch or updating the null model with one
    variable using `epitidy::epi_tidymodel_up`
6.  create more than one simple models using `purrr::map`
7.  create more than one multiple models with one common set of
    confunders using all tools above
8.  create a final table mixing the simple and multiple regression
    models because `tidyverse`
9.  perform a nested selection model procedure with
    `epitidy::epi_tidynested`

<!-- end list -->

``` r
library(epitidy)
## basic example code
```

``` r
# paquetes ----------------------------------------------------------------

set.seed(33)

library(tidyverse)
library(mosaicData)
# library(avallecam)

# imporat base ------------------------------------------------------------

data("Whickham")
smoke <- Whickham %>% as_tibble()

# limpieza ----------------------------------------------------------------

smoke_clean <- smoke %>%
  mutate(
    #desenlace
    outcome_1=as.numeric(outcome),
    outcome_1=outcome_1-1,
    outcome_2=fct_rev(outcome),
    #exposiciÃ³n
    smoker_2=fct_rev(smoker),
    #confusor
    #agegrp=cut(age,breaks = c(18,44,64,Inf),include.lowest = T))
    agegrp=case_when(
      age %in% 18:44 ~ "18-44",
      age %in% 45:64 ~ "45-64",
      age > 64 ~ "65+"),
    agegrp=as.factor(agegrp),
    random_cov1=rnorm(n = n()),
    random_cov2=rnorm(n = n(),mean = 5,sd = 10),
  )

# table 1 -----------------------------------------------------------------

# outcome_1: 1 is dead
smoke_clean %>%
  mutate(outcome_1=as.factor(outcome_1)) %>%
  compareGroups::compareGroups(~.,data = .) %>%
  compareGroups::createTable()
#> 
#> --------Summary descriptives table ---------
#> 
#> ____________________________ 
#>                [ALL]     N   
#>               N=1314         
#> ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
#> outcome:                1314 
#>     Alive   945 (71.9%)      
#>     Dead    369 (28.1%)      
#> smoker:                 1314 
#>     No      732 (55.7%)      
#>     Yes     582 (44.3%)      
#> age         46.9 (17.4) 1314 
#> outcome_1:              1314 
#>     0       945 (71.9%)      
#>     1       369 (28.1%)      
#> outcome_2:              1314 
#>     Dead    369 (28.1%)      
#>     Alive   945 (71.9%)      
#> smoker_2:               1314 
#>     Yes     582 (44.3%)      
#>     No      732 (55.7%)      
#> agegrp:                 1314 
#>     18-44   624 (47.5%)      
#>     45-64   447 (34.0%)      
#>     65+     243 (18.5%)      
#> random_cov1 0.02 (1.00) 1314 
#> random_cov2 5.12 (9.70) 1314 
#> ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# table 2 -----------------------------------------------------------------

smoke_clean %>%
  mutate(outcome_1=as.factor(outcome_1)) %>%
  compareGroups::compareGroups(outcome~.,
                               data = .) %>%
  compareGroups::createTable()
#> 
#> --------Summary descriptives table by 'outcome'---------
#> 
#> ______________________________________________ 
#>                Alive        Dead     p.overall 
#>                N=945       N=369               
#> ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
#> smoker:                                0.003   
#>     No      502 (53.1%) 230 (62.3%)            
#>     Yes     443 (46.9%) 139 (37.7%)            
#> age         40.1 (13.8) 64.4 (12.8)   <0.001   
#> outcome_1:                            <0.001   
#>     0       945 (100%)   0 (0.00%)             
#>     1        0 (0.00%)   369 (100%)            
#> outcome_2:                            <0.001   
#>     Dead     0 (0.00%)   369 (100%)            
#>     Alive   945 (100%)   0 (0.00%)             
#> smoker_2:                              0.003   
#>     Yes     443 (46.9%) 139 (37.7%)            
#>     No      502 (53.1%) 230 (62.3%)            
#> agegrp:                               <0.001   
#>     18-44   597 (63.2%)  27 (7.32%)            
#>     45-64   314 (33.2%) 133 (36.0%)            
#>     65+     34 (3.60%)  209 (56.6%)            
#> random_cov1 0.04 (1.00) -0.03 (1.01)   0.244   
#> random_cov2 4.98 (9.69) 5.49 (9.72)    0.393   
#> ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# null model --------------------------------------------------------------

smoke_clean %>% pull(outcome_1) %>% mean()
#> [1] 0.2808219

glm_null <- glm(outcome_1 ~ 1,
                data = smoke_clean,
                family = poisson(link = "log"),
                na.action = na.exclude)

glm_null %>% epi_tidymodel_rr()
#> # A tibble: 1 x 7
#>   term        log.rr     se    rr conf.low conf.high p.value
#>   <chr>        <dbl>  <dbl> <dbl>    <dbl>     <dbl>   <dbl>
#> 1 (Intercept)  -1.27 0.0521 0.281    0.253     0.310       0

# one simple model ------------------------------------------------------------

# write all
glm(outcome_1 ~ smoker,
    data = smoke_clean,
    family = poisson(link = "log"),
    na.action = na.exclude) %>%
  epi_tidymodel_rr()
#> # A tibble: 2 x 7
#>   term        log.rr     se    rr conf.low conf.high p.value
#>   <chr>        <dbl>  <dbl> <dbl>    <dbl>     <dbl>   <dbl>
#> 1 (Intercept) -1.16  0.0659 0.314    0.275     0.357  0     
#> 2 smokerYes   -0.274 0.107  0.760    0.615     0.937  0.0107

# or just an update
epi_tidymodel_up(reference_model = glm_null,
                 variable = dplyr::sym("smoker")) %>%
  epi_tidymodel_rr()
#> # A tibble: 2 x 7
#>   term        log.rr     se    rr conf.low conf.high p.value
#>   <chr>        <dbl>  <dbl> <dbl>    <dbl>     <dbl>   <dbl>
#> 1 (Intercept) -1.16  0.0659 0.314    0.275     0.357  0     
#> 2 smokerYes   -0.274 0.107  0.760    0.615     0.937  0.0107

# more than one simple model ------------------------------------------------------------

simple_models <- smoke_clean %>%
  #transform columnames to tibble
  colnames() %>%
  enframe(name = NULL) %>%
  #remove non required variables
  filter(!magrittr::is_in(value,c("outcome","outcome_1",
                                  "outcome_2","smoker_2"))) %>%
  #purrr::map
  #create symbol, update null model, tidy up the results
  mutate(variable=map(value,dplyr::sym),
         simple_rawm=map(.x = variable, .f = epi_tidymodel_up, reference_model=glm_null),
         simple_tidy=map(.x = simple_rawm, .f = epi_tidymodel_rr)
  ) %>%
  #unnest coefficients
  unnest(cols = c(simple_tidy)) %>%
  #filter out intercepts
  filter(term!="(Intercept)")

simple_models
#> # A tibble: 6 x 10
#>   value variable simple_rawm term   log.rr      se     rr conf.low
#>   <chr> <list>   <list>      <chr>   <dbl>   <dbl>  <dbl>    <dbl>
#> 1 smok~ <sym>    <glm>       smok~ -0.274  0.107    0.760    0.615
#> 2 age   <sym>    <glm>       age    0.0629 0.00358  1.06     1.06 
#> 3 ageg~ <sym>    <glm>       ageg~  1.93   0.211    6.88     4.63 
#> 4 ageg~ <sym>    <glm>       ageg~  2.99   0.204   19.9     13.6  
#> 5 rand~ <sym>    <glm>       rand~ -0.0516 0.0519   0.950    0.858
#> 6 rand~ <sym>    <glm>       rand~  0.0039 0.00537  1.00     0.993
#> # ... with 2 more variables: conf.high <dbl>, p.value <dbl>

# multiple model ----------------------------------------------------------

# _ bivariate selection ---------------------------------------------------

# define confounder set
glm_adjusted <- epi_tidymodel_up(reference_model = glm_null,
                                 variable = dplyr::sym("agegrp"))

multiple_model <- simple_models %>%
  #keep variables over a p value threshold
  filter(p.value<0.05) %>%
  #keep those variables
  select(value) %>%
  distinct(.keep_all = T) %>%
  #remove unwanted covariates: e.g. confounder related
  filter(!magrittr::is_in(value,c("agegrp","age"))) %>%
  #add new themaic covariates to evaluate as exposure
  add_row(value="random_cov1") %>% #add one thematic importat covariate
  #purrr::map
  #create symbol, update simple models, tidy up the results
  mutate(variable=map(value,dplyr::sym),
         multiple_rawm=map(variable,epi_tidymodel_up,reference_model=glm_adjusted),
         multiple_tidy=map(multiple_rawm,epi_tidymodel_rr)
  ) %>%
  unnest(cols = c(multiple_tidy)) %>%
  filter(term!="(Intercept)") %>%
  select(-variable,-multiple_rawm) %>%
  #remove confounders from estimated coefficients
  distinct(term,.keep_all = T) %>%
  #CAREFULL!
  #this only remove confunders, requires manual changes!
  slice(-(1:2))

multiple_model
#> # A tibble: 2 x 8
#>   value       term          log.rr     se    rr conf.low conf.high p.value
#>   <chr>       <chr>          <dbl>  <dbl> <dbl>    <dbl>     <dbl>   <dbl>
#> 1 smoker      smokerYes    0.136   0.115  1.15     0.913      1.43   0.236
#> 2 random_cov1 random_cov1 -0.00428 0.0512 0.996    0.901      1.10   0.933

# _ final table -----------------------------------------------------------

simple_models %>%
  select(-variable,-simple_rawm) %>%
  full_join(multiple_model,by = "term",suffix=c(".s",".m")) %>%
  #filter(!is.na(p.value.m)) %>%
  #add to upper rows to add covariate name and reference category
  group_by(value.s) %>%
  nest() %>%
  mutate(data=map(.x = data,
                  .f = ~add_row(.data = .x,
                                term=".ref",
                                .before = 1)),
         data=map(.x = data,
                  .f = ~add_row(.data = .x,
                                term=".name",
                                .before = 1))) %>%
  unnest(cols = c(data)) %>%
  #retire columns
  select(-contains("log.rr"),-contains("se.")) %>%
  # round numeric values
  mutate_at(.vars = vars(rr.s,conf.low.s,conf.high.s,
                         rr.m,conf.low.m,conf.high.m),
            .funs = round, digits=2) %>%
  mutate_at(.vars = vars(p.value.s,p.value.m),
            .funs = round, digits=3) %>%
  #join confidence intervals
  mutate(ci.s=str_c(conf.low.s," - ",conf.high.s),
         ci.m=str_c(conf.low.m," - ",conf.high.m)) %>%
  #remove and reorder columns
  select(starts_with("value"),term,
         starts_with("rr"),starts_with("ci"),starts_with("p.val"),
         -starts_with("conf")) %>%
  select(starts_with("value"),term,ends_with(".s"),ends_with(".m")) %>%
  select(-value.m) %>%
  #add ref to estimates
  mutate(rr.s=if_else(str_detect(term,".ref"),"Ref.",as.character(rr.s)),
         rr.m=if_else(str_detect(term,".ref"),"Ref.",as.character(rr.m))) %>%
  ungroup()
#> # A tibble: 16 x 8
#>    value.s    term      rr.s  ci.s       p.value.s rr.m  ci.m     p.value.m
#>    <chr>      <chr>     <chr> <chr>          <dbl> <chr> <chr>        <dbl>
#>  1 smoker     .name     <NA>  <NA>          NA     <NA>  <NA>        NA    
#>  2 smoker     .ref      Ref.  <NA>          NA     Ref.  <NA>        NA    
#>  3 smoker     smokerYes 0.76  0.61 - 0.~     0.011 1.15  0.91 - ~     0.236
#>  4 age        .name     <NA>  <NA>          NA     <NA>  <NA>        NA    
#>  5 age        .ref      Ref.  <NA>          NA     Ref.  <NA>        NA    
#>  6 age        age       1.06  1.06 - 1.~     0     <NA>  <NA>        NA    
#>  7 agegrp     .name     <NA>  <NA>          NA     <NA>  <NA>        NA    
#>  8 agegrp     .ref      Ref.  <NA>          NA     Ref.  <NA>        NA    
#>  9 agegrp     agegrp45~ 6.88  4.63 - 10~     0     <NA>  <NA>        NA    
#> 10 agegrp     agegrp65+ 19.88 13.57 - 3~     0     <NA>  <NA>        NA    
#> 11 random_co~ .name     <NA>  <NA>          NA     <NA>  <NA>        NA    
#> 12 random_co~ .ref      Ref.  <NA>          NA     Ref.  <NA>        NA    
#> 13 random_co~ random_c~ 0.95  0.86 - 1.~     0.32  1     0.9 - 1~     0.933
#> 14 random_co~ .name     <NA>  <NA>          NA     <NA>  <NA>        NA    
#> 15 random_co~ .ref      Ref.  <NA>          NA     Ref.  <NA>        NA    
#> 16 random_co~ random_c~ 1     0.99 - 1.~     0.468 <NA>  <NA>        NA


# _ nested selection ------------------------------------------------------

#source: http://www.cookbook-r.com/Formulas/Creating_a_formula_from_a_string/
measurevar <- "outcome"
groupvars  <- smoke_clean %>%
  select_if(.predicate = !magrittr::is_in(x = colnames(.),
                                          table = c("outcome","outcome_1",
                                                    "outcome_2","smoker_2"))) %>%
  colnames()

# This returns the formula:
myformula <- as.formula(paste(measurevar,
                              paste(groupvars, collapse=" + "),
                              sep=" ~ "))

add1(glm_null,
     scope = myformula,
     test = "LRT") %>%
  epi_tidynested(1) #-> rank_l1
#> # A tibble: 6 x 5
#>   term           df   LRT_1 p.value_1 rank_1
#>   <chr>       <dbl>   <dbl>     <dbl> <chr> 
#> 1 age             1 382.     5.21e-85 1     
#> 2 agegrp          2 382.     9.86e-84 2     
#> 3 smoker          1   6.65   9.93e- 3 3     
#> 4 random_cov1     1   0.990  3.20e- 1 4     
#> 5 random_cov2     1   0.527  4.68e- 1 5     
#> 6 <none>         NA  NA     NA        6

add1(update(glm_null, ~ . + age),
     scope = myformula,
     test = "LRT") %>%
  epi_tidynested(2) #-> rank_l2
#> # A tibble: 5 x 5
#>   term           df    LRT_2 p.value_2 rank_2
#>   <chr>       <dbl>    <dbl>     <dbl> <chr> 
#> 1 agegrp          2 16.0      0.000343 1     
#> 2 smoker          1  2.19     0.139    2     
#> 3 random_cov1     1  0.00780  0.930    3     
#> 4 random_cov2     1  0.00372  0.951    4     
#> 5 <none>         NA NA       NA        5

add1(update(glm_null, ~ . + age + agegrp),
     scope = myformula,
     test = "LRT") %>%
  epi_tidynested(3) #-> rank_l3
#> # A tibble: 4 x 5
#>   term           df    LRT_3 p.value_3 rank_3
#>   <chr>       <dbl>    <dbl>     <dbl> <chr> 
#> 1 smoker          1  1.90        0.168 1     
#> 2 random_cov2     1  0.00905     0.924 2     
#> 3 random_cov1     1  0.00402     0.949 3     
#> 4 <none>         NA NA          NA     4

glm_nested <- update(glm_null, ~ . + age + agegrp)
glm_nested %>% epi_tidymodel_or()
#> # A tibble: 4 x 7
#>   term         log.or      se     or conf.low conf.high  p.value
#>   <chr>         <dbl>   <dbl>  <dbl>    <dbl>     <dbl>    <dbl>
#> 1 (Intercept) -4.26   0.350   0.0141  0.00702    0.0277 0       
#> 2 age          0.0348 0.00885 1.04    1.02       1.05   0.00008 
#> 3 agegrp45-64  1.12   0.293   3.06    1.74       5.50   0.000130
#> 4 agegrp65+    1.56   0.415   4.75    2.12      10.8    0.00018
```
