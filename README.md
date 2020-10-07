# 크롤링 과정

>## 1. 페이지 이동
>
>```R
>library(RSelenium)
>remDr <- remoteDriver(remoteServerAddr = "localhost" , 
>                      port = 4445, browserName = "chrome")
>remDr$open()
>site <- 'https://www.acmicpc.net/problem/tags'
>remDr$navigate(site)
>```
>
>## 2. 태그명과 총 문제수 각각 변수에 저장 후 태그 클릭
>
>```R
>for (n in 1:30) {  # 100문제 이상인 문제가 1번 부터 30번까지
>  pageLink <- NULL
>  algo_title <- NULL
>  problem_num <- NULL
>  answer_percent <- NULL
>
>  #태그로 이동_문제수 100문제이상
>  Sys.sleep(5)
>  pageLink <- remDr$findElements(using='xpath',
>                                 value= paste0('/html/body/div[3]/div[2]/div[5]/div/div/table/tbody/tr[', n, ']/td[1]/a'))
>  #알고리즘 태그명
>  algo_titles <- sapply(pageLink, function(x) {x$getElementText()})
>  print(algo_titles)
>  algo_title <- append(algo_title, unlist(algo_titles))
>  
>  #태그별 문제수
>  algo_node <- remDr$findElements(using='xpath',
>                                 value= paste0('/html/body/div[3]/div[2]/div[5]/div/div/table/tbody/tr[', n, ']/td[3]'))
>  problem_nums <- sapply(algo_node, function(x) {x$getElementText()})
>  print(problem_nums)
>  problem_num <- append(problem_num, unlist(problem_nums))
>  
>  #태그 클릭
>  remDr$executeScript("arguments[0].click();",pageLink)
>```
>
>## 3. for문 안에 페이지별 문제에대한 정답률을 끌어오기 위한 반복문(repeat)사용
>
>```R
>repeat{
>    #정답 비율
>    problem_nodes <- remDr$findElements(using='xpath',
>                                    value= paste0('//*[@id="problemset"]/tbody/tr/td[6]'))
>    answer_percents <- sapply(problem_nodes, function(x) {x$getElementText()})
>    answer_percent <- append(answer_percent, unlist(answer_percents))
>    
>    #다음페이지(다음 버튼이 없는데 다음 페이지의 숫자에 자동으로 #next_page가 붙음..좋은 사이트)
>    #단점은 문제수가 100이 안되는 경우(다음페이지가 없을 경우)에는 비율이 두번 저장됨...
>    pageLink_next <- remDr$findElements(using='css',"#next_page")
>    remDr$executeScript("arguments[0].click();",pageLink_next)
>    Sys.sleep(1)
>    
>    curr_PageElem <- remDr$findElement(using='css', 'div.wrapper > div.container.content > div:nth-child(6) > div:nth-child(2) > div > ul > li.active')
>    curr_PageNewNum <- as.numeric(curr_PageElem$getElementText())
>
>    if(curr_PageNewNum == curr_PageOldNum)  {
>      cat("종료\n")
>      #태그 하나 종료 시 다시 처음 화면으로
>      site <- 'https://www.acmicpc.net/problem/tags'
>      remDr$navigate(site)
>      # csv안에 데이터프레임의 구성은 변경 가능(현재는 문제수, 정답비율 만 보이게함.)
>      df <- data.frame(problem_num, answer_percent, check.rows = FALSE)
>      # 파일명 생성
>      file_name <- paste0(df[n,"algo_title"],".csv")
>      # 저장 경로지정 + 순서 + 파일 이름
>      save_name <- paste0("./BEAKJOON/", n, "_", file_name)
>      # 파일 저장
>      write.csv(df, save_name)
>      break; 
>    }
>    curr_PageOldNum <- curr_PageNewNum;
>  }
>}
>```
>
>```R
>if(curr_PageNewNum == curr_PageOldNum)  {
>      cat("종료\n")
>      #태그 하나 종료 시 다시 처음 화면으로
>      site <- 'https://www.acmicpc.net/problem/tags'
>      remDr$navigate(site)
>      # csv안에 데이터프레임의 구성은 변경 가능(현재는 문제수, 정답비율 만 보이게함.)
>      df <- data.frame(problem_num, answer_percent, check.rows = FALSE)
>      # 파일명 생성
>      file_name <- paste0(df[n,"algo_title"],".csv")
>      # 저장 경로지정 + 순서 + 파일 이름
>      save_name <- paste0("./BEAKJOON/", n, "_", file_name)
>      # 파일 저장
>      write.csv(df, save_name)
>      break; 
>    }
>```
>
>
>
>

