import re


# import requests
# txt_url = "https://raw.githubusercontent.com/wilsonyin123/geekbangpython/master/timegeekbang.com/sanguo.txt"
#
# r = requests.get(txt_url) # create HTTP response object
#
# with open("sanguo.txt",'wb') as f:
#     f.write(r.content)
#

def find_item(hero):
    name_num = 0
    with open('sanguo.txt', encoding='GB18030') as f:
        data = f.read().replace('\n', '')
        name_num = len(re.findall(hero, data))
        print(name_num)
    return name_num


# 读取人物信息
name_dict = {}
with open('name_sanguo.txt', encoding='UTF-8') as f:
    for line in f:
        names = line.split('|')
        for n in names:
            print(n)
            name_num = find_item(n)
            name_dict[n] = name_num
name_sorted = sorted(name_dict.items(), key=lambda item: item[1], reverse=True)
print(name_sorted[0:10])


# 可变长参数
def fun(first, *other):
    print(1 + len(other))


fun(1, 2, 3, 4, 5, 6)
fun(1)
