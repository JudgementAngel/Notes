### Remark

**[tangentToWorld]**	

​	Unity 中使用的float4 tangentToWorld[3] 是以该数组的用途来命名的，而非矩阵的含义。实际上如果将这个数组转化为3x3矩阵（忽略最后一列变量，通常用于存放World Pos），这是一个World Space 到 Tangent Space 的变换矩阵。该矩阵是由World Space Tangent 、World Space  Binormal、World Space Normal 三个向量构造的，三个向量两两垂直且均Normalize 处理过。

​	因此该World To Tangent矩阵是一个 平移矩阵 和 旋转矩阵 相乘的结果，所以World To Tangent是一个正交矩阵，正交矩阵的特点是转置矩阵等于逆矩阵，所以使用这个矩阵将切空间的点转换到世界空间时，用它的转置矩阵即可，对于法线也是一样的（同样也是因为这里的矩阵没有缩放，如果是把法线从模型空间变换到世界空间，就需要用ObjectToWorld的转逆矩阵。原因可参考 [3D 变换中法向量变换矩阵的推导 -- 潘李亮]）。

​	用该矩阵的转置矩阵和切空间法线向量相乘正好就是float3（worldTangent * tangentNormal.x ,worldBinormal * tangentNormal.y,worldNormal * tangentNormal.z）;



**[ParallaxMap]**

​	**TODO**



**[smoothness&oneMinusReflectivity]**

​	smoothness 就是通常所说的 gloss，也就是 1-roughness 。

​	oneMinusReflectivity 是 1 - 反射率。在很多地方(例如：BRDF Fresnel项 的计算)都要使用这个数值，所以提前计算出来可以避免后面重复计算。

​	反射率是物质的一个物理属性，表示在物体表面反射中，反射波与入射波功率的比值。

​	为什么要用 1-x ?以及具体怎么计算？以及为什么要取最大值？

​	**TODO**



**[tangentSpaceNormal]**

​	当使用简单版的Standard Shader时，使用切空间法线，这样的法线直接就是从贴图中采样出来再Unpack 之后的，不用对法线做矩阵变换，是效率比较高的，但是这样就需要从Vertex程序中传入切空间的Light Dir 和 View Dir 。



**[FresnelEquation]**

​	Fresnel Equation 菲涅尔方程 是 Maxwell's equations 麦克斯韦方程组 在折射率不同的两个物质间有一个无限大且绝对光滑的交界面这种情况下的解。 

​	**F0** 指的是 Fresnel 方程在法线和视线夹角 **θ** 为 0 的值。这个值通常是从现实世界中真实数据采集折射率**n**，然后计算获得。

​	Fresnel 应用在渲染中通常使用  schlick的 近似方程，镜面反射系数 **R** ：

​	$R(\theta) = R_0 + (1-R_0)(1-cos \theta)^5$

​	$R_0 = (\frac{n_1-n_2}{n_1+n_2})^2$ 

​	这里的 **R0** 即是 **F0** 。

 

**[SpecularSetup]**

​	Unity 的 SpecularSetup 指的是 PBR 中的 **镜面反射/光泽度工作流程** 。

​	在这一工作流程中，金属的反射率以及金属的 **F0**  

