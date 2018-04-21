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


# L = [x*x for x in range(10)]
# g = (x*x for x in range(10))
# print(L)
# print(g,next(g),next(g))
# for n in g:
# 	print(n)

# def fib(max):
# 	n,a,b = 0,0,1
# 	while n<max:
# 		print(b)
# 		a,b = b,a+b
# 		n = n+1
# 	return 'done'
# print(fib(5))

# def fib(max):
# 	n,a,b = 0,0,1
# 	while n<max:
# 		yield b
# 		a,b = b,a+b
# 		n=n+1
# 	return 'done'
# f = fib(6)
# print(f)
# for x in f:
# 	print(x)

# g = fib(6)
# while True:
# 	try:
# 		x = next(g)
# 		print('g:',x)
# 	except StopIteration as e:
# 		print('Generator return value:',e.value)
# 		break

# def triangles():
# 	s = [1]
# 	yield s
# 	s = [1,1]
# 	yield s
	

# 	while True:
# 		t = [s[0]]
# 		for i in range(1,len(s)):
# 			t.append(s[i]+s[i-1])
# 		t.append(s[-1])
# 		s = t
# 		yield s

# n = 0
# results = []
# for t in triangles():
#     print(t)
#     results.append(t)
#     print(results)
#     n = n + 1
#     if n == 10:
#         break

# if results == [
#     [1],
#     [1, 1],
#     [1, 2, 1],
#     [1, 3, 3, 1],
#     [1, 4, 6, 4, 1],
#     [1, 5, 10, 10, 5, 1],
#     [1, 6, 15, 20, 15, 6, 1],
#     [1, 7, 21, 35, 35, 21, 7, 1],
#     [1, 8, 28, 56, 70, 56, 28, 8, 1],
#     [1, 9, 36, 84, 126, 126, 84, 36, 9, 1]
# ]:
#     print('Pass')
# else:
#     print('Fail')


# from collections.abc import Iterable
# print(isinstance([],Iterable))
# print(isinstance((),Iterable))
# print(isinstance({},Iterable))
# print(isinstance('abc',Iterable))
# print(isinstance((x for x in range(10)),Iterable))
# print(isinstance(100,Iterable))

from collections.abc import Iterator
print(isinstance([],Iterator))
print(isinstance((),Iterator))
print(isinstance({},Iterator))
print(isinstance('abc',Iterator))
print(isinstance((x for x in range(10)),Iterator))
print(isinstance(100,Iterator))