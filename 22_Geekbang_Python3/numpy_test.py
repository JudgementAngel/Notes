import numpy as np

arr1 = np.array([2, 4])
print(arr1)
print(arr1.dtype)

arr2 = np.array([1.2, 3.4])
print(arr2)
print(arr2.dtype)

print(arr1 + arr2)

print(arr2 * 10)

data = [[1,2,3],[4,5,6]]
arr3 = np.array(data)
print(arr3)
print(arr3.dtype)

print(np.zeros(10))
print(np.zeros((3,5)))
print(np.ones((5,6)))
print(np.empty((2,3,2)))

arr4 = np.arange(10)
# print(arr4)
# print(arr4[5:8])
# arr4[5:8] = 10
# print(arr4[5:8])
# print(arr4)

arr_slice = arr4[5:8].copy()
arr_slice[:] = 15
print(arr4)
print(arr_slice)
