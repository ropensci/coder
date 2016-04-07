memory.size(50000)

# Läs in data som har förberetts inför detta steg i processen
# Vi föredrar här att jobba med enbart gemenr i variabelnamnen
load("Z:\\SHPR\\SZILARD\\Beslutstöd\\Data\\data for calculating the Comorb indices_2015-11-03.RData")
names(shpr_operation) <- tolower(names(shpr_operation))
names(oppen)          <- tolower(names(oppen))
names(sluten)         <- tolower(names(sluten))

# Hjälpfunktion för att omforma output från icd_comorbid till data frame
icd2df <- function(x)
  as.data.frame(x) %>%
  mutate(lpnr = rownames(.))

# sammanför data för öppen- och slutenvård samt transformera till
# long format med en rad per icd10-kod
par <-
  bind_rows(oppen = oppen, sluten = sluten, .id = "sjtyp") %>%
  tidyr::gather(id, icd10, hdia, contains("dia"))  %>%
  mutate(indatum = as.Date(indatum, "%Y/%m/%d")) %>%
  filter(icd10 != '')

# Skapa dataframe med en rad per lpnr från shpr_operation samt numeriska 0/1-kolumner
# som indikerar morbiditetsklasser
elixhauser1yr <-
  shpr_operation %>%
  # filter(lpnr == 3) %>%
  slice(1:1000) %>%
  mutate(oppdat = as.Date(oppdat, "%Y/%m/%d")) %>%
  left_join(par, by = "lpnr") %>%
  partition() %>%
    cluster_library("dplyr") %>%
    cluster_library("icd") %>%
    cluster_assign_value("icd2df", icd2df) %>%
    filter(oppdat >= "1999-01-01",
      is.na(indatum) | oppdat - indatum <= 365 * 1,
      is.na(indatum) | oppdat - indatum > 0) %>%
    group_by(opnr) %>%
    do(icd2df(icd_comorbid(., icd10_map_quan_elix, visit_name = "lpnr", icd_name = "icd10"))) %>%
  collect() %>%
  ungroup() %>%
  select(lpnr, opnr, everything(), -PARTITION_ID) %>%
  distinct() %>%
  group_by(lpnr, opnr) %>%
  summarise_each(funs(any)) %>%
  mutate_each(funs(as.numeric)) %>%
  ungroup() %>%
  mutate(index = rowSums(.[, -(1:2)]))



# Spara datasettet för att kunna återanvända
save(elixhauser1yr, file = "data/elixhauser1yr_1st_2016-03-24.RData")
load(file = "data/elixhauser1yr_1st_2016-03-24.RData")
