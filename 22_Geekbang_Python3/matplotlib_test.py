import matplotlib.pyplot as plt
import warnings
warnings.filterwarnings("ignore")
# # 绘制简单的曲线
# plt.plot([1,3,5],[4,8,10])
# plt.show()

import numpy as np

# x = np.linspace(-np.pi, np.pi, 100)  # x轴的定义域为 -3.14~3.14，中间间隔100个元素
# plt.plot(x, np.sin(x))
# plt.show()

# x = np.linspace(-np.pi * 2, np.pi * 2, 100)  # x轴的定义域为 -3.14~3.14，中间间隔100个元素
# plt.figure(1,dpi = 50)
# for i in range(1,5):
#     plt.plot(x, np.sin(x/i))
# plt.show()

# plt.figure(1, dpi=50)
# data = [1, 1, 1, 2, 2, 2, 3, 3, 4, 5, 5, 6, 4]
# plt.hist(data)
# plt.show()

# x = np.arange(1,10)
# y = x
# fig = plt.figure()
# plt.scatter(x,y,c = 'r',marker = 'o') # c = 'r'表示散点的颜色为红色，marker表示指定散点的形状为圆形
# plt.show()

import pandas as pd

# iris = pd.read_csv("./iris_test.csv")
# print(iris.head())
#
# # 绘制散点图
# iris.plot(kind="scatter",x="SepalLength",y ="SpealWidth")
# plt.show()

import seaborn as sns

# iris = pd.read_csv("./iris_test.csv")
# # 设置样式
# sns.set(style="white", color_codes=True)
# # 设置绘制格式为散点图
# sns.jointplot(x="SepalLength", y="SpealWidth", data=iris, size=5)
# # displot 绘制曲线
# sns.distplot(iris["SepalLength"])
# plt.show()


iris = pd.read_csv("./iris_test.csv")
# 设置样式
sns.set(style="white", color_codes=True)
# 设置绘制格式为散点图
# sns.jointplot(x="SepalLength", y="SpealWidth", data=iris, size=5)
sns.FacetGrid(iris,hue="Species",size=5).map(plt.scatter,"SepalLength","SpealWidth").add_legend()
# displot 绘制曲线
# sns.distplot(iris["SepalLength"])
plt.show()