

library(readxl)

###code to find the table files 
ls <- list.files("//root/projects/Acuity_MtSinai/tables")
grep("Average CS summary", ls)
grep("Morning CS", ls)


##Importing porcessed data - Average CS & Morning CS

T1_Average_CS_summary <- read_excel("//root/projects/Acuity_MtSinai/tables/2018-02-26_1502 Average CS summary.xlsx", 
                                    sheet = "2018-02-26_1420-T1-person")

T3_Average_CS_summary <-  read_excel("//root/projects/Acuity_MtSinai/tables/2018-02-26_1502 Average CS summary.xlsx", 
                                     sheet = "2018-02-26_1420-T3-person")


T3_bed_Morning_CS <-read_excel("//root/projects/Acuity_MtSinai/tables/2018-02-26_1502 Morning CS.xlsx", 
                               sheet = "2018-02-26_1420-T3-bed")

T3_fixture_Morning_CS <- read_excel("//root/projects/Acuity_MtSinai/tables/2018-02-26_1502 Morning CS.xlsx", 
                                    sheet = "2018-02-26_1420-T3-fixture")

T3_person_Morning_CS <- read_excel("//root/projects/Acuity_MtSinai/tables/2018-02-26_1502 Morning CS.xlsx", 
                                   sheet = "2018-02-26_1420-T3-person")



##Combining data.frames for Average CS summary

# Adding T1/T3 factor & Changing the subject column name

T1_Average_CS_summary$time <- "T1"
T3_Average_CS_summary$time <- "T3"

colnames(T1_Average_CS_summary)[1] <- "subject"
colnames(T3_Average_CS_summary)[1] <- "subject"


# Binding the data.frames together in new data.frame, remove parent data.frames

Average_CS_summary <- rbind(T1_Average_CS_summary, T3_Average_CS_summary)

rm(T1_Average_CS_summary, T3_Average_CS_summary)



### Summary plots of data

library(ggplot2)
library(Rmisc)
library(plotly)
library(ggsignif)

#Summarize data accross time and condition

Average_CS_summary <- subset(Average_CS_summary, condition != "unknown")
Average_CS_summary_conditions <- summarySE(Average_CS_summary, measurevar = "mean_valid_CS", groupvars = c("condition", "time"))

t.test(mean_valid_CS ~ condition, data = Average_CS_summary[Average_CS_summary$time == "T3",])


ggplot(Average_CS_summary_conditions, aes(x=time, y=mean_valid_CS, fill = condition)) +
  geom_bar(position=position_dodge(0.9), stat="identity", color="black" ) +
  geom_errorbar(aes(ymin=mean_valid_CS-se, ymax=mean_valid_CS+se), colour =  "black",
                width=.2 , position=position_dodge(.9)) +
  scale_fill_manual(values=c("deepskyblue4", "orange1"))+
  labs(x = " Measurement Session", y ="Mean Circadian Stimulus (CS)")  +
  geom_text(aes(label = paste("Mean =", round(mean_valid_CS, digits = 3), sep = " "), vjust=4), position=position_dodge(.9))+
  geom_text(aes(label = paste("SEM =", round(se, digits = 3), sep = " "), vjust=6), position=position_dodge(.9))


ggsave("//root/projects/Acuity_MtSinai/Reports/Figures/fig1-meanCS.png", dpi = 300)





###Morning CS summary

##Bed


T3_bed_Morning_CS <- subset(T3_bed_Morning_CS, condition != "unknown")
T3_bed_Morning_CS_conditions <- summarySE(T3_bed_Morning_CS, measurevar = "morning_CS", groupvars = c("condition"))

T3_bed_Morning_CS_conditions$morning_CS <- as.numeric(T3_bed_Morning_CS_conditions$morning_CS)
T3_bed_Morning_CS_conditions$condition <- as.factor(T3_bed_Morning_CS_conditions$condition)

t.test(morning_CS ~ condition, data = T3_bed_Morning_CS)

ggplot(T3_bed_Morning_CS_conditions, aes(x=condition, y=morning_CS, fill = condition)) +
  geom_bar(position=position_dodge(0.9), stat="identity", color="black" ) +
  geom_errorbar(aes(ymin=morning_CS-se, ymax=morning_CS+se), colour =  "black",
                width=.2 , position=position_dodge(.9)) +
  scale_fill_manual(values=c("deepskyblue4", "orange1"))+
  #ggtitle("T3 bed morning CS") +
  geom_signif(comparisons = list(c("BWL", "DWL")), annotations="****")+
  labs(x = " Measurement Session", y ="Mean Circadian Stimulus (CS)")+
  coord_cartesian(ylim=c(0,.4))+
  geom_text(aes(label = paste("Mean =", round(morning_CS, digits = 3), sep = " "), vjust=3), position=position_dodge(.9))+
  geom_text(aes(label = paste("SEM =", round(se, digits = 3), sep = " "), vjust=5), position=position_dodge(.9))



ggsave("//root/projects/Acuity_MtSinai/Reports/Figures/fig2-mornCSbed.png", dpi = 300)


##Fixture


T3_fixture_Morning_CS <- subset(T3_fixture_Morning_CS, condition != "unknown")
T3_fixture_Morning_CS_conditions <- summarySE(T3_fixture_Morning_CS, measurevar = "morning_CS", groupvars = c("condition"))

t.test(morning_CS ~ condition, data = T3_fixture_Morning_CS)

ggplot(T3_fixture_Morning_CS_conditions, aes(x=condition, y=morning_CS, fill = condition)) +
  geom_bar(position=position_dodge(0.9), stat="identity", color="black" ) +
  geom_errorbar(aes(ymin=morning_CS-se, ymax=morning_CS+se), colour =  "black",
                width=.2 , position=position_dodge(.9)) +
  scale_fill_manual(values=c("deepskyblue4", "orange1"))+
  #ggtitle("T3 fixture morning CS")+
  geom_signif(comparisons = list(c("BWL", "DWL")), annotations="****")+
  labs(x = " Measurement Session", y ="Mean Circadian Stimulus (CS)")+
  coord_cartesian(ylim=c(0,.4))+
  geom_text(aes(label = paste("Mean =", round(morning_CS, digits = 3), sep = " "), vjust=3), position=position_dodge(.9))+
  geom_text(aes(label = paste("SEM =", round(se, digits = 3), sep = " "), vjust=5), position=position_dodge(.9))



ggsave("//root/projects/Acuity_MtSinai/Reports/Figures/fig3-mornCSfix.png", dpi = 300)






##Person


T3_person_Morning_CS <- subset(T3_person_Morning_CS, condition != "unknown")
T3_person_Morning_CS_conditions <- summarySE(T3_person_Morning_CS, measurevar = "morning_CS", groupvars = c("condition"))

t.test(morning_CS ~ condition, data = T3_person_Morning_CS)

ggplot(T3_person_Morning_CS_conditions, aes(x=condition, y=morning_CS, fill = condition)) +
  geom_bar(position=position_dodge(0.9), stat="identity", color="black" ) +
  geom_errorbar(aes(ymin=morning_CS-se, ymax=morning_CS+se), colour =  "black",
                width=.2 , position=position_dodge(.9)) +
  scale_fill_manual(values=c("deepskyblue4", "orange1"))+
  #ggtitle("T3 person morning CS")+
  coord_cartesian(ylim=c(0,.4))+
  geom_signif(comparisons = list(c("BWL", "DWL")), annotations="**")+
  labs(x = " Measurement Session", y ="Mean Circadian Stimulus (CS)")+
  geom_text(aes(label = paste("Mean =", round(morning_CS, digits = 3), sep = " "), vjust=3), position=position_dodge(.9))+
  geom_text(aes(label = paste("SEM =", round(se, digits = 3), sep = " "), vjust=5), position=position_dodge(.9))



ggsave("//root/projects/Acuity_MtSinai/Reports/Figures/fig4-mornCShuman.png", dpi = 300)


