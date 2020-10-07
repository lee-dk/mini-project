#cmd -> 프로젝트폴더로 이동 
# -> java -Dwebdriver.chrome.driver="chromedriver.exe" -jar selenium-server-standalone-4.0.0-alpha-1.jar -port 4445

library(RSelenium)
remDr <- remoteDriver(remoteServerAddr = "localhost" , port = 4445, browserName = "chrome")
remDr$open()
site <- 'https://www.acmicpc.net/problem/tags'
remDr$navigate(site)

problem_title <- NULL
problem_submit <- NULL
answer_percent <- NULL
  pageLink <- NULL

for (n in 1:30) {
  #태그로 이동_문제수가 100 넘어가는 것들만 1~30번까지지
  Sys.sleep(5)
  pageLink <- remDr$findElements(using='xpath',
                                 value= paste0('/html/body/div[3]/div[2]/div[5]/div/div/table/tbody/tr[', n, ']/td[1]/a'))
  remDr$executeScript("arguments[0].click();",pageLink)
  
  Sys.sleep(1)
  pageLink_next <- NULL
  curr_PageOldNum <- 0
  repeat{
    #문제 제목
    problem_nodes <- remDr$findElements(using='css', '#problemset > tbody > tr > td:nth-child(2)')
    problem_titles <- sapply(problem_nodes, function(x) {x$getElementText()})
    print(problem_titles)
    problem_title <- append(problem_title, unlist(problem_titles))
    
    #제출한 사람
    problem_nodes <- remDr$findElements(using='css', '#problemset > tbody > tr > td:nth-child(5)')
    problem_submits <- sapply(problem_nodes, function(x) {x$getElementText()})
    print(problem_submits)
    problem_submit <- append(problem_submit, unlist(problem_submits))
    
    #정답 비율
    problem_nodes <- remDr$findElements(using='css', '#problemset > tbody > tr > td:nth-child(6)')
    answer_percents <- sapply(problem_nodes, function(x) {x$getElementText()})
    print(answer_percents)
    answer_percent <- append(answer_percent, unlist(answer_percents))
    
    #다음페이지(다음 버튼이 없는데 다음 페이지의 숫자에 자동으로 #next_page가 붙음..좋은 사이트)
    pageLink_next <- remDr$findElements(using='css',"#next_page")
    remDr$executeScript("arguments[0].click();",pageLink_next)
    Sys.sleep(2)
    
    curr_PageElem <- remDr$findElement(using='css', 'div.wrapper > div.container.content > div:nth-child(6) > div:nth-child(2) > div > ul > li.active')
    curr_PageNewNum <- as.numeric(curr_PageElem$getElementText())

    if(curr_PageNewNum == curr_PageOldNum)  {
      cat("종료\n")
      #태그 하나 종료 시 다시 처음 화면으로
      site <- 'https://www.acmicpc.net/problem/tags'
      remDr$navigate(site)
      df <- data.frame(problem_title, problem_submit, answer_percent)
      write.csv(df, 'BEAKJOON.csv', append = T)
      break; 
    }
    curr_PageOldNum <- curr_PageNewNum;
  }
}
View(df)
