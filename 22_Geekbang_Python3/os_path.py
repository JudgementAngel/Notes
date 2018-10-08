import os

print(os.path.abspath('.'))
print(os.path.abspath('..'))
print(os.path.exists('/Users'))
print(os.path.exists('re_test.py'))
print(os.path.isfile('re_test.py'))
print(os.path.isfile('Test'))
os.path.join('/temp/a/', 'b/c')

import pathlib

p = pathlib.Path('.')
print(p.resolve())
print(p.is_dir())

q = pathlib.Path(r'E:/02_GitHubProjects/Notes/22_Geekbang_Python3/tmp/a/b/c')
pathlib.Path.mkdir(q,parents=True)
# pathlib.Path.rmdir('E:/02_GitHubProjects/Notes/22_Geekbang_Python3/tmp/a/b/c')