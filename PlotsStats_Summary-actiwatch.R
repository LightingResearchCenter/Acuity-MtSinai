library(readxl)
library(Rmisc)
library(nlme)

pd <- position_dodge(0.1) # move them .05 to the left and right

ActiwatchAnalyses <- read_excel("//root/projects/Acuity_MtSinai/Analyzed actiwatch data/2018-01-17_1511_ActiwatchAnalyses_with_conditions.xlsx", 
                                                                 sheet = "Sheet1")

ActiwatchAnalyses <- subset(ActiwatchAnalyses, subject != 450)

ActiwatchAnalyses$subject <- as.factor(ActiwatchAnalyses$subject)

ggplot(ActiwatchAnalyses, aes(x=session, y=IV, colour=subject, group=subject, size=nHours)) + 
  geom_line(position=pd, size = .5) +
  geom_point(aes(size = nHours), position=pd) +
  labs(x = "Measurment Session", y = "Intradaily Variability (IV)") +
  facet_grid(.~condition)

ggsave("//root/projects/Acuity_MtSinai/Reports/Figures/IVSubjects.png", dpi = 300, width = 8, height = 5, units = "in")

ggplot(ActiwatchAnalyses, aes(x=session, y=IS, colour=subject, group=subject, size=nHours)) + 
  geom_line(position=pd, size = .5) +
  geom_point(aes(size = nHours), position=pd) +
  labs(x = "Measurment Session", y = "Intradaily Variability (IV)") +
  facet_grid(.~condition)

ggsave("//root/projects/Acuity_MtSinai/Reports/Figures/ISSubjects.png", dpi = 300, width = 8, height = 5, units = "in")

ActiwatchAnalyses2 <- ActiwatchAnalyses %>% group_by(subject) %>% filter(n()>1) 
ActiwatchAnalyses3 <- ActiwatchAnalyses %>% group_by(subject) %>% filter(n()==4) 

#intradaily variability (IV) which quantifies the rhythm fragmentation; 
#interdaily stability (IS) which quantifies the synchronization to the 24-h light-dark cycle; the average activity during the least active 5-h period, or nocturnal activity (L5); and the average activity during the most active 10-h period, or daily activity (M10).

Average_IV_summary_conditions <- summarySE(ActiwatchAnalyses, measurevar = "IV", groupvars = c("condition", "session"))
Average_IV_summary_conditions2 <- summarySE(ActiwatchAnalyses3, measurevar = "IV", groupvars = c("condition", "session"))

t.test(IV ~ condition, data = ActiwatchAnalyses[ActiwatchAnalyses$session == "T3",])


ggplot(Average_IV_summary_conditions, aes(x=session, y=IV, fill = condition)) +
  geom_bar(position=position_dodge(0.9), stat="identity", color="black" ) +
  geom_errorbar(aes(ymin=IV-se, ymax=IV+se), colour =  "black",
                width=.2 , position=position_dodge(.9)) +
  scale_fill_manual(values=c("deepskyblue4", "orange1"))+
  #ggtitle("Average IV") +
  labs(x = " Measurement Session", y ="Mean Intradaily Variability (IV)")+
  geom_text(aes(label = paste("N =", N, sep = " "), vjust=5), position=position_dodge(.9))

ggsave("//root/projects/Acuity_MtSinai/Reports/Figures/IVsum1.png", dpi = 300)


ggplot(Average_IV_summary_conditions2, aes(x=session, y=IV, fill = condition)) +
  geom_bar(position=position_dodge(0.9), stat="identity", color="black" ) +
  geom_errorbar(aes(ymin=IV-se, ymax=IV+se), colour =  "black",
                width=.2 , position=position_dodge(.9)) +
  scale_fill_manual(values=c("deepskyblue4", "orange1"))+
  #ggtitle("Average IV") +
  labs(x = " Measurement Session", y ="Mean Intradaily Variability (IV)")+
  geom_text(aes(label = paste("N =", N, sep = " "), vjust=5), position=position_dodge(.9))

ggsave("//root/projects/Acuity_MtSinai/Reports/Figures/IVsum2.png", dpi = 300)



Average_IS_summary_conditions <- summarySE(ActiwatchAnalyses[!is.na(ActiwatchAnalyses$IS),], measurevar = "IS", groupvars = c("condition", "session"))
Average_IS_summary_conditions2 <- summarySE(ActiwatchAnalyses3[!is.na(ActiwatchAnalyses3$IS) & ActiwatchAnalyses3$subject != 444,], measurevar = "IS", groupvars = c("condition", "session"))

t.test(IS ~ condition, data = ActiwatchAnalyses[ActiwatchAnalyses$session == "T3",])
t.test(IS ~ condition, data = ActiwatchAnalyses3[ActiwatchAnalyses3$session == "T3",])

ggplot(Average_IS_summary_conditions, aes(x=session, y=IS, fill = condition)) +
  geom_bar(position=position_dodge(0.9), stat="identity", color="black" ) +
  geom_errorbar(aes(ymin=IS-se, ymax=IS+se), colour =  "black",
                width=.2 , position=position_dodge(.9)) +
  scale_fill_manual(values=c("deepskyblue4", "orange1"))+
  labs(x = " Measurement Session", y ="Mean Interdaily Stability (IS)")+
  geom_text(aes(label = paste("N =", N, sep = " "), vjust=5), position=position_dodge(.9))

ggsave("//root/projects/Acuity_MtSinai/Reports/Figures/ISsum1.png", dpi = 300)


ggplot(Average_IS_summary_conditions2, aes(x=session, y=IS, fill = condition)) +
  geom_bar(position=position_dodge(0.9), stat="identity", color="black" ) +
  geom_errorbar(aes(ymin=IS-se, ymax=IS+se), colour =  "black",
                width=.2 , position=position_dodge(.9)) +
  scale_fill_manual(values=c("deepskyblue4", "orange1"))+
  labs(x = " Measurement Session", y ="Mean Interdaily Stability (IS)")+
  geom_text(aes(label = paste("N =", N, sep = " "), vjust=5), position=position_dodge(.9))

ggsave("//root/projects/Acuity_MtSinai/Reports/Figures/ISsum2.png", dpi = 300)


library(tidyr)
library(reshape2)
acrophase_data <- ActiwatchAnalyses
acrophase_data$nHours <- NULL
acrophase_data$IS <- NULL
acrophase_data$IV <- NULL

acrophase_data2 <- spread(acrophase_data, key =  "session", value = "acrophase")
acrophase_data2$completed <- !is.na(acrophase_data2$T1) & !is.na(acrophase_data2$T3) & !is.na(acrophase_data2$T4) & !is.na(acrophase_data2$T5)
acrophase_data2$deltaT3 <- as.numeric(difftime(acrophase_data2$T1, acrophase_data2$T3,  units = "mins" ))
acrophase_data2$deltaT4 <- as.numeric(difftime(acrophase_data2$T1, acrophase_data2$T4,  units = "mins" ))
acrophase_data2$deltaT5 <- as.numeric(difftime(acrophase_data2$T1, acrophase_data2$T5,  units = "mins" ))

acrophase_data3.2 <- melt(acrophase_data2, id.vars = c("subject", "condition", "completed"), measure.vars = c( "T1","T3", "T4", "T5"))
acrophase_data3.2_c <- subset(acrophase_data3.2, completed == TRUE)


acrophase_data3 <- melt(acrophase_data2, id.vars = c("subject", "condition", "completed"), measure.vars = c("deltaT3", "deltaT4", "deltaT5"))

acrophase_data3$variable <- as.numeric(substr(acrophase_data3$variable, 7, 7))
acrophase_data3 <- subset(acrophase_data3, !is.na(acrophase_data3$value))

acrophase_data3_c <- subset(acrophase_data3, completed == TRUE)

acrophase_data3_summary <- summarySE(acrophase_data3, measurevar = "value", groupvars = c("condition", "variable"))
acrophase_data3c_summary <- summarySE(acrophase_data3_c, measurevar = "value", groupvars = c("condition", "variable"))



acrophase_data$acrophase <- substr(acrophase_data$acrophase, 12, 20 )
acrophase_data$acrophase <- as.POSIXct(acrophase_data$acrophase, format = "%H:%M:%S")
acrophase_data$subject <- as.factor(acrophase_data$subject)

ggplot(acrophase_data, aes(x=session, y=acrophase, colour=subject, group=subject)) + 
  geom_line(position=pd) +
  geom_point(position=pd, size=3) +
  labs(x = "Measurment Session", y = "Acrophase") +
  #scale_colour_manual(values=c("deepskyblue4", "orange1"))+
  facet_grid(.~condition)
ggsave("//root/projects/Acuity_MtSinai/Reports/Figures/acrophaseSubjects.png", dpi = 300, width = 8, height = 5, units = "in")


## suppose we have a time in seconds since 1960-01-01 00:00:00 GMT
z <- 1472562988
# two ways to convert this
ISOdatetime(1960,1,1,0,0,0) + z # late August 2006
strptime("1960-01-01", "%Y-%m-%d", tz="GMT") + z

acrophase_data3.2_c$acrophase <- as.POSIXct(acrophase_data3.2_c$value, format = "%H:%M:%S")

Average_acrophase_summary_conditions <- summarySE(acrophase_data3.2[!is.na(acrophase_data3.2$value),], measurevar = "value", groupvars = c("condition", "variable"))
Average_acrophase_summary_conditions2 <- summarySE(acrophase_data3.2_c, measurevar = "value", groupvars = c("condition", "variable"))

Average_acrophase_summary_conditions$value <- ISOdatetime(1960,1,1,0,0,0) + Average_acrophase_summary_conditions$value
Average_acrophase_summary_conditions2$value <- ISOdatetime(1960,1,1,0,0,0) + Average_acrophase_summary_conditions2$value

Average_acrophase_summary_conditions$value <- substr(Average_acrophase_summary_conditions$value, 12, 20 )
Average_acrophase_summary_conditions$value <- as.POSIXct(Average_acrophase_summary_conditions$value, format = "%H:%M:%S")


Average_acrophase_summary_conditions2$value <- substr(Average_acrophase_summary_conditions2$value, 12, 20 )
Average_acrophase_summary_conditions2$value <- as.POSIXct(Average_acrophase_summary_conditions2$value, format = "%H:%M:%S")

library(scales)

ggplot(Average_acrophase_summary_conditions, aes(x=variable, y=value, colour=condition, group=condition)) +
  geom_errorbar(aes(ymin=value-se, ymax=value+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3) +
  scale_colour_manual(values=c("deepskyblue4", "orange1"))+
  labs(x = " Measurement Session", y ="Activity Acrophase")
 # geom_text(aes(label = paste("N =", N, sep = " "), vjust=2), position=position_dodge(.9))

ggsave("//root/projects/Acuity_MtSinai/Reports/Figures/acrophaseRaw1.png", dpi = 300)



ggplot(Average_acrophase_summary_conditions2, aes(x=variable, y=value, colour=condition, group=condition)) +
  geom_errorbar(aes(ymin=value-se, ymax=value+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3) +
  scale_colour_manual(values=c("deepskyblue4", "orange1"))+
  labs(x = " Measurement Session", y ="Activity Acrophase")
# geom_text(aes(label = paste("N =", N, sep = " "), vjust=2), position=position_dodge(.9))

ggsave("//root/projects/Acuity_MtSinai/Reports/Figures/acrophaseRaw2.png", dpi = 300)

ggplot(acrophase_data3_summary, aes(x=variable, y=value, colour=condition, group=condition)) + 
  geom_errorbar(aes(ymin=value-se, ymax=value+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3) +
  labs(x = "Measurment Session", y = "Delta") +
  scale_colour_manual(values=c("deepskyblue4", "orange1"))+
  scale_x_continuous(breaks=c(3,4,5), labels=c("T3", "T4", "T5"))

ggsave("//root/projects/Acuity_MtSinai/Reports/Figures/acrophase1.png", dpi = 300)

ggplot(acrophase_data3c_summary, aes(x=variable, y=value, colour=condition, group=condition)) + 
  geom_errorbar(aes(ymin=value-se, ymax=value+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3) +
  labs(x = "Measurment Session", y = "Delta") +
  scale_colour_manual(values=c("deepskyblue4", "orange1"))+
  scale_x_continuous(breaks=c(3,4,5), labels=c("T3", "T4", "T5"))

ggsave("//root/projects/Acuity_MtSinai/Reports/Figures/acrophase1completed.png", dpi = 300)



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




acrophase_data4c_summary <- summarySE(acrophase_data4[acrophase_data4$completed == TRUE,], measurevar = "value", groupvars = c("condition", "variable"))
pd <- position_dodge(0.1) # move them .05 to the left and right

ggplot(acrophase_data4_summary, aes(x=variable, y=value, colour=condition, group=condition)) + 
  geom_errorbar(aes(ymin=value-se, ymax=value+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3) +
  labs(x = "Measurment Session", y = "Absolute Delta" )+
  scale_colour_manual(values=c("deepskyblue4", "orange1")) +
  scale_x_continuous(breaks=c(3,4,5), labels=c("T3", "T4", "T5"))



ggsave("//root/projects/Acuity_MtSinai/Reports/Figures/acrophase2.png", dpi = 300)

ggplot(acrophase_data4c_summary, aes(x=variable, y=value, colour=condition, group=condition)) + 
  geom_errorbar(aes(ymin=value-se, ymax=value+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3) +
  labs(x = "Measurment Session", y = "Absolute Delta" )+
  scale_colour_manual(values=c("deepskyblue4", "orange1")) +
  scale_x_continuous(breaks=c(3,4,5), labels=c("T3", "T4", "T5"))



ggsave("//root/projects/Acuity_MtSinai/Reports/Figures/acrophase2completed.png", dpi = 300)

acrophase_model2 <- lme(value ~ condition*variable , random = ~1|subject/variable,
                        data=acrophase_data4)

anova(acrophase_model2)





acrophase_data2$deltaT3abs <- abs(as.numeric(difftime(acrophase_data2$T1, acrophase_data2$T3,  units = "mins" )))
acrophase_data2$deltaT4abs <- abs(as.numeric(difftime(acrophase_data2$T1, acrophase_data2$T4,  units = "mins" )))
acrophase_data2$deltaT5abs <- abs(as.numeric(difftime(acrophase_data2$T1, acrophase_data2$T5,  units = "mins" )))




t.test(deltaT3abs ~ condition, data = acrophase_data2[!is.na(acrophase_data2$deltaT3abs),])


t.test(deltaT4abs ~ condition, data = acrophase_data2[!is.na(acrophase_data2$deltaT4abs),])

t.test(deltaT5abs ~ condition, data = acrophase_data2[!is.na(acrophase_data2$deltaT5abs),])



