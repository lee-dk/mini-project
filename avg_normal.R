library(dplyr)
library(ggplot2)
getwd()
#setwd("/mini_project")

rm(list=ls())
src_dir <- c("D:/R기반_빅데이터처리/Rexam/mini_project/data")
src_dir

src_file <- list.files(src_dir)
src_file

src_file_cnt <- length(src_file)
src_file_cnt

total<-NULL
for(i in 1:src_file_cnt){
  dataset <- read.table(
    paste(src_dir,"/",src_file[i],sep=""),
    sep=",",header=T,stringsAsFactors = F)
  dataset$answer_percent=as.numeric(gsub("%","",dataset$answer_percent))
  head(dataset)
  normal = dataset %>% 
  group_by(algo_title) %>% 
  summarise(mean_percent=round(mean(answer_percent),2))
  total<-bind_rows(total,normal)
}

View(total)

# total 테이블을 그래프로 그린다.
avg_level <- ggplot(total, aes(x=algo_title,y=mean_percent,group=1))+
  geom_point(color="steelblue",stroke=1)+
  geom_line(color="steelblue")+
  theme(axis.text.x=element_text(angle=90, hjust=1))+
  labs(x="알고리즘 분류", y="평균 정답율(%)", title="알고리즘 별 평균 정답율")
print(avg_level)
ggsave("알고리즘 별 평균 정답율.png")


# total 난이도 순으로 표를 그린다.
total <- total[order(-total$mean_percent),]
View(total)
