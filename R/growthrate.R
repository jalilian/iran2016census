# yearly population growth rate between 2011 and 2016 censuses
# Abdollah Jalilian
# December 28, 2022

# ===============================================
# population data: 2011 (1390) census
ir2011pop <- read.csv("https://github.com/jalilian/iran2016census/raw/main/iran2011census.csv")
# population data: 2016 (1395) census
ir2016pop <- read.csv("https://github.com/jalilian/iran2016census/raw/main/iran2016census.csv")
# ===============================================
library("dplyr")

growthrate <- ir2011pop %>% 
  group_by(province_name, age_group) %>% 
  summarise(male2011=sum(male), 
            female2011=sum(female),
            .groups="keep") %>%
  left_join(ir2016pop %>% group_by(province_name, age_group) %>% 
              summarise(male2016=sum(male), 
                        female2016=sum(female),
                        .groups="keep"),
            by = c("province_name", "age_group")) %>%
  mutate(rate_male=(male2016 - male2011) / male2011 / 5 * 100,
         rate_female=(female2016 - female2011) / female2011 / 5 * 100) %>%
  arrange(province_name,
          factor(age_group, 
                 levels=c("0-4", "5-9", "10-14",
                          "15-19", "20-24", "25-29",
                          "30-34", "35-39", "40-44", 
                          "45-49", "50-54", "55-59",
                          "60-64", "65-69", "70-74",
                          "75-79", "80-84", "85-89",
                          "90-94", "95-99", ">100", 
                          "unknown"))) %>%
  as_tibble()

growthrate %>% 
  print(., n=100)

# save growth rates as a csv file
write.csv(growthrate, "growthrate.csv", row.names = FALSE)
