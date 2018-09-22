# 写入
file1 = open('name.txt','w')
file1.write('Move')
file1.close()

# 增加
file3 = open('name.txt','a')
file3.write('\nJma')
file3.write('\nM')
file3.write('\nJ')
file3.close()

#读取
file2 = open('name.txt','r')
print( file2.readline())
print( file2.read())
file2.close()

file4 = open('name.txt','r')
for line in file4.readlines():
    print(line)
    print('-----')
file4.close()

file6 = open('name.txt','rb')
print(file6.tell())
print(file6.read(1))
# 第一个参数表示 偏移的位置
# 第二个参数 0 表示从文件开头偏移 1 表示从当前位置偏移 2 表示从文件结尾
# 参数为 1 2 时必须用'rb'模式
file6.seek(5,2)
print(file6.tell())
print(file6.read(1))
file6.close()
