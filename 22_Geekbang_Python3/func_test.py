# list1 = [1,2,3]
# it = iter(list1)
# print(it)
# print(next(it))
# print(next(it))
# print(next(it))

# def frange(start, stop, step):
#     x = start
#     while x < stop:
#         yield (x)
#         x += step
#
#
# for i in frange(10, 20, 0.5):
#     print(i)
#
#
# def true(): return True
# lambda: True
#
# def add(x,y):return x+y
# lambda x,y: x+y

# filter()
# map()
# reduce()
# zip()

# help(filter)
# a = [1,2,3,4,5,6,7]
# print(list(filter(lambda x:x>2,a)))
# print(list(map(lambda x:x+2,a)))
# b = [4,5,6]
# print(list(map(lambda x,y:x+y,a,b)))

# from functools import reduce
# print(reduce(lambda x,y:x+y,[2,3,4],1))
#
# print(list(zip((1,2,3),(4,5,6))))

# # zip 对字典key和values进行对调
# dicta = {'a':'aa','b':'bb'}
# print(dict(zip(dicta.values(),dicta.keys())))

def func():
    a = 1;b = 2
    return a+b


# 闭包
def sum(a):
    def add(b):
        return a+b
    return add
print(sum(1)(2))
# add 函数名称或函数的引用
# add() 函数的调用


def counter(first = 0):
    cnt=[first]
    def add_one():
        cnt[0]+=1
        return cnt[0]
    return add_one
counter()

time_counter = counter()
print('`````````````````````')
print(time_counter())
print(time_counter())
print(time_counter())
print(time_counter())
print(time_counter())
print(time_counter())
print(time_counter())

time_counter = counter(2)
print('`````````````````````')
print(time_counter())
print(time_counter())
print(time_counter())
print(time_counter())
print(time_counter())
print(time_counter())
print(time_counter())

# 闭包使用
# a * x+b = y

def a_line(a,b):
    def arg_y(x):
        return a*x+b
    return arg_y

line1 = a_line(3,5)
print(line1(3))

# 装饰器
import time
print(time.time())

def timer(func):
    def wrapper():
        start_time = time.time()
        func()
        stop_time = time.time()
        print(stop_time - start_time)
    return wrapper

@timer
def i_can_sleep():
    time.sleep(3)

# start_time = time.time()
i_can_sleep()
# stop_time = time.time()
# print(stop_time -start_time)

def new_tips(argv):
    def tips(func):
        def nei(a,b):
            print('start %s %s' % (argv,func.__name__))
            func(a,b)
            print('stop')
        return nei
    return tips

@new_tips('add tips:')
def add(a,b):
    print(a+b)

add(1,2)

# 上下文管理器
fd = open('name.txt',encoding='UTF-8')
try:
    for line in fd.readlines():
        print(line)
finally:
    fd.close()

with open('name.txt',encoding='UTF-8') as f:
    for line in f:
        print(line)


