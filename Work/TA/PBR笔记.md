##蛮牛PBR笔记

BRDF 模型可以分为以下几类：

​	经验模型(Empirical Models):使用基于实验提出的公式对BRDF做快速估计。
	数据驱动模型(Data-driven Models):采集真实材质表面在不同光照角度和观察角度将BRDF按照实测数据建立查找表，记录在数据库内，以便于快速的查找和计算。
	基于物理模型(Physical-based Models):根据物体表面材料的几何以及光学属性建立反射方程，从而计算BRDF，实现极具真实感的渲染效果。



BRDF 描述的是 入射光线 在非透明物体表面如何进行反射的。



常见的基于物理的BRDF模型有：
	Cook-Torrance BRDF 模型
	Ward BRDF 模型

Cook-Torrance微面元着色模型(Cook-Torrance microfacet specular shading model)，即 Microfacet Specular BRDF，定义为：

$f(l,v) = \frac {F(l,h)G(l,v,h)D(h)}{4(n \cdot h)(n \cdot v)}$

F 为菲涅耳反射函数 (Fresnel 函数)

G 为阴影遮罩函数 (Geometry Factor 几何因子)，即未被shadow或mask的比例

D 为法线分布函数 (NDF)

​	该光照模型是基于物理材质的光照模型。光照射到物体表面发生漫反射、镜面反射、折射、透射等现象，在这里我们只考虑漫反射和镜面反射，Cook-Torrance是用来模拟不同材质的镜面反射效果。

$r = ambient + \sum_{l}(n \cdot l) \times (k + (1-k) \times r_s)  $

​	其中：

​	ambient : 环境光

​	k：决定高光部分和漫反射部分的比例，一般而言，光符合能量守恒定律，即入射光的总能量 >= 出射光的总能量

​	rs : 镜面反射

$r_s = \frac{F\times D\times G}{\pi (n \cdot l)(n \cdot v)}$ 

#####F项：菲涅耳反射

​	即 Fresnel ，菲涅耳反射。

$F_{\lambda}(u) = f_{\lambda} + (1-f_{\lambda})(1-(h \cdot v))^5$

v：视线方向：顶点指向摄像机

h : 半角向量，normalize(v + l)

##### D项 : 微平面法线分布函数

$D = \frac{1}{\pi m^2 cos^4\alpha } e^{-(\frac{tan \alpha}{m})^2} = \frac{1}{\pi m^2 (n \cdot h)^4}e^{\frac{(n \cdot h)^2 - 1}{m^2(n \cdot h)^2}}$

##### G项：几何项

该项用于计算微平面中反射光重合部分的修正

$G_b = \frac{2(n \cdot h)(n \cdot v)}{v \cdot h}$

$G_c = \frac{2(n \cdot h)(n \cdot l)}{l \cdot h}$

$G = min(1,G_b,G_c)$



Shader Calibration Scene 50 beta.unitypackage 



#####简化版各向异性金属拉丝效果实现

原理： 法线偏移 + 三角函数周期化处理（环形效果）

```

```

