
# Iran unemplyment data
# 1395 (2016) population and housing census
# source: Statistical Center of Iran https://amar.org.ir/
# data link
# https://www.amar.org.ir/%D8%B3%D8%B1%D8%B4%D9%85%D8%A7%D8%B1%DB%8C-%D8%B9%D9%85%D9%88%D9%85%DB%8C-%D9%86%D9%81%D9%88%D8%B3-%D9%88-%D9%85%D8%B3%DA%A9%D9%86/%D9%86%D8%AA%D8%A7%DB%8C%D8%AC-%D8%B3%D8%B1%D8%B4%D9%85%D8%A7%D8%B1%DB%8C/%D9%86%D8%AA%D8%A7%DB%8C%D8%AC-%D8%AA%D9%81%D8%B5%DB%8C%D9%84%DB%8C-%D8%B3%D8%B1%D8%B4%D9%85%D8%A7%D8%B1%DB%8C-1395-%D8%B4%D9%87%D8%B1%D8%B3%D8%AA%D8%A7%D9%86/%D8%AC%D8%AF%D9%88%D9%84-1-%D8%AC%D9%85%D8%B9%D9%8A%D8%AA
# Abdollah Jalilian
# January 18, 2023
# ===============================================
# unemployment by county, gender and education
# ===============================================

library("dplyr")
library("tidyr")
library("readxl")
library("stringr")

# unzip ISC Excel files
exdir <- "unemp2016census/"
unzip("./SCIdata/unemployment2016census.zip", exdir=exdir)

unempdata <- NULL

for (fi in list.files(exdir))
{
  path <- paste0(exdir, fi)
  cat("reading ", path, "\n")
  
  sht <- excel_sheets(path)
  ccode <- str_extract(sht, pattern="[0-9]+")
  cname <- str_extract(sht, pattern="[^0-9]+")
  
  for (i in 1:length(sht))
  {
    ud <- read_excel(path, sheet=sht[i], 
                     range=ifelse(i == 1, "E14:M22", "E13:M21"), 
                     col_names = FALSE) %>%
      slice(c(1, 3, 7, 9)) %>% 
      select(-4) %>% 
      rename("Elementary school"="...1", 
             "Middle school"="...2", 
             "High school"="...3", 
             "College"="...5", 
             "Higher education"="...6", 
             "Other education"="...7", 
             "Illitrate"="...8",
             "Unknown"="...9") %>%
      mutate(county_name=cname[i], 
             county_code=ccode[i],
             gender=rep(c("Male", "Female"), each=2),
             status=rep(c("Active", "Unemployed"), 2)) %>%
      relocate(9:12, .before=`Elementary school`)
    unempdata <- bind_rows(unempdata, ud)
  }
}

unempdata <- unempdata %>% 
  # replace NA's with zeros
  replace(is.na(.), 0) %>%
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
  relocate(province_code, .before = county_name) %>%
  relocate(province_name, .before = province_code) %>%
  mutate(county_name=
           str_replace_all(county_name, 
                           c("ي"="ی", "ك"="ک", "ئ$"="ی", "ئ "="ی "))) %>% 
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
unempdata %>% count(province_name)
unempdata %>% count(county_name)
unempdata %>% count(county_code)
unempdata %>% count(gender)
unempdata %>% count(status)

unempdata %>% group_by(gender, status) %>% 
  select(-(1:6)) %>% summarise_all(sum) %>% t()

# view data in a spread sheet
View(unempdata)

# save data as a csv file
write.csv(unempdata, "iran2016unemployment.csv", row.names = FALSE)
