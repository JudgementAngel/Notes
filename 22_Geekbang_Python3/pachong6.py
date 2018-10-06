from bs4 import BeautifulSoup
import requests

# 告诉网站我们是一个合法的浏览器
headers = {
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Language": "zh-CN,zh;q=0.8",
    "Connection": "close",
    "Cookie": "_gauges_unique_hour=1; _gauges_unique_day=1; _gauges_unique_month=1; _gauges_unique_year=1; _gauges_unique=1",
    "Referer": "http://www.infoq.com",
    "Upgrade-Insecure-Requests": "1",
    "User-Agent": "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.98 Safari/537.36 LBBROWSER"
}

url = 'http://www.infoq.com/cn/news'

# 获取新闻标题
def craw2(url):

    print(current_thread().getName(), 'start')
    response = requests.get(url,headers = headers)
    soup = BeautifulSoup(response.text,'lxml')

    for title_href in soup.find_all('div',class_='news_type_block'):
        print([title.get('title')
               for title in title_href.find_all('a') if title.get('title')])
    print("-------------------------------------")

import threading
from threading import current_thread


# 翻页
for i in range(15,80,15):

    threadCraw = threading.Thread(target=craw2, args=(url,))
    threadCraw.start()
    url = 'http://www.infoq.com/cn/news' + str(i)