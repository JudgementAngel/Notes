// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef UNITY_STANDARD_UTILS_INCLUDED
#define UNITY_STANDARD_UTILS_INCLUDED

#include "UnityCG.cginc"
#include "UnityStandardConfig.cginc"

// Helper functions, maybe move into UnityCG.cginc

half SpecularStrength(half3 specular)
{
    #if (SHADER_TARGET < 30)
        // SM2.0: instruction count limitation
        // SM2.0: simplified SpecularStrength
        return specular.r; // Red channel - because most metals are either monocrhome or with redish/yellowish tint
    #else
        return max (max (specular.r, specular.g), specular.b);
    #endif
}

// Diffuse/Spec Energy conservation
// Diffuse/Spec 能量守恒
// @Remark:[EnergyConservationBetweenDiffuseAndSpecular]
inline half3 EnergyConservationBetweenDiffuseAndSpecular (half3 albedo, half3 specColor, out half oneMinusReflectivity)
{
    oneMinusReflectivity = 1 - SpecularStrength(specColor);
    #if !UNITY_CONSERVE_ENERGY
        return albedo;
    #elif UNITY_CONSERVE_ENERGY_MONOCHROME
        return albedo * oneMinusReflectivity;
    #else
        return albedo * (half3(1,1,1) - specColor);
    #endif
}

// 根据Metallic 计算 oneMinusReflectivity
// @Remark:[OneMinusReflectivityFromMetallic]
inline half OneMinusReflectivityFromMetallic(half metallic)
{
    // 简化推导：
    // We'll need oneMinusReflectivity, so
    // 我们 oneMinusReflectivity，所以：
    //   1-reflectivity = 1-lerp(dielectricSpec, 1, metallic) = lerp(1-dielectricSpec, 0, metallic)
    // store (1-dielectricSpec) in unity_ColorSpaceDielectricSpec.a, then
    // 存储 (1-dielectricSpec) 在 unity_ColorSpaceDielectricSpec.a 中，因此：
    //   1-reflectivity = lerp(alpha, 0, metallic) = alpha + metallic*(0 - alpha) =
    //                  = alpha - metallic * alpha
    half oneMinusDielectricSpec = unity_ColorSpaceDielectricSpec.a;
    return oneMinusDielectricSpec - metallic * oneMinusDielectricSpec;
}

// 根据metallic 和 albedo 计算Diffuse 和 Specular
inline half3 DiffuseAndSpecularFromMetallic (half3 albedo, half metallic, out half3 specColor, out half oneMinusReflectivity)
{
    specColor = lerp (unity_ColorSpaceDielectricSpec.rgb, albedo, metallic);
    oneMinusReflectivity = OneMinusReflectivityFromMetallic(metallic);

    // @TODO 这里要用albedo * oneMinusReflectivity ，而不是用 albedo*(1-Metallic)，个人猜测是为了能量守恒
    return albedo * oneMinusReflectivity;
}

// Alpha预乘主要用于 Standard 中特殊的 Transparent 的混合模式
// @Remarl: [PreMultiplyAlpha]
inline half3 PreMultiplyAlpha (half3 diffColor, half alpha, half oneMinusReflectivity, out half outModifiedAlpha)
{
    #if defined(_ALPHAPREMULTIPLY_ON)
        // NOTE: shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
        // 注意：shader 的 alpha混合模式(_SrcBlend = One, _DstBlend = OneMinusSrcAlpha) 依赖于预乘

        // Transparency 'removes' from Diffuse component
        // 从Diffuse 中 “移除” 透明部分
        diffColor *= alpha;

        #if (SHADER_TARGET < 30)
            // SM2.0: instruction count limitation
            // SM2.0: 指令计数限制
            // Instead will sacrifice part of physically based transparency where amount Reflectivity is affecting Transparency
            // 反而会牺牲基于物理的透明度，也就是反射率影响透明度的地方
            // SM2.0: uses unmodified alpha
            // SM2.0: 使用未修改的透明度
            outModifiedAlpha = alpha;
        #else
            // Reflectivity 'removes' from the rest of components, including Transparency
            // 将反射率从其他部分中“移除”，包括透明度 // @TODO Why?
            // outAlpha = 1-(1-alpha)*(1-reflectivity) = 1-(oneMinusReflectivity - alpha*oneMinusReflectivity) =
            //          = 1-oneMinusReflectivity + alpha*oneMinusReflectivity
            outModifiedAlpha = 1-oneMinusReflectivity + alpha*oneMinusReflectivity;
        #endif
    #else
        outModifiedAlpha = alpha;
    #endif
    return diffColor;
}

// Same as ParallaxOffset in Unity CG, except:
//  *) precision - half instead of float
// 和UnityCG.cginc中的ParallaxOffset 函数类似，除了：
// v的精度是half 而不是 float

// h 是高度图中的数值[0,1]
// height是外部输入的数值，表示缩放的大小[0.005, 0.08]
// viewDir是切空间的实现视向量
half2 ParallaxOffset1Step (half h, half height, half3 viewDir)
{
    h = h * height - height/2.0; // 对高度做映射
    half3 v = normalize(viewDir); // 归一化视向量
    v.z += 0.42; // 对z做偏移保证不会出现特别小的值或者小于等于0的值
    return h * (v.xy / v.z); // 计算UV偏移的量
}

half LerpOneTo(half b, half t)
{
    half oneMinusT = 1 - t;
    return oneMinusT + b * t;
}

half3 LerpWhiteTo(half3 b, half t)
{
    half oneMinusT = 1 - t;
    return half3(oneMinusT, oneMinusT, oneMinusT) + b * t;
}

half3 UnpackScaleNormalDXT5nm(half4 packednormal, half bumpScale)
{
    half3 normal;
    normal.xy = (packednormal.wy * 2 - 1);
    #if (SHADER_TARGET >= 30)
        // SM2.0: instruction count limitation
        // SM2.0: normal scaler is not supported
        normal.xy *= bumpScale;
    #endif
    normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
    return normal;
}

half3 UnpackScaleNormalRGorAG(half4 packednormal, half bumpScale)
{
    #if defined(UNITY_NO_DXT5nm)
        half3 normal = packednormal.xyz * 2 - 1;
        #if (SHADER_TARGET >= 30)
            // SM2.0: instruction count limitation
            // SM2.0: normal scaler is not supported
            normal.xy *= bumpScale;
        #endif
        return normal;
    #else
        // This do the trick
        packednormal.x *= packednormal.w;

        half3 normal;
        normal.xy = (packednormal.xy * 2 - 1);
        #if (SHADER_TARGET >= 30)
            // SM2.0: instruction count limitation
            // SM2.0: normal scaler is not supported
            normal.xy *= bumpScale;
        #endif
        normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
        return normal;
    #endif
}

half3 UnpackScaleNormal(half4 packednormal, half bumpScale)
{
    return UnpackScaleNormalRGorAG(packednormal, bumpScale);
}

half3 BlendNormals(half3 n1, half3 n2)
{
    return normalize(half3(n1.xy + n2.xy, n1.z*n2.z));
}

half3x3 CreateTangentToWorldPerVertex(half3 normal, half3 tangent, half tangentSign)
{
    // For odd-negative scale transforms we need to flip the sign
    half sign = tangentSign * unity_WorldTransformParams.w;
    half3 binormal = cross(normal, tangent) * sign;
    return half3x3(tangent, binormal, normal);
}

//-------------------------------------------------------------------------------------
half3 ShadeSHPerVertex (half3 normal, half3 ambient)
{
    #if UNITY_SAMPLE_FULL_SH_PER_PIXEL
        // Completely per-pixel
        // nothing to do here
    #elif (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
        // Completely per-vertex
        ambient += max(half3(0,0,0), ShadeSH9 (half4(normal, 1.0)));
    #else
        // L2 per-vertex, L0..L1 & gamma-correction per-pixel

        // NOTE: SH data is always in Linear AND calculation is split between vertex & pixel
        // Convert ambient to Linear and do final gamma-correction at the end (per-pixel)
        #ifdef UNITY_COLORSPACE_GAMMA
            ambient = GammaToLinearSpace (ambient);
        #endif
        ambient += SHEvalLinearL2 (half4(normal, 1.0));     // no max since this is only L2 contribution
    #endif

    return ambient;
}

half3 ShadeSHPerPixel (half3 normal, half3 ambient, float3 worldPos)
{
    half3 ambient_contrib = 0.0;

    #if UNITY_SAMPLE_FULL_SH_PER_PIXEL
        // Completely per-pixel
        #if UNITY_LIGHT_PROBE_PROXY_VOLUME
            if (unity_ProbeVolumeParams.x == 1.0)
                ambient_contrib = SHEvalLinearL0L1_SampleProbeVolume(half4(normal, 1.0), worldPos);
            else
                ambient_contrib = SHEvalLinearL0L1(half4(normal, 1.0));
        #else
            ambient_contrib = SHEvalLinearL0L1(half4(normal, 1.0));
        #endif

            ambient_contrib += SHEvalLinearL2(half4(normal, 1.0));

            ambient += max(half3(0, 0, 0), ambient_contrib);

        #ifdef UNITY_COLORSPACE_GAMMA
            ambient = LinearToGammaSpace(ambient);
        #endif
    #elif (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
        // Completely per-vertex
        // nothing to do here. Gamma conversion on ambient from SH takes place in the vertex shader, see ShadeSHPerVertex.
    #else
        // L2 per-vertex, L0..L1 & gamma-correction per-pixel
        // Ambient in this case is expected to be always Linear, see ShadeSHPerVertex()
        #if UNITY_LIGHT_PROBE_PROXY_VOLUME
            if (unity_ProbeVolumeParams.x == 1.0)
                ambient_contrib = SHEvalLinearL0L1_SampleProbeVolume (half4(normal, 1.0), worldPos);
            else
                ambient_contrib = SHEvalLinearL0L1 (half4(normal, 1.0));
        #else
            ambient_contrib = SHEvalLinearL0L1 (half4(normal, 1.0));
        #endif

        ambient = max(half3(0, 0, 0), ambient+ambient_contrib);     // include L2 contribution in vertex shader before clamp.
        #ifdef UNITY_COLORSPACE_GAMMA
            ambient = LinearToGammaSpace (ambient);
        #endif
    #endif

    return ambient;
}

//-------------------------------------------------------------------------------------
inline half3 BoxProjectedCubemapDirection (half3 worldRefl, float3 worldPos, float4 cubemapCenter, float4 boxMin, float4 boxMax)
{
    // Do we have a valid reflection probe?
    UNITY_BRANCH
    if (cubemapCenter.w > 0.0)
    {
        half3 nrdir = normalize(worldRefl);

        #if 1
            half3 rbmax = (boxMax.xyz - worldPos) / nrdir;
            half3 rbmin = (boxMin.xyz - worldPos) / nrdir;

            half3 rbminmax = (nrdir > 0.0f) ? rbmax : rbmin;

        #else // Optimized version
            half3 rbmax = (boxMax.xyz - worldPos);
            half3 rbmin = (boxMin.xyz - worldPos);

            half3 select = step (half3(0,0,0), nrdir);
            half3 rbminmax = lerp (rbmax, rbmin, select);
            rbminmax /= nrdir;
        #endif

        half fa = min(min(rbminmax.x, rbminmax.y), rbminmax.z);

        worldPos -= cubemapCenter.xyz;
        worldRefl = worldPos + nrdir * fa;
    }
    return worldRefl;
}


//-------------------------------------------------------------------------------------
// Derivative maps
// http://www.rorydriscoll.com/2012/01/11/derivative-maps/
// For future use.

// Project the surface gradient (dhdx, dhdy) onto the surface (n, dpdx, dpdy)
half3 CalculateSurfaceGradient(half3 n, half3 dpdx, half3 dpdy, half dhdx, half dhdy)
{
    half3 r1 = cross(dpdy, n);
    half3 r2 = cross(n, dpdx);
    return (r1 * dhdx + r2 * dhdy) / dot(dpdx, r1);
}

// Move the normal away from the surface normal in the opposite surface gradient direction
half3 PerturbNormal(half3 n, half3 dpdx, half3 dpdy, half dhdx, half dhdy)
{
    //TODO: normalize seems to be necessary when scales do go beyond the 2...-2 range, should we limit that?
    //how expensive is a normalize? Anything cheaper for this case?
    return normalize(n - CalculateSurfaceGradient(n, dpdx, dpdy, dhdx, dhdy));
}

// Calculate the surface normal using the uv-space gradient (dhdu, dhdv)
half3 CalculateSurfaceNormal(half3 position, half3 normal, half2 gradient, half2 uv)
{
    half3 dpdx = ddx(position);
    half3 dpdy = ddy(position);

    half dhdx = dot(gradient, ddx(uv));
    half dhdy = dot(gradient, ddy(uv));

    return PerturbNormal(normal, dpdx, dpdy, dhdx, dhdy);
}


#endif // UNITY_STANDARD_UTILS_INCLUDED
