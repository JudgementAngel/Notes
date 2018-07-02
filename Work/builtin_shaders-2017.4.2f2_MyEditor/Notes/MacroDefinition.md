###Macro Definition 宏定义

**UNITY_SETUP_BRDF_INPUT**	设置BRDF的输入模式，一共有三种：SpecularSetup RoughnessSetup MetallicSetup 分别对应于Unity Standard 的三种模式

**SHADER_TARGET**		Shader的目标平台

**UNITY_STANDARD_SIMPLE**	判断Standard Shader是否是简单模式的

**UNITY_TANGENT_ORTHONORMALIZE**		是否对切线进行Ortho-Normalize直角归一

**UNITY_REQUIRE_FRAG_WORLDPOS**		是否需要在Fragment 程序中使用World Pos 世界空间中顶点位置

**UNITY_PACK_WORLDPOS_WITH_TANGENT**		是否将World Pos 打包存在Tangent To World 的数组中

**UNITY_SPECCUBE_BLENDING**		TODO

**UNITY_SPECCUBE_BOX_PROJECTION**		TODO

**UNITY_ENABLE_REFLECTION_BUFFERS**	 	TODO

**LIGHTMAP_ON** 	是否使用灯光贴图

**DYNAMICLIGHTMAP_ON** 	是否使用动态灯光贴图

**HANDLE_SHADOWS_BLENDING_IN_GI**		是否在GI中混合阴影

**UNITY_SHOULD_SAMPLE_SH** 		是否应该采样球谐光照

**UNITY_SAMPLE_FULL_SH_PER_PIXEL** 	是否逐像素采样完整的SH光照

**UNITY_LIGHT_PROBE_PROXY_VOLUME** 	是否使用光照探针代理体

**DIRLIGHTMAP_COMBINED** 	是否合并灯光的方向贴图

**LIGHTMAP_SHADOW_MIXING** 	TODO

**SHADOWS_SHADOWMASK** 	TODO

**SHADOWS_SCREEN**	 TODO

**DYNAMICLIGHTMAP_ON** 		是否启用动态灯光贴图

**VERTEXLIGHT_ON** 	是否开启顶点灯光

**LOD_FADE_CROSSFADE** 	LOD淡入淡入的模式是否为交叉淡入淡出 LODFadeMode.CrossFade 

**UNITY_USE_LODFADEARRAY** 	TODO

**UNITY_PBS_USE_BRDF3/2/1** 	定义Shader使用的BRDF，3/2/1 ，优限级和效果依次降低

**SHADER_TARGET_SURFACE_ANALYSIS** 	是否是 着色器目标平面分析阶段

**UNITY_BRDF_GGX** 	是否使用GGX的法线分布函数

**UNITY_COLORSPACE_GAMMA** 	是否使用Gamma的颜色空间

**SHADER_API_MOBILE** 	是否是移动平台的API

**UNITY_HANDLE_CORRECTLY_NEGATIVE_NDOTV** 	对于可见的像素来说 NdotV 不应该是负的，但是可能会在透视投影和法线贴图的影响下发生。在这种情况下，法线应该被修改为有效的（即面向摄像机），并且不会造成奇怪的伪影。但是这个操作可能增加了一些逻辑运算，并且用户可能并不想要它。另一种方法是简单使用NdotV的绝对值（不太正确，但也可以接受）。这个宏定义允许控制这个。如果ALU对你的目标平台至关重要，请设置为0。这个修正对带有 SmithJointGGX 的可见函数来说很有趣。因为在这种情况下，由于粗糙表面的突出边缘，伪影更加明显。编辑：默认禁用此代码，因为它和SpeedTree的双面照明不兼容。

**USING_DIRECTIONAL_LIGHT** 	是否使用方向光

------



**_NORMALMAP**	是否使用法线贴图

**_PARALLAXMAP**	是否使用视差贴图

**_ALPHATEST_ON**	是否使用Alpha Test 剔除模式

**_ALPHAPREMULTIPLY_ON** 是否使用Alpha 预乘，Alpha预乘主要用于 Standard 中特殊的 Transparent 的混合模式

**_GLOSSYREFLECTIONS_OFF** 	是否启用光泽度反射

**_ALPHABLEND_ON** 	是否使用Alpha混合

**_ALPHAPREMULTIPLY_ON** 	是否使用Alpha 预乘

**_TANGENT_TO_WORLD**  	切空间到世界变换的数组

**_SPECULARHIGHLIGHTS_OFF** 	是否使用镜面高光反射

