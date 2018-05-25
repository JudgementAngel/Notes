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

**UNITY_COLORSPACE_GAMMA** 	是否使用Gamma颜色空间

**DIRLIGHTMAP_COMBINED** 	是否合并灯光的方向贴图

**LIGHTMAP_SHADOW_MIXING** 	TODO

**SHADOWS_SHADOWMASK** 	TODO

**SHADOWS_SCREEN**	 TODO

**DYNAMICLIGHTMAP_ON** 		是否启用动态灯光贴图

**VERTEXLIGHT_ON** 	是否开启顶点灯光



------



**_NORMALMAP**	是否使用法线贴图

**_PARALLAXMAP**	是否使用视差贴图

**_ALPHATEST_ON**	是否使用Alpha Test 剔除模式

**_ALPHAPREMULTIPLY_ON** 是否使用Alpha 预乘，Alpha预乘主要用于 Standard 中特殊的 Transparent 的混合模式

**_GLOSSYREFLECTIONS_OFF** 	是否启用光泽度反射

**_ALPHABLEND_ON** 	是否使用Alpha混合

**_ALPHAPREMULTIPLY_ON** 	是否使用Alpha 预乘

**_TANGENT_TO_WORLD**  	切空间到世界变换的数组

