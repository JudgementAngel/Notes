// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef UNITY_STANDARD_BRDF_INCLUDED
#define UNITY_STANDARD_BRDF_INCLUDED

#include "UnityCG.cginc"
#include "UnityStandardConfig.cginc"
#include "UnityLightingCommon.cginc"

//-----------------------------------------------------------------------------
// Helper to convert smoothness to roughness
// 转化光滑度到粗糙度的帮助函数
//-----------------------------------------------------------------------------

float PerceptualRoughnessToRoughness(float perceptualRoughness)
{
    return perceptualRoughness * perceptualRoughness;
}

half RoughnessToPerceptualRoughness(half roughness)
{
    return sqrt(roughness);
}

// Smoothness is the user facing name
// Smoothness 是用户面对的名字
// it should be perceptualSmoothness but we don't want the user to have to deal with this name
// 它应该是 perceptual Smoothness 感知光泽度 但是我们不希望用户应付这个名字
// 从 Perceptual Smoothness 获取 Roughness (不是 Perceptual Roughness)
half SmoothnessToRoughness(half smoothness)
{
    return (1 - smoothness) * (1 - smoothness);
}

// 从 Perceptual Smoothness 获取 Perceptual Roughness
float SmoothnessToPerceptualRoughness(float smoothness)
{
    return (1 - smoothness);
}

//-------------------------------------------------------------------------------------

inline half Pow4 (half x)
{
    return x*x*x*x;
}

inline float2 Pow4 (float2 x)
{
    return x*x*x*x;
}

inline half3 Pow4 (half3 x)
{
    return x*x*x*x;
}

inline half4 Pow4 (half4 x)
{
    return x*x*x*x;
}

// Pow5 uses the same amount of instructions as generic pow(), but has 2 advantages:
// Pow5 和通用的pow()使用相同的指令数，但是有两个优点：
// 1) better instruction pipelining // 1) 更好的指令流水线
// 2) no need to worry about NaNs // 2) 不需要担心NaNs(非数元素) ?
inline half Pow5 (half x)
{
    return x*x * x*x * x;
}

inline half2 Pow5 (half2 x)
{
    return x*x * x*x * x;
}

inline half3 Pow5 (half3 x)
{
    return x*x * x*x * x;
}

inline half4 Pow5 (half4 x)
{
    return x*x * x*x * x;
}

inline half3 FresnelTerm (half3 F0, half cosA)
{
    half t = Pow5 (1 - cosA);   // ala Schlick interpoliation
    return F0 + (1-F0) * t;
}
inline half3 FresnelLerp (half3 F0, half3 F90, half cosA)
{
    half t = Pow5 (1 - cosA);   // ala Schlick interpoliation
    return lerp (F0, F90, t);
}
// approximage Schlick with ^4 instead of ^5
// 用 4次方 来代替 5次方 来近似优化 Schlick 的结果
inline half3 FresnelLerpFast (half3 F0, half3 F90, half cosA)
{
    half t = Pow4 (1 - cosA);
    return lerp (F0, F90, t);
}

// Note: Disney diffuse must be multiply by diffuseAlbedo / PI. This is done outside of this function.
// 注意：Disney 漫反射必须乘 diffuseAlbedo / PI 。 这一部分在这个函数外面实现
half DisneyDiffuse(half NdotV, half NdotL, half LdotH, half perceptualRoughness)
{
    half fd90 = 0.5 + 2 * LdotH * LdotH * perceptualRoughness;
    // Two schlick fresnel term // 两个 schlick Fresnel 项
    half lightScatter   = (1 + (fd90 - 1) * Pow5(1 - NdotL));
    half viewScatter    = (1 + (fd90 - 1) * Pow5(1 - NdotV));

    return lightScatter * viewScatter;
}

// NOTE: Visibility term here is the full form from Torrance-Sparrow model, it includes Geometric term: V = G / (N.L * N.V)
// This way it is easier to swap Geometric terms and more room for optimizations (except maybe in case of CookTorrance geom term)
// 注意：可见项是来自 Torrance-Sparrow 模型的完整形式，它包含了 几何遮挡项 ： V = G / (N.L * N.V)
// 这种方式可以更容易地交换几何项，并且有更多空间进行优化（除了可能在CookTorrance几何术语的情况下）

// Generic Smith-Schlick visibility term // 通用的 Smith-Schlick 可见项
inline half SmithVisibilityTerm (half NdotL, half NdotV, half k)
{
    half gL = NdotL * (1-k) + k;
    half gV = NdotV * (1-k) + k;
    return 1.0 / (gL * gV + 1e-5f); // This function is not intended to be running on Mobile, // 这个函数不打算在Mobile上运行，
                                    // therefore epsilon is smaller than can be represented by half // 因此 e 小于可以表示的一半
}

// Smith-Schlick derived for Beckmann //  Smith-Schlick 派生自 Beckmann
inline half SmithBeckmannVisibilityTerm (half NdotL, half NdotV, half roughness)
{
    half c = 0.797884560802865h; // c = sqrt(2 / Pi)
    half k = roughness * c;
    return SmithVisibilityTerm (NdotL, NdotV, k) * 0.25f; // * 0.25 is the 1/4 of the visibility term
}

// Ref: http://jcgt.org/published/0003/02/03/paper.pdf
inline half SmithJointGGXVisibilityTerm (half NdotL, half NdotV, half roughness)
{
#if 0
    // Original formulation: // 原始的公式：
    //  lambda_v    = (-1 + sqrt(a2 * (1 - NdotL2) / NdotL2 + 1)) * 0.5f;
    //  lambda_l    = (-1 + sqrt(a2 * (1 - NdotV2) / NdotV2 + 1)) * 0.5f;
    //  G           = 1 / (1 + lambda_v + lambda_l);

    // Reorder code to be more optimal // 重新排列代码让其更优化
    half a          = roughness;
    half a2         = a * a;

    half lambdaV    = NdotL * sqrt((-NdotV * a2 + NdotV) * NdotV + a2);
    half lambdaL    = NdotV * sqrt((-NdotL * a2 + NdotL) * NdotL + a2);

    // Simplify visibility term: (2.0f * NdotL * NdotV) /  ((4.0f * NdotL * NdotV) * (lambda_v + lambda_l + 1e-5f));
    return 0.5f / (lambdaV + lambdaL + 1e-5f);  // This function is not intended to be running on Mobile, // 这个函数不打算在Mobile上运行，
                                                // therefore epsilon is smaller than can be represented by half // 因此 e 小于可以表示的一半
#else
    // Approximation of the above formulation (simplify the sqrt, not mathematically correct but close enough) // 近似上述公式（简化sqrt，不是数学上正确但足够接近）
    half a = roughness;
    half lambdaV = NdotL * (NdotV * (1 - a) + a);
    half lambdaL = NdotV * (NdotL * (1 - a) + a);

    return 0.5f / (lambdaV + lambdaL + 1e-5f);
#endif
}

inline float GGXTerm (float NdotH, float roughness)
{
    float a2 = roughness * roughness;
    float d = (NdotH * a2 - NdotH) * NdotH + 1.0f; // 2 mad
    return UNITY_INV_PI * a2 / (d * d + 1e-7f); // This function is not intended to be running on Mobile, // 这个函数不打算在Mobile上运行，
                                            // therefore epsilon is smaller than what can be represented by half // 因此 e 小于可以表示的一半
}

// 从感知粗糙度获取高光强度 n = 2.0/pow(pr,4) - 2.0;
// @Remark: [SpecPower]
inline half PerceptualRoughnessToSpecPower (half perceptualRoughness)
{
    half m = PerceptualRoughnessToRoughness(perceptualRoughness);   // m is the true academic roughness. // m 是真正学术上的粗糙度
    half sq = max(1e-4f, m*m);
    half n = (2.0 / sq) - 2.0;                          // https://dl.dropboxusercontent.com/u/55891920/papers/mm_brdf.pdf
    n = max(n, 1e-4f);                                  // prevent possible cases of pow(0,0), which could happen when roughness is 1.0 and NdotH is zero // 防止 pow(0,0)的情况出现，当roughness 是 1.0，NdotH 是0的时候出现
    return n;
}

// BlinnPhong normalized as normal distribution function (NDF)
// for use in micro-facet model: spec=D*G*F
// eq. 19 in https://dl.dropboxusercontent.com/u/55891920/papers/mm_brdf.pdf
// 归一化的BlinnPhong 作为 法线分布函数 (NDF) 用于 微面元模型: spec = D * G * F
// https://dl.dropboxusercontent.com/u/55891920/papers/mm_brdf.pdf 中的公式19
// @Remark: [NDFBlinnPhongNormalizedTerm]

inline half NDFBlinnPhongNormalizedTerm (half NdotH, half n)
{
    // norm = (n+2)/(2*pi)
    half normTerm = (n + 2.0) * (0.5/UNITY_PI);

    half specTerm = pow (NdotH, n);
    return specTerm * normTerm;
}

//-------------------------------------------------------------------------------------
/*
// https://s3.amazonaws.com/docs.knaldtech.com/knald/1.0.0/lys_power_drops.html

const float k0 = 0.00098, k1 = 0.9921;
// pass this as a constant for optimization
const float fUserMaxSPow = 100000; // sqrt(12M)
const float g_fMaxT = ( exp2(-10.0/fUserMaxSPow) - k0)/k1;
float GetSpecPowToMip(float fSpecPow, int nMips)
{
   // Default curve - Inverse of TB2 curve with adjusted constants
   float fSmulMaxT = ( exp2(-10.0/sqrt( fSpecPow )) - k0)/k1;
   return float(nMips-1)*(1.0 - clamp( fSmulMaxT/g_fMaxT, 0.0, 1.0 ));
}

    //float specPower = PerceptualRoughnessToSpecPower(perceptualRoughness);
    //float mip = GetSpecPowToMip (specPower, 7);
*/

// 更安全的Normalize
// @TODO 为什么要这么做?
inline float3 Unity_SafeNormalize(float3 inVec)
{
    float dp3 = max(0.001f, dot(inVec, inVec));
    return inVec * rsqrt(dp3); // rsqrt(x) = 1/sqrt(x) 求平方根的倒数
}

//-------------------------------------------------------------------------------------

// Note: BRDF entry points use smoothness and oneMinusReflectivity for optimization
// purposes, mostly for DX9 SM2.0 level. Most of the math is being done on these (1-x) values, and that saves
// a few precious ALU slots.
// 注意：BRDF入口点使用 smoothness 和 oneMinusReflectivity 是为了优化的目的。
// 尤其是针对 DX9 SM2.0 的等级。大多数的数学运算是在(1-x)的值上面运行的，这样做会节省一些ALU资源。

// Main Physically Based BRDF // 基于物理的BRDF
// Derived from Disney work and based on Torrance-Sparrow micro-facet model
// 派生自迪士尼的工作方式 和 Torrance-Sparrow 的微面元模型
// @Remark: [DisneyPBR]
//
//   BRDF = kD / pi + kS * (D * V * F) / 4
//   I = BRDF * NdotL
//
// * NDF (depending on UNITY_BRDF_GGX): 
//  a) Normalized BlinnPhong
//  b) GGX
// * Smith for Visiblity term 
// * Schlick approximation for Fresnel
// * NDF (依赖于 UNITY_BRDF_GGX 来做区分):
//  a) 规范化的 Blinn-Phong
//  b) GGX
// * 可见项是 Smith
// * Fresnel 项是 Schlick 近似
half4 BRDF1_Unity_PBS (half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
    float3 normal, float3 viewDir,
    UnityLight light, UnityIndirect gi)
{
    float perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
    float3 halfDir = Unity_SafeNormalize (float3(light.dir) + viewDir);

// NdotV should not be negative for visible pixels, but it can happen due to perspective projection and normal mapping
// In this case normal should be modified to become valid (i.e facing camera) and not cause weird artifacts.
// but this operation adds few ALU and users may not want it. Alternative is to simply take the abs of NdotV (less correct but works too).
// Following define allow to control this. Set it to 0 if ALU is critical on your platform.
// This correction is interesting for GGX with SmithJoint visibility function because artifacts are more visible in this case due to highlight edge of rough surface
// Edit: Disable this code by default for now as it is not compatible with two sided lighting used in SpeedTree.
// 对于可见的像素来说 NdotV 不应该是负的，但是可能会在透视投影和法线贴图的影响下发生。
// 在这种情况下，法线应该被修改为有效的（即面向摄像机），并且不会造成奇怪的伪影。
// 但是这个操作可能增加了一些逻辑运算，并且用户可能并不想要它。另一种方法是简单使用NdotV的绝对值（不太正确，但也可以接受）。
// 下面这个宏定义允许控制这个。如果ALU对你的目标平台至关重要，请设置为0。
// 这个修正对带有 SmithJointGGX 的可见函数来说很有趣。因为在这种情况下，由于粗糙表面的突出边缘，伪影更加明显。
// 编辑：默认禁用此代码，因为它和SpeedTree的双面照明不兼容。
#define UNITY_HANDLE_CORRECTLY_NEGATIVE_NDOTV 0

#if UNITY_HANDLE_CORRECTLY_NEGATIVE_NDOTV
    // The amount we shift the normal toward the view vector is defined by the dot product.
    // 我们把法线偏移到视向量的强度是使用点积的结果来定义的。
    half shiftAmount = dot(normal, viewDir);
    normal = shiftAmount < 0.0f ? normal + viewDir * (-shiftAmount + 1e-5f) : normal;
    // A re-normalization should be applied here but as the shift is small we don't do it to save ALU.
    // 这里应该 re-normalization 一下，但是由于偏移很小，所以我们没这么来节省ALU。
    //normal = normalize(normal);

    half nv = saturate(dot(normal, viewDir)); // TODO: this saturate should no be necessary here // TODO: 这个saturate 在这里没有必要
#else
    half nv = abs(dot(normal, viewDir));    // This abs allow to limit artifact  // 这个 abs 允许限制伪影
#endif

    half nl = saturate(dot(normal, light.dir));
    float nh = saturate(dot(normal, halfDir));

    half lv = saturate(dot(light.dir, viewDir));
    half lh = saturate(dot(light.dir, halfDir));

    // Diffuse term // 漫反射项
    half diffuseTerm = DisneyDiffuse(nv, nl, lh, perceptualRoughness) * nl;

    // Specular term // 镜面反射项
    // HACK: theoretically we should divide diffuseTerm by Pi and not multiply specularTerm!
    // BUT 1) that will make shader look significantly darker than Legacy ones
    // and 2) on engine side "Non-important" lights have to be divided by Pi too in cases when they are injected into ambient SH
    // HACK: 理论上 漫反射项应该除 pi ，并且不应该给 高光项乘 pi ，这样做的原因如下：
    // 1) 如果不这样做会导致着色器看起来比传统的着色器暗得多
    // 2) 在引擎中看，"Non-important" 的灯被当作 SH 光计算到环境光中的时候，也必须除 pi
    float roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
#if UNITY_BRDF_GGX
    // GGX with roughtness to 0 would mean no specular at all, using max(roughness, 0.002) here to match HDrenderloop roughtness remapping.
    // 当 roughness = 0 时 GGX 意味着没有一点高光，这里使用max(roughness,0.002) 来匹配 HDrenderloop 的roughness 重映射
    // Remark: [HDrenderloop]
    roughness = max(roughness, 0.002);
    half V = SmithJointGGXVisibilityTerm (nl, nv, roughness);
    float D = GGXTerm (nh, roughness);
#else
    // Legacy // 旧版
    half V = SmithBeckmannVisibilityTerm (nl, nv, roughness);
    half D = NDFBlinnPhongNormalizedTerm (nh, PerceptualRoughnessToSpecPower(perceptualRoughness));
#endif

    half specularTerm = V*D * UNITY_PI; // Torrance-Sparrow model, Fresnel is applied later // Torrance_Sparrow 光照模型，Fresnel 稍后应用

    // Gamma 矫正
#   ifdef UNITY_COLORSPACE_GAMMA
        specularTerm = sqrt(max(1e-4h, specularTerm));
#   endif

    // specularTerm * nl can be NaN on Metal in some cases, use max() to make sure it's a sane value
    // 高光项 * nl 在金属上的某些情况下 可能会变为 NaN ，使用 max() 函数来确保它是一个合理的数值
    // @Remark: [NaN]
    specularTerm = max(0, specularTerm * nl);
#if defined(_SPECULARHIGHLIGHTS_OFF)
    specularTerm = 0.0;
#endif

    // surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(roughness^2+1)
    // @Remark: [SurfaceReduction]
    half surfaceReduction;
#   ifdef UNITY_COLORSPACE_GAMMA
        surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;      // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
#   else
        surfaceReduction = 1.0 / (roughness*roughness + 1.0);           // fade \in [0.5;1]
#   endif

    // To provide true Lambert lighting, we need to be able to kill specular completely.
    // 为了提供真正的Lambert 照明，我们需要能够完全去除镜面反射
    specularTerm *= any(specColor) ? 1.0 : 0.0;

    // @Remark: [GrazingTerm]
    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
    half3 color =   diffColor * (gi.diffuse + light.color * diffuseTerm)
                    + specularTerm * light.color * FresnelTerm (specColor, lh)
                    + surfaceReduction * gi.specular * FresnelLerp (specColor, grazingTerm, nv);

    return half4(color, 1);
}

// @Remark: [BRDF2]
// Based on Minimalist CookTorrance BRDF
// Implementation is slightly different from original derivation: http://www.thetenthplanet.de/archives/255
// 基于 简单版的 Cooktorrance BRDF模型
// 实现和原始的版本稍有不同：http://www.thetenthplanet.de/archives/255
//
// * NDF (depending on UNITY_BRDF_GGX):
//  a) BlinnPhong
//  b) [Modified] GGX
// * Modified Kelemen and Szirmay-​Kalos for Visibility term
// * Fresnel approximated with 1/LdotH
//
// * NDF 法线分布函数 (依赖于 UNITY_BRDF_GGX 区分)
//  a) BlinnPhong
//  b) [改良版] GGX
// * 改进版的 Kelemen 和 Szirmay-Kalos 作为几何遮挡项
// * Fresnel 项使用近似的 1/LdotH
half4 BRDF2_Unity_PBS (half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
    float3 normal, float3 viewDir,
    UnityLight light, UnityIndirect gi)
{
    float3 halfDir = Unity_SafeNormalize (float3(light.dir) + viewDir); 

    half nl = saturate(dot(normal, light.dir));
    float nh = saturate(dot(normal, halfDir));
    half nv = saturate(dot(normal, viewDir));
    float lh = saturate(dot(light.dir, halfDir));

    // Specular term // 高光反射项
    half perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
    half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);

#if UNITY_BRDF_GGX

    // GGX Distribution multiplied by combined approximation of Visibility and Fresnel
    // See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
    // https://community.arm.com/events/1155
    // GGX 分布乘以可见度和菲涅耳组合的近似值
    // 查看 2015年 Siggraph移动设备图形论文：“针对移动端优化PBR”
    // https://community.arm.com/events/1155
    half a = roughness;
    float a2 = a*a;

    float d = nh * nh * (a2 - 1.f) + 1.00001f;
    #ifdef UNITY_COLORSPACE_GAMMA // 是否是Gamma 空间
        // Tighter approximation for Gamma only rendering mode!
        // 仅Gamma渲染模式更严格的近似
        // DVF = sqrt(DVF);
        // DVF = (a * sqrt(.25)) / (max(sqrt(0.1), lh)*sqrt(roughness + .5) * d);
        float specularTerm = a / (max(0.32f, lh) * (1.5f + roughness) * d);
    #else
        float specularTerm = a2 / (max(0.1f, lh*lh) * (roughness + 0.5f) * (d * d) * 4);
    #endif

    // on mobiles (where half actually means something) denominator have risk of overflow
    // clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
    // sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
    // 在移动设备上（实际上意味着其中的一半），分母有溢出的风险
    // clamp 下面被专门添加到“修复”里，除了dx 的编译器（我们将字节码转换到 metal/gles 平台）
    // 由于 Specular Term 只有非负的项，所以可以跳过 clamp 中的 max(0,...) 只留下 min(100,...) 
    #if defined (SHADER_API_MOBILE) 
        specularTerm = specularTerm - 1e-4f;
    #endif

#else

    // Legacy // 遗产，不使用GGX就使用这个方式来代替
    half specularPower = PerceptualRoughnessToSpecPower(perceptualRoughness);
    // Modified with approximate Visibility function that takes roughness into account
    // Original ((n+1)*N.H^n) / (8*Pi * L.H^3) didn't take into account roughness
    // and produced extremely bright specular at grazing angles
    // 修改为用粗糙度近似 可见项函数
    // 原本的 ((n+1)*N.H^n) / (8*Pi * L.H^3) 没有考虑 粗糙度
    // 并且在扫视角度有非常亮的高光

    half invV = lh * lh * smoothness + perceptualRoughness * perceptualRoughness; // approx ModifiedKelemenVisibilityTerm(lh, perceptualRoughness); // 约等于修改的Kelemen可见项(lh,perceptualRoughness) smoothness 是感知光滑度 这里计算的是 1/V
    half invF = lh; // 1/F 

    half specularTerm = ((specularPower + 1) * pow (nh, specularPower)) / (8 * invV * invF + 1e-4h); // @TODO: ?

    #ifdef UNITY_COLORSPACE_GAMMA
        specularTerm = sqrt(max(1e-4f, specularTerm));
    #endif

#endif

#if defined (SHADER_API_MOBILE)
    specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles // 防止手机上的FP16溢出 @TODO: ?
#endif
#if defined(_SPECULARHIGHLIGHTS_OFF)
    specularTerm = 0.0;
#endif

    // surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(realRoughness^2+1)

    // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
    // 1-x^3*(0.6-0.08*x)   approximation for 1/(x^4+1)
    // 1-0.28*x^3 用于在[0,1]的值域上近似 (1/(x^4+1))^(1/2.2)
    // 1-x^3*(0.6-0.08*x)   用于近似 1/(x^4+1)
#ifdef UNITY_COLORSPACE_GAMMA
    half surfaceReduction = 0.28;
#else
    half surfaceReduction = (0.6-0.08*perceptualRoughness);
#endif

    surfaceReduction = 1.0 - roughness*perceptualRoughness*surfaceReduction;
    // @Remark:[GrazingTerm]
    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
    half3 color =   (diffColor + specularTerm * specColor) * light.color * nl
                    + gi.diffuse * diffColor
                    + surfaceReduction * gi.specular * FresnelLerpFast (specColor, grazingTerm, nv);

    return half4(color, 1);
}

sampler2D_float unity_NHxRoughness; //以N.H为U，感知粗糙度为V 的 LUT 查找贴图
// BRDF3的直接光照
half3 BRDF3_Direct(half3 diffColor, half3 specColor, half rlPow4, half smoothness)
{
    half LUT_RANGE = 16.0; // must match range in NHxRoughness() function in GeneratedTextures.cpp // 必须匹配 GeneratedTextures.cpp 中 NHxRoughness()函数的 range
    // Lookup texture to save instructions // 使用Lookup 贴图来节省指令数
    half specular = tex2D(unity_NHxRoughness, half2(rlPow4, SmoothnessToPerceptualRoughness(smoothness))).UNITY_ATTEN_CHANNEL * LUT_RANGE;
#if defined(_SPECULARHIGHLIGHTS_OFF)
    specular = 0.0;
#endif

    return diffColor + specular * specColor;
}

// BRDF3 的间接光照
half3 BRDF3_Indirect(half3 diffColor, half3 specColor, UnityIndirect indirect, half grazingTerm, half fresnelTerm)
{
    half3 c = indirect.diffuse * diffColor;
    c += indirect.specular * lerp (specColor, grazingTerm, fresnelTerm);
    return c;
}

// Old school, not microfacet based Modified Normalized Blinn-Phong BRDF
// Implementation uses Lookup texture for performance
// 旧的方法，不是基于 Microfacet 微面元理论改良标准化之后的 Blinn-Phong BRDF模型
// 出于性能考虑，使用Lookup纹理贴图实现
//
// * Normalized BlinnPhong in RDF form // * 以 RDF的形式规范化 BlinnPhong // @TODO ?
// * Implicit Visibility term          // * 隐式的可见项
// * No Fresnel term                   // * 没有Fresnel 项
//
// TODO: specular is too weak in Linear rendering mode
// TODO：线性渲染模式下高光反射太弱
half4 BRDF3_Unity_PBS (half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
    float3 normal, float3 viewDir,
    UnityLight light, UnityIndirect gi)
{
    float3 reflDir = reflect (viewDir, normal); // 反射向量

    half nl = saturate(dot(normal, light.dir)); 
    half nv = saturate(dot(normal, viewDir));

    // Vectorize Pow4 to save instructions
    // 矢量化Pow4 来节省指令数
    half2 rlPow4AndFresnelTerm = Pow4 (float2(dot(reflDir, light.dir), 1-nv));  // use R.L instead of N.H to save couple of instructions // 使用 R.L 来代替 N.H是为了节省几条指令数
    half rlPow4 = rlPow4AndFresnelTerm.x; // power exponent must match kHorizontalWarpExp in NHxRoughness() function in GeneratedTextures.cpp // power 指数必须和GeneratedTextures.cpp中的 NHxRoughness() 函数中的 kHorizontalWarpExp 参数匹配
    half fresnelTerm = rlPow4AndFresnelTerm.y;

    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity)); // @Remark: [GrazingTerm]

    half3 color = BRDF3_Direct(diffColor, specColor, rlPow4, smoothness);
    color *= light.color * nl;
    color += BRDF3_Indirect(diffColor, specColor, gi, grazingTerm, fresnelTerm);

    return half4(color, 1);
}

// Include deprecated function
#define INCLUDE_UNITY_STANDARD_BRDF_DEPRECATED
#include "UnityDeprecated.cginc"
#undef INCLUDE_UNITY_STANDARD_BRDF_DEPRECATED

#endif // UNITY_STANDARD_BRDF_INCLUDED
