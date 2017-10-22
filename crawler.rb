require 'nokogiri' 
require 'open-uri'
require 'net/http'
require 'json'

# http://wolfapple.tumblr.com/post/30861736496/open-uri-%EC%82%AC%EC%9A%A9%EC%8B%9C-%ED%95%9C%EA%B8%80%EC%9D%B4-%EA%B9%A8%EC%A7%88%EB%95%8C
# 한글 깨질 때


# 조선일보 크롤러
def crawl_chosun
	newsName = "조선일보"
	polarity = false
	base_url  = "http://news.chosun.com"

	c = 0
	results = []

	(1..10).each do |i|
		sleep 1
		# 제목을 담고 있는 페이지 가져오기, 신문마다 규칙 다름
		doc = Nokogiri::HTML(open(base_url + "/svc/list_in/list.html?catid=2&pn=" + i.to_s, 'r:binary').read.encode('utf-8', 'euc-kr'))

		# 제목링크 가져오기, 신문마다 규칙 다름
		links = doc.search(".list_item dt a")

		links.each do |link|
			paper = {}
			# 신문의 제목
			paper[:title] = link.inner_html 
			# 제목을 클릭 했을 때의 주소 (신문마다 다를 수 있음)
			paper[:news_url] = link["href"]
			# 신문 이름 ; 파라미터로 전달된다
			paper[:news_name] = newsName 
			# 날짜가 담겨있는 태그
			news = Nokogiri::HTML(open(link["href"]).read.encode('utf-8', 'euc-kr'))
			date_info  = news.search("#date_text").inner_html.strip.split(" ")
			# 날짜를 가져온다. 신문마다 규칙이 다를 수 있다
			paper[:news_time] = Time.new(date_info[2].split(".")[0].to_i, date_info[2].split(".")[1].to_i, date_info[2].split(".")[2].to_i, date_info[3].split(":")[0], date_info[3].split(":")[1])
			# 신문의 성향 , 파라미터로 전달 된다
			paper[:polarity] = polarity 
			# content = news.search(".par").inner_html
			results.push(paper)
			c += 1
		end
	end
	#print results.to_json
	puts c.to_s + " 개 전송"

	# API call
	uri = URI("http://polatics.news/news")
	res = Net::HTTP.post_form(uri, news: results.to_json, auth: ENV["AUTH"])
	puts "======================================================"
	puts res.body
end

# 한겨례 크롤러
def crawl_hani
	newsName = "한거례"
	polarity = true 
	base_url  = "http://www.hani.co.kr"

	c = 0
	results = []

	(1..10).each do |i|
		sleep 1
		# 제목을 담고 있는 페이지 가져오기, 신문마다 규칙 다름(open 하는 방식도 다름)
		doc = Nokogiri::HTML(open(base_url + "/arti/politics/list" + i.to_s +  ".html"))

		# 제목링크 가져오기, 신문마다 규칙 다름
		links = doc.search(".article-title a")

		links.each_with_index do |link, idx|
			paper = {}
			# 신문의 제목
			paper[:title] = link.inner_html 
			# 제목을 클릭 했을 때의 주소 (신문마다 다를 수 있음)
			paper[:news_url] = base_url + link["href"]
			# 신문 이름 ; 파라미터로 전달된다
			paper[:news_name] = newsName 
			# 날짜가 담겨있는 태그
			dates = doc.search(".date")
			date_info = dates[idx].inner_html.strip.split(" ")
			# 날짜를 가져온다. 신문마다 규칙이 다를 수 있다
			paper[:news_time] = Time.new(date_info[0].split("-")[0].to_i, date_info[0].split("-")[1].to_i, date_info[0].split("-")[2].to_i, date_info[1].split(":")[0], date_info[1].split(":")[1]) 
			# 신문의 성향 , 파라미터로 전달 된다
			paper[:polarity] = polarity 
			# content = news.search(".par").inner_html
			results.push(paper)
			c += 1
		end
	end
	puts c.to_s + " 개 전송"

	# API call
	uri = URI("http://polatics.news/news")
	res = Net::HTTP.post_form(uri, news: results.to_json, auth: ENV["AUTH"])
	puts "======================================================"
	puts res.body
end

# 중앙 크롤러
def crawl_jungang
	newsName = "중앙일보"
	polarity = false 
	base_url  = "http://news.joins.com"

	c = 0
	results = []

	(1..10).each do |i|
		sleep 1
		# 제목을 담고 있는 페이지 가져오기, 신문마다 규칙 다름(open 하는 방식도 다름)
		doc = Nokogiri::HTML(open(base_url + "/politics/assemgov/list/" + i.to_s))

		# 제목링크 가져오기, 신문마다 규칙 다름
		links = doc.search(".headline.mg a")

		links.each_with_index do |link, idx|
			paper = {}
			# 신문의 제목
			paper[:title] = link.inner_html 
			# 제목을 클릭 했을 때의 주소 (신문마다 다를 수 있음)
			paper[:news_url] = base_url + link["href"]
			# 신문 이름 ; 파라미터로 전달된다
			paper[:news_name] = newsName 
			# 날짜가 담겨있는 태그
			dates = doc.search(".byline em:nth-child(2)")
			date_info = dates[idx].inner_html.strip.split(" ")
			# 날짜를 가져온다. 신문마다 규칙이 다를 수 있다
			paper[:news_time] = Time.new(date_info[0].split(".")[0].to_i, date_info[0].split(".")[1].to_i, date_info[0].split(".")[2].to_i, date_info[1].split(":")[0], date_info[1].split(":")[1]) 
			# 신문의 성향 , 파라미터로 전달 된다
			paper[:polarity] = polarity 
			# content = news.search(".par").inner_html
			results.push(paper)
			c += 1
		end
	end
	puts c.to_s + " 개 전송"

	# API call
	uri = URI("http://polatics.news/news")
	res = Net::HTTP.post_form(uri, news: results.to_json, auth: ENV["AUTH"])
	puts "======================================================"
	puts res.body
end

# 프레시안 크롤러
def crawl_pressian
	newsName = "프레시안"
	polarity = true 
	base_url  = "http://www.pressian.com"

	c = 0
	results = []

	(1..10).each do |i|
		sleep 1
		# 제목을 담고 있는 페이지 가져오기, 신문마다 규칙 다름(open 하는 방식도 다름)
		doc = Nokogiri::HTML(open(base_url + "/news/section_list_all.html?sec_no=66&page=" + i.to_s))

		# 제목링크 가져오기, 신문마다 규칙 다름
		links = doc.search("a.tt")

		links.each_with_index do |link, idx|
			paper = {}
			# 신문의 제목
			paper[:title] = link.inner_html 
			# 제목을 클릭 했을 때의 주소 (신문마다 다를 수 있음)
			paper[:news_url] = link["href"]
			# 신문 이름 ; 파라미터로 전달된다
			paper[:news_name] = newsName 
			# 날짜가 담겨있는 태그
			dates = doc.search(".list_data")
			date_info = dates[idx].inner_html.strip.split(" ")
			# 날짜를 가져온다. 신문마다 규칙이 다를 수 있다
			paper[:news_time] = Time.new(date_info[0].split(".")[0].to_i, date_info[0].split(".")[1].to_i, date_info[0].split(".")[2].to_i, date_info[1].split(":")[0], date_info[1].split(":")[1]) 
			# 신문의 성향 , 파라미터로 전달 된다
			paper[:polarity] = polarity 
			# content = news.search(".par").inner_html
			results.push(paper)
			c += 1
		end
	end
	puts c.to_s + " 개 전송"

	# API call
	uri = URI("http://polatics.news/news")
	res = Net::HTTP.post_form(uri, news: results.to_json, auth: ENV["AUTH"])
	puts "======================================================"
	puts res.body
end


def crawl_donga
	# 한겨례 

	base_url  = "http://news.donga.com"

	candidates = [
		"economy", "politics" #...
	]

	c = 0
	donga_i = 1
	ret = ""
	(1..10).each do |i|
		sleep 5 
		if i != 1
			# 동아일보가 독특한 규칙을 가지고 있음, 한페이지마다 16씩 증가
			donga_i +=  16 
		end
		doc = Nokogiri::HTML(open(base_url + "/List/00?p=" + donga_i.to_s + "&ymd=&m=" ))

		links = doc.search(".articleList .title a")
		dates = doc.search(".articleList span")

		links.each_with_index  do |link, idx|
			# 이미 있는 것인지 체크
			if New.where(title: link.inner_html).length == 1
				ret += link.inner_html
				break;
			end

			# 객체 생성
			paper = New.new

			# 제목 및 유알엘 
			paper.title = link.inner_html 
			paper.news_url = link["href"]
			
			# 날짜 계산
			date_info = dates[idx].inner_html.split("[")[1].split("]")[0].split(" ")

			# 신문 이름 및 성향 진보/보수(true/false)
			paper.news_name = "동아일보"
			paper.polarity = false  

			# 날짜 계산
			ymd = date_info[0].split("-")
			time = date_info[1].split(":")
			paper.news_time = Time.new(ymd[0], ymd[1], ymd[2], time[0], time[1]) 

			paper.save
			c += 1
		end
	end

	render text: "success " + c.to_s + " " + ret

end

# execute crawler
crawl_chosun
crawl_hani
crawl_jungang
crawl_pressian

