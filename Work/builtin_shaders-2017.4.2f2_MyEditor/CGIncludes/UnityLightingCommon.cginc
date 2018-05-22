// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef UNITY_LIGHTING_COMMON_INCLUDED
#define UNITY_LIGHTING_COMMON_INCLUDED

// 主灯光颜色，只要声明这个变量，Unity会自动赋值主灯光的颜色
fixed4 _LightColor0;
// 高光颜色 // @TODO ?
fixed4 _SpecColor;

// 直接光照的灯光参数结构体
struct UnityLight
{
    half3 color; // 灯光颜色
    half3 dir; // 灯光方向
    half  ndotl; // Deprecated: Ndotl is now calculated on the fly and is no longer stored. Do not used it. // 已弃用：Ndotl现在即时计算，不再存储。 不要用它。
};

// 间接光照结构体
struct UnityIndirect
{
    half3 diffuse; // 间接光照的漫反射部分
    half3 specular; // 间接光照的高光部分
};

// 全局光照
struct UnityGI
{
    UnityLight light; // 直接光照
    UnityIndirect indirect; // 间接光照
};

// Unity 全局光照输入参数结构体
struct UnityGIInput
{
    UnityLight light; // pixel light, sent from the engine // 逐像素灯光，从引擎中输入

    float3 worldPos; // 世界空间顶点位置
    half3 worldViewDir; // 世界空间视线向量
    half atten; // 灯光衰减，直射光非0即1，点光源和聚光灯具有衰减，也用来实现自阴影
    half3 ambient; // 环境光

    // interpolated lightmap UVs are passed as full float precision data to fragment shaders
    // 内置光照贴图UV，作为完整的float 精度数据传递给fragment 着色器
    // so lightmapUV (which is used as a tmp inside of lightmap fragment shaders) should
    // also be full float precision to avoid data loss before sampling a texture.
    // 所以 lightmapUV (作为临时参数被用于在Fragment着色器中传递灯光贴图UV)也应该
    // 使用完整的float精度以避免在采样贴图之前丢失精度。

    float4 lightmapUV; // .xy = static lightmap UV, .zw = dynamic lightmap UV // xy是静态的灯光贴图UV，zw是动态的灯光贴图UV

    // @TODO
    #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION) || defined(UNITY_ENABLE_REFLECTION_BUFFERS)
    float4 boxMin[2];
    #endif
    #ifdef UNITY_SPECCUBE_BOX_PROJECTION
    float4 boxMax[2];
    float4 probePosition[2];
    #endif

    // HDR cubemap properties, use to decompress HDR texture
    // HDR cubemap 属性，用来解压HDR贴图
    float4 probeHDR[2];
};

#endif
