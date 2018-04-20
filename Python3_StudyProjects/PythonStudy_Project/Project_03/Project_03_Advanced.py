# L= []
# n = 1
# while n <= 99:
# 	L.append(n)
# 	n+=2
# print(L)

# L = ['A','B','C','D']
# r=[]
# n=3
# print(L)
# print(list(range(n)))
# for i in range(n):
# 	r.append(L[i])
# print(r)
# print(L[0:3],L[:3],L[1:3],L[-2:])

# L = list(range(100))
# print(L)
# print(L[:10])
# print(L[-10:])
# print(L[10:20])
# print(L[10:20:2])
# print(L[10:20:5])
# print((1,2,3,4,5,6,7,8,9)[:3])
# print('ABCDE'[:3])
# print('ABCDE'[::2])

# # 去掉一个字符串两头的空格
# def trim(s):
# 	isEmpty = True;
# 	for i in range(len(s)):
# 		if s[i]!=' ':
# 			s = s[i:len(s)]
# 			isEmpty = False
# 			break
# 	if isEmpty :
# 		return ''
	
# 	for i in list(range(len(s)+2))[1:len(s)+1]:
# 		if s[-i]!=' ':
# 			s = s[:len(s)-i+1]
# 			break
	
# 	return s

# if trim('  hello  ') != 'hello':
#     print('测试失败!')
# elif trim('  hello') != 'hello':
#     print('测试失败!')
# elif trim('  hello  ') != 'hello':
#     print('测试失败!')
# elif trim('  hello  world  ') != 'hello  world':
#     print('测试失败!')
# elif trim('') != '':
#     print('测试失败!')
# elif trim('    ') != '':
#     print('测试失败!')
# else:
#     print('测试成功!')


# d = {'a' :1,'b':2,'c':3}
# for k,v in d.items():
# 	print(k,v)

# from collections.abc import Iterable
# print(isinstance('abc',Iterable))
# print(isinstance([1,2,3],Iterable))
# print(isinstance(123,Iterable))

# for i,value in enumerate(['A','B','C']):
# 	print(i,value)

# def findMinAndMax(L):
# 	if L == None or len(L) == 0:
# 		return (None,None)
# 	maxValue = L[0]
# 	minValue = L[0]
# 	for v in L:
# 		if v > maxValue :
# 			maxValue = v
# 		if v < minValue :
# 			minValue = v
# 	return (minValue,maxValue)


# if findMinAndMax([]) != (None, None):
#     print('测试失败!')
# elif findMinAndMax([7]) != (7, 7):
#     print('测试失败!')
# elif findMinAndMax([7, 1]) != (1, 7):
#     print('测试失败!')
# elif findMinAndMax([7, 1, 3, 9, 5]) != (1, 9):
#     print('测试失败!')
# else:
#     print('测试成功!')

# print(list(range(1,11)))
# print([x*x for x in range(1,11)])
# print([x*x for x in range(1,11) if x%2 == 0])
# print([m+n for m in 'ABC' for n in 'XYZ'])

# import os
# print([d for d in os.listdir('.')])

# d = {'x':'A','y':'B','z':'C'}
# print([k+'='+v for k,v in d.items()])

# L = ['Hello','World','IBM',18,'Apple',None]
# # print([s.lower() for s in L])
# print([s.lower() for s in L if isinstance(s,str) and s != None])


L = [x*x for x in range(10)]
g = (x*x for x in range(10))
print(L)
print(g,next(g),next(g))
for n in g:
	print(n)
