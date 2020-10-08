    
    # 멀티캠퍼스 빅데이터 분석 서비스개발 미니프로젝트
    # 이동규, 이지혜
    # 백준 사이트를 활용한 올바른 공부방법 제시


# [ 1. 웹 크롤링 ]

library(RSelenium)
remDr <- remoteDriver(remoteServerAddr = "localhost" , 
                      port = 4445, browserName = "chrome")
remDr$open()
site <- 'https://www.acmicpc.net/problem/tags'
remDr$navigate(site)

#작업 디렉토리에 새폴더 생성(csv파일 저장 폴더)
dir.create('BAEKJOON')

for (n in 1:30) {
  pageLink <- NULL
  algo_title <- NULL
  problem_num <- NULL
  answer_percent <- NULL
  
  #태그로 이동_문제수 100문제이상
  Sys.sleep(5)
  pageLink <- remDr$findElements(using='xpath',
                                 value= paste0('/html/body/div[3]/div[2]/div[5]/div/div/table/tbody/tr[', n, ']/td[1]/a'))
  #알고리즘 태그명
  algo_titles <- sapply(pageLink, function(x) {x$getElementText()})
  print(algo_titles)
  algo_title <- append(algo_title, unlist(algo_titles))
  
  #태그별 문제수
  algo_node <- remDr$findElements(using='xpath',
                                  value= paste0('/html/body/div[3]/div[2]/div[5]/div/div/table/tbody/tr[', n, ']/td[3]'))
  problem_nums <- sapply(algo_node, function(x) {x$getElementText()})
  print(problem_nums)
  problem_num <- append(problem_num, unlist(problem_nums))
  
  #태그 클릭
  remDr$executeScript("arguments[0].click();",pageLink)
  
  Sys.sleep(3)
  pageLink_next <- NULL
  curr_PageOldNum <- 0
  
  repeat{
    #정답 비율
    problem_nodes <- remDr$findElements(using='xpath',
                                        value= paste0('//*[@id="problemset"]/tbody/tr/td[6]'))
    answer_percents <- sapply(problem_nodes, function(x) {x$getElementText()})
    answer_percent <- append(answer_percent, unlist(answer_percents))
    
    #다음페이지
    pageLink_next <- remDr$findElements(using='css',"#next_page")
    remDr$executeScript("arguments[0].click();",pageLink_next)
    Sys.sleep(1)
    
    curr_PageElem <- remDr$findElement(using='css', 
                                       'div.wrapper > div.container.content > div:nth-child(6) > div:nth-child(2) > div > ul > li.active')
    curr_PageNewNum <- as.numeric(curr_PageElem$getElementText())
    
    if(curr_PageNewNum == curr_PageOldNum)  {
      cat("종료\n")
      #태그 하나 종료 시 다시 처음 화면으로
      site <- 'https://www.acmicpc.net/problem/tags'
      remDr$navigate(site)
      df <- data.frame(algo_title, problem_num, answer_percent, check.rows = FALSE)
      # 파일명 생성
      file_name <- paste0(df[n,"algo_title"],".csv")
      # 저장 경로지정 + 순서 + 파일 이름
      save_name <- paste0("./BAEKJOON/", n, "_", file_name)
      # 파일 저장
      write.csv(df, save_name)
      break; 
    }
    curr_PageOldNum <- curr_PageNewNum;
  }
}


# [ 2. dplyr 패키지 전처리 및 시각화 ]

library(dplyr)
library(ggplot2)
getwd()
#setwd("C:/mini_project")

rm(list=ls())
src_dir <- c("./BAEKJOON")
src_file <- list.files(src_dir)
src_file_cnt <- length(src_file)
total <- NULL

dir.create('BAEKJOON_graph')
#정답율의 비율을 처리한다.
for(i in 1:src_file_cnt){
  dataset <- read.table(
    paste(src_dir,"/",src_file[i],sep=""),
    sep=",",header=T,stringsAsFactors = F)
  
  # answer_percent의 %제거, 숫자로 변환
  dataset$answer_percent=as.numeric(gsub("%","",dataset$answer_percent))
  answer_percent <- round(dataset$answer_percent,2)
  head(dataset)
  
  # total 테이블을 그래프로 그릴때 사용
  normal = dataset %>% 
    group_by(algo_title) %>% 
    summarise(mean_percent=round(mean(answer_percent),2))
  total<-bind_rows(total,normal)
  
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
  j = dataset %>% 
    filter(answer_percent >= 10 & answer_percent < 20) %>% 
    tally()*100/dataset$problem_num
  k = dataset %>% 
    filter(answer_percent >= 0 & answer_percent < 10) %>% 
    tally()*100/dataset$problem_num
  
  #이를 테이블로 만든다.
  tab <- data.frame(tag = c('90~100','80~90','70~80',
                            '60~70','50~60','40~50',
                            '30~40','20~30','10~20',
                            '0~10'),  
                    percent = rbind(round(a,2),round(b,2),round(c,2),
                                    round(d,2),round(e,2),round(f,2),
                                    round(g,2),round(h,2),round(j,2),round(k,2)))
  names(tab) <- c("tag", "percent")
  print(head(tab))
  
  #테이블을 그래프로 그린다.
  baekjoon <- ggplot(tab, aes(x=tag,y=round(percent,2),group=1))+
    geom_point(color="steelblue",stroke=1)+
    geom_line(color="steelblue")+
    geom_label(aes(label=percent), nudge_y=1)+
    labs(x="정답율(%)", y="문제 비율(%)", title=gsub("[[:digit:][:punct:][:lower:][:upper:]]","",src_file[i]))
  print(baekjoon)
  ggsave(paste0("./BAEKJOON_graph/",gsub("[[:digit:][:punct:][:lower:][:upper:]]","",src_file[i]),".png"))
}

# [ 3. 알고리즘별 평균 정답비율 시각화 ]

# total 테이블을 그래프로 그린다.
avg_level <- ggplot(total, aes(x=algo_title,y=mean_percent,group=1))+
  geom_point(color="steelblue",stroke=1)+
  geom_line(color="steelblue")+
  theme(axis.text.x=element_text(angle=90, hjust=1))+
  labs(x="알고리즘 분류", y="평균 정답율(%)", title="알고리즘 별 평균 정답율")
print(avg_level)
ggsave(paste0("./BAEKJOON_graph/","알고리즘 별 평균 정답율.png"))

bar_color<-rep('#ff4d4d',11)
bar_color<-c(bar_color,rep('orange',9))
bar_color<-c(bar_color,rep('steelblue',10))
bar_color

# total 테이블을 막대 그래프로 그린다.
avg_level <- ggplot(total, aes(mean_percent,reorder(algo_title,mean_percent),
                               fill = reorder(algo_title,mean_percent)))+
  geom_col(width = 0.5)+
  labs(y="알고리즘 분류", x="평균 정답율(%)", title="알고리즘 별 평균 정답율")+
  theme(axis.text.y=element_text(size=6))+
  scale_fill_manual(values = bar_color)+
  theme(legend.position = "none")
print(avg_level)
ggsave(paste0("./BAEKJOON_graph/","알고리즘 별 평균 정답율_막대.png"))


# total 난이도 순으로 표를 그린다.
total <- total[order(-total$mean_percent),]
View(total)
write.csv(total,"./ordered_avg.csv")

