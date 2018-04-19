# print('hello')

# name = input() 
# name = input('Please Enter your Name : ')
# print('Hello',name)

#a = 'ABC'
#b = a
#a = 'XYZ'
#print(b)

#print(10/3)
#print(9/3)
#print(10//3)
#print(10%3)

#print('包含中文的str')
#print('\u4e2d\u6587')
#print('ABC'.encode("ascii"))
#print('中文'.encode("utf-8"))
## '中文'.encode('ascii')

#print (b'ABC'.decode('ascii'))
#print(b'\xe4\xb8\xad\xe6\x96\x87'.decode('utf-8'))
#print(b'\xe4\xb8\xad\xff'.decode('utf-8', errors='ignore'))
#print(len('ABC'),len('中文'))
#print(len(b'ABC'))

# print('中文测试正常')
# print("Hi %s ,%d" % ("Marry",1000))
# print("Hello,{0} 的成绩提高了{1}%".format("小明",17.5))

# classmates = ['Marry','B','t']
# print(classmates,len(classmates))
# print(classmates[0],classmates[1],classmates[2],classmates[-1],classmates[-2],classmates[-3])
# classmates.append('A')
# print(classmates)
# classmates.insert(0,'C')
# print(classmates)
# classmates.pop()
# print(classmates)
# classmates.pop(2)
# print(classmates)
# classmates[0] = 'Siri'
# print(classmates)

# L = ['Apple',123,True]
# print(L,len(L))
# L.append(['A','B'])
# print(L,len(L),L[3][1])

# t = (1,2)
# print(t,len(t))
# t = ()
# print(t,len(t))
# t = (1)
# print(t)
# t = (1,)
# print(t,len(t))
# t = ('a','b',['A','B'])
# print(t,len(t))
# t[2][1] = 'C'
# print(t,len(t))

# classmates = ['A','B','C','D']
# for name in classmates :
# 	print(name)
# sum = 0
# for x in [1,2,3,4,5,6,7,8,9,10] :
# 	sum+=x
# print(sum)

# while True:
# 	a = input('A:')
# 	print(a)
# 	if a == 'something':
# 		break;

# d = {'A':12,'B':76,'C':63}
# print(d['A'])
# print('A' in d,'D' in d)
# print(d.get('D'))
# print(d.get('D',-1))
# d.pop('C')
# print(d)


# s = set([1,1,1,1,2,3,4,4,4,4,2,3,1,45,7])
# print(s)
# s.add(1)
# print(s)
# s.remove(4)
# print(s)
# s1 = set([1,2,3])
# s2 = set([2,3,4])
# print(s1,s2,s1|s2)

# a = ['c','d','a','b']
# print(a)
# a.sort()
# print(a)

a = (1,2,3)
d = {'A':12,'B':24,'C':a}
print(d)
d[a] = 1
print(d)
b = (1,2,3,[1,2])
#d[b] = 2
print(d)

e = set([1,23,a])
print(e)
#e.add(b)
print(e)