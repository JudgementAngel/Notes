# from urllib import request
#
# url = 'http://www.baidu.com'
# response = request.urlopen(url,timeout=1)
# print( response.read().decode('utf-8'))

from urllib import parse
from urllib import request

data = bytes(parse.urlencode({'word':'hello'}),encoding='utf8')

response = request.urlopen('http://httpbin.org/post',data= data)
print(response.read().decode('utf-8'))

response2 = request.urlopen('http://httpbin.org/get',timeout= 1) # 如果不加timeout 一旦超时，程序就会卡死
print(response2.read())

import urllib
import socket
try:
    response3 = request.urlopen('http://httpbin.org/get', timeout=0.1)
except urllib.error.URLError as e:
    if isinstance(e.reason,socket.timeout):
        print('Time Out~')



