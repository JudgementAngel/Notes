###Macro Definition 宏定义

**UNITY_SETUP_BRDF_INPUT**	设置BRDF的输入模式，一共有三种：SpecularSetup RoughnessSetup MetallicSetup 分别对应于Unity Standard 的三种模式

**SHADER_TARGET**		Shader的目标平台

**UNITY_STANDARD_SIMPLE**	判断Standard Shader是否是简单模式的

**UNITY_TANGENT_ORTHONORMALIZE**		是否对切线进行Ortho-Normalize直角归一

**UNITY_REQUIRE_FRAG_WORLDPOS**		是否需要在Fragment 程序中使用World Pos 世界空间中顶点位置

**UNITY_PACK_WORLDPOS_WITH_TANGENT**		是否将World Pos 打包存在Tangent To World 的数组中