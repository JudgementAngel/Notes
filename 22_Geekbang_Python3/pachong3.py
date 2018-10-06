#get请求
import requests
url = 'http://httpbin.org/get'
data = {'key':'value','abc':'xyz'}
# .get是使用get 方式请求url，字典类型的data不用进行额外处理
response = requests.get(url,data)
print(response.text)

#post请求
url = 'http://httpbin.org/post'
response = requests.post(url,data)
print(response.json())