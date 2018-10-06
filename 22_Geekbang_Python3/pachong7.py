from bs4 import BeautifulSoup
import requests
import os
import re
import shutil

headers = {
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Language": "zh-CN,zh;q=0.8",
    "Connection": "close",
    "Cookie": "_gauges_unique_hour=1; _gauges_unique_day=1; _gauges_unique_month=1; _gauges_unique_year=1; _gauges_unique=1",
    "Referer": "http://www.infoq.com",
    "Upgrade-Insecure-Requests": "1",
    "User-Agent": "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.98 Safari/537.36 LBBROWSER"
}

url = "https://thehentaiworld.com/hentai-cosplay-images/tracer-widowmaker-zoe-doll-alexa-tomas-overwatch"
url = "11"
reCompile = re.compile(r'-\d+x\d+')

def download_jpg(image_url,image_localpath):
    response = requests.get(image_url,stream =True)
    if response.status_code == 200: # 防止在扒取的过程中，服务器变动导致程序崩溃，不存在则是404
        with open(image_localpath,'wb') as f:
            response.raw.deconde_content = True
            shutil.copyfileobj(response.raw,f) # shutil 配合 response下载，几乎是通用的下载方式

def craw3(url):
    response = requests.get(url,headers=headers)
    soup = BeautifulSoup(response.text,'lxml')
    print( soup.prettify())
    for pic_href in soup.find_all('div',itemtype="http://schema.org/ImageObject"):
        for pic in pic_href.find_all('img'):
            imgurl = pic.get('src')
            imgurl = imgurl.replace(reCompile.search(imgurl).group(), '') # 对字符串进行处理

            dir = os.path.abspath('.')
            filename = os.path.basename(imgurl) # 把前面的地址去掉值保留文件名称
            imgpath = os.path.join(dir,filename)

            print('开始下载 %s' % imgurl)
            download_jpg(imgurl,imgpath)

craw3(url)

