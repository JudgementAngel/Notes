### Remark

**[tangentToWorld]**	

​	Unity 中使用的float4 tangentToWorld[3] 是以该数组的用途来命名的，而非矩阵的含义。实际上如果将这个数组转化为3x3矩阵（忽略最后一列变量，通常用于存放World Pos），这是一个World Space 到 Tangent Space 的变换矩阵。该矩阵是由World Space Tangent 、World Space  Binormal、World Space Normal 三个向量构造的，三个向量两两垂直且均Normalize 处理过。

​	因此该World To Tangent矩阵是一个 平移矩阵 和 旋转矩阵 相乘的结果，所以World To Tangent是一个正交矩阵，正交矩阵的特点是转置矩阵等于逆矩阵，所以使用这个矩阵将切空间的点转换到世界空间时，用它的转置矩阵即可，对于法线也是一样的（同样也是因为这里的矩阵没有缩放，如果是把法线从模型空间变换到世界空间，就需要用ObjectToWorld的转逆矩阵。原因可参考 [3D 变换中法向量变换矩阵的推导 -- 潘李亮]）。

​	用该矩阵的转置矩阵和切空间法线向量相乘正好就是float3（worldTangent * tangentNormal.x ,worldBinormal * tangentNormal.y,worldNormal * tangentNormal.z）;



**[ParallaxMap]**

​	**TODO**

