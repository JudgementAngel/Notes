zodiac_name = (u'摩羯座', u'水瓶座', u'双鱼座', u'白羊座', u'金牛座', u'双子座',
               u'巨蟹座', u'狮子座', u'处女座', u'天秤座', u'天蝎座', u'射手座')
zodiac_days = ((1, 20), (2, 19), (3, 21), (4, 21), (5, 21), (6, 22),
               (7, 23), (8, 23), (9, 23), (10, 23), (11, 23), (12, 23))
(month, day) = (12, 23)
zodiac_day = filter(lambda x: x <= (month, day), zodiac_days)
zodiac_len = len(list(zodiac_day)) % 12
print(zodiac_name[zodiac_len])


int_year = int(input('请输入年份：'))
int_month = int(input('请输入月份：'))

while int_month > 12 :
    int_month = int(input('输入的月份大于12，请重新输入月份：'))

int_day = int(input('请输入日期：'))


def JudgeDay(d, maxDay):
    while d > maxDay:
        d = int(input('输入的日期大于%s，请重新输入日期：' % (maxDay)))
    return d


while True:
    day31 = (1, 3, 5, 7, 8, 10, 12)
    day30 = (4, 6, 9, 11)
    if int_day in day31:
        int_day = JudgeDay(int_day, 31)
        break
    elif int_day in day30:
        int_day = JudgeDay(int_day, 30)
        break
    else:
        if int_year % 4 == 0:
            int_day = JudgeDay(int_day, 29)
        else:
            int_day = JudgeDay(int_day, 28)
        break

for zd_num in range(len(zodiac_days)):
    if zodiac_days[zd_num] >= (int_month, int_day):
        print(zodiac_name[zd_num])
        break
    elif int_month == 12 and int_day > 23:
        print(zodiac_name[0])
        break
