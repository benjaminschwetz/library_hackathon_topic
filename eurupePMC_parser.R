#
#
# following the guides on this link
# https://github.com/ropensci/europepmc
#install.packages("europepmc")
library(europepmc)
library(tidyverse)
#installed.packages("data.table")
library(data.table)

###

# example of trendline extraction from Europe PMC API
search_query <- "dermatology"

tt_oa <- europepmc::epmc_hits_trend(search_query, period = 1995:2016, synonym = FALSE)
tt_oa

ggplot(tt_oa, aes(year, query_hits / all_hits)) + 
  geom_point() + 
  geom_line() +
  xlab("Year published") + 
  ylab(paste("Proportion of articles on",search_query ,"in Europe PMC"))


###
# further details on how to use the europePMC package
# https://ropensci.github.io/europepmc/articles/introducing-europepmc.html

# extracting abstracts of Psoriasis papers (for use in word2vec microPoC...)

#parsed <- epmc_search(search_query, limit = 10, output = "parsed") # standaed output is 'parsed' which is a defined tibble
#parsed

#id_list <- epmc_search(search_query, limit = 10, output = "id_list") # returns tibble with ID numbers from publications
#id_list

raw <- epmc_search(search_query, limit = 3000, output = "raw") # 'raw" returns all metadata in list format - needs a bit of wrangling
#raw 

# to access the abstract field ofthe first entry: 
#raw[[1]]$abstractText

# converting a publication-entry (a list element) into a dataframe - each row is seemingly the same, but actually defined by the keywords
# each keyword get a row?
#df1 <- as.data.frame(raw[[1]])

# each pub-entry has different length depending on how many authors -- this has complicated the conversion into dataframes via easy routes
#df2 <- as.data.frame(raw[[2]])



# rbindlist (from the 'data.table' package) seem to solve the issue
raw_df <- (data.table::rbindlist(raw, fill = T))

abs_df <- as.tibble(unique(raw_df$abstractText)) %>%
  glimpse()
# it only takes out 44 abstracts?! - limit is set to 100 in above code
# 524 when limit is 1000?


id_df <- as.tibble((unique(raw_df$pmid))) %>%
  glimpse()
# pmid gets all 1000 entries - the missing abs must be due to NA's and dublications? 
abs_df_na <- as.tibble(raw_df$abstractText) %>%
  glimpse()
sum(is.na(abs_df_na))
# half is NA's -- this explains the results. proceed with extraction of abstracts.



write_csv2(abs_df, "dermatology_3000_abs_df.csv")
dir()

