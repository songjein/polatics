# -*- coding:utf8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

import json
import operator 
import urllib2


from konlpy.tag import Kkma
from konlpy.utils import pprint
from konlpy.tag import Twitter

twitter = Twitter()

urllib2.urlopen("http://polatics.news:3000/crawl_chosun").read()
urllib2.urlopen("http://polatics.news:3000/crawl_hani").read()
urllib2.urlopen("http://polatics.news:3000/crawl_jungang").read()
urllib2.urlopen("http://polatics.news:3000/crawl_pressian").read()
urllib2.urlopen("http://polatics.news:3000/crawl_donga").read()

#f = open("seoul_data2.txt", "r")
#f = open("polatics.txt", "r")
# current 500 articles
f = urllib2.urlopen("http://polatics.news:3000/all").read().split('\n')
f.reverse()
f = f[0:400]

for i in f:
	print i 

print "line : %d" %(len(f))
f2 = open("polatics_out.txt", "w")

voca = {}

for line in f:
	for i in twitter.nouns(line):
		if i in voca:
			voca[i] += 1
		else:
			voca[i] = 0
	f2.write(str(twitter.nouns(line)))

#voca = sorted(voca.iteritems(), key=itemgetter(1), reverse=True)
voca =  sorted(voca.items(), key=operator.itemgetter(1), reverse=True) 

c = 0
ret = []
for k,v in voca:
	if len(k) > 1 and k != "단독":
		print k,v
		ret.append(k)
		c += 1 
	if c == 20: break;

hot_topics = ",".join(ret)


print urllib2.urlopen("http://polatics.news:3000/add_hot_topics?hot=" + hot_topics).read()

