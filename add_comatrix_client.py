# -*- coding:utf8 -*-
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

import json
import operator 
import urllib2

from konlpy.tag import Komoran

import collections

komoran = Komoran()

allTitle = urllib2.urlopen("http://polatics.news:3000/all").read().split('\n')
allTitle = "\n".join([" ".join(komoran.nouns(t)) for t in allTitle])

vocaAll = allTitle.split()
print (len(vocaAll))

# 길이 1 이하인 것을 제외만 해도, 상당한 노이즈를 제거할 수 있다
vocaAll = [v for v in vocaAll if len(v) > 1]

# result ; list of tuple
# 모든 애들에 대해서 할필요가 전혀 없다.
# 유용하지 못한 관계만 추가될 것 같다
voca_topK = collections.Counter(vocaAll).most_common(300)

vocabulary = []
reverse_index = {}
for i in voca_topK:
	vocabulary.append(i[0])
	reverse_index[i[0]] = len(vocabulary) - 1

#print (reverse_index[u"박근혜"])
#print (vocabulary[reverse_index[u"박근혜"]])

relatedTerms = {}
for k in reverse_index.keys():
	relatedTerms[k] = []
	for t in allTitle.split('\n'):
		if k in t:
			relatedTerms[k] += [word for word in t.split() if len(word) > 1]
	# top 5 for each
	# 자기 자신은 제외시키기 +1 개 가져온 후 [1:]
	relatedTerms[k] = collections.Counter(relatedTerms[k]).most_common(5 + 1)[1:]
	print (k + "---> " + ",".join([t[0] for t in relatedTerms[k]]))
	
""" 
	Result

	박근혜---> 한국당,정부,자유,정치,청와대
	의원---> 한국당,자유,대통령,청탁,국회의원
	위안부---> 합의,재검토,강경,대통령,검증
	비판---> 대통령,홍준표,한국당,대사,사드
	민주당---> 한국당,의원,정당,대표,김명수
	트럼프---> 대통령,정상회담,김정은,문재인,한미

	http://bl.ocks.org/jhb/5955887
	로 그리기
"""

