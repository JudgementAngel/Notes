# 记录生肖，根据年份判断生肖

chinese_zodiac = '猴鸡狗猪鼠牛虎兔龙蛇马羊'

# year = int(input('请用户输入出生年份：'))
# print(year % 12)
# print(chinese_zodiac[year % 12])

for cz in chinese_zodiac:
    print(cz)

for i in range(13):
    print(i)

for year in range(2000, 2019):
    print('%s年的生肖是 %s' % (year, chinese_zodiac[year % 12]))

import time

num = 5
while True:
    num += 1
    if num == 10:
        continue
    print(num)
    time.sleep(1)
    if num > 20:
        break
