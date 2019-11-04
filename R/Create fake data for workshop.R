library(simstudy)
library(tidyverse)
library(tableone)
library(datapasta)
library(broom)
library(Matching)

# Create fake data
set.seed(31)
comorb <- c("hypertension", "diabetes", "CHF", "dementia")

def_lin <- defData(varname = 'hypertension', dist='binary', formula= '0.3 ') %>%
  defData(varname = 'male', dist='binary', formula= '0.52 ') %>% 
  defData(varname = 'diabetes', dist='binary', formula= '0.1 ') %>% 
  defData(varname = 'dementia', dist='binary', formula= '0.25 ') %>% 
  defData(varname = 'smoking_unobserved', dist='binary', formula = "0.01 + hypertension*0.08 + dementia*0.12 + diabetes*0.07 + male*0.05") %>% 
  defData(varname='intervention', dist= 'binary', formula='0.05+hypertension*0.08 + diabetes*0.08 + dementia*0.07 + smoking_unobserved*0.05 + male*.01') %>% 
  defData(varname='age', dist = "normal", formula = "50 + male*3+ intervention*5 + diabetes*2 + dementia*5 - hypertension*3", variance=10) %>%
  defData(varname= 'outcome', dist='normal', 
          formula='0.1- 0.1*intervention + male*0.03+ hypertension*0.2 + diabetes*0.02 + dementia*0.3 +0.001*age**2 + smoking_unobserved*0.15')

df <- genData(5000, def_lin)

# Save fake data 
saveRDS(df, here::here('data', 'df.rds'))
# Check that the fake data looks useful
crude_lin <- lm(died ~ intervention, data=df)
adj_lin <- lm(died ~ intervention + hypertension, data=df)
tidy(crude_lin)
tidy(adj_lin)
filter(df, is.na(died)) %>%  View()
map_chr(df, ~sum(is.na(.x)))

table_var <- c("age", "hypertension", "diabetes", "dementia", "smoking_unobserved", 'died', "nr_comorb")
median_var <- median_var<- c('age')
factor_var <- c("hypertension", "diabetes","dementia","smoking_unobserved")

table1<- CreateTableOne(table_var, data = df,  strata = "intervention", factorVars = factor_var,
                        testNonNormal = kruskal.test, argsNonNormal = median_var)
table1

crude <- glm(died ~ intervention, data=df, binomial(link = "logit"))
adj <- glm(died ~ intervention +age + hypertension + diabetes + dementia , data=df, binomial(link = "logit"))
adj_smoking <- glm(died ~ intervention +age + hypertension + diabetes + dementia + smoking_unobserved, data=df, binomial(link = "logit"))

tidy(crude, exponentiate = TRUE, conf.int = TRUE)
tidy(adj, exponentiate = TRUE, conf.int = TRUE)
tidy(adj_smoking, exponentiate = TRUE, conf.int = TRUE)


# Run genetic matching using fake data
gen_match <- function(intervention="intervention", data, matching_vars, balance_vars, exact_vars, name, replace=TRUE,...) {
  
  time_start <- Sys.time()
  data_name <- quote(data)
  data2 <- eval(data)
  
  matching_matrix <- data2 %>%
    dplyr::select_at(matching_vars) %>% # in a newer version of dplyr this would be select_at
    data.matrix()
  
  balance_matrix <- data2 %>%
    dplyr::select_at(balance_vars) %>% # in a newer version of dplyr this would be select_at
    data.matrix()
  
  treatment_status <- data2 %>%
    dplyr::select_at(intervention) %>% # in a newer version of dplyr this would be select_at
    data.matrix()
  
  exact_vars2 <- colnames(matching_matrix) %in% exact_vars  # Compute logical indicators in matching 2d-array for variables exactly matched on
  
  list(matching_matrix,balance_matrix,treatment_status,exact_vars2)
  
  gen <- GenMatch(Tr=treatment_status, X=matching_matrix, BalanceMatrix=balance_matrix,
                  exact=exact_vars2, estimand='ATT', M=1, pop.size=100,
                  wait.generations=10, hard.generation.limit=TRUE, max.generations=500,
                  replace=replace, ties=FALSE, weight=NULL, print.level=1, balance=TRUE)    # Carry out genetic matching
  
  mw <- Match(Tr=treatment_status, X=matching_matrix, exact=exact_vars2, Weight.matrix=as.matrix(gen$Weight.matrix),
              estimand="ATT", replace=replace, ties=FALSE, M=1)   # Carry out matching with genetic matching weights
  
  # get matched data
  treated <- data.frame(index=mw$index.treated, weights=mw$weights)
  control <- data.frame(index=mw$index.control, weights=mw$weights)
  
  bind_treated_control <- rbind(control, treated) %>%
    as.data.frame() %>%
    tbl_df()
  
  data2 <-dplyr:: mutate(data, index=row_number())
  
  match_dat<- inner_join(bind_treated_control,data2, by="index") %>%
    tbl_df()
  
  if(length(mw$index.treated)!=mw$orig.treated.nob) warning("Treated individuals being matched to more than 1 person")
  
  time_end <- Sys.time()- time_start
  mw[["spec"]] <- list(data_name,matching_vars=matching_vars, balance_vars=balance_vars, exact_vars=exact_vars, time_run=time_end, nobs=dim(data2))
  mw[["genmatch_weight_matrix"]] <- list(gen$Weight.matrix)
  mw[['matched_df']] <- match_dat
  # saveRDS(mw, file=here::here("data", "matching",'base', paste0(name,".rds" )))
  return(mw)
}

base_match_var <- c("hypertension", "diabetes", "dementia", "smoking_unobserved", "age")
dat_neighbourhood_match_base_exact_none_replacement <- df %>%
  gen_match(data=., matching_vars=base_match_var, exact_var=NULL,
                                                   balance_vars=base_match_var,
                                                   replace=FALSE)

matched_df <- dat_neighbourhood_match_base_exact_none_replacement$matched_df

# Save matched data

saveRDS(matched_df,here::here('data', 'matched_df.rds'))

