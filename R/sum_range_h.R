
# 04 rangos de 06 horas cada uno
# - 06.00 - 11.59 (06, 07, 08, 09, 10, 11)
# - 12.00 - 17.59 (12, 13, 14, 15, 16, 17)
# - 18.00 - 23.59 (18, 19, 20, 21, 22, 23)
# - 00.00 - 05.59 (24, 01, 02, 03, 04, 05)

#
test <- data_frame(obs_sal_hx=c(07,04,07,04,24,11,NA,20,22,04), 
                   obs_ret_hx=c(10,08,13,13,21,NA,NA,09,04,22))
test

#https://stackoverflow.com/questions/26003574/dplyr-mutate-use-dynamic-variable-names

sum_range_h <- function(dt, lim_sal_h, lim_ret_h, obs_sal_h, obs_ret_h, prefix, suffix) {
  
  varname <- paste0(prefix, 
                    if_else(lim_sal_h<10,str_c(0,lim_sal_h),str_c(lim_sal_h)), 
                    if_else(lim_ret_h<10,str_c(0,lim_ret_h),str_c(lim_ret_h)), 
                    suffix)
  s_obs <- enquo(obs_sal_h)
  r_obs <- enquo(obs_ret_h)
  
  dt %>% 
    mutate(!!varname := NA_real_,
           !!varname := if_else((!!r_obs<=lim_ret_h & !!r_obs>=lim_sal_h) & 
                                  (!!s_obs>=lim_sal_h & !!s_obs<=lim_ret_h) & (!!r_obs>!!s_obs),
                                (!!r_obs+1)-!!s_obs,
                                if_else((!!r_obs<=lim_ret_h & !!r_obs>=lim_sal_h) & 
                                          (!!s_obs>=lim_sal_h & !!s_obs<=lim_ret_h) & (!!s_obs>!!r_obs),
                                        ((lim_ret_h+1)-!!s_obs) + ((!!r_obs+1)-lim_sal_h),
                                        if_else((!!r_obs>lim_sal_h & !!r_obs<=lim_ret_h) & 
                                                  (!!s_obs<lim_sal_h | !!s_obs>!!r_obs),
                                                (!!r_obs+1)-lim_sal_h,
                                                if_else((!!r_obs>lim_ret_h | !!r_obs<!!s_obs ) & 
                                                          (!!s_obs>=lim_sal_h & !!s_obs<lim_ret_h),
                                                        (lim_ret_h+1)-!!s_obs,
                                                        if_else((!!r_obs>lim_ret_h) & 
                                                                  (!!s_obs<lim_sal_h) & (!!r_obs>!!s_obs),
                                                                (lim_ret_h+1)-lim_sal_h,
                                                                NA_real_)))))
    )
}

test %>% 
  sum_range_h(lim_sal_h = 6,
              lim_ret_h = 11,
              obs_sal_h = obs_sal_hx,
              obs_ret_h = obs_ret_hx,prefix = "mpu_",suffix = "_h1") %>% 
  sum_range_h(lim_sal_h = 12,
              lim_ret_h = 17,
              obs_sal_h = obs_sal_hx,
              obs_ret_h = obs_ret_hx,prefix = "mpu_",suffix = "_h1") %>% 
  sum_range_h(lim_sal_h = 18,
              lim_ret_h = 23,
              obs_sal_h = obs_sal_hx,
              obs_ret_h = obs_ret_hx,prefix = "mpu_",suffix = "_h1") %>% 
  sum_range_h(lim_sal_h = 00,
              lim_ret_h = 05,
              obs_sal_h = obs_sal_hx,
              obs_ret_h = obs_ret_hx,prefix = "mpu_",suffix = "_h1") %>% 
  sum_range_h(lim_sal_h = 19,
              lim_ret_h = 24,
              obs_sal_h = obs_sal_hx,
              obs_ret_h = obs_ret_hx,prefix = "mpu_",suffix = "_h1") %>% 
  sum_range_h(lim_sal_h = 17,
              lim_ret_h = 22,
              obs_sal_h = obs_sal_hx,
              obs_ret_h = obs_ret_hx,prefix = "mpu_",suffix = "_h1")
