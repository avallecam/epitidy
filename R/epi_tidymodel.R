#' Tidy up -even more- an output model using broom functions
#'
#' @description Summarize OR, RR, PR regression outputs and update models for simple and other multiple models.
#'
#' @describeIn epi_tidymodel_or summarize and calculates OR coefficients from bin-logit regression
#'
#' @param model_output output raw GLM model
#' @param digits digits for numeric double objects (p.value)
#'
#' @import dplyr
#' @import broom
#'
#' @return table summary from traditional epi models.
#'
#' @examples
#'
#' \dontrun{
#'
#' # paquetes ----------------------------------------------------------------
#'
#' set.seed(33)
#'
#' library(tidyverse)
#' library(mosaicData)
#' library(avallecam)
#'
#' # imporat base ------------------------------------------------------------
#'
#' data("Whickham")
#' smoke <- Whickham %>% as_tibble()
#'
#' # limpieza ----------------------------------------------------------------
#'
#' smoke_clean <- smoke %>%
#'   mutate(
#'     #desenlace
#'     outcome_1=as.numeric(outcome),
#'     outcome_1=outcome_1-1,
#'     outcome_2=fct_rev(outcome),
#'     #exposición
#'     smoker_2=fct_rev(smoker),
#'     #confusor
#'     #agegrp=cut(age,breaks = c(18,44,64,Inf),include.lowest = T))
#'     agegrp=case_when(
#'       age %in% 18:44 ~ "18-44",
#'       age %in% 45:64 ~ "45-64",
#'       age > 64 ~ "65+"),
#'     agegrp=as.factor(agegrp),
#'     random_cov1=rnorm(n = n()),
#'     random_cov2=rnorm(n = n(),mean = 5,sd = 10),
#'   )
#'
#' # outcome_1: 1 is dead
#' smoke_clean %>%
#'   mutate(outcome_1=as.factor(outcome_1)) %>%
#'   compareGroups::compareGroups(~.,data = .) %>%
#'   compareGroups::createTable()
#'
#' # null model --------------------------------------------------------------
#'
#' smoke_clean %>% pull(outcome_1) %>% mean()
#'
#' glm_null <- glm(outcome_1 ~ 1,
#'                 data = smoke_clean,
#'                 family = poisson(link = "log"),
#'                 na.action = na.exclude)
#'
#' glm_null %>% epi_tidymodel_rr()
#'
#' # one simple model ------------------------------------------------------------
#'
#' # write all
#' glm(outcome_1 ~ smoker,
#'     data = smoke_clean,
#'     family = poisson(link = "log"),
#'     na.action = na.exclude) %>%
#'   epi_tidymodel_rr()
#'
#' # or just an update
#' epi_tidymodel_up(reference_model = glm_null,
#'                  variable = dplyr::sym("smoker")) %>%
#'   epi_tidymodel_rr()
#'
#' # more than one simple model ------------------------------------------------------------
#'
#' simple_models <- smoke_clean %>%
#'   #transform columnames to tibble
#'   colnames() %>%
#'   enframe(name = NULL) %>%
#'   #remove non required variables
#'   filter(!magrittr::is_in(value,c("outcome","outcome_1",
#'                                   "outcome_2","smoker_2"))) %>%
#'   #purrr::map
#'   #create symbol, update null model, tidy up the results
#'   mutate(variable=map(value,dplyr::sym),
#'          simple_rawm=map(.x = variable, .f = epi_tidymodel_up, reference_model=glm_null),
#'          simple_tidy=map(.x = simple_rawm, .f = epi_tidymodel_rr)
#'   ) %>%
#'   #unnest coefficients
#'   unnest(cols = c(simple_tidy)) %>%
#'   #filter out intercepts
#'   filter(term!="(Intercept)")
#'
#' simple_models
#'
#' # multiple model ----------------------------------------------------------
#'
#' # _ bivariate selection ---------------------------------------------------
#'
#' # define confounder set
#' glm_adjusted <- epi_tidymodel_up(reference_model = glm_null,
#'                                  variable = dplyr::sym("agegrp"))
#'
#' multiple_model <- simple_models %>%
#'   #keep variables over a p value threshold
#'   filter(p.value<0.05) %>%
#'   #keep those variables
#'   select(value) %>%
#'   distinct(.keep_all = T) %>%
#'   #remove unwanted covariates: e.g. confounder related
#'   filter(!magrittr::is_in(value,c("agegrp","age"))) %>%
#'   #add new themaic covariates to evaluate as exposure
#'   add_row(value="random_cov1") %>% #add one thematic importat covariate
#'   #purrr::map
#'   #create symbol, update simple models, tidy up the results
#'   mutate(variable=map(value,dplyr::sym),
#'          multiple_rawm=map(variable,epi_tidymodel_up,reference_model=glm_adjusted),
#'          multiple_tidy=map(multiple_rawm,epi_tidymodel_rr)
#'   ) %>%
#'   unnest(cols = c(multiple_tidy)) %>%
#'   filter(term!="(Intercept)") %>%
#'   select(-variable,-multiple_rawm) %>%
#'   #remove confounders from estimated coefficients
#'   distinct(term,.keep_all = T) %>%
#'   #CAREFULL!
#'   #this only remove confunders, requires manual changes!
#'   slice(-(1:2))
#'
#' multiple_model
#'
#' # _ final table -----------------------------------------------------------
#'
#' simple_models %>%
#'   select(-variable,-simple_rawm) %>%
#'   full_join(multiple_model,by = "term",suffix=c(".s",".m")) %>%
#'   #filter(!is.na(p.value.m)) %>%
#'   #add to upper rows to add covariate name and reference category
#'   group_by(value.s) %>%
#'   nest() %>%
#'   mutate(data=map(.x = data,
#'                   .f = ~add_row(.data = .x,
#'                                 term=".ref",
#'                                 .before = 1)),
#'          data=map(.x = data,
#'                   .f = ~add_row(.data = .x,
#'                                 term=".name",
#'                                 .before = 1))) %>%
#'   unnest(cols = c(data)) %>%
#'   #retire columns
#'   select(-contains("log.rr"),-contains("se.")) %>%
#'   # round numeric values
#'   mutate_at(.vars = vars(rr.s,conf.low.s,conf.high.s,
#'                          rr.m,conf.low.m,conf.high.m),
#'             .funs = round, digits=2) %>%
#'   mutate_at(.vars = vars(p.value.s,p.value.m),
#'             .funs = round, digits=3) %>%
#'   #join confidence intervals
#'   mutate(ci.s=str_c(conf.low.s," - ",conf.high.s),
#'          ci.m=str_c(conf.low.m," - ",conf.high.m)) %>%
#'   #remove and reorder columns
#'   select(starts_with("value"),term,
#'          starts_with("rr"),starts_with("ci"),starts_with("p.val"),
#'          -starts_with("conf")) %>%
#'   select(starts_with("value"),term,ends_with(".s"),ends_with(".m")) %>%
#'   select(-value.m) %>%
#'   #add ref to estimates
#'   mutate(rr.s=if_else(str_detect(term,".ref"),"Ref.",as.character(rr.s)),
#'          rr.m=if_else(str_detect(term,".ref"),"Ref.",as.character(rr.m))) %>%
#'   ungroup()
#'
#'
#' # _ nested selection ------------------------------------------------------
#'
#' #source: http://www.cookbook-r.com/Formulas/Creating_a_formula_from_a_string/
#' measurevar <- "outcome"
#' groupvars  <- smoke_clean %>%
#'   select_if(.predicate = !magrittr::is_in(x = colnames(.),
#'                                           table = c("outcome","outcome_1",
#'                                                     "outcome_2","smoker_2"))) %>%
#'   colnames()
#'
#' # This returns the formula:
#' myformula <- as.formula(paste(measurevar,
#'                               paste(groupvars, collapse=" + "),
#'                               sep=" ~ "))
#'
#' add1(glm_null,
#'      scope = myformula,
#'      test = "LRT") %>%
#'   epi_tidynested(1) #-> rank_l1
#'
#' add1(update(glm_null, ~ . + age),
#'      scope = myformula,
#'      test = "LRT") %>%
#'   epi_tidynested(2) #-> rank_l2
#'
#' add1(update(glm_null, ~ . + age + agegrp),
#'      scope = myformula,
#'      test = "LRT") %>%
#'   epi_tidynested(3) #-> rank_l3
#'
#' glm_nested <- update(glm_null, ~ . + age + agegrp)
#' glm_nested %>% epi_tidymodel_or()
#'
#' }
#'
#'@export epi_tidymodel_or
#'@export epi_tidymodel_rr
#'@export epi_tidymodel_pr
#'@export epi_tidymodel_up
#'@export epi_tidynested
#'@export epi_tidymodel_coef
#'

epi_tidymodel_or <- function(model_output,digits=5) {
  # m1 <- model_output %>% tidy(conf.int=TRUE) %>% mutate(or=exp(estimate)) %>% rownames_to_column()
  # m2 <- model_output %>% confint_tidy() %>% mutate_all(list(exp)) %>% rownames_to_column()
  m3 <- model_output %>% tidy(conf.int=TRUE) %>% mutate(or=exp(estimate)) %>% rownames_to_column()

  # left_join(m1,m2) %>%
  m3 %>%
    dplyr::select(term,log.or=estimate,se=std.error,or,
                  conf.low,conf.high,p.value) %>%
    mutate_at(.vars = vars(-term,-p.value),round, digits = digits) %>%
    mutate_at(.vars = vars(p.value),round, digits = digits) %>%
    #print() %>%
    return()
}

#' @describeIn epi_tidymodel_or summarize and calculates RR coefficients from bin-log regression
#' @inheritParams epi_tidymodel_or

epi_tidymodel_rr <- function(model_output,digits = 5) {
  m1 <- model_output %>% tidy() %>% mutate(rr=exp(estimate)) %>% rownames_to_column()
  m2 <- model_output %>% confint_tidy() %>% mutate_all(list(exp)) %>% rownames_to_column()

  left_join(m1,m2) %>%
    dplyr::select(term,log.rr=estimate,se=std.error,rr,
                  conf.low,conf.high,p.value) %>%
    mutate_at(.vars = vars(-term,-p.value),round, digits = digits) %>%
    mutate_at(.vars = vars(p.value),round, digits = digits) %>%
    #print() %>%
    return()
}

#' @describeIn epi_tidymodel_or summarize and calculates PR coefficients from bin/poisson-log regression
#' @inheritParams epi_tidymodel_or

epi_tidymodel_pr <- function(model_output,digits=5) {
  m1 <- model_output %>% tidy() %>% mutate(pr=exp(estimate)) %>% rownames_to_column()
  m2 <- model_output %>% confint_tidy() %>% mutate_all(list(exp)) %>% rownames_to_column()

  left_join(m1,m2) %>%
    dplyr::select(term,log.pr=estimate,se=std.error,pr,
                  conf.low,conf.high,p.value) %>%
    mutate_at(.vars = vars(-term,-p.value),round, digits = digits) %>%
    mutate_at(.vars = vars(p.value),round, digits = digits) %>%
    #print() %>%
    return()
}

#' @describeIn epi_tidymodel_or updates reference models (null or parsimonius) by adjusting with a new covariate. to use with purrr::map() and requires to use rlang::sym() to recognize the variable.
#' @inheritParams epi_tidymodel_or
#' @param reference_model reference model to update
#' @param variable new variable to update into the model

epi_tidymodel_up <- function(reference_model,variable) {
  update(reference_model, expr(~ . + !!variable))
}

#' @describeIn epi_tidymodel_or tidy output for each update level in the nested models procedure
#' @inheritParams epi_tidymodel_or
#' @param add_nested add1() output model
#' @param level level of nesting process

epi_tidynested <- function(add_nested,level=i) {
  add_nested %>%
    broom::tidy() %>%
    arrange(p.value) %>%
    #print() %>%
    rownames_to_column("rank") %>%
    select(term,df,LRT,p.value,rank) %>%
    rename_at(.vars = c("rank","LRT","p.value"),.funs = str_replace, "(.+)",paste0("\\1\\_",level))
}


#' @describeIn epi_tidymodel_or summarize and calculates coefficients from linear regression (gaussian identity GLM)
#' @inheritParams epi_tidymodel_or

epi_tidymodel_coef <- function(model_output,digits = 5) {
  m1 <- model_output %>% tidy() %>% #mutate(coef=estimate) %>%
    rownames_to_column()
  m2 <- model_output %>% confint_tidy() %>% #mutate_all(list(exp)) %>%
    rownames_to_column()

  left_join(m1,m2) %>%
    dplyr::select(term,#log.coef=estimate,
                  estimate ,#coef,
                  se=std.error,
                  conf.low,conf.high,
                  p.value) %>%
    mutate_at(.vars = vars(-term,-p.value),round, digits = digits) %>%
    mutate_at(.vars = vars(p.value),round, digits = digits) %>%
    #print() %>%
    return()
}
