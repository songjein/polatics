# -*- coding:utf8 -*-
import tweepy
import os
import sys
import json
import time
import urllib2
import requests

"""
ref. http://kslee7746.tistory.com/entry/python-tweepy-%EC%82%AC%EC%9A%A9%ED%95%9C-%ED%8A%B8%EC%9C%84%ED%84%B0-%ED%81%AC%EB%A1%A4%EB%A7%81crawling

ref. https://proinlab.com/archives/1562

ref. http://kyeoneee.tistory.com/9

"""
reload(sys)
sys.setdefaultencoding('utf-8')

hotTopics = json.loads(urllib2.urlopen("http://polatics.news/get_hot_topics").read())
track_list = [topic["topic"] for topic in hotTopics]

# api 인증 요청
consumer_token = 	""
consumer_secret = ""
auth = tweepy.OAuthHandler(consumer_token, consumer_secret)

# access 토큰 요청
access_token = ""
access_token_secret = ""
auth.set_access_token(access_token, access_token_secret)

f = open("twitter_%s.txt"%(time.strftime("%H-%d-%m-%Y")), "a");
print (time.strftime("%H:%d:%m:%Y"))

# api 생성
api = tweepy.API(auth)

data_len = 0
buf = []
class StreamListener(tweepy.StreamListener):
	def on_data(self, data):
		global data_len
		global track_list 
		global buf
		if data_len == 1000:
			json_results = json.dumps(buf)
			post_data= {'twitter': json_results}
			res = requests.post("http://polatics.news/add_twitter", data=post_data)
			buf = []
			data_len = 0
			print("전송 " + res.text)
			return
		json_data = json.loads(data)
		#print ("=======================================================")
		#print ("핫토픽: " + ",".join([ht for ht in track_list if ht in json.loads(data)["text"]]))
		#print (json.loads(data)["text"])
		#print ("유저아이디: " + json.loads(data)["user"]["name"])
		ret = {}
		ret["created_at"] = json_data["created_at"]
		ret["text"] = json_data["text"]
		ret["name"] = json_data["user"]["name"]
		ret["screen_name"] = json_data["user"]["screen_name"]
		ret["topic"] = [ht for ht in track_list if ht in json.loads(data)["text"]]

		if len(ret["topic"]) > 0:
			buf.append(ret)
		
		f.write(data.encode("utf-8"))
		data_len = data_len + 1

	def on_error(self, status_code):
		if status_code == 420: 
			return False

location = "%s,%s,%s" % ("35.95", "128.25", "1000km")  # 대한민국 중심 좌표, 반지름  

if __name__ == "__main__":
	strmr = StreamListener()
	strmr = tweepy.Stream(auth=api.auth, listener=strmr)
	strmr.filter(track=track_list)

"""
keyword = "박근혜 OR 문재인"  # 검색어

wfile = open(os.getcwd()+"/twitter.txt", mode='w')

cursor = tweepy.Cursor(api.search, 
                       q=keyword,
                       since='2017-10-01', # 2015-01-01 이후에 작성된 트윗들로 가져옴
                       count=100,  # 페이지당 반환할 트위터 수 최대 100
                       geocode=location,
                       include_entities=True)

for i, tweet in enumerate(cursor.items()):
    print("{}: {}".format(i, tweet.text))
    wfile.write(tweet.text + '\n')
wfile.close()
"""

