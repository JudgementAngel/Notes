# year = int(input('input year:'))

# try:
#     year = int(input('input year:'))
# except ValueError:
#     print('int Only')

# except (ValueError,KeyError,AttributeError):

# try:
#     print(1 / 0)
# except ZeroDivisionError as e:
#     print('?? %s' % e)

# try:
#     print(1 / 0)
# except Exception as e:  # Exception 捕获所有错误
#     print('?? %s' % e)

# try:
#     raise NameError('Hello Error')  # 自己抛出一个Error
# except Exception as e:  # Exception 捕获所有错误
#     print('?? %s' % e)

try:
    a = open('name1.txt')
except Exception as e:  # Exception 捕获所有错误
    print('?? %s' % e)
finally:  # 总是会执行
    a.close()