

library(readxl)
T1_Average_CS_summary <- read_excel("//root/projects/Acuity_MtSinai/tables/2018-01-17_1350 Average CS summary.xlsx", 
                                                  sheet = "2018-01-17_1313-T1-person")

T3_Average_CS_summary <- read_excel("//root/projects/Acuity_MtSinai/tables/2018-01-17_1350 Average CS summary.xlsx", 
                                                  sheet = "2018-01-17_1313-T3-person")



T3_bed-Morning_CS <- read_excel("//root/projects/Acuity_MtSinai/tables/2018-01-17_1350 Morning CS.xlsx", 
                                          sheet = "2018-01-17_1313-T3-bed")

T3_fixture_Morning_CS <- read_excel("//root/projects/Acuity_MtSinai/tables/2018-01-17_1350 Morning CS.xlsx", 
                                          sheet = "2018-01-17_1313-T3-fixture")

T3_person-Morning_CS <- read_excel("//root/projects/Acuity_MtSinai/tables/2018-01-17_1350 Morning CS.xlsx", 
                                          sheet = "2018-01-17_1313-T3-person")