library(readxl)
library(Rmisc)
library(nlme)
ActiwatchAnalyses <- read_excel("//root/projects/Acuity_MtSinai/Analyzed actiwatch data/2018-01-17_1511_ActiwatchAnalyses_with_conditions.xlsx", 
                                                                 sheet = "Sheet1")

ActiwatchAnalyses <- subset(ActiwatchAnalyses, subject != 450)



Average_IV_summary_conditions <- summarySE(ActiwatchAnalyses, measurevar = "IV", groupvars = c("condition", "session"))

t.test(IV ~ condition, data = ActiwatchAnalyses[ActiwatchAnalyses$session == "T3",])


ggplot(Average_IV_summary_conditions, aes(x=session, y=IV, fill = condition)) +
  geom_bar(position=position_dodge(0.9), stat="identity", color="black" ) +
  geom_errorbar(aes(ymin=IV-se, ymax=IV+se), colour =  "black",
                width=.2 , position=position_dodge(.9)) +
  scale_fill_manual(values=c("deepskyblue4", "orange1"))+
  ggtitle("Average IV") 


Average_IS_summary_conditions <- summarySE(ActiwatchAnalyses[!is.na(ActiwatchAnalyses$IS),], measurevar = "IS", groupvars = c("condition", "session"))

t.test(IS ~ condition, data = ActiwatchAnalyses[ActiwatchAnalyses$session == "T3",])

ggplot(Average_IS_summary_conditions, aes(x=session, y=IS, fill = condition)) +
  geom_bar(position=position_dodge(0.9), stat="identity", color="black" ) +
  geom_errorbar(aes(ymin=IS-se, ymax=IS+se), colour =  "black",
                width=.2 , position=position_dodge(.9)) +
  scale_fill_manual(values=c("deepskyblue4", "orange1"))+
  ggtitle("Average IS") 


library(tidyr)
library(reshape2)
acrophase_data <- ActiwatchAnalyses
acrophase_data$nHours <- NULL
acrophase_data$IS <- NULL
acrophase_data$IV <- NULL

acrophase_data2 <- spread(acrophase_data, key =  "session", value = "acrophase")

acrophase_data2$deltaT3 <- as.numeric(difftime(acrophase_data2$T1, acrophase_data2$T3,  units = "mins" ))
acrophase_data2$deltaT4 <- as.numeric(difftime(acrophase_data2$T1, acrophase_data2$T4,  units = "mins" ))
acrophase_data2$deltaT5 <- as.numeric(difftime(acrophase_data2$T1, acrophase_data2$T5,  units = "mins" ))

acrophase_data3 <- melt(acrophase_data2, id.vars = c("subject", "condition"), measure.vars = c("deltaT3", "deltaT4", "deltaT5"))

acrophase_data3$variable <- as.numeric(substr(acrophase_data3$variable, 7, 7))
acrophase_data3 <- subset(acrophase_data3, !is.na(acrophase_data3$value))

acrophase_data3_summary <- summarySE(acrophase_data3, measurevar = "value", groupvars = c("condition", "variable"))
pd <- position_dodge(0.1) # move them .05 to the left and right

ggplot(acrophase_data3_summary, aes(x=variable, y=value, colour=condition, group=condition)) + 
  geom_errorbar(aes(ymin=value-se, ymax=value+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3) +
  labs(x = "Session number", y = "Delta = T1 - i") +
  scale_colour_manual(values=c("deepskyblue4", "orange1"))


acrophase_model1 <- lme(value ~ condition*variable , random = ~1|subject/variable,
                   data=acrophase_data3)

anova(acrophase_model1)



t.test(deltaT3 ~ condition, data = acrophase_data2[!is.na(acrophase_data2$deltaT3),])


t.test(deltaT4 ~ condition, data = acrophase_data2[!is.na(acrophase_data2$deltaT4),])


t.test(deltaT5 ~ condition, data = acrophase_data2[!is.na(acrophase_data2$deltaT5),])



##Absolute value

acrophase_data4 <- acrophase_data3

acrophase_data4$value <- abs(acrophase_data4$value)

acrophase_data4_summary <- summarySE(acrophase_data4, measurevar = "value", groupvars = c("condition", "variable"))




acrophase_data4_summary <- summarySE(acrophase_data4, measurevar = "value", groupvars = c("condition", "variable"))
pd <- position_dodge(0.1) # move them .05 to the left and right

ggplot(acrophase_data4_summary, aes(x=variable, y=value, colour=condition, group=condition)) + 
  geom_errorbar(aes(ymin=value-se, ymax=value+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3) +
  labs(x = "Session number", y = "Delta = abs(T1 - i)")+
  scale_colour_manual(values=c("deepskyblue4", "orange1"))




acrophase_model2 <- lme(value ~ condition*variable , random = ~1|subject/variable,
                        data=acrophase_data4)

anova(acrophase_model2)





acrophase_data2$deltaT3abs <- abs(as.numeric(difftime(acrophase_data2$T1, acrophase_data2$T3,  units = "mins" )))
acrophase_data2$deltaT4abs <- abs(as.numeric(difftime(acrophase_data2$T1, acrophase_data2$T4,  units = "mins" )))
acrophase_data2$deltaT5abs <- abs(as.numeric(difftime(acrophase_data2$T1, acrophase_data2$T5,  units = "mins" )))




t.test(deltaT3abs ~ condition, data = acrophase_data2[!is.na(acrophase_data2$deltaT3abs),])

t.test(deltaT4abs ~ condition, data = acrophase_data2[!is.na(acrophase_data2$deltaT4abs),])

t.test(deltaT4abs ~ condition, data = acrophase_data2[!is.na(acrophase_data2$deltaT4abs),])

t.test(deltaT5abs ~ condition, data = acrophase_data2[!is.na(acrophase_data2$deltaT5abs),])



