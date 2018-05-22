### Remark

**[tangentToWorld]**	

​	Unity 中使用的float4 tangentToWorld[3] 是以该数组的用途来命名的，而非矩阵的含义。实际上如果将这个数组转化为3x3矩阵（忽略最后一列变量，通常用于存放World Pos），这是一个World Space 到 Tangent Space 的变换矩阵。该矩阵是由World Space Tangent 、World Space  Binormal、World Space Normal 三个向量构造的，三个向量两两垂直且均Normalize 处理过。

​	因此该World To Tangent矩阵是一个 平移矩阵 和 旋转矩阵 相乘的结果，所以World To Tangent是一个正交矩阵，正交矩阵的特点是转置矩阵等于逆矩阵，所以使用这个矩阵将切空间的点转换到世界空间时，用它的转置矩阵即可，对于法线也是一样的（同样也是因为这里的矩阵没有缩放，如果是把法线从模型空间变换到世界空间，就需要用ObjectToWorld的转逆矩阵。原因可参考 [3D 变换中法向量变换矩阵的推导 -- 潘李亮]）。

​	用该矩阵的转置矩阵和切空间法线向量相乘正好就是float3（worldTangent * tangentNormal.x ,worldBinormal * tangentNormal.y,worldNormal * tangentNormal.z）;



** [ParallaxMap]**

​	视差贴图是一种用于模拟物体表面凹凸效果的方法，原理是：通过采样一张高度图，对原本贴图采样的UV做偏移，实现在不同角度，某些物体表面被遮挡，增强立体凹凸的效果。

​	具体实现方法是，依据当前位置的高度，UV沿着在切空间归一化后的视线方向的xy平移，越从正上方看，平移得越少，越侧着看，平移得越多。所以用切空间的 xy/z 实现。当前高度对平移量的影响需要做一些调整（一般是缩放和偏移）来适配物体表面。在Unity中的具体实现代码如下（在UnityCG.cginc和UnityStandardUtils.cginc中）：

```C++
// h 是高度图中的数值[0,1]
// height是外部输入的数值，表示缩放的大小[0.005, 0.08]
// viewDir是切空间的实现视向量
half2 ParallaxOffset1Step (half h, half height, half3 viewDir)
{
    h = h * height - height/2.0; // 对高度做映射
    half3 v = normalize(viewDir); // 归一化视向量
    v.z += 0.42; // 对z做偏移保证不会出现特别小的值或者小于等于0的值
    return h * (v.xy / v.z); // 计算UV偏移
}
```

​	参考 ShaderX 3  2.1章 Parallax Mapping



**[smoothness&oneMinusReflectivity]**

​	smoothness 就是通常所说的 gloss，也就是 1-roughness 。

​	oneMinusReflectivity 是 1 - 反射率。这里需要注意的是，非金属的反射率是灰度值金属的反射率应该是一个三维的颜色值，但是为了优化的目的，这里只取金属反射率rgb中的一个分量，取的原则是：SM2.0以下直接去r 分量，SM2.0以上取三个分量中的最大值。

​	在很多地方都要使用这个数值，所以提前计算出来可以避免后面重复计算。

​	反射率是物质的一个物理属性，表示在物体表面反射中，反射波与入射波功率的比值。

​	为什么要用 1-x ?以及具体怎么计算？以及为什么要取最大值？

​	**TODO**



**[tangentSpaceNormal]**

​	当使用简单版的Standard Shader时，使用切空间法线，这样的法线直接就是从贴图中采样出来再Unpack 之后的，不用对法线做矩阵变换，是效率比较高的，但是这样就需要从Vertex程序中传入切空间的Light Dir 和 View Dir 。



**[FresnelEquation]**

​	**Fresnel Equation** 菲涅尔方程 是 **Maxwell's equations** 麦克斯韦方程组 在折射率不同的两个物质间有一个无限大且绝对光滑的交界面这种情况下的解。 

​	**F0** 指的是 Fresnel 方程在法线和视线夹角 **θ** 为 0 的值。这个值通常是从现实世界中真实数据采集折射率**n**，然后计算获得。Fresnel Equation 的值介于 [F0,1]，当视线方向和法线的夹角无限接近90度，Fresnel 的值无限接近于 1。 

​	Fresnel 应用在渲染中通常使用  schlick的 近似方程，镜面反射系数 **R** ：

​	$R(\theta) = R_0 + (1-R_0)(1-cos \theta)^5$

​	$R_0 = (\frac{n_1-n_2}{n_1+n_2})^2$ 

​	这里的 **R0** 即是 **F0** 。对于大多数绝缘体，F0的范围在 0.02 - 0.05 范围之间，而导体的F0在 0.5 - 1.0 之间。F0的反射率是我们在创作纹理时关心的内容，非金属（电介质/绝缘体）有一个灰度值，而金属（导体）会有一个彩色值。

​	大部分非金属的F0数值互相之间的区别并不大。宝石是一个例外，它具有很高的数值。

 

**[SpecularSetup]**

​	Unity 的 SpecularSetup 指的是 PBR 中的 **Specular/Glossines 镜面反射/光泽度工作流程** 。

​	在这一工作流程中，金属的反射率以及非金属的 **F0**  值（即Specular）放在镜面反射贴图中。在镜面反射/光泽度工作流程中，会用到两张 RGB 贴图：一张是漫反射颜色（反照率）而另一张是反射率值（镜面反射）。在镜面反射贴图中，可以直接控制绝缘体材质的F0值。

​	这种工作流有可能会打破能量守恒的原则。

​	Unity 中使用的 _SpecGlossMap 的RGB通道存储 Specular ，Gloss (Smoothness) 可以根据需求存储在 _SpecGlossMap 的 A通道 或者 _MainTex(Albedo) 的A通道 或者 用 _Glossiness 这个变量输入。



**[EnergyConservationBetweenDiffuseAndSpecular]**

​	PBR的原则之一：Energy Conservation 能量守恒，即 出射光的能量 <= 入射光的能量。而使用 Specular / Gloss 因为可以控制非金属的F0值，很容易出现能量不守恒的情况，例如：白色（1.0）的漫反射值与白色（1.0）的镜面反射值相组合，得到的反射/折射光的总量会大于接收到的，结果就会打破能量守恒原则。这意味着，你做出来的贴图可能不会得到正确的渲染结果。

​	Unity为了避免这种情况，因此在这里使用EnergyConservationBetweenDiffuseAndSpecular 函数做处理，保证 albedo + specular <= 1;



**[RoughnessSetup]**

​	Unity 中的 RoughnessSetup 指的是 PBR 中的 **Metallic/Roughness 金属度/粗糙度工作流程** 。

​	在这一个工作流程中，金属的反射率和绝缘体的反射色存在 固有色贴图中。金属性贴图起到类似于蒙版的作用，区分固有色贴图中的金属和绝缘体数据。绝缘体F0值不需要手动输入，由Shader 自动处理。当shader在金属性贴图中识别到黑色时，它将固有色贴图中的相应区域处理为绝缘体，使用4%（0.04）的反射率。4%的值适用于绝大多数常见绝缘体材质。

​	在金属/粗糙度工作流程中，能量守恒法则不可能被打破。漫反射（反射光）以及镜面反射光之间的平衡由金属性贴图控制，这意味着你无法创造出一种漫反射与镜面反射相组合，能够使得反射/折射光比表面初始接收到的更多。这也正是这种工作流被广泛使用的原因。

​	Unity的 RoughnessSetup中， 金属度 存储在 _MetallicGlossMap.r 或者 _Metallic 这个变量中，Roughness 存储在 _SpecGlossMap.r 或者 _Glossiness 变量中。

​	因为RoughnessSetup 是后来2017版本新加入的输入模式，所以为了避免新的变量名出现，所以就用旧的代替了。（因为当变量名相同时，切换Shader，贴图就能直接链接上）



**[OneMinusReflectivityFromMetallic]**

​	从金属度中获取1-反射率的值，这里Unity使用了一个小技巧：

​	$1-reflectivity = 1-lerp(dielectricSpec,1,Metallic)   = lerp(1-dielectricSpec,0,Metallic)$ 

​	$dielectricSpec$ 就是电介质的默认反射率0.04， 然后将 $ 1 - dielectricSpec $  提前存储起来为 $oneMinusDielectricSpec$ ，则：

​	$lerp(1-dielectricSpec,0,Metallic) = oneMinusDielectricSpec - oneMinusDielectricSpec * Metallic$

​	这样拆开运算效率会高一些。



**[MetallicSetup]**

​	Unity中的 MetallicSetup 是，传统的PBR，Metallic/Roughness 金属粗糙度流程的一个变种，Metallic/Glossiness 金属和光泽度工作流，这里 Glossiness = 1 - Roughness ，这里并不推荐这种方法来实现PBR，因为 大部分的软件中都是使用 Metallic /Roughness 和 Specular/Glossiness 两种模式，这样制作的美术资源就能直接用，不用再在PhotoShop 中做处理。

​	金属度存储在 _MetallicGlossMap.r  或 _Metallic 变量中。光泽度 存储在 _MetallicGlossMap.a 或 _MainTex.a 或 _Glossiness 中。