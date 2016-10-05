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


#f = open("seoul_data2.txt", "r")
f = open("polatics.txt", "r")
f2 = open("polatics_out.txt", "w")

voca = {}

while True:
	line = f.readline()
	if not line: break
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
	if len(k) > 1:
		print k,v
		ret.append(k)
		c += 1 
	if c == 20: break;

hot_topics = ",".join(ret)


print urllib2.urlopen("http://polatics.link:3000/add_hot_topics?hot=" + hot_topics).read()

