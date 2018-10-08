from pandas import Series, DataFrame
import pandas as pd

obj = Series([4, 5, 6, -7])
print(obj)
print(obj.index)
print(obj.values)

obj2 = Series([4, 7, -5, 3], index=['d', 'b', 'c', 'a'])
print(obj2)
obj2['c'] = 6
print(obj2)

print('a' in obj2)
print('q' in obj2)

sdata = {'a': 1, 'b': 2, 'c': 3, 'd': 4}
obj3 = Series(sdata)
print(obj3)
obj3.index = ['bj', 'sh', 'gz', 'sz']
print(obj3)

import numpy as np
data3 = Series(np.random.rand(10), index=[['a','a','a','b','b','b','c','c','d','d'],
                                          [1, 2, 3, 1, 2, 3, 1, 2, 2, 3]])
print(data3)
print(data3['b':'c'])

data3 = data3.unstack()
print(data3)
data3 = data3.stack()
print(data3)

