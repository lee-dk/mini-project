#cmd -> 프로젝트폴더로 이동 
# -> java -Dwebdriver.chrome.driver="chromedriver.exe" -jar selenium-server-standalone-4.0.0-alpha-1.jar -port 4445

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
      df <- data.frame(problem_num, answer_percent, check.rows = FALSE)
      # 파일명 생성
      file_name <- paste0(df[n,"algo_title"],".csv")
      # 저장 경로지정 + 순서 + 파일 이름
      save_name <- paste0("./BEAKJOON/", n, "_", file_name)
      # 파일 저장
      write.csv(df, save_name)
      break; 
    }
    curr_PageOldNum <- curr_PageNewNum;
  }
}

