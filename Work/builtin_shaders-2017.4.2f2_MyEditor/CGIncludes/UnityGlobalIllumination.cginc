// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef UNITY_GLOBAL_ILLUMINATION_INCLUDED
#define UNITY_GLOBAL_ILLUMINATION_INCLUDED

// Functions sampling light environment data (lightmaps, light probes, reflection probes), which is then returned as the UnityGI struct.
// 功能是 采样环境光的数据 (lightmaps 灯光贴图, light probes 灯光探针, reflection probes 反射探针), 结果会返回 UnityGI 的结构体.

#include "UnityImageBasedLighting.cginc"
#include "UnityStandardUtils.cginc"
#include "UnityShadowLibrary.cginc"

inline half3 DecodeDirectionalSpecularLightmap (half3 color, half4 dirTex, half3 normalWorld, bool isRealtimeLightmap, fixed4 realtimeNormalTex, out UnityLight o_light)
{
    o_light.color = color;
    o_light.dir = dirTex.xyz * 2 - 1;
    o_light.ndotl = 0; // Not use;

    // The length of the direction vector is the light's "directionality", i.e. 1 for all light coming from this direction,
    // lower values for more spread out, ambient light.
    half directionality = max(0.001, length(o_light.dir));
    o_light.dir /= directionality;

    #ifdef DYNAMICLIGHTMAP_ON
    if (isRealtimeLightmap)
    {
        // Realtime directional lightmaps' intensity needs to be divided by N.L
        // to get the incoming light intensity. Baked directional lightmaps are already
        // output like that (including the max() to prevent div by zero).
        half3 realtimeNormal = realtimeNormalTex.xyz * 2 - 1;
        o_light.color /= max(0.125, dot(realtimeNormal, o_light.dir));
    }
    #endif

    // Split light into the directional and ambient parts, according to the directionality factor.
    half3 ambient = o_light.color * (1 - directionality);
    o_light.color = o_light.color * directionality;

    // Technically this is incorrect, but helps hide jagged light edge at the object silhouettes and
    // makes normalmaps show up.
    ambient *= saturate(dot(normalWorld, o_light.dir));
    return ambient;
}

// 重置UnityLight 结构体
inline void ResetUnityLight(out UnityLight outLight)
{
    outLight.color = half3(0, 0, 0);
    outLight.dir = half3(0, 1, 0); // Irrelevant direction, just not null // 不相干的方向而已，这里只是不能为空
    outLight.ndotl = 0; // Not used // 不再使用
}

inline half3 SubtractMainLightWithRealtimeAttenuationFromLightmap (half3 lightmap, half attenuation, half4 bakedColorTex, half3 normalWorld)
{
    // Let's try to make realtime shadows work on a surface, which already contains
    // baked lighting and shadowing from the main sun light.
    half3 shadowColor = unity_ShadowColor.rgb;
    half shadowStrength = _LightShadowData.x;

    // Summary:
    // 1) Calculate possible value in the shadow by subtracting estimated light contribution from the places occluded by realtime shadow:
    //      a) preserves other baked lights and light bounces
    //      b) eliminates shadows on the geometry facing away from the light
    // 2) Clamp against user defined ShadowColor.
    // 3) Pick original lightmap value, if it is the darkest one.


    // 1) Gives good estimate of illumination as if light would've been shadowed during the bake.
    //    Preserves bounce and other baked lights
    //    No shadows on the geometry facing away from the light
    half ndotl = LambertTerm (normalWorld, _WorldSpaceLightPos0.xyz);
    half3 estimatedLightContributionMaskedByInverseOfShadow = ndotl * (1- attenuation) * _LightColor0.rgb;
    half3 subtractedLightmap = lightmap - estimatedLightContributionMaskedByInverseOfShadow;

    // 2) Allows user to define overall ambient of the scene and control situation when realtime shadow becomes too dark.
    half3 realtimeShadow = max(subtractedLightmap, shadowColor);
    realtimeShadow = lerp(realtimeShadow, lightmap, shadowStrength);

    // 3) Pick darkest color
    return min(lightmap, realtimeShadow);
}

// 重置UnityGI结构体中的数据
inline void ResetUnityGI(out UnityGI outGI)
{
    ResetUnityLight(outGI.light); // 重置UnitLight 

    // 重置间接光照
    outGI.indirect.diffuse = 0;
    outGI.indirect.specular = 0;
}

// 计算基础GI的函数
inline UnityGI UnityGI_Base(UnityGIInput data, half occlusion, half3 normalWorld)
{
    UnityGI o_gi;
    ResetUnityGI(o_gi); // 重置UnityGI

    // Base pass with Lightmap support is responsible for handling ShadowMask / blending here for performance reason
    // 出于性能的原因，支持Lightmap的基础Pass 负责在这里 处理ShadowMask 或 混合。
    // @Remark: [HANDLE_SHADOWS_BLENDING_IN_GI]
    #if defined(HANDLE_SHADOWS_BLENDING_IN_GI) // @TODO
        half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
        float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
        float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
        data.atten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
    #endif

    o_gi.light = data.light;
    o_gi.light.color *= data.atten; // 灯光做衰减

    // 计算球谐光照
    // @Remark: [SphericalHarmonic] // DOING
    #if UNITY_SHOULD_SAMPLE_SH
        o_gi.indirect.diffuse = ShadeSHPerPixel(normalWorld, data.ambient, data.worldPos);
    #endif

    #if defined(LIGHTMAP_ON)
        // Baked lightmaps
        half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, data.lightmapUV.xy);
        half3 bakedColor = DecodeLightmap(bakedColorTex);

        #ifdef DIRLIGHTMAP_COMBINED
            fixed4 bakedDirTex = UNITY_SAMPLE_TEX2D_SAMPLER (unity_LightmapInd, unity_Lightmap, data.lightmapUV.xy);
            o_gi.indirect.diffuse += DecodeDirectionalLightmap (bakedColor, bakedDirTex, normalWorld);

            #if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
                ResetUnityLight(o_gi.light);
                o_gi.indirect.diffuse = SubtractMainLightWithRealtimeAttenuationFromLightmap (o_gi.indirect.diffuse, data.atten, bakedColorTex, normalWorld);
            #endif

        #else // not directional lightmap
            o_gi.indirect.diffuse += bakedColor;

            #if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
                ResetUnityLight(o_gi.light);
                o_gi.indirect.diffuse = SubtractMainLightWithRealtimeAttenuationFromLightmap(o_gi.indirect.diffuse, data.atten, bakedColorTex, normalWorld);
            #endif

        #endif
    #endif

    #ifdef DYNAMICLIGHTMAP_ON
        // Dynamic lightmaps
        fixed4 realtimeColorTex = UNITY_SAMPLE_TEX2D(unity_DynamicLightmap, data.lightmapUV.zw);
        half3 realtimeColor = DecodeRealtimeLightmap (realtimeColorTex);

        #ifdef DIRLIGHTMAP_COMBINED
            half4 realtimeDirTex = UNITY_SAMPLE_TEX2D_SAMPLER(unity_DynamicDirectionality, unity_DynamicLightmap, data.lightmapUV.zw);
            o_gi.indirect.diffuse += DecodeDirectionalLightmap (realtimeColor, realtimeDirTex, normalWorld);
        #else
            o_gi.indirect.diffuse += realtimeColor;
        #endif
    #endif

    o_gi.indirect.diffuse *= occlusion;
    return o_gi;
}


inline half3 UnityGI_IndirectSpecular(UnityGIInput data, half occlusion, Unity_GlossyEnvironmentData glossIn)
{
    half3 specular;

    #ifdef UNITY_SPECCUBE_BOX_PROJECTION
        // we will tweak reflUVW in glossIn directly (as we pass it to Unity_GlossyEnvironment twice for probe0 and probe1), so keep original to pass into BoxProjectedCubemapDirection
        half3 originalReflUVW = glossIn.reflUVW;
        glossIn.reflUVW = BoxProjectedCubemapDirection (originalReflUVW, data.worldPos, data.probePosition[0], data.boxMin[0], data.boxMax[0]);
    #endif

    #ifdef _GLOSSYREFLECTIONS_OFF
        specular = unity_IndirectSpecColor.rgb;
    #else
        half3 env0 = Unity_GlossyEnvironment (UNITY_PASS_TEXCUBE(unity_SpecCube0), data.probeHDR[0], glossIn);
        #ifdef UNITY_SPECCUBE_BLENDING
            const float kBlendFactor = 0.99999;
            float blendLerp = data.boxMin[0].w;
            UNITY_BRANCH
            if (blendLerp < kBlendFactor)
            {
                #ifdef UNITY_SPECCUBE_BOX_PROJECTION
                    glossIn.reflUVW = BoxProjectedCubemapDirection (originalReflUVW, data.worldPos, data.probePosition[1], data.boxMin[1], data.boxMax[1]);
                #endif

                half3 env1 = Unity_GlossyEnvironment (UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1,unity_SpecCube0), data.probeHDR[1], glossIn);
                specular = lerp(env1, env0, blendLerp);
            }
            else
            {
                specular = env0;
            }
        #else
            specular = env0;
        #endif
    #endif

    return specular * occlusion;
}

// Deprecated old prototype but can't be move to Deprecated.cginc file due to order dependency
// 弃用的旧原型，但是由于顺序依赖性的原因，不能移动到 Deprecated.cginc
inline half3 UnityGI_IndirectSpecular(UnityGIInput data, half occlusion, half3 normalWorld, Unity_GlossyEnvironmentData glossIn)
{
    // normalWorld is not used
    return UnityGI_IndirectSpecular(data, occlusion, glossIn);
}

// 简单版本的Standard使用这个函数
inline UnityGI UnityGlobalIllumination (UnityGIInput data, half occlusion, half3 normalWorld)
{
    return UnityGI_Base(data, occlusion, normalWorld); // 计算基础的GI并直接返回
}

// 添加环境光对GI间接光Specular项的影响 
inline UnityGI UnityGlobalIllumination (UnityGIInput data, half occlusion, half3 normalWorld, Unity_GlossyEnvironmentData glossIn)
{
    UnityGI o_gi = UnityGI_Base(data, occlusion, normalWorld); // 计算基础的GI
    o_gi.indirect.specular = UnityGI_IndirectSpecular(data, occlusion, glossIn); // 单独处理计算间接光specular项
    return o_gi;
}

//
// Old UnityGlobalIllumination signatures. Kept only for backward compatibility and will be removed soon
// 旧的 UnityGlobalIllumination 函数签名。保留只为了向下兼容，并且很快会被移除
//

inline UnityGI UnityGlobalIllumination (UnityGIInput data, half occlusion, half smoothness, half3 normalWorld, bool reflections)
{
    if(reflections)
    {
        Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(smoothness, data.worldViewDir, normalWorld, float3(0, 0, 0));
        return UnityGlobalIllumination(data, occlusion, normalWorld, g);
    }
    else
    {
        return UnityGlobalIllumination(data, occlusion, normalWorld);
    }
}
inline UnityGI UnityGlobalIllumination (UnityGIInput data, half occlusion, half smoothness, half3 normalWorld)
{
#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
    // No need to sample reflection probes during deferred G-buffer pass
    bool sampleReflections = false;
#else
    bool sampleReflections = true;
#endif
    return UnityGlobalIllumination (data, occlusion, smoothness, normalWorld, sampleReflections);
}


#endif
