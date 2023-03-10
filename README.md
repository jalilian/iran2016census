# Iran population data
Population of Iran according to the 2011 and 2016 National Population and Housing Census
| Census      | Number of Provinces | Number of Counties | Population
| ----------- | ----------- | ----------- | ----------- |
| 2016        | 31          | 429         | **79926270** <br/> 40498442 male <br/> 39427828 female
| 2011        | 31          | 397         | **75149669** <br/> 37905669 male <br/> 37244000 female

 Population data are given by 
  - first (province) and second (county) level administrative divisions, 
  - gender (male and female) and 
  - age group (five-year age groups)
  
Source: [Statistical Centre of Iran](https://www.amar.org.ir/english)

## Getting the data
Download the [iran2016census.csv](https://github.com/jalilian/iran2016census/raw/main/iran2016census.csv) file or read it directly in `R` with
```
ir2016pop <- read.csv("https://github.com/jalilian/iran2016census/raw/main/iran2016census.csv")
by(ir2016pop$female, ir2016pop$age_group, sum)
```
Download the [iran2011census.csv](https://github.com/jalilian/iran2016census/raw/main/iran2011census.csv) file or read it directly in `R` with
```
ir2011pop <- read.csv("https://github.com/jalilian/iran2016census/raw/main/iran2011census.csv")
```

## Data on maps
Download the [iran2016census.rds](https://github.com/jalilian/iran2016census/raw/main/iran2016census.rds) file or read it directly in `R` with
```
library("sf")
ir2016sf <- readRDS(url("https://github.com/jalilian/iran2016census/raw/main/iran2016census.rds", "rb"))
library("ggplot2")
ggplot(ir2016sf) + geom_sf(aes(fill=`male_10-14`))
```
![iran counties](shapefile/irancounties.png)

A shapefile (.shp) file is also available in the `shapefile` directory.
