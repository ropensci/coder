library(dplyr)

# oppen, sluten  - operationskoder (omsparade till läsligt format)
oppen_op  <- haven::read_sav("Z:/SHPR/SZILARD/Beslutstöd/Data/SoS/patientregsiteret/Patient_oppen_op.sav")
sluten_op <- haven::read_sav("Z:/SHPR/SZILARD/Beslutstöd/Data/SoS/patientregsiteret/Patient_sluten_op.sav")
npr_op   <- as.pardata(oppen_op, sluten_op)

# oppen, sluten
load("Z:/SHPR/SZILARD/Beslutstöd/Data/par_data2017_02_09.RData")
npr <- as.pardata(oppen, sluten)

load("Z:/SHPR/SZILARD/Till Erik/frakture_lpnr.RData")

x <-
  lpn %>%
  mutate(
    OppDat = as.Date(trimws(OppDat))
  )


# sida = 1
x1 <- filter(x, Sida == 1)

# KVÅ
x130 <- add("tha_fracture_ae_kva", x1, npr_op, id = "lpnr", date = "OppDat", days = c(0, 30), ind = FALSE)
x190 <- add("tha_fracture_ae_kva", x1, npr_op, id = "lpnr", date = "OppDat", days = c(0, 90), ind = FALSE)
x1180 <- add("tha_fracture_ae_kva", x1, npr_op, id = "lpnr", date = "OppDat", days = c(0, 180), ind = FALSE)

# ICD10
x130icd <- add("tha_fracture_ae_icd10", x1, npr, id = "lpnr", date = "OppDat", days = c(0, 30), ind = FALSE)
x190icd <- add("tha_fracture_ae_icd10", x1, npr, id = "lpnr", date = "OppDat", days = c(0, 90), ind = FALSE)
x1180icd <- add("tha_fracture_ae_icd10", x1, npr, id = "lpnr", date = "OppDat", days = c(0, 180), ind = FALSE)

xsida1 <-
  x130 %>%
    left_join(x190,     by = c("lpnr", "Sida", "OppDat")) %>%
    left_join(x1180,    by = c("lpnr", "Sida", "OppDat")) %>%
    left_join(x130icd,  by = c("lpnr", "Sida", "OppDat")) %>%
    left_join(x190icd,  by = c("lpnr", "Sida", "OppDat")) %>%
    left_join(x1180icd, by = c("lpnr", "Sida", "OppDat"))
names(xsida1) <- c("lpnr", "Sida", "OppDat",
                   paste0("ae_kva", c(30, 90, 180)),
                   paste0("ae_icd10", c(30, 90, 180)))




# sida = 2
x2 <- filter(x, Sida == 2)

# KVÅ
x230 <- add("tha_fracture_ae_kva", x2, npr_op, id = "lpnr", date = "OppDat", days = c(0, 30), ind = FALSE)
x290 <- add("tha_fracture_ae_kva", x2, npr_op, id = "lpnr", date = "OppDat", days = c(0, 90), ind = FALSE)
x2180 <- add("tha_fracture_ae_kva", x2, npr_op, id = "lpnr", date = "OppDat", days = c(0, 180), ind = FALSE)

# ICD10
x230icd <- add("tha_fracture_ae_icd10", x2, npr, id = "lpnr", date = "OppDat", days = c(0, 30), ind = FALSE)
x290icd <- add("tha_fracture_ae_icd10", x2, npr, id = "lpnr", date = "OppDat", days = c(0, 90), ind = FALSE)
x2180icd <- add("tha_fracture_ae_icd10", x2, npr, id = "lpnr", date = "OppDat", days = c(0, 180), ind = FALSE)


xsida2 <-
  x130 %>%
  left_join(x290,     by = c("lpnr", "Sida", "OppDat")) %>%
  left_join(x2180,    by = c("lpnr", "Sida", "OppDat")) %>%
  left_join(x230icd,  by = c("lpnr", "Sida", "OppDat")) %>%
  left_join(x290icd,  by = c("lpnr", "Sida", "OppDat")) %>%
  left_join(x2180icd, by = c("lpnr", "Sida", "OppDat"))
names(xsida2) <- c("lpnr", "Sida", "OppDat",
                   paste0("ae_kva", c(30, 90, 180)),
                   paste0("ae_icd10", c(30, 90, 180)))


# lägg ihop
res <- bind_rows(xsida1, xsida2)
save(res, file = "Z:/SHPR/SZILARD/Till Erik/till_cecilia_2017-02-09.RData")
