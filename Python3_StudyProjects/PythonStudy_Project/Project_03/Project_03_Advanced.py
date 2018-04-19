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

# 去掉一个字符串两头的空格
def trim(s):
	isEmpty = True;
	for i in range(len(s)):
		if s[i]!=' ':
			s = s[i:len(s)]
			isEmpty = False
			break
	if isEmpty :
		return ''
	
	for i in list(range(len(s)+2))[1:len(s)+1]:
		if s[-i]!=' ':
			s = s[:len(s)-i+1]
			break
	
	return s

if trim('  hello  ') != 'hello':
    print('测试失败!')
elif trim('  hello') != 'hello':
    print('测试失败!')
elif trim('  hello  ') != 'hello':
    print('测试失败!')
elif trim('  hello  world  ') != 'hello  world':
    print('测试失败!')
elif trim('') != '':
    print('测试失败!')
elif trim('    ') != '':
    print('测试失败!')
else:
    print('测试成功!')