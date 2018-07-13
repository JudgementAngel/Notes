// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef UNITY_STANDARD_CORE_INCLUDED
#define UNITY_STANDARD_CORE_INCLUDED

#include "UnityCG.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityInstancing.cginc"
#include "UnityStandardConfig.cginc"
#include "UnityStandardInput.cginc"
#include "UnityPBSLighting.cginc"
#include "UnityStandardUtils.cginc"
#include "UnityGBuffer.cginc"
#include "UnityStandardBRDF.cginc"

#include "AutoLight.cginc"
//-------------------------------------------------------------------------------------
// counterpart for NormalizePerPixelNormal
// 对应于 NormalizePerPixelNormal
// 这两个函数的区别将决定在非常近的角度会不会有数值偏差
// skips normalization per-vertex and expects normalization to happen per-pixel
// 跳过在Vertex程序中Normalize，并在Fragment程序中进行
half3 NormalizePerVertexNormal (float3 n) // takes float to avoid overflow // 采用float 类型避免溢出
{
    #if (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
        return normalize(n);
    #else
        return n; // will normalize per-pixel instead 
        // 这里直接返回将会在Fragment程序中Normalize
    #endif
}

// 逐像素的Normalize
float3 NormalizePerPixelNormal (float3 n)
{
    #if (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
        return n;
    #else
        return normalize(n);
    #endif
}

//-------------------------------------------------------------------------------------
// 计算ForwardBase主光源参数
UnityLight MainLight ()
{
    UnityLight l;

    l.color = _LightColor0.rgb;
    l.dir = _WorldSpaceLightPos0.xyz;
    return l;
}

// 计算ForwardAdd光源参数
UnityLight AdditiveLight (half3 lightDir, half atten)
{
    UnityLight l;

    l.color = _LightColor0.rgb;
    l.dir = lightDir;
    #ifndef USING_DIRECTIONAL_LIGHT
        l.dir = NormalizePerPixelNormal(l.dir);
    #endif

    // shadow the light 
    // 灯光阴影
    l.color *= atten;
    return l;
}

// 生成一个假设的光源，黑色，从正上方打光
UnityLight DummyLight ()
{
    UnityLight l;
    l.color = 0;
    l.dir = half3 (0,1,0);
    return l;
}

// 返回一个强度为0的间接光照
UnityIndirect ZeroIndirect ()
{
    UnityIndirect ind;
    ind.diffuse = 0;
    ind.specular = 0;
    return ind;
}

//-------------------------------------------------------------------------------------
// Common fragment setup
// 通用的Fragment 数据初始化

// deprecated // 弃用的
half3 WorldNormal(half4 tan2world[3])
{
    return normalize(tan2world[2].xyz);
}

// deprecated // 弃用的
#ifdef _TANGENT_TO_WORLD
    half3x3 ExtractTangentToWorldPerPixel(half4 tan2world[3])
    {
        half3 t = tan2world[0].xyz;
        half3 b = tan2world[1].xyz;
        half3 n = tan2world[2].xyz;

    #if UNITY_TANGENT_ORTHONORMALIZE
        n = NormalizePerPixelNormal(n);

        // ortho-normalize Tangent
        t = normalize (t - n * dot(t, n));

        // recalculate Binormal
        half3 newB = cross(n, t);
        b = newB * sign (dot (newB, b));
    #endif

        return half3x3(t, b, n);
    }
#else
    half3x3 ExtractTangentToWorldPerPixel(half4 tan2world[3])
    {
        return half3x3(0,0,0,0,0,0,0,0,0);
    }
#endif

// 逐像素计算世界空间法线
// @Remark:[tangentToWorld]
float3 PerPixelWorldNormal(float4 i_tex, float4 tangentToWorld[3])
{
// 如果使用法线贴图
#ifdef _NORMALMAP
    half3 tangent = tangentToWorld[0].xyz;
    half3 binormal = tangentToWorld[1].xyz;
    half3 normal = tangentToWorld[2].xyz;

    #if UNITY_TANGENT_ORTHONORMALIZE
        normal = NormalizePerPixelNormal(normal);

        // ortho-normalize Tangent
        // 直角归一切线
        tangent = normalize (tangent - normal * dot(tangent, normal));

        // recalculate Binormal
        // 重计算副法线
        half3 newB = cross(normal, tangent);
        binormal = newB * sign (dot (newB, binormal));
    #endif

    // 从贴图中得到切空间的法线向量
    half3 normalTangent = NormalInTangentSpace(i_tex); 
    // 将切空间的法线转换到世界空间，这里通过切空间基向量乘法实现矩阵变换
    float3 normalWorld = NormalizePerPixelNormal(tangent * normalTangent.x + binormal * normalTangent.y + normal * normalTangent.z); 
    // @TODO: see if we can squeeze this normalize on SM2.0 as well
    // @TODO：看看我们是否可以在SM2.0上优化这个 normalize
#else
    // 如果不使用法线贴图，则直接返回T2W的法线基向量
    float3 normalWorld = normalize(tangentToWorld[2].xyz);
#endif
    return normalWorld;
}

// 如果使用视差贴图 
// @Remark:[ParallaxMap]
#ifdef _PARALLAXMAP
    // 使用视差贴图，将切空间的viewDir打包存放在 Tangent To World的四维数组里
    #define IN_VIEWDIR4PARALLAX(i) NormalizePerPixelNormal(half3(i.tangentToWorldAndPackedData[0].w,i.tangentToWorldAndPackedData[1].w,i.tangentToWorldAndPackedData[2].w))
    #define IN_VIEWDIR4PARALLAX_FWDADD(i) NormalizePerPixelNormal(i.viewDirForParallax.xyz)
#else
    #define IN_VIEWDIR4PARALLAX(i) half3(0,0,0)
    #define IN_VIEWDIR4PARALLAX_FWDADD(i) half3(0,0,0)
#endif

// 在Fragment程序中是否需要 WorldPos
#if UNITY_REQUIRE_FRAG_WORLDPOS
    // 是否将WorldPos 打包存在TangentToWorld的数组中
    #if UNITY_PACK_WORLDPOS_WITH_TANGENT
        #define IN_WORLDPOS(i) half3(i.tangentToWorldAndPackedData[0].w,i.tangentToWorldAndPackedData[1].w,i.tangentToWorldAndPackedData[2].w)
    #else
        #define IN_WORLDPOS(i) i.posWorld
    #endif
    // @TODO: 在Add中不使用法线吗？
    #define IN_WORLDPOS_FWDADD(i) i.posWorld
#else
    #define IN_WORLDPOS(i) half3(0,0,0)
    #define IN_WORLDPOS_FWDADD(i) half3(0,0,0)
#endif

// ForwardAdd中Fragment 程序获取灯光方向
#define IN_LIGHTDIR_FWDADD(i) half3(i.tangentToWorldAndLightDir[0].w, i.tangentToWorldAndLightDir[1].w, i.tangentToWorldAndLightDir[2].w)

// 初始化ForwardBase中 FragmentCommonData
#define FRAGMENT_SETUP(x) FragmentCommonData x = \
    FragmentSetup(i.tex, i.eyeVec, IN_VIEWDIR4PARALLAX(i), i.tangentToWorldAndPackedData, IN_WORLDPOS(i));

// 初始化ForwardAdd 中 FragmentCommonData
#define FRAGMENT_SETUP_FWDADD(x) FragmentCommonData x = \
    FragmentSetup(i.tex, i.eyeVec, IN_VIEWDIR4PARALLAX_FWDADD(i), i.tangentToWorldAndLightDir, IN_WORLDPOS_FWDADD(i));

// 用于存放Fragment中需要使用的一些通用数据的结构体
struct FragmentCommonData
{
    half3 diffColor, specColor; // 漫反射颜色，高光颜色
    // Note: smoothness & oneMinusReflectivity for optimization purposes, mostly for DX9 SM2.0 level.
    // 注意：使用 smoothness 和 oneMinusReflectivity 是出于优化的目的，尤其是针对 DX9 SM2.0 的等级。
    // Most of the math is being done on these (1-x) values, and that saves a few precious ALU slots.
    // 大多数的数学运算都是使用这些(1-x)的值，这样就能节省一些ALU（逻辑运算单元）的资源。
    // @Remark:[smoothness&oneMinusReflectivity]
    half oneMinusReflectivity, smoothness; // 简化版1-反射率，应该是 perceptual Smoothness 感知光泽度，即 1 - perceptual Roughness
    float3 normalWorld; // 世界空间法线
    float3 eyeVec; // 视向量，从摄像机指向顶点
    half alpha; // alpha透明度
    float3 posWorld; // 世界空间顶点位置

#if UNITY_STANDARD_SIMPLE
    // @TODO
    half3 reflUVW;
#endif

#if UNITY_STANDARD_SIMPLE
    // 切空间法线 // @Remark [tangentSpaceNormal]
    half3 tangentSpaceNormal; // 切空间的法线
#endif
};

// 定义BRDF的输入模式，有 SpecularSetup RoughnessSetup MetallicSetup 三种
#ifndef UNITY_SETUP_BRDF_INPUT
    #define UNITY_SETUP_BRDF_INPUT SpecularSetup
#endif

// Specular/Smoothness 镜面反射/光泽度 工作流输入模式 获取 FragmentCommonData
// @Remark [SpecularSetup]
inline FragmentCommonData SpecularSetup (float4 i_tex)
{
    // 获取反射率和光泽度
    half4 specGloss = SpecularGloss(i_tex.xy); 
    half3 specColor = specGloss.rgb;
    half smoothness = specGloss.a;

    // 根据反射率、光泽度以及相关贴图 获取 diffColor 漫反射颜色 和 oneMinusReflectivity
    half oneMinusReflectivity;
    half3 diffColor = EnergyConservationBetweenDiffuseAndSpecular (Albedo(i_tex), specColor, /*out*/ oneMinusReflectivity);

    FragmentCommonData o = (FragmentCommonData)0;
    o.diffColor = diffColor;
    o.specColor = specColor;
    o.oneMinusReflectivity = oneMinusReflectivity;
    o.smoothness = smoothness;

    return o;
}

// Metallic/Roughness 金属/粗糙度 工作流输入模式 获取 FragmentCommonData
// @Remark [RoughnessSetup]
inline FragmentCommonData RoughnessSetup(float4 i_tex)
{
    // 获取金属度和光泽度
    half2 metallicGloss = MetallicRough(i_tex.xy);
    half metallic = metallicGloss.x;
    half smoothness = metallicGloss.y; // this is 1 minus the square root of real roughness m. // 这是1减真实粗糙度m的平方根 // @TODO Why?

    // 根据金属度和相关贴图获取 diffColor 漫反射颜色 specColor 镜面反射颜色 和 oneMinusReflectivity
    half oneMinusReflectivity;
    half3 specColor;
    half3 diffColor = DiffuseAndSpecularFromMetallic(Albedo(i_tex), metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

    FragmentCommonData o = (FragmentCommonData)0;
    o.diffColor = diffColor;
    o.specColor = specColor;
    o.oneMinusReflectivity = oneMinusReflectivity;
    o.smoothness = smoothness;
    return o;
}

// Metallic/Glossness 金属/光泽度 工作流输入模式 获取 FragmentCommonData
// @Remark [MetallicSetup]
inline FragmentCommonData MetallicSetup (float4 i_tex)
{
    half2 metallicGloss = MetallicGloss(i_tex.xy);
    half metallic = metallicGloss.x;
    half smoothness = metallicGloss.y; // this is 1 minus the square root of real roughness m. // 这是1减真实粗糙度m的平方根 // @TODO Why?

    // 根据金属度和相关贴图获取 diffColor 漫反射颜色 specColor 镜面反射颜色 和 oneMinusReflectivity
    half oneMinusReflectivity;
    half3 specColor;
    half3 diffColor = DiffuseAndSpecularFromMetallic (Albedo(i_tex), metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

    FragmentCommonData o = (FragmentCommonData)0;
    o.diffColor = diffColor;
    o.specColor = specColor;
    o.oneMinusReflectivity = oneMinusReflectivity;
    o.smoothness = smoothness;
    return o;
}

// parallax transformed texcoord is used to sample occlusion
// 视差转换坐标，用于采样遮蔽 
inline FragmentCommonData FragmentSetup (inout float4 i_tex, float3 i_eyeVec, half3 i_viewDirForParallax, float4 tangentToWorld[3], float3 i_posWorld)
{
    // 计算视差贴图偏移之后的UV坐标
    i_tex = Parallax(i_tex, i_viewDirForParallax);

    // 获取Alpha 以及是否需要使用Alpha进行剔除操作
    half alpha = Alpha(i_tex.xy);
    #if defined(_ALPHATEST_ON)
        clip (alpha - _Cutoff);
    #endif

    FragmentCommonData o = UNITY_SETUP_BRDF_INPUT (i_tex); // 根据三种不同得到输入获取Fragment程序需要用到的通用数据
    o.normalWorld = PerPixelWorldNormal(i_tex, tangentToWorld); // 根据不同情况获取世界空间的法线
    o.eyeVec = NormalizePerPixelNormal(i_eyeVec); // 归一化视向量
    o.posWorld = i_posWorld; // 世界空间顶点位置

    // NOTE: shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
    // 注意：shader 的 alpha混合模式(_SrcBlend = One, _DstBlend = OneMinusSrcAlpha) 依赖于预乘
    o.diffColor = PreMultiplyAlpha (o.diffColor, alpha, o.oneMinusReflectivity, /*out*/ o.alpha);
    return o;
}

// Unity 中计算全局光照
inline UnityGI FragmentGI (FragmentCommonData s, half occlusion, half4 i_ambientOrLightmapUV, half atten, UnityLight light, bool reflections)
{
    UnityGIInput d;
    d.light = light;
    d.worldPos = s.posWorld;
    d.worldViewDir = -s.eyeVec;
    d.atten = atten;

    // 是否使用灯光贴图，使用灯光贴图就不使用环境光
    #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
        d.ambient = 0;
        d.lightmapUV = i_ambientOrLightmapUV;
    #else
        d.ambient = i_ambientOrLightmapUV.rgb;
        d.lightmapUV = 0;
    #endif

    // @TODO: unity_SpecCube0_HDR unity_SpecCube1_HDR 具体指什么
    d.probeHDR[0] = unity_SpecCube0_HDR;
    d.probeHDR[1] = unity_SpecCube1_HDR;
    #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
      d.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending // w 存储用混合的差值变量
    #endif

    // @TODO
    #ifdef UNITY_SPECCUBE_BOX_PROJECTION
      d.boxMax[0] = unity_SpecCube0_BoxMax;
      d.probePosition[0] = unity_SpecCube0_ProbePosition;
      d.boxMax[1] = unity_SpecCube1_BoxMax;
      d.boxMin[1] = unity_SpecCube1_BoxMin;
      d.probePosition[1] = unity_SpecCube1_ProbePosition;
    #endif

    if(reflections)
    {
        Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.smoothness, -s.eyeVec, s.normalWorld, s.specColor); // 计算Unity_GlossyEnvironmentData数据
        
        // Replace the reflUVW if it has been compute in Vertex shader. Note: the compiler will optimize the calcul in UnityGlossyEnvironmentSetup itself
        // 如果已经在Vertex着色器中计算过，则替换reflUVW。注意，编译器会优化 UnityGlossyEnvironmentSetup 中的计算。
        #if UNITY_STANDARD_SIMPLE
            g.reflUVW = s.reflUVW;
        #endif

        return UnityGlobalIllumination (d, occlusion, s.normalWorld, g);
    }
    else
    {
        return UnityGlobalIllumination (d, occlusion, s.normalWorld);
    }
}

// 如果没有明确指明是否使用反射，则默认开启
inline UnityGI FragmentGI (FragmentCommonData s, half occlusion, half4 i_ambientOrLightmapUV, half atten, UnityLight light)
{
    return FragmentGI(s, occlusion, i_ambientOrLightmapUV, atten, light, true);
}


//-------------------------------------------------------------------------------------
// 最终输出对Alpha作处理
half4 OutputForward (half4 output, half alphaFromSurface)
{
    #if defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON)
        output.a = alphaFromSurface;
    #else
        UNITY_OPAQUE_ALPHA(output.a); // 使用不透明的Alpha 
    #endif
    return output;
}

// 顶点着色其中的GI
inline half4 VertexGIForward(VertexInput v, float3 posWorld, half3 normalWorld)
{
    half4 ambientOrLightmapUV = 0;
    // Static lightmaps // 静态灯光贴图
    #ifdef LIGHTMAP_ON
        ambientOrLightmapUV.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
        ambientOrLightmapUV.zw = 0;
    // Sample light probe for Dynamic objects only (no static or dynamic lightmaps)
    // 仅针对动态物体（不是静态或动态灯光贴图的物体）采样灯光探针
    #elif UNITY_SHOULD_SAMPLE_SH
        #ifdef VERTEXLIGHT_ON
            // Approximated illumination from non-important point lights
            // 从 non-important 的点光源中近似照明
            ambientOrLightmapUV.rgb = Shade4PointLights (
                unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                unity_4LightAtten0, posWorld, normalWorld);
        #endif

        ambientOrLightmapUV.rgb = ShadeSHPerVertex (normalWorld, ambientOrLightmapUV.rgb); // 逐顶点的SH光
    #endif

    #ifdef DYNAMICLIGHTMAP_ON
        ambientOrLightmapUV.zw = v.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
    #endif

    return ambientOrLightmapUV;
}

// ------------------------------------------------------------------
//  Base forward pass (directional light, emission, lightmaps, ...)
// Base forward pass (包含方向光，自发光，灯光贴图，...)

// Forward Base 中 Vertex着色器输出到Fragment着色器的结构体，就是通常所用的 v2f
struct VertexOutputForwardBase
{
    UNITY_POSITION(pos);                                  // 位置
    float4 tex                            : TEXCOORD0;    // 纹理坐标
    float3 eyeVec                         : TEXCOORD1;
    float4 tangentToWorldAndPackedData[3] : TEXCOORD2;    // [3x3:tangentToWorld | 1x3:viewDirForParallax or worldPos] // [3x3: 用于计算 TangentToWorld 的数组 | 1x3: 用于计算视差贴图的视向量 或 世界空间顶点位置] // @Remark: [tangentToWorld] // @Remark: [TEXCOORD]
    half4 ambientOrLightmapUV             : TEXCOORD5;    // SH or Lightmap UV // SH 灯光 或者 灯光贴图UV
    UNITY_SHADOW_COORDS(6)                                // 阴影坐标
    UNITY_FOG_COORDS(7)                                   // 雾坐标

    // next ones would not fit into SM2.0 limits, but they are always for SM3.0+
    // 接下来的数量将不适合 SM2.0 的限制，但是他们总是适用于 SM3.0+

    // 在Fragment着色器中需要world pos 并且没有将它打包在上面的 TangentToWorld的数组里
    #if UNITY_REQUIRE_FRAG_WORLDPOS && !UNITY_PACK_WORLDPOS_WITH_TANGENT 
        float3 posWorld                 : TEXCOORD8;
    #endif

    // 为该顶点设置一个实例化的ID，这么做是为了实现 GPU Instancing
    UNITY_VERTEX_INPUT_INSTANCE_ID
    // 在顶点着色器输出结构中声明目标的立体眼场，左眼和右眼，用于VR渲染，防止渲染两遍
    UNITY_VERTEX_OUTPUT_STEREO
};

// Forward Base 的Vertex着色程序
VertexOutputForwardBase vertForwardBase (VertexInput v)
{
    UNITY_SETUP_INSTANCE_ID(v); // 设置顶点实例化ID
    VertexOutputForwardBase o; // 声明输出结构体
    UNITY_INITIALIZE_OUTPUT(VertexOutputForwardBase, o); //初始化结构体
    
    // @TODO :Unity的GPU Instance 具体的实现原理
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    // 计算世界空间的顶点位置
    float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
    #if UNITY_REQUIRE_FRAG_WORLDPOS
        #if UNITY_PACK_WORLDPOS_WITH_TANGENT
            o.tangentToWorldAndPackedData[0].w = posWorld.x;
            o.tangentToWorldAndPackedData[1].w = posWorld.y;
            o.tangentToWorldAndPackedData[2].w = posWorld.z;
        #else
            o.posWorld = posWorld.xyz;
        #endif
    #endif

    o.pos = UnityObjectToClipPos(v.vertex); // 转换顶点位置到屏幕空间

    o.tex = TexCoords(v); // 计算纹理坐标
    o.eyeVec = NormalizePerVertexNormal(posWorld.xyz - _WorldSpaceCameraPos); // 从摄像机指向顶点的向量
    float3 normalWorld = UnityObjectToWorldNormal(v.normal); // 世界空间的法线
    #ifdef _TANGENT_TO_WORLD
        float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);

        float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w); // 计算切空间到世界空间变换用的数组
        o.tangentToWorldAndPackedData[0].xyz = tangentToWorld[0];
        o.tangentToWorldAndPackedData[1].xyz = tangentToWorld[1];
        o.tangentToWorldAndPackedData[2].xyz = tangentToWorld[2];
    #else
        o.tangentToWorldAndPackedData[0].xyz = 0;
        o.tangentToWorldAndPackedData[1].xyz = 0;
        o.tangentToWorldAndPackedData[2].xyz = normalWorld;
    #endif

    //We need this for shadow receving // 我们需要这个来接受投影
    UNITY_TRANSFER_SHADOW(o, v.uv1);

    o.ambientOrLightmapUV = VertexGIForward(v, posWorld, normalWorld); // 顶点GI

    #ifdef _PARALLAXMAP
        TANGENT_SPACE_ROTATION;
        half3 viewDirForParallax = mul (rotation, ObjSpaceViewDir(v.vertex));
        o.tangentToWorldAndPackedData[0].w = viewDirForParallax.x;
        o.tangentToWorldAndPackedData[1].w = viewDirForParallax.y;
        o.tangentToWorldAndPackedData[2].w = viewDirForParallax.z;
    #endif

    UNITY_TRANSFER_FOG(o,o.pos);
    return o;
}

// Forward Base 的 Fragment 着色内部程序
half4 fragForwardBaseInternal (VertexOutputForwardBase i)
{
    UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy); // 应用交叉防抖动淡入淡出

    FRAGMENT_SETUP(s) // 获取 FragmentCommonData 数据

    // @TODO : GPU Instance 用到的ID
    UNITY_SETUP_INSTANCE_ID(i);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

    UnityLight mainLight = MainLight (); // 获取主灯光参数
    UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld); // 获取灯光衰减

    half occlusion = Occlusion(i.tex.xy); // 获取环境光遮蔽
    UnityGI gi = FragmentGI (s, occlusion, i.ambientOrLightmapUV, atten, mainLight); // 获取全局光照GI

    // 根据BRDF计算着色
    half4 c = UNITY_BRDF_PBS (s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect);
    c.rgb += Emission(i.tex.xy); // 加上自发光的效果

    UNITY_APPLY_FOG(i.fogCoord, c.rgb);
    return OutputForward (c, s.alpha); // 最终输出对Alpha做处理
}

// Forward Base 的 Fragment 着色程序
half4 fragForwardBase (VertexOutputForwardBase i) : SV_Target   // backward compatibility (this used to be the fragment entry function) // 向后兼容性（这曾经是Fragment函数的入口）
{
    return fragForwardBaseInternal(i);
}

// ------------------------------------------------------------------
//  Additive forward pass (one light per pass)
//  Additive 前向Pass (每个Pass计算一次灯光)

struct VertexOutputForwardAdd
{
    UNITY_POSITION(pos);                                // 位置
    float4 tex                          : TEXCOORD0;    // 纹理坐标
    float3 eyeVec                       : TEXCOORD1;    // 视向量，从摄像机指向顶点
    float4 tangentToWorldAndLightDir[3] : TEXCOORD2;    // [3x3:tangentToWorld | 1x3:lightDir] // [3x3: 用于计算 TangentToWorld 的数组 | 1x3:世界空间灯光方向 ] // @Remark: [tangentToWorld]
    float3 posWorld                     : TEXCOORD5;    // 世界空间位置
    UNITY_SHADOW_COORDS(6)                              // 阴影坐标
    UNITY_FOG_COORDS(7)                                 // 雾坐标

    // next ones would not fit into SM2.0 limits, but they are always for SM3.0+
    // 下一个不适合SM2.0的限制，但是他始终在SM3.0+下执行。
#if defined(_PARALLAXMAP)
    half3 viewDirForParallax            : TEXCOORD8;
#endif

    // 在顶点着色器输出结构中声明目标的立体眼场，左眼和右眼，用于VR渲染，防止渲染两遍
    UNITY_VERTEX_OUTPUT_STEREO
};

// Forward Add 的Vertex 程序
VertexOutputForwardAdd vertForwardAdd (VertexInput v)
{
    // @Remark: [UnityInstancing][STEREO]
    UNITY_SETUP_INSTANCE_ID(v);
    VertexOutputForwardAdd o;
    UNITY_INITIALIZE_OUTPUT(VertexOutputForwardAdd, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    float4 posWorld = mul(unity_ObjectToWorld, v.vertex); // 世界空间顶点位置
    o.pos = UnityObjectToClipPos(v.vertex); // MVP矩阵变换 

    o.tex = TexCoords(v); // 求纹理坐标
    o.eyeVec = NormalizePerVertexNormal(posWorld.xyz - _WorldSpaceCameraPos); // 摄像机指向顶点的向量
    o.posWorld = posWorld.xyz;
    float3 normalWorld = UnityObjectToWorldNormal(v.normal); 
    #ifdef _TANGENT_TO_WORLD
        float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);

        float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w);
        o.tangentToWorldAndLightDir[0].xyz = tangentToWorld[0];
        o.tangentToWorldAndLightDir[1].xyz = tangentToWorld[1];
        o.tangentToWorldAndLightDir[2].xyz = tangentToWorld[2];
    #else
        o.tangentToWorldAndLightDir[0].xyz = 0;
        o.tangentToWorldAndLightDir[1].xyz = 0;
        o.tangentToWorldAndLightDir[2].xyz = normalWorld;
    #endif
    // We need this for shadow receiving
    // 我们需要这个来接受阴影
    UNITY_TRANSFER_SHADOW(o, v.uv1);

    float3 lightDir = _WorldSpaceLightPos0.xyz - posWorld.xyz * _WorldSpaceLightPos0.w; // 获取世界空间灯光方向
    #ifndef USING_DIRECTIONAL_LIGHT
        lightDir = NormalizePerVertexNormal(lightDir);
    #endif
    o.tangentToWorldAndLightDir[0].w = lightDir.x;
    o.tangentToWorldAndLightDir[1].w = lightDir.y;
    o.tangentToWorldAndLightDir[2].w = lightDir.z;

    #ifdef _PARALLAXMAP
        TANGENT_SPACE_ROTATION;
        o.viewDirForParallax = mul (rotation, ObjSpaceViewDir(v.vertex));
    #endif

    UNITY_TRANSFER_FOG(o,o.pos);
    return o;
}

// Forward Add 的 Fragment 内部程序
half4 fragForwardAddInternal (VertexOutputForwardAdd i)
{
    UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy); // 应用抖动的交叉淡入淡出

    FRAGMENT_SETUP_FWDADD(s) // 获取 Fragmentdata 数据 Add和Base的区别是worldPos 和 tangentViewDir输入的区别

    UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld) // 获取灯光衰减
    UnityLight light = AdditiveLight (IN_LIGHTDIR_FWDADD(i), atten); // 获取灯光参数
    UnityIndirect noIndirect = ZeroIndirect (); // Add不考虑间接光

    half4 c = UNITY_BRDF_PBS (s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, light, noIndirect);

    UNITY_APPLY_FOG_COLOR(i.fogCoord, c.rgb, half4(0,0,0,0)); // fog towards black in additive pass // Add pass 中雾的背景是黑色
    return OutputForward (c, s.alpha); // 最后输出，处理Alpha
}

// Fragment Add 的 Fragement 程序入口
half4 fragForwardAdd (VertexOutputForwardAdd i) : SV_Target     // backward compatibility (this used to be the fragment entry function) // 向后兼容性（以前是片段入口函数）
{
    return fragForwardAddInternal(i);
}

// ------------------------------------------------------------------
//  Deferred pass
// @Remark: [DeferredPass]

struct VertexOutputDeferred
{
    UNITY_POSITION(pos);
    float4 tex                            : TEXCOORD0;    // 纹理坐标
    float3 eyeVec                         : TEXCOORD1;    // 视向量，从摄像机指向顶点
    float4 tangentToWorldAndPackedData[3] : TEXCOORD2;    // [3x3:tangentToWorld | 1x3:viewDirForParallax or worldPos] // [3x3: 用于计算 TangentToWorld 的数组 | 1x3: 用于计算视差贴图的视向量 或 世界空间顶点位置] // @Remark: [tangentToWorld] // @Remark: [TEXCOORD]
    half4 ambientOrLightmapUV             : TEXCOORD5;    // SH or Lightmap UVs // 存放SH光照结果 或灯光贴图UV

    // 需要在Fragement中使用World Pos 并且没有把World Pos 打包在 Tangent 中 
    #if UNITY_REQUIRE_FRAG_WORLDPOS && !UNITY_PACK_WORLDPOS_WITH_TANGENT
        float3 posWorld                     : TEXCOORD6;  // 世界空间顶点坐标
    #endif

    UNITY_VERTEX_OUTPUT_STEREO
};

// Deferred 的Vertex Shader 入口程序
VertexOutputDeferred vertDeferred (VertexInput v)
{
    UNITY_SETUP_INSTANCE_ID(v); // 设置顶点实例化ID // @Remark: [UnityInstancing]
    VertexOutputDeferred o; 
    UNITY_INITIALIZE_OUTPUT(VertexOutputDeferred, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    float4 posWorld = mul(unity_ObjectToWorld, v.vertex); // 计算世界空间位置坐标
    #if UNITY_REQUIRE_FRAG_WORLDPOS
        #if UNITY_PACK_WORLDPOS_WITH_TANGENT
            o.tangentToWorldAndPackedData[0].w = posWorld.x;
            o.tangentToWorldAndPackedData[1].w = posWorld.y;
            o.tangentToWorldAndPackedData[2].w = posWorld.z;
        #else
            o.posWorld = posWorld.xyz;
        #endif
    #endif
    o.pos = UnityObjectToClipPos(v.vertex);

    o.tex = TexCoords(v);
    o.eyeVec = NormalizePerVertexNormal(posWorld.xyz - _WorldSpaceCameraPos);
    float3 normalWorld = UnityObjectToWorldNormal(v.normal);
    #ifdef _TANGENT_TO_WORLD
        float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);

        float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w);
        o.tangentToWorldAndPackedData[0].xyz = tangentToWorld[0];
        o.tangentToWorldAndPackedData[1].xyz = tangentToWorld[1];
        o.tangentToWorldAndPackedData[2].xyz = tangentToWorld[2];
    #else
        o.tangentToWorldAndPackedData[0].xyz = 0;
        o.tangentToWorldAndPackedData[1].xyz = 0;
        o.tangentToWorldAndPackedData[2].xyz = normalWorld;
    #endif

    o.ambientOrLightmapUV = 0;
    #ifdef LIGHTMAP_ON
        o.ambientOrLightmapUV.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
    #elif UNITY_SHOULD_SAMPLE_SH
        o.ambientOrLightmapUV.rgb = ShadeSHPerVertex (normalWorld, o.ambientOrLightmapUV.rgb);
    #endif
    #ifdef DYNAMICLIGHTMAP_ON
        o.ambientOrLightmapUV.zw = v.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
    #endif

    #ifdef _PARALLAXMAP
        TANGENT_SPACE_ROTATION;
        half3 viewDirForParallax = mul (rotation, ObjSpaceViewDir(v.vertex));
        o.tangentToWorldAndPackedData[0].w = viewDirForParallax.x;
        o.tangentToWorldAndPackedData[1].w = viewDirForParallax.y;
        o.tangentToWorldAndPackedData[2].w = viewDirForParallax.z;
    #endif

    return o;
}

void fragDeferred (
    VertexOutputDeferred i,
    out half4 outGBuffer0 : SV_Target0,
    out half4 outGBuffer1 : SV_Target1,
    out half4 outGBuffer2 : SV_Target2,
    out half4 outEmission : SV_Target3          // RT3: emission (rgb), --unused-- (a)
#if defined(SHADOWS_SHADOWMASK) && (UNITY_ALLOWED_MRT_COUNT > 4)
    ,out half4 outShadowMask : SV_Target4       // RT4: shadowmask (rgba)
#endif
)
{
    #if (SHADER_TARGET < 30)
        outGBuffer0 = 1;
        outGBuffer1 = 1;
        outGBuffer2 = 0;
        outEmission = 0;
        #if defined(SHADOWS_SHADOWMASK) && (UNITY_ALLOWED_MRT_COUNT > 4)
            outShadowMask = 1;
        #endif
        return;
    #endif

    UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

    FRAGMENT_SETUP(s)

    // no analytic lights in this pass
    // 不计算灯光
    UnityLight dummyLight = DummyLight ();
    half atten = 1;

    // only GI
    half occlusion = Occlusion(i.tex.xy);
#if UNITY_ENABLE_REFLECTION_BUFFERS
    bool sampleReflectionsInDeferred = false;
#else
    bool sampleReflectionsInDeferred = true;
#endif

    UnityGI gi = FragmentGI (s, occlusion, i.ambientOrLightmapUV, atten, dummyLight, sampleReflectionsInDeferred);

    half3 emissiveColor = UNITY_BRDF_PBS (s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect).rgb;

    #ifdef _EMISSION
        emissiveColor += Emission (i.tex.xy);
    #endif

    #ifndef UNITY_HDR_ON
        emissiveColor.rgb = exp2(-emissiveColor.rgb);
    #endif

    UnityStandardData data;
    data.diffuseColor   = s.diffColor;
    data.occlusion      = occlusion;
    data.specularColor  = s.specColor;
    data.smoothness     = s.smoothness;
    data.normalWorld    = s.normalWorld;

    UnityStandardDataToGbuffer(data, outGBuffer0, outGBuffer1, outGBuffer2);

    // Emissive lighting buffer
    outEmission = half4(emissiveColor, 1);

    // Baked direct lighting occlusion if any
    #if defined(SHADOWS_SHADOWMASK) && (UNITY_ALLOWED_MRT_COUNT > 4)
        outShadowMask = UnityGetRawBakedOcclusions(i.ambientOrLightmapUV.xy, IN_WORLDPOS(i));
    #endif
}


//
// Old FragmentGI signature. Kept only for backward compatibility and will be removed soon
// 旧的FragmentGI 签名。 只保留向后兼容性，并将很快被删除
//

inline UnityGI FragmentGI(
    float3 posWorld,
    half occlusion, half4 i_ambientOrLightmapUV, half atten, half smoothness, half3 normalWorld, half3 eyeVec,
    UnityLight light,
    bool reflections)
{
    // we init only fields actually used
    // 我们只初始化实际使用的字段
    FragmentCommonData s = (FragmentCommonData)0;
    s.smoothness = smoothness;
    s.normalWorld = normalWorld;
    s.eyeVec = eyeVec;
    s.posWorld = posWorld;
    return FragmentGI(s, occlusion, i_ambientOrLightmapUV, atten, light, reflections);
}
inline UnityGI FragmentGI (
    float3 posWorld,
    half occlusion, half4 i_ambientOrLightmapUV, half atten, half smoothness, half3 normalWorld, half3 eyeVec,
    UnityLight light)
{
    return FragmentGI (posWorld, occlusion, i_ambientOrLightmapUV, atten, smoothness, normalWorld, eyeVec, light, true);
}

#endif // UNITY_STANDARD_CORE_INCLUDED
