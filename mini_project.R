#정답율의 비율을 처리한다.
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

for(n in 1:src_file_cnt){
  dataset <- read.table(
    paste(src_dir,"/",src_file[n],sep=""),
    sep=",",header=T,stringsAsFactors = F)
  # answer_percent의 %제거, 숫자로 변환
  dataset$answer_percent=as.numeric(gsub("%","",dataset$answer_percent))
  answer_percent <- round(dataset$answer_percent,2)
  head(dataset)
  
  #전체 문제 중 각 정답율이 차지하는 문제 비율을 구한다.
  a = dataset %>% 
    filter(answer_percent >= 90) %>% 
    tally()*100/dataset$problem_num 
  b = dataset %>% 
    filter(answer_percent >= 80 & answer_percent < 90) %>% 
    tally()*100/dataset$problem_num
  c = dataset %>% 
    filter(answer_percent >= 70 & answer_percent < 80) %>% 
    tally()*100/dataset$problem_num
  d = dataset %>% 
    filter(answer_percent >= 60 & answer_percent < 70) %>% 
    tally()*100/dataset$problem_num
  e = dataset %>% 
    filter(answer_percent >= 50 & answer_percent < 60) %>% 
    tally()*100/dataset$problem_num
  f = dataset %>% 
    filter(answer_percent >= 40 & answer_percent < 50) %>% 
    tally()*100/dataset$problem_num
  g = dataset %>% 
    filter(answer_percent >= 30 & answer_percent < 40) %>% 
    tally()*100/dataset$problem_num
  h = dataset %>% 
    filter(answer_percent >= 20 & answer_percent < 30) %>% 
    tally()*100/dataset$problem_num
  i = dataset %>% 
    filter(answer_percent >= 10 & answer_percent < 20) %>% 
    tally()*100/dataset$problem_num
  j = dataset %>% 
    filter(answer_percent >= 0 & answer_percent < 10) %>% 
    tally()*100/dataset$problem_num
  
  #이를 테이블로 만든다.
  tab <- data.frame(tag = c('90~100','80~90','70~80',
                            '60~70','50~60','40~50',
                            '30~40','20~30','10~20',
                            '0~10'),  
                    percent = rbind(round(a,2),round(b,2),round(c,2),
                                    round(d,2),round(e,2),round(f,2),
                                    round(g,2),round(h,2),round(i,2),round(j,2)))
  names(tab) <- c("tag", "percent")
  print(src_file[n])
  print(head(tab))
  
  
  #테이블을 그래프로 그린다.
  baekjoon <- ggplot(tab, aes(x=tag,y=round(percent,2),group=1))+
    geom_point(color="steelblue",stroke=1)+
    geom_line(color="steelblue")+
    geom_label(aes(label=percent), nudge_y=1)+
    labs(x="정답율(%)", y="문제 비율(%)", title=src_file[n])
  print(baekjoon)
}





