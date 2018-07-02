#Remark

###[RenderingPipline]

####Rendering Paths

https://docs.unity3d.com/Manual/RenderingPaths.html

​	Unity支持多种不同的 Rendering Paths 。你应该根据你的游戏内容以及目标平台/硬件。不同的渲染路径有不同的性能特点，主要是影响灯光和阴影。

​	可以在Graphics Settings 中设置项目的Rendering Path ，也可以针对每个摄像机重写这个参数。

​	如果当前显卡不支持选择的Rendering Path，Unity将会自动使用低一级相似度最接近的那个。例如：如果GPU不支持 Deferred Shading ，则将会使用 Forward Rendering。

##### Deferred Shading

​	"Deferred"

​	延迟着色 是具有最高照明和阴影保真度的渲染路径，如果你有很多实时灯光，则适合用这个渲染路径，但是它需要一定的硬件支持。（大部分的手机和移动平台都不支持）

##### Forward Rendering

​	"LightMode" = "ForwardBase" / "ForwardAdd"

​	前向渲染是传统的渲染路径，它支持Unity图形的典型特性（法线贴图，逐像素光照，阴影等等）。但是，在默认的设置下，只有少量最亮的灯光会逐像素计算。其余的灯光都是在物体顶点或者每个物体计算的。

##### Legacy Deferred

​	"PrepassBase" / "PrepassFinal"

​	Legacy Deferred (逐Pass 光照)是一种轻量的延迟着色。只是使用不同的技术和不同的权衡。它不支持Unity5基于物理的标准的着色器。

#####Legacy Vertex Lit

​	"Vertex"/"VertexLMRGBM"/"VertexLM"

​	Legacy Vertex Lit 是具有最低保真度的渲染路径，并且不支持实时阴影。它是前向渲染的一个子集。

​	由于顶点照明最常用于不可编程着色器的平台，因此Unity无法通过创建多个变种的方式处理光照贴图和无光照贴图的情况。所以，需要明确声明写出多个Pass来处理。

​	Vertex pass 被用来处理无灯光贴图的对象，使用固定功能的OpenGL/Direct3D照明模型（[Blinn-Phong](https://en.wikipedia.org/wiki/Blinn%E2%80%93Phong_shading_model)），所有灯光都会立即渲染。

​	VertexLMRGBM pass 当灯光贴图是RGBM编码（PC和主机）时， 用于光照贴图对象，不能应用实时照明，pass 预期是混合纹理和灯光贴图。

​	VertexLMM pass 当灯光贴图是 double-LDR 编码（移动平台）时，用于光照贴图对象，不能应用实时照明，pass 预期是混合纹理和灯光贴图。

**注：** 使用正交摄像机投影时不支持延迟渲染。如果相机的投影模式设置为“正交”，则这些值将会被覆盖，并且摄像机始终使用“Forward ”渲染。（下面就不介绍Legacy的两种渲染路径了）

除了上面的这些之外，要渲染阴影和深度贴图，需要使用 "ShadowCaster" pass。

#### Rendering Paths Comparison

|                                                              | **Deferred**                                                 | **Forward**                                                  | **Legacy Deferred**                              | **Vertex Lit** |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------ | -------------- |
| **Features 特性**                                            |                                                              |                                                              |                                                  |                |
| Per-pixel lighting (normal maps, light cookies) 逐像素灯光（法线贴图，灯光效果遮罩） | Yes                                                          | Yes                                                          | Yes                                              | -              |
| Realtime shadows 实时阴影                                    | Yes                                                          | With caveats有一些注意事项                                   | Yes                                              | -              |
| Reflection Probes 反射探针                                   | Yes                                                          | Yes                                                          | -                                                | -              |
| Depth&Normals Buffers 深度和法线缓冲                         | Yes                                                          | Additional render passes Add 渲染通道                        | Yes                                              | -              |
| Soft Particles 软粒子                                        | Yes                                                          | -                                                            | Yes                                              | -              |
| Semitransparent objects 半透明物体                           | -                                                            | Yes                                                          | -                                                | Yes            |
| Anti-Aliasing 抗锯齿                                         | -                                                            | Yes                                                          | -                                                | Yes            |
| Light Culling Masks 灯光剔除遮罩                             | Limited 受限的                                               | Yes                                                          | Limited                                          | Yes            |
| Lighting Fidelity 灯光保真度                                 | All per-pixel 所有逐像素的                                   | Some per-pixel 一些逐像素的                                  | All per-pixel                                    | All per-vertex |
| **Performance  性能**                                        |                                                              |                                                              |                                                  |                |
| Cost of a per-pixel Light  每像素的光照消耗                  | Number of pixels it illuminates 它照亮的像素数               | Number of pixels * Number of objects it illuminates 像素数量 * 它照亮的物体数量 | Number of pixels it illuminates 它照亮的像素数量 | -              |
| Number of times objects are normally rendered 物体正常渲染的次数 | 1                                                            | Number of per-pixel lights 逐像素灯光的数量                  | 2                                                | 1              |
| Overhead for simple scenes 简单场景的开销                    | High                                                         | None                                                         | Medium                                           | None           |
| **Platform Support 支持的平台**                              |                                                              |                                                              |                                                  |                |
| PC (Windows/Mac)                                             | Shader Model 3.0+ & MRT                                      | All                                                          | Shader Model 3.0+                                | All            |
| Mobile (iOS/Android)                                         | OpenGL ES 3.0 & MRT, Metal (on devices with A8 or later SoC) | All                                                          | OpenGL ES 2.0                                    | All            |
| Consoles                                                     | XB1, PS4                                                     | All                                                          | XB1, PS4, 360                                    | -              |



####Forward Rendering :

​	https://docs.unity3d.com/Manual/RenderTech-ForwardRendering.html

​	在 Forward Rendering 正向渲染 中根据影响对象的光线渲染每个对象一次或多次。灯光本身也通过正向渲染得到不同的处理，具体取决于它们的设置和强度。

​	在Forward Rendering 中，影响每个对象的某些数目的最亮灯将完全逐像素计算。每个顶点最多计算4个点光源。其他灯光被计算为球面谐波（SH），虽然效率更高，但只是一个近似值。

​	一个灯光无论是否逐像素计算，都依赖下面的条件：

​	*Render Mode 设置为“Not Important” 的灯光始终为顶点光照 或 SH ;*

​	*最亮的方向光始终是逐像素计算的 ;*

​	*Render Mode 设置为 "Important" 的灯光始终为逐像素计算 ;*

​	*如果上面筛选出来的逐像素灯光数量 少于 Quality Setting 里的 “Pixel Light Count” ，则按照灯光亮度降低的顺序逐像素渲染 ;*  

​	渲染每一个对象遵循下面原则：

​	*ForwardBase Pass 计算一个最主要的逐像素灯光和所有的逐顶点计算的光照/SH灯光；*

​	其他的逐像素光照计算在 Additional Pass 中，一个Pass 计算一次灯光。

​	例如：如果某些物体受到多个灯光的影响（下图中的圆圈，受灯光A到H的影响）

​	![](Images\ForwardLightsExample.png)

​	假设A到H具有相同的颜色和强度，并且它们都是设置自动渲染的模式，因此它们的渲染顺序将按照对物体的影响程度排序。最亮的灯光将逐像素计算(A-D)，之后有四个灯光逐顶点计算(D-G)，剩下的灯光将使用 SH 球谐照明(G-H) 。

​	![](Images\ForwardLightsClassify.png)

​	注意：灯光组重叠的情况。例如：最后一个逐像素的光照会和逐顶点的光照模式混合，这样当物体发生移动的时候，就不会出现 “灯光爆裂” 的情况。

##### Base Pass

​	Base Pass 渲染物体，一个最重要的方向光合SH/顶点光照。这个Pass还添加了Shader中用到的所有 lightmaps 灯光贴图、ambient环境光 和 emissive 自发光。在这个过程中方向光可以产生阴影。注意：lightmap static 的物体不会受到SH的全局光照。

​	如果在着色器中使用“Only Directional”的 Pass Flag 时: Tags{"PassFlags" = "OnlyDirectional"} 。 Forward Base Pass 仅渲染主要的方向光，ambient 环境光/lightprobe 灯光探针 和 lightmap 灯光贴图（SH和顶点光源不包含在Pass数据中）（这个并不是很常用，至少Unity自己的Shader案例中从来没有用）。

##### Additional Passes

​	Additional passes 用于渲染每个附加的逐像素计算的灯光。默认情况下，这些通道中的灯不具有阴影（因此从结果上看，“Forward Rendering”支持带阴影的一个方向光），除非使用 [multi_compile_fwdadd_fullshadows](https://docs.unity3d.com/Manual/SL-MultipleProgramVariants.html)  这个变种。

####Performance Considerations 性能考虑

​	Spherical Harmonics 球面谐波光照的渲染是非常快的。CPU上的消耗非常低，实际上在GPU上是免费使用的（因为，在Base Pass中总是计算SH照明；而且由于SH灯光的工作方式，无论有多少SH灯，在那里的成本都是一样的）。

​	SH光照的缺点：

​	*它们是在对象的顶点计算的，而不是像素。这意味着他们不支持 Light Cookies 灯光遮罩 或 Normal Maps 法线贴图。*

​	*SH光照的频率很低，因此不能进行尖锐的照明转换。它们也仅影响漫反射照明（对于镜面高光来说频率太低）。*

​	*SH照明不是局部照明。靠近SH类型的点光源或者聚光灯的一些表面将会“看起来不正确”。*	

​	综上所述，SH灯光非常适合小的动态物体。

#### Deferred shading rendering path

https://docs.unity3d.com/Manual/RenderTech-DeferredShading.html

https://en.wikipedia.org/wiki/Deferred_shading

https://www.cnblogs.com/polobymulberry/p/5126892.html

https://blog.csdn.net/BugRunner/article/details/7436600

​	Deferred Rendering （延迟渲染） 顾名思义，就是将光照处理这一步骤延迟一段时间。具体做法是将光照处理这一步放在三维物体生成二维图片之后进行处理。也就是在屏幕空间进行光照处理。要做到这一步，需要一个重要的辅助工具--G-Buffer。

​	G-Buffer 主要用来存储每个像素对应的Position、Normal、Diffuse Color、Specular Color 、Emission Color和其他的Material Parameters 。根据这些信息我们就可以在屏幕空间进行光照处理。

​	使用延迟着色时，对可影响游戏对象的灯光数量没有限制。所有的灯都是以像素为单位计算的，这意味着所有灯光都可以使用法线贴图渲染。此外，所有的灯光都可以有Cookies（灯光效果遮罩）和阴影。

​	延迟着色的优点是，照明的处理开销与光照射的像素数量呈正比。这由场景中的灯光数量决定，无论它照亮多少个GameObjects。因此，通过减少灯光可以提高性能。延迟着色也具有高度一致性和可预测的行为。影响每个灯光的效果是逐像素计算的，所以没有在较大的三角面分解的照明计算。？

​	缺点：延迟渲染没有真正的抗锯齿支持，并且无法处理半透明的物体（这些物体在前向渲染中实现）。Mesh渲染器的“接收阴影”的设置也不支持，并且尽在有限的方式中支持CullMask。最多只能使用四个层的遮罩。

##### Requirements

​	延迟渲染需要显卡支持  Multiple Render Targets 多渲染对象 (MRT)。Shader Model 3.0 （或更高版本）的显卡，以及支持深度渲染纹理。2006年之后制造的大多数PC显卡都支持延迟渲染，从GeForce 8xxx,Radeon X2400,Intel G45开始。

​	在移动设备上，延迟渲染不支持，主要是由于使用了MRT格式（一些支持多个渲染目标的GPU仍然仅支持非常有限的位数）。

注：使用正交摄像机，不支持延迟渲染。如果相机的投影模式为“正交”，则相机将回退到前向渲染。

##### Performance considerations

​	Deferred Shading 中实时灯光的渲染开销和灯光照射的像素数成正比，并且与场景的复杂度无关。所以小的点光源或者聚光灯渲染的消耗非常小，并且如果有全部或者部分被场景中的物体遮挡住，消耗就更小。

​	当然，有阴影的灯光会比没有阴影的灯光开销大。在Deferred Shading中，产生阴影的物体仍然需要为每个投影灯渲染一次或多次。此外，应用投影的Shader会比禁用阴影的Shader渲染成本更高。

##### Implementation details

​	不支持延迟渲染Shader 的对象在前向渲染路径 完成延迟着色之后进行渲染。

​	The geometry buffer 几何缓冲区 (g-buffer) 中的渲染目标（RT0 - RT4）的默认布局如下所示：数据类型放在每个渲染目标的各个通道中。使用的通道显示在括号内：

- RT0, ARGB32 format: Diffuse color (RGB), occlusion (A).
- RT1, ARGB32 format: Specular color (RGB), roughness (A).
- RT2, ARGB2101010 format: World space normal (RGB), unused (A).
- RT3, ARGB2101010 (HDR) or ARGBHalf (non-HDR) format: Emission + lighting + lightmaps + reflection probes buffer.
- Depth+Stencil buffer.

所以默认的g-buffer布局是 160bits/pixel(非HDR) 或 192bits/pixel (HDR)

如果使用 Shadowmask 或 Distance Shadowmask 模式来混合灯光，则使用第五个目标：

- RT4, ARGB32 format: Light occlusion values (RGBA).

		因此，g缓冲区布局是192bits/pixel（非HDR）或224bits/pixel（HDR）。 

		如果硬件不支持五个兵法的rendertaret，则使用shadowmasks的对象将回退到前向渲染路径。当摄像机不使用HDR时，Emission+lighting buffer (RT3) 将以对数编码来提供比通常的ARGB32格式更大的动态范围。

##### G-Buffer pass

​	G-Buffer pass 渲染每个游戏对象一次。Diffuse 、Specular colors、 surface smoothness、world space normal、 emission+ambient+reflections+lightmaps 这些被存储在g-buffer 的贴图中。g-buffer 的纹理贴图设置为全局Shader属性，以供以后的着色器访问(*CameraGBufferTexture0 ..* CameraGBufferTexture3 这些名字)。 

##### Lighting pass

​	Lighting Pass 依赖g-buffer 和 深度 来计算着色效果。灯光在屏幕空间计算的，因此处理所花费的时间与场景复杂度无关。最终的着色结果是被添加到自发光缓冲区。

​	不穿过摄像机近裁剪面的点光源和聚光灯会被作为3D形状渲染，，并且Z Buffer的测试是针对启用的场景进行的，这使得部分或完全被遮挡的点光源和聚光灯消耗非常低。穿过近裁剪面的方向光和点光源聚光灯会被渲染为全屏四边形。

​	如果一个灯光启用了阴影，那么将会在这个通道中渲染和使用。注意阴影的使用并不是“免费”的；投射阴影需要被渲染，并且必须应用更复杂的灯光着色器。

###[tangentToWorld]	

​	Unity 中使用的float4 tangentToWorld[3] 是以该数组的用途来命名的，而非矩阵的含义。实际上如果将这个数组转化为3x3矩阵（忽略最后一列变量，通常用于存放World Pos），这是一个World Space 到 Tangent Space 的变换矩阵。该矩阵是由World Space Tangent 、World Space  Binormal、World Space Normal 三个向量构造的，三个向量两两垂直且均Normalize 处理过。

​	因此该World To Tangent矩阵是一个 平移矩阵 和 旋转矩阵 相乘的结果，所以World To Tangent是一个正交矩阵，正交矩阵的特点是转置矩阵等于逆矩阵，所以使用这个矩阵将切空间的点转换到世界空间时，用它的转置矩阵即可，对于法线也是一样的（同样也是因为这里的矩阵没有缩放，如果是把法线从模型空间变换到世界空间，就需要用ObjectToWorld的转逆矩阵。原因可参考 [3D 变换中法向量变换矩阵的推导 -- 潘李亮]）。

​	用该矩阵的转置矩阵和切空间法线向量相乘正好就是float3（worldTangent * tangentNormal.x ,worldBinormal * tangentNormal.y,worldNormal * tangentNormal.z）;

​	上面的三个变量需要 3x3 的空间即可存储，所以

```c++
float3(tangentToWorld[0].w,tangentToWorld[1].w,tangentToWorld[2].w)
```

​	在ForwardBase中，会根据需要将 存储 切空间的视向量 或者顶点在世界空间的位置，在ForwardAdd中，会存储 世界空间的灯光向量。



###[TEXCOORD]

​	TEXCOORD0 语义可以用来传输数据，但是最多存储float4的数据， 如果传递的是float4x4 , float3x3 的矩阵数据 或者 float4 **[3] ，会自动向后扩展。例如： 

```C
float4 tangentToWorld[3] : TEXCOORD0; // 这里指明的是TEXCOORD0,但实际，TEXCOORD1 和 TEXCOORD2 也被占用，float3x3 和 float4x4同理
float4 normal:TEXCOORD3; // 这里就要使用TEXCOORD3，如果使用TEXCOORD1或TEXCOORD2会报错
```

​	SM2.0 最多到 TEXCOORD7 ,使用TEXCOORD8 需要指定SM3.0 。

###[ParallaxMap]

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



###[smoothness&oneMinusReflectivity]

​	smoothness 就是通常所说的 gloss，也就是 1-roughness 。

​	oneMinusReflectivity 是 1 - 反射率。这里需要注意的是，非金属的反射率是灰度值金属的反射率应该是一个三维的颜色值，但是为了优化的目的，这里只取金属反射率rgb中的一个分量，取的原则是：SM2.0以下直接去r 分量，SM2.0以上取三个分量中的最大值。

​	在很多地方都要使用这个数值，所以提前计算出来可以避免后面重复计算。

​	反射率是物质的一个物理属性，表示在物体表面反射中，反射波与入射波功率的比值。

​	为什么要用 1-x ?以及具体怎么计算？以及为什么要取最大值？

​	**TODO**



###[tangentSpaceNormal]

​	当使用简单版的Standard Shader时，使用切空间法线，这样的法线直接就是从贴图中采样出来再Unpack 之后的，不用对法线做矩阵变换，是效率比较高的，但是这样就需要从Vertex程序中传入切空间的Light Dir 和 View Dir 。



###[FresnelEquation]

​	**Fresnel Equation** 菲涅尔方程 是 **Maxwell's equations** 麦克斯韦方程组 在折射率不同的两个物质间有一个无限大且绝对光滑的交界面这种情况下的解。 

​	**F0** 指的是 Fresnel 方程在法线和视线夹角 **θ** 为 0 的值。这个值通常是从现实世界中真实数据采集折射率**n**，然后计算获得。Fresnel Equation 的值介于 [F0,1]，当视线方向和法线的夹角无限接近90度，Fresnel 的值无限接近于 1。 

​	Fresnel 应用在渲染中通常使用  schlick的 近似方程，镜面反射系数 **R** ：

​	$R(\theta) = R_0 + (1-R_0)(1-cos \theta)^5$

​	$R_0 = (\frac{n_1-n_2}{n_1+n_2})^2$ 

​	这里的 **R0** 即是 **F0** 。对于大多数绝缘体，F0的范围在 0.02 - 0.05 范围之间，而导体的F0在 0.5 - 1.0 之间。F0的反射率是我们在创作纹理时关心的内容，非金属（电介质/绝缘体）有一个灰度值，而金属（导体）会有一个彩色值。

​	大部分非金属的F0数值互相之间的区别并不大。宝石是一个例外，它具有很高的数值。

 

###[SpecularSetup]

​	Unity 的 SpecularSetup 指的是 PBR 中的 **Specular/Glossines 镜面反射/光泽度工作流程** 。

​	在这一工作流程中，金属的反射率以及非金属的 **F0**  值（即Specular）放在镜面反射贴图中。在镜面反射/光泽度工作流程中，会用到两张 RGB 贴图：一张是漫反射颜色（反照率）而另一张是反射率值（镜面反射）。在镜面反射贴图中，可以直接控制绝缘体材质的F0值。

​	这种工作流有可能会打破能量守恒的原则。

​	Unity 中使用的 _SpecGlossMap 的RGB通道存储 Specular ，Gloss (Smoothness) 可以根据需求存储在 _SpecGlossMap 的 A通道 或者 _MainTex(Albedo) 的A通道 或者 用 _Glossiness 这个变量输入。



###[EnergyConservationBetweenDiffuseAndSpecular]

​	PBR的原则之一：Energy Conservation 能量守恒，即 出射光的能量 <= 入射光的能量。而使用 Specular / Gloss 因为可以控制非金属的F0值，很容易出现能量不守恒的情况，例如：白色（1.0）的漫反射值与白色（1.0）的镜面反射值相组合，得到的反射/折射光的总量会大于接收到的，结果就会打破能量守恒原则。这意味着，你做出来的贴图可能不会得到正确的渲染结果。

​	Unity为了避免这种情况，因此在这里使用EnergyConservationBetweenDiffuseAndSpecular 函数做处理，保证 albedo + specular <= 1;



###[RoughnessSetup]

​	Unity 中的 RoughnessSetup 指的是 PBR 中的 **Metallic/Roughness 金属度/粗糙度工作流程** 。

​	在这一个工作流程中，金属的反射率和绝缘体的反射色存在 固有色贴图中。金属性贴图起到类似于蒙版的作用，区分固有色贴图中的金属和绝缘体数据。绝缘体F0值不需要手动输入，由Shader 自动处理。当shader在金属性贴图中识别到黑色时，它将固有色贴图中的相应区域处理为绝缘体，使用4%（0.04）的反射率。4%的值适用于绝大多数常见绝缘体材质。

​	在金属/粗糙度工作流程中，能量守恒法则不可能被打破。漫反射（反射光）以及镜面反射光之间的平衡由金属性贴图控制，这意味着你无法创造出一种漫反射与镜面反射相组合，能够使得反射/折射光比表面初始接收到的更多。这也正是这种工作流被广泛使用的原因。

​	Unity的 RoughnessSetup中， 金属度 存储在 _MetallicGlossMap.r 或者 _Metallic 这个变量中，Roughness 存储在 _SpecGlossMap.r 或者 _Glossiness 变量中。

​	因为RoughnessSetup 是后来2017版本新加入的输入模式，所以为了避免新的变量名出现，所以就用旧的代替了。（因为当变量名相同时，切换Shader，贴图就能直接链接上）



###[OneMinusReflectivityFromMetallic]

​	从金属度中获取1-反射率的值，这里Unity使用了一个小技巧：

​	$1-reflectivity = 1-lerp(dielectricSpec,1,Metallic)   = lerp(1-dielectricSpec,0,Metallic)$ 

​	$dielectricSpec$ 就是电介质的默认反射率0.04， 然后将 $ 1 - dielectricSpec $  提前存储起来为 $oneMinusDielectricSpec$ ，则：

​	$lerp(1-dielectricSpec,0,Metallic) = oneMinusDielectricSpec - oneMinusDielectricSpec * Metallic$

​	这样拆开运算效率会高一些。



###[MetallicSetup]

​	Unity中的 MetallicSetup 是，传统的PBR，Metallic/Roughness 金属粗糙度流程的一个变种，Metallic/Glossiness 金属和光泽度工作流，这里 Glossiness = 1 - Roughness ，这里并不推荐这种方法来实现PBR，因为 大部分的软件中都是使用 Metallic /Roughness 和 Specular/Glossiness 两种模式，这样制作的美术资源就能直接用，不用再在PhotoShop 中做处理。

​	金属度存储在 _MetallicGlossMap.r  或 _Metallic 变量中。光泽度 存储在 _MetallicGlossMap.a 或 _MainTex.a 或 _Glossiness 中。



###[PreMultiplyAlpha]

​	用于Unity的 Transparent 参数，适用于像彩色玻璃一样的半透明物体，高光反射不会随透明而消失。 **TODO** 



###[PerceptualRoughness&Roughness]

​	Perceptual Roughness 感知粗糙度 和 Roughness 粗糙度，感知粗糙度和感知光泽度都是为了方便艺术家制作的参数，他们并不是真正的GGX BRDF 中使用的Roughness ，它们之间的关系是：

​	Roughness = PerceptualRoughness * PerceptualRoughness;

​	Smoothness = 1 - (1- PerceptualSmoothness)*(1- PerceptualSmoothness);

​	The specular part of Disney “principled” BRDF is a GGX BRDF. It use a roughness parameter. This roughness is the “Disney roughness”, not the real GGX roughness. Disney Roughness = sqrt(Roughness). When use at runtime this Disney Roughness is transform to the GGX roughness with roughness = Disney Roughness * Disney Roughness.

​	迪士尼“原则性”BRDF的高光部分是GGX BRDF。 它使用Roughness参数。 这种Roughness 是“Disney roughness ”，而不是真正的GGX Roughness。 Disney roughness = sqrt(Roughness)。 在运行时使用时，Disney Roughness 会转变为的GGX粗糙度。Roughness = Disney Roughness * Disney Roughness 

​	Unity、Unreal 等引擎的BRDF都使用这种方式计算。Unity 里  PerceptualRoughness 等价于 Unreal 中的roughness

​	参考： UnityStandardBRDF.cginc 

​	https://seblagarde.wordpress.com/2014/04/14/dontnod-physically-based-rendering-chart-for-unreal-engine-4/

​	@TODO Substance Painter中输出到贴图中的是 PerceptualRoughness 还是Roughness ？是否跟贴图存储的颜色空间有关系？



###[sRGB]

​	sRGB采样 允许 Unity Editor 在纹理处在Gamma颜色空间时，在Linear 空间中渲染时使用。当您选择在线性色彩空间中工作时，编辑器默认使用sRGB采样。

​	 也就是说：如果你当前项目的颜色空间是Linear ，你要使用Gamma空间的纹理贴图，则纹理贴图就需要勾选sRGB，如果是使用Linear Space 的贴图，就不要勾选。

​	如果你当前项目的颜色空间是Gamma，那么勾不勾选 sRGB 对结果并没有影响。



###[HANDLE_SHADOWS_BLENDING_IN_GI]

​	**TODO** ： GI中的Shadow是怎么生成的，怎么应用到GI中的？



###[SphericalHarmonic]

​	Spherical Harmonic 球面谐波 

​	https://blog.csdn.net/leonwei/article/details/78269765

​	http://silviojemma.com/public/papers/lighting/spherical-harmonic-lighting.pdf 

​	原理太复杂，这里只介绍怎么用：

​	**TODO**



###[SubtractMainLightWithRealtimeAttenuationFromLightmap]

​	**TODO**



###[BoxProjectedCubemapDirection]

https://zhuanlan.zhihu.com/p/35495074 

**TODO**



### [UnityInstancing]

**TODO**



### [STEREO]

​	TODO



###[Emission]

​	Unity Standard 的自发光颜色是HDR的，HDR的效果是在GUI脚本中使用TexturePropertyWithHDRColor 实现的。

TexturePropertyWithHDRColor  的应用: TODO 



### [UnityBRDF321]





### [GrazingTerm]

​	grazingTerm 在BRDF3 中 是 saturate(smoothness + (1-oneMinusReflectivity));表示的意思是在扫视角度的亮度，Fresnel90 的值，但是 为什么要这么做？TODO

​	

###[BRDF2]

​	http://www.thetenthplanet.de/archives/255



### [SpecPower]

https://dl.dropboxusercontent.com/u/55891920/papers/mm_brdf.pdf

粗糙度和高光强度的转换：

```
roughness = perceptuaRoughness * perceptuaRoughness;
specPower = max(1e-4f,2.0/max(1e-4f,roughness * roughness)-2.0);
```



### [DisneyPBR]

http://blog.selfshadow.com/publications/s2012-shading-course/

http://blog.selfshadow.com/publications/s2012-shading-course/burley/s2012_pbs_disney_brdf_notes_v3.pdf

https://blog.uwa4d.com/archives/Study_Shading-Disney.html

​	迪士尼基于物理的微面元着色模型，siggraphic 2012 的文章。不同于前人提出的基于物理的材质模型，这篇文章的材质模型在设计之初并不是以物理正确为原则，而是以让美术设计者更容易理解和使用为原则。文章作者认为是否是物理正确并不重要，重要的是能达到美术设计者的需求并且使用方便、容易理解。因此，他们提出了5个主要的设计原则： 

1. 使用方便、便于理解比物理真实更重要；
2. 可调节参数越少越好；
3. 参数的值都必须在效果可接受的范围内归一化到（0～1）之间；
4. 参数可以被赋予超过其实际可接受范围（0～1）之外的值；
5. 所有参数组合的效果都必须是可接受并且稳定；



![](Images/Study_ShaderDisney2.png)

​	从上图可以看到，经过对参数的简化，文章提出的材质模型用了11个参数即可非常真实地模拟出金属、非金属以及不同粗糙度的材质光照结果。

​	文章作者基于上述的5个原则以及对真实测量数据的观察结果，对传统的微表面材质模型中的各项函数进行修改。接下来我们首先介绍传统的微表面模型的通用表达式，然后对其中的每一项函数进行说明，并介绍在文章中采用的各项函数的表达式。

​	文章中的模型采用了微表面模型的通用形式，该通用形式最早出现在Cook-Torrance模型中。
$$
f(l,v) = diffuse + \frac{D(\theta_h)F(\theta_d)G(\theta_l,\theta_v) }{4cos \theta_l cos \theta_v}
$$
​	向量 $l$ 和 $v$ 分别表示入射光和视线方向，向量 $h$ 表示半角向量。它们和法线之间的夹角分别用对应下标的 $\theta$ 表示，$\theta_d$ 则表示 $l$ 和 $v$ 之间夹角的一半。即：$lh$ 或 $vh$ 之间的夹角。$diffuse$ 表示漫反射函数，$D$表示微表面法线分布函数， $F$ 表示菲涅尔系数， $G$表示阴影系数。 BRDF 如下：$diffuse$ 函数：
$$
f_d = \frac{baseColor}{\pi}(1+(F_{D90} - 1)(1-cos \theta_l)^5)(1+(F_{D90} - 1)(1-cos \theta_v)^5)
$$

$$
F_{D90} = 0.5 + 2cos \theta _d^2 roughness
$$

$roughness$ 表示粗糙度。



微表面法线分布函数 $D$ ，这里没有使用GGX，而是使用更为通用的形式GTR (Generalized-Trowbridge-Reitz) :
$$
D_{GTR} = c/(\alpha^2cos^2\theta_h + sin^2\theta_h)^\gamma
$$
它与GGX的区别是，GGX是上面式子中 $\gamma = 2$ 的结果。迪士尼采用了两个不同的GTR函数来拟合高光项，采用 $\gamma = 1$ 和 $\gamma = 2$ 。 其中 $\alpha = roughness^2$ ， $c$ 是一个常数用于调节整体缩放。

Unity使用的法线分布函数 $D$ 是:


$$
D_{GGX}(h) = \frac{ \alpha^2}{\pi(cos^2\theta_h(\alpha^2-1)+1)^2}
$$


菲涅尔项 $F$ ，采用Schlick 的公式：
$$
F_{Schlick} = F_0+(1-F_0)(1-cos\theta_d)^5
$$
$F_0$ 是一个常量，其值取决于材质的透射系数。



几何遮挡项 $G$，采用Walter 在其论文中根据 GGX 推导的 G公式，并将公式中的 $roughness$ 从 [0,1] 缩放到 [0.5,1] ，这个缩放是在粗糙度平方之前。做这个缩放的原因是，根据与实际测量的数据对比以及美术设计者的反馈，高光在 $roughness$ 值较小时显得过于亮。虽然这个缩放的过程使得模型不再物理准确，但是它符合了美术设计者的需求，这也正是这篇文章最主要的设计原则。 
$$
G_{GGX} = \frac{2*cos\theta_v}{cos\theta_v+ \sqrt{\alpha^2 + (1-\alpha^2)cos^2\theta_v}}
$$
$$
\alpha = (roughness * 0.5 + 0.5)^2
$$

Unity 中使用的几何遮挡项 $G$ 是 SmithJointGGX  http://jcgt.org/published/0003/02/03/paper.pdf 原始公式：
$$
a = roughness ; a2 = a * a;
$$

$$
lambda\_v = \frac{\sqrt{a2 * (1-cos^2\theta_l) / cos^2\theta_l+ 1}-1}{2}
$$

$$
lambda\_l = \frac{\sqrt{a2 * (1-cos^2\theta_v) / cos^2\theta_v+ 1}-1}{2}
$$

$$
G_{Smith-GGX} = \frac{1}{1+lambda\_v+lambda\_l}
$$

首先给每个 $lambda$ 加 0.5 来抵消  $G_{Smith-GGX} = \frac{1}{1+lambda\_v+lambda\_l}$ 分母中的 1 。然后给分子分母同时乘  $2cos\theta_lcos\theta_v$ 来进行化简：
$$
lambdaV = cos\theta_l \sqrt{a2*(1-cos^2\theta_v) + cos^2\theta_v}
$$

$$
lambdaL = cos\theta_v \sqrt{a2*(1-cos^2\theta_l) + cos^2\theta_l}
$$

在对这个 $lambda$ 继续进行近似优化（UE4使用了同样的公式），因为上述的代码依旧很复杂。考虑到整体的性能，牺牲一部分难以察觉到的精度来提升效率是必要的 ：


$$
lambdaV \approx cos\theta_l * (cos\theta_v*(1-a) + a)
$$

$$
lambdaL \approx cos\theta_v * (cos\theta_l*(1-a) + a)
$$

最后加上 $1e^{-5}​$ 防止分母为 0。



优化版本：
$$
G_{Smith-GGX\_Opt} = \frac{2cos\theta_vcos\theta_l}{lambdaV +lambdaL + 1e^{-5}}
$$
将$G$ 项 和 分母 $4cos\theta_l cos\theta_v$ 合并为 $V$ 项：
$$
V = \frac{G}{4cos\theta_lcos\theta_v}
$$

$$
V = \frac{0.5}{lambdaV + lambdaL + 1e^{-5}}
$$



则最终 Unity 中使用的 BRDF1公式，再在上面的基础上做了一些HACK：

理论上 漫反射项应该除 pi ，并且不应该给 高光项乘 pi ，这样做的原因如下：

​	1) 如果不这样做会导致着色器看起来比传统的着色器暗得多；2) 在引擎中看，"Non-important" 的灯被当作 SH 光计算到环境光中的时候，也必须除 pi



### [HDrenderloop]

​	TODO



### [NDFBlinnPhongNormalizedTerm]

$$
L_{o}(\mathbf{v}) = (\mathbf{c}_{diff} + \pi \mathbf{c}_{spec}(\mathbf{n} \cdot \mathbf{h})^{e}) \otimes \mathbf{c}_{light}(\mathbf{n}\cdot \mathbf{l_c})
$$

$$
e = \frac{2}{roughness^2} - 2
$$

$$
D_{Blinn}(w_m) = (w_n \cdot w_m)^e
$$

传统的Blinn-Phong 并不是真实的法线分布，上面的公式也不满足能量守恒定律（$D$需要满足$w_m$在半球面上积分为1，Blinn-Phong还需要乘一个常量 $\frac{e+2}{2\pi}$ 才能满足这个条件）。

```c++
// 计算镜面反射强度
float e = 2 / roughness * roughness - 2;
float NdotH = dot(normal,Wm); // Wm = normalize(Wo + Wi) // 半角向量
//float normTerm = (n+2)/(2*pi);
float normTerm = (n+2)*(0.5/pi);
float specularIntensity = pow(saturate(NdotH),e) * normTerm;
```


### [NaN]

**NaN**（**N**ot **a** **N**umber，非数）是[计算机科学](https://zh.wikipedia.org/wiki/%E8%AE%A1%E7%AE%97%E6%9C%BA%E7%A7%91%E5%AD%A6)中数值[数据类型](https://zh.wikipedia.org/wiki/%E6%95%B8%E6%93%9A%E9%A1%9E%E5%9E%8B)的一类值，表示未定义或不可表示的值。常在[浮点数](https://zh.wikipedia.org/wiki/%E6%B5%AE%E7%82%B9%E6%95%B0)运算中使用。首次引入NaN的是1985年的[IEEE 754](https://zh.wikipedia.org/wiki/IEEE_754)浮点数标准。 

返回NaN的运算有如下三种 :

​	操作数中至少有一个是NaN的运算;

​	未定义操作 :

​		下列[除法](https://zh.wikipedia.org/wiki/%E9%99%A4%E6%B3%95)运算：[0/0](https://zh.wikipedia.org/wiki/0/0)、[∞](https://zh.wikipedia.org/wiki/%E2%88%9E)/∞、∞/−∞、−∞/∞、−∞/−∞

​		下列[乘法](https://zh.wikipedia.org/wiki/%E4%B9%98%E6%B3%95)运算：0×∞、0×-∞

​		下列[加法](https://zh.wikipedia.org/wiki/%E5%8A%A0%E6%B3%95)运算：∞ + (−∞)、(−∞) + ∞

​		下列[减法](https://zh.wikipedia.org/wiki/%E5%87%8F%E6%B3%95)运算：∞ - ∞、(−∞) - (−∞)

​	产生[复数](https://zh.wikipedia.org/wiki/%E5%A4%8D%E6%95%B0_(%E6%95%B0%E5%AD%A6))结果的实数运算。例如： 

​		对负数进行[开偶次方](https://zh.wikipedia.org/wiki/%E9%96%8B%E6%96%B9)的运算

​		对负数进行[对数](https://zh.wikipedia.org/wiki/%E5%AF%B9%E6%95%B0)运算

​		对比-1小或比+1大的数进行[反正弦](https://zh.wikipedia.org/wiki/%E5%8F%8D%E6%AD%A3%E5%BC%A6)或[反余弦](https://zh.wikipedia.org/wiki/%E5%8F%8D%E9%A4%98%E5%BC%A6)运算



### [SurfaceReduction]

surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(roughness^2+1)

TODO



### [DeferredPass]

​	这里的Deferred Pass 只是为了计算 G-Buffer的数据，也就是 UnityStandardData 这个结构体里数据，然后使用 UnityStandardDataToGbuffer 这个函数将UnityStandardData 的数据转化为 G-Buffer 里的数据。

​	G-Buffer中的数据如下：

```C
// 这四个变量表示四张贴图
half4 outGBuffer0 : SV_Target0,	//Diffuse(rgb),Occlusion(a) // ARGB32
half4 outGBuffer1 : SV_Target1, //Specular(rgb),Roughness(a) // ARGB32
half4 outGBuffer2 : SV_Target2, //WorldSpaceNormal(rgb),unused(a) //ARGB 2101010
half4 outEmission : SV_Target3,	//emission + lighting + lightmaps + reflection probes (rgb), unused (a) // HDR的情况下是ARGB2101010,非HDR是 ARGBHalf
// 注：为了减少显存和渲染开销。当前场景的摄像机开启了HDR模式时，RT3将不会被创建。而是直接使用摄像机的HDR RT。
Depth + Stencil buffer // 深度和模板缓冲，8bit+8bit

// 所以默认的g-buffer，每个屏幕像素占 
// 32(0)+32(1)+32(2)+16(3)+16(ds)+32(这个是像素显示的颜色,color) 160bits/pixel(非HDR) 
// 或 32(0)+32(1)+32(2)+32(3)+16(ds)+32(color) 192bits/pixel (HDR)
   
// 如果使用 ShadowMask 或 Distance ShadowMask 模式来处理混合灯光则使用第五个变量
half4 outShadowMask : SV_Target4 //shadowmask (rgba) //ARGB32
// 所以真实的 g-buffer，每个屏幕像素占 
// 32(0)+32(1)+32(2)+16(3)+32(4)+16(ds)+32(color) 192bits/pixel(非HDR) 
// 或 32(0)+32(1)+32(2)+32(3)+32(4)+16(ds)+32(color) 224bits/pixel (HDR)
```

​	我们编写的Shader只是用来生成 G-Buffer的数据，而G-Buffer的数据是在Unity的默认延迟渲染Shader中使用的，这个Shader可以在 (2017.4.2)"Edit->Project Settings->Graphics->Built-in Shader Settings->Deferred / Deferred Reflections "中设置，默认是使用 Built-in Shader , Built-in Shader 可以从Unity 官方文档中查到：

Internal-DeferredShading.shader 和 Internal-DeferredReflections.shader 。

​	Standard Shader 在这里计算数据的时候使用的是一个亮度为0 的灯光，只是为了获取G-Buffer 所需数据。