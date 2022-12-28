# Iran population data
# 1395 (2016) population and housing census
# source: Statistical Center of Iran https://amar.org.ir/
# data link
# https://www.amar.org.ir/%D8%B3%D8%B1%D8%B4%D9%85%D8%A7%D8%B1%DB%8C-%D8%B9%D9%85%D9%88%D9%85%DB%8C-%D9%86%D9%81%D9%88%D8%B3-%D9%88-%D9%85%D8%B3%DA%A9%D9%86/%D9%86%D8%AA%D8%A7%DB%8C%D8%AC-%D8%B3%D8%B1%D8%B4%D9%85%D8%A7%D8%B1%DB%8C/%D9%86%D8%AA%D8%A7%DB%8C%D8%AC-%D8%AA%D9%81%D8%B5%DB%8C%D9%84%DB%8C-%D8%B3%D8%B1%D8%B4%D9%85%D8%A7%D8%B1%DB%8C-1395-%D8%B4%D9%87%D8%B1%D8%B3%D8%AA%D8%A7%D9%86/%D8%AC%D8%AF%D9%88%D9%84-1-%D8%AC%D9%85%D8%B9%D9%8A%D8%AA
# Abdollah Jalilian
# December 25, 2022
# ===============================================
# population by county, age group and gender
# ===============================================

library("dplyr")
library("readxl")
library("stringr")

# unzip ISC Excel files
exdir <- "pop2016census/"
unzip("./SCIdata/population2016census.zip", exdir=exdir)

pdata <- NULL
for (fi in list.files(exdir))
{
  path <- paste0(exdir, fi)
  cat("reading ", path, "\n")
  
  sht <- excel_sheets(path)
  ccode <- str_extract(sht, pattern="[0-9]+")
  cname <- str_extract(sht, pattern="[^0-9]+")
  for (i in 1:length(sht))
  {
    pd <- read_excel(path, sheet=sht[i], 
                     range=ifelse(i == 1, "D8:E128", "D7:E127"), 
                     col_names = FALSE) %>%
      slice(seq(1, 121, 6))
    pd <- pd %>% rename(male="...1", female="...2") %>% 
      tibble::add_column(county_name=cname[i], 
                         county_code=ccode[i],
                         age_group=c("0-4", "5-9", "10-14",
                                     "15-19", "20-24", "25-29",
                                     "30-34", "35-39", "40-44",
                                     "45-49", "50-54", "55-59",
                                     "60-64", "65-69", "70-74",
                                     "75-79", "80-84", "85-89", 
                                     "90-94", "95-99", ">100"))
    
    pdata <- bind_rows(pdata, pd)
  }
}

popdata <- pdata %>% 
  # extract province code from county code
  mutate(province_code=str_extract(county_code, 
                                   pattern="[0-9]{2}")) %>%
  # provide province name based on province code
  mutate(province_name=recode(province_code,
                              "00"="مرکزی",
                              "01"="گیلان",
                              "02"="مازندران",
                              "03"="آذربایجان شرقی",
                              "04"="آذربایجان غربی",
                              "05"="کرمانشاه",
                              "06"="خوزستان",
                              "07"="فارس",
                              "08"="کرمان",
                              "09"="خراسان رضوی",
                              "10"="اصفهان",
                              "11"="سیستان و بلوچستان",
                              "12"="کردستان",
                              "13"="همدان",
                              "14"="چهارمحال و بختیاری",
                              "15"="لرستان",
                              "16"="ایلام",
                              "17"="کهگیلویه و بویراحمد",
                              "18"="بوشهر",
                              "19"="زنجان",
                              "20"="سمنان",
                              "21"="یزد",
                              "22"="هرمزگان",
                              "23"="تهران",
                              "24"="اردبیل",
                              "25"="قم",
                              "26"="قزوین",
                              "27"="گلستان",
                              "28"="خراسان شمالی",
                              "29"="خراسان جنوبی",
                              "30"="البرز"
  )) %>%
  # change columns order
  relocate(province_code, .before = county_name) %>%
  relocate(province_name, .before = province_code) %>%
  relocate(male, female, .after=age_group) %>%
  # replace empty cells (no cases) with zeros
  tidyr::replace_na(list(male=0, female=0)) %>%
  # replace conflicting Arabic characters with their Persian equivalents
  mutate(county_name=
           str_replace_all(county_name, 
                           c("ي"="ی", "ك"="ک", "ئ$"="ی", "ئ "="ی ")))

popdata <- popdata %>% 
  # fix county name spelling
  mutate(county_name=recode(county_name,
                            "طوالش"="تالش",
                            "آران وبیدگل"="آران و بیدگل",
                            "اسلام آبادغرب"="اسلام آباد غرب",
                            "بو یین و میاندشت"="بوئین میاندشت",
                            "تیران وکرون"="تیران و کرون",
                            "حاجی اباد"="حاجی آباد",
                            "رباطکریم"="رباط کریم",
                            "رودبارجنوب"="رودبار جنوب",
                            "شاهین شهرومیمه"="شاهین شهر و میمه",
                            "فریدونشهر"="فریدون شهر",
                            "قیروکارزین"="قیر و کارزین",
                            "مانه وسملقان"="مانه و سملقان",
                            "نایین"="نائین"
  ))

# checking province, county and age group
popdata %>% count(province_code)
popdata %>% count(county_name)
popdata %>% count(county_code)
popdata %>% count(age_group)
popdata %>% summarise(male=sum(male), 
                      female=sum(female))
popdata %>% group_by(age_group) %>% 
  summarise(male=sum(male == 0), 
            female=sum(female == 0)) %>%
  print(., n=50)

# check characters in province and county names
popdata %>% 
  select(province_name) %>% 
  paste(collapse="") %>% 
  strsplit(split="") %>% unlist %>%
  table

popdata %>% 
  select(county_name) %>% 
  paste(collapse="") %>% 
  strsplit(split="") %>% unlist %>%
  table

# view data in a spread sheet
View(popdata)

# save data as a csv file
write.csv(popdata, "iran2016census.csv", row.names = FALSE)
