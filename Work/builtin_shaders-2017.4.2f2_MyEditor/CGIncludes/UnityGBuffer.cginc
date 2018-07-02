// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef UNITY_GBUFFER_INCLUDED
#define UNITY_GBUFFER_INCLUDED

//-----------------------------------------------------------------------------
// Main structure that store the data from the standard shader (i.e user input)
// 存储来自标准着色器（即：用户输入）数据的主要结构体
struct UnityStandardData
{
    half3   diffuseColor;       // 漫反射颜色
    half    occlusion;          // 环境光遮罩

    half3   specularColor;      // 高光颜色
    half    smoothness;         // 感知光泽度

    float3  normalWorld;        // normal in world space // 世界空间的法线
};

//-----------------------------------------------------------------------------
// This will encode UnityStandardData into GBuffer
// 这个函数将 UntiyStandardData 编码进 GBuffer
void UnityStandardDataToGbuffer(UnityStandardData data, out half4 outGBuffer0, out half4 outGBuffer1, out half4 outGBuffer2)
{
    // RT0: diffuse color (rgb), occlusion (a) - sRGB rendertarget
    // RT0: 漫反射颜色 (rgb) , 环境光遮罩(a) - RenderTarget 使用sRGB 
    outGBuffer0 = half4(data.diffuseColor, data.occlusion);

    // RT1: spec color (rgb), smoothness (a) - sRGB rendertarget
    // RT1: 高光反射颜色 (rgb) , 感知光泽度(a) - RenderTarget 使用sRGB 
    outGBuffer1 = half4(data.specularColor, data.smoothness);

    // RT2: normal (rgb), --unused, very low precision-- (a)
    // RT2: 世界空间法线信息(rgb) , 未使用A通道，并且A通道精度很低只有2bits (a) 
    outGBuffer2 = half4(data.normalWorld * 0.5f + 0.5f, 1.0f);
}
//-----------------------------------------------------------------------------
// This decode the Gbuffer in a UnityStandardData struct

UnityStandardData UnityStandardDataFromGbuffer(half4 inGBuffer0, half4 inGBuffer1, half4 inGBuffer2)
{
    UnityStandardData data;

    data.diffuseColor   = inGBuffer0.rgb;
    data.occlusion      = inGBuffer0.a;

    data.specularColor  = inGBuffer1.rgb;
    data.smoothness     = inGBuffer1.a;

    data.normalWorld    = normalize((float3)inGBuffer2.rgb * 2 - 1);

    return data;
}
//-----------------------------------------------------------------------------
// In some cases like for terrain, the user want to apply a specific weight to the attribute
// The function below is use for this
void UnityStandardDataApplyWeightToGbuffer(inout half4 inOutGBuffer0, inout half4 inOutGBuffer1, inout half4 inOutGBuffer2, half alpha)
{
    // With UnityStandardData current encoding, We can apply the weigth directly on the gbuffer
    inOutGBuffer0.rgb   *= alpha; // diffuseColor
    inOutGBuffer1       *= alpha; // SpecularColor and Smoothness
    inOutGBuffer2.rgb   *= alpha; // Normal
}
//-----------------------------------------------------------------------------

#endif // #ifndef UNITY_GBUFFER_INCLUDED
