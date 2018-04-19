# help(abs)
# print(abs(100),abs(-20),abs(3.14))
# print(max(1,2,6,3))

# print(int('123'),float(123.4),str(1.54))
# print(hex(142))


# from abstest import my_abs
# print(my_abs(-42))
# def nop():
# 	pass
# # print(abs('A'))
# print(my_abs(1))

# import math
# def move(x,y,step,angle = 0):
# 	nx = x + step * math.cos(angle)
# 	ny = y - step *math.sin(angle)
# 	return nx,ny

# x,y = move(100,100,60,math.pi/6)
# print(x,y)

# def power(x,n=2):
# 	s = 1
# 	while n>0:
# 		n = n-1;
# 		s = s*x;
# 	return s
# print(power(5),power(5,3))

# def add_end_old(L=[]):
# 	L.append("End")
# 	return(L)
# def add_end(L=None):
# 	if L is None:
# 		L=[]
# 	L.append("End")
# 	return L	
# print(add_end_old(),add_end(),add_end(),add_end_old())
# print(add_end_old())

# def calc(*numbers):
# 	s = 0
# 	for n in numbers:
# 		s += n*n
# 	return s
# print(calc(1,2,3,4,5))

# def person(name,age,**kw):
# 	print('name:',name,'age:',age,'other:',kw)
# person('A',30)
# person('B',20,city='BB',job='BBB')
# extra = {'city':'CC','job':'CCC'}
# person('C',40,**extra)

# def person(name,age,**kw):
# 	if 'city' in kw:
# 		# have city
# 		pass
# 	if 'job' in kw:
# 		# have job
# 		pass
# 	print('name:',name,'age:',age,'other:',kw)

# def person(name,age,*,city,job):
# 	print('name:',name,'age:',age,'other:',city,job)
# person('A',10,city = 'AA',job='AAA')

# def person(name,age,*args,city,job):
# 	print(name,age,args,city,job)
# person('A',10,1,2,3,4,5,6,city='AA',job='AAA')

# def f1(a,b,c=0,*args,**kw):
# 	print('a=',a,'b=',b,'c=',c,'args=',args,'kw=',kw)
# f1(1,2)
# f1(1,2,3)
# f1(1,2,3,4,5,6,7,8)
# f1(1,2,3,4,5,6,7,8,x=1)
# args = (1,2,3,4)
# kw = {'d':99,'x':'#'}
# f1(*args,**kw)

# def fact(n):
# 	if n==1:
# 		return 1
# 	return n * fact(n-1)
# print(fact(100))

def fact(n):
	return fact_iter(n,1)
def fact_iter(num,product):
	if num == 1:
		return product
	return fact_iter(num - 1,num*product)
print(fact(100))
# print(fact(1000)) python没有做尾递归的优化，同样会导致栈溢出 