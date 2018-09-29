# 正则表达式标准库
import re

p = re.compile('a')
print(p.match('b'))

# . 匹配任意单个字符
# ^ 表示以什么样的数字做开头
# $ 表示以什么样的数字做结尾 例如'jpg$' 表示以jpg 结尾的文件
# * 匹配前面的字符出现零次或多次
# + 匹配前面的字符出现一次或多次
# ? 匹配前面的字符出现零次或一次
# {m} 表示前面的字符出现m次 例如'ca{3}t' 会匹配到 'caaat'
# {m,n} 表示前面的字符出现m-n次 例如'ca{1-3}t' 会匹配到 'cat' 'caat' 'caaat'
# [] 任意一个字符匹配成功都可以 例如'c[abc]t' 会匹配到 'cat' 'cbt' 'cct'
# | 应用于 (a|b) 表示或的功能
# \d 匹配数字，等价于 [0-9]+
# \D 匹配不包含数字
# \s 匹配字符串
# () 分组功能
# ^$ 表示这一行是空行
# .#? 不使用非贪婪模式
# 前面加 r 表示不进行转译

p = re.compile('.{3}')
print(p.match('bat'))


p = re.compile('....-..-..')
p = re.compile(r'(\d+)-(\d+)-(\d+)')
print(p.match('2018-05-10').group(2))
print(p.match('2018-05-10').groups())
year,month,day = p.match('2018-05-10').groups()