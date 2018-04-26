# print(abs)
# f = abs
# print(f)

# def add(a,b,f):
# 	return f(a) + f(b)
# print(add(2,-2,abs))


# def f(x):
# 	return x*x
# r = map(f,[1,2,3,4,5,6,7,8,9])
# print(list(r))
# r = map(str,[1,2,3,4,5,6,7,8,9])
# print(list(r))

# from functools import reduce
# def add(x,y):
# 	return x+y
# L =[1,2,3,4,5,6,7,8,9]
# print(reduce(add,L),sum(L))

# def fn(x,y):
# 	return x*10 + y
# print(reduce(fn,L))

# def char2num(s):
# 	digits = {'0':0,'1':1,'2':2,'3':3,'4':4,'5':5,'6':6,'7':7,'8':8,'9':9}
# 	return digits[s]
# reduce(fn,map(char2num,'123456789'))

# from functools import reduce
# DIGITS = {'0':0,'1':1,'2':2,'3':3,'4':4,'5':5,'6':6,'7':7,'8':8,'9':9}
# def char2num(s):
# 	return DIGITS[s]
# def str2int(s):
# 	return reduce(lambda x,y:x * 10 +y,map(char2num,s))

# print(str2int('2345'))


# def is_odd(n):
# 	return n % 2 == 0
# print(list(filter(is_odd,[1,2,3,5,6,7,9,10,15])))

# def not_empty(s):
# 	return s and s.strip()
# print(list(filter(not_empty,['A','B','',None,'C'])))


# # 无限生成素数
# def _odd_iter():
# 	n = 1
# 	while True:
# 		n+=2
# 		yield n
# def _not_divisible(n):
# 	return lambda x:x%n > 0
# def primes():
# 	yield 2
# 	it = _odd_iter()
# 	while True:
# 		n = next(it)
# 		yield n
# 		it = filter(_not_divisible(n),it)

# for n in primes():
# 	if n<1000:
# 		print(n)
# 	else:
# 		break


# # 判断回文数
# def is_palindrome(n):
# 	s = n[::-1]
# 	return s == n

# output = filter(is_palindrome, range(1, 1000))
# print('1~1000:', list(output))
# if list(filter(is_palindrome, range(1, 200))) == [1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 22, 33, 44, 55, 66, 77, 88, 99, 101, 111, 121, 131, 141, 151, 161, 171, 181, 191]:
#     print('测试成功!')
# else:
#     print('测试失败!')