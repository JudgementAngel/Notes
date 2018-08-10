Shader "Move/PBR_Eye_Shader_Move"
{
	Properties
	{
		_scleraColor ("巩膜颜色", Color) = (0.95,0.95,0.95,1)
		_irisColor ("虹膜颜色", Color) = (1,1,1,1)
		_CausticsColor ("焦散颜色", Color) = (0,0,0,0)

		_pupilSize("瞳孔大小", Range(0.0,1.0)) = 0.27
		_irisSize("虹膜大小", Range(1.5,5.0)) = 1.88
		_parallax("折射强度", Range(0.0,0.1)) = 0.05
		_limbus("角膜缘透明度", Range(0.0,1.0)) = 0.5
		_corneaSmoothness("角膜光泽度", Range(0.0,1.0)) = 0.9
		_scleraSmoothness("巩膜光泽度", Range(0.0,1.0)) = 0.75
		
		// _corneaSpecular("角膜反射率",Color) = (0.03,0.03,0.03,1)
		// _scleraSpecular("巩膜反射率",Color)= (0.03,0.03,0.03,1)

		_SpecularColor("反射率颜色", Color) = (0.03,0.03,0.03,1)
		
		// _scleraShadowAmt("巩膜阴影遮蔽程度", Range(0.0,1.0)) = 0.0
		// _irisShadowAmt("虹膜阴影遮蔽程度", Range(0.0,1.0)) = 0.0

		_IrisColorTex ("虹膜贴图", 2D) = "white" {}
		_MaskTex ("遮罩贴图", 2D) = "white" {}
		_CorneaBump ("_CorneaBump", 2D) = "white" {}
		_MainTex ("_MainTex", 2D) = "white" {}
		// _ShadeScleraTex ("_ShadeScleraTex", 2D) = "white" {}
		// _ShadeIrisTex ("Shade Iris Texture", 2D) = "white" {}

		_EnvColor ("环境颜色",Color) = (1,1,1,0.5) 
        _EnvScale ("环境强度",Float) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			 Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "AutoLight.cginc"
			#include "UnityCG.cginc"

			#ifdef UNITY_COLORSPACE_GAMMA 
				#define unity_ColorSpaceGrey fixed4(0.5, 0.5, 0.5, 0.5)
				#define unity_ColorSpaceDouble fixed4(2.0, 2.0, 2.0, 2.0)
				#define unity_ColorSpaceDielectricSpec half4(0.220916301, 0.220916301, 0.220916301, 1.0 - 0.220916301)
				#define unity_ColorSpaceLuminance half4(0.22, 0.707, 0.071, 0.0) // Legacy: alpha is set to 0.0 to specify gamma mode 
			#else // Linear values 
				#define unity_ColorSpaceGrey fixed4(0.214041144, 0.214041144, 0.214041144, 0.5)
				#define unity_ColorSpaceDouble fixed4(4.59479380, 4.59479380, 4.59479380, 2.0)
				#define unity_ColorSpaceDielectricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04) // standard dielectric reflectivity coef at incident angle (= 4%) 
				#define unity_ColorSpaceLuminance half4(0.0396819152, 0.458021790, 0.00609653955, 1.0) // Legacy: alpha is set to 1.0 to specify linear mode
			#endif

			#define UNITY_SPECCUBE_LOD_STEPS (6)

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD0;
				half4 tangent : TANGENT;
				half3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 eyeVec : TEXCOORD1;
				float4 tangentToWorld_tangentView[3] : TEXCOORD2;
				half4 ambient : TEXCOORD5;
				UNITY_SHADOW_COORDS(6)
				float3 worldPos : TEXCOORD7;
				float3 tangentLightDir : TEXCOORD8;
				float3 tangentViewDir : TEXCOORD9;
			};


			sampler2D _IrisColorTex;
			sampler2D _MaskTex;
			sampler2D _MainTex;
			sampler2D _ShadeScleraTex;
			sampler2D _ShadeIrisTex;
			float _scleraShadowAmt;
			float _irisShadowAmt;
			float4 _albedoColor;
			float4 reflectionMatte;
			float4 irradianceTex;
			float3 albedoColor;
			float _roughness;
			float _reflective;
			float _metalMap;
			float _ambientMap;
			float _irisSize;
			float _pupilSize;
			float _limbus;
			sampler2D _CorneaBump;
			sampler2D _EyeBump;
			sampler2D _IrisBump;
			float4 _scleraColor;
			float4 _irisColor;
			float4 _irisColorB;
			float4 _pupilColor;
			float4 _CausticsColor;
			float _parallax;
			float irismasktex;
			
			float _scleraSmoothness;
			float _corneaSmoothness;
			float4 _SpecularColor;

			float4 _EnvColor;
			float _EnvScale;

			float4 _LightColor0;

			float4 _corneaSpecular,_scleraSpecular;

			v2f vert (appdata v)
			{
				v2f o = (v2f)0;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv ;
				float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.worldPos = posWorld;
				o.eyeVec = posWorld.xyz - _WorldSpaceCameraPos;
				

				half3 normalWorld = UnityObjectToWorldNormal(v.normal);
				half3 tangentWorld = UnityObjectToWorldDir(v.tangent.xyz);
				half3 binormalWorld = cross(normalWorld,tangentWorld) * v.tangent.w;

				o.tangentToWorld_tangentView[0].xyz = tangentWorld;
				o.tangentToWorld_tangentView[1].xyz = binormalWorld;
				o.tangentToWorld_tangentView[2].xyz = normalWorld;

				float3x3 rotation = float3x3(tangentWorld,binormalWorld,normalWorld);
				half3 viewDirForParallax = mul (rotation, normalize(UnityWorldSpaceViewDir(o.worldPos)));
				o.tangentLightDir = UnityWorldSpaceLightDir(o.worldPos);//mul(rotation,UnityWorldSpaceLightDir(o.worldPos));
				o.tangentViewDir = WorldSpaceViewDir(v.vertex);
				o.tangentToWorld_tangentView[0].w = viewDirForParallax.x;
				o.tangentToWorld_tangentView[1].w = viewDirForParallax.y;
				o.tangentToWorld_tangentView[2].w = viewDirForParallax.z;
				
			
					o.ambient.rgb = Shade4PointLights (
		                unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
		                unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
		                unity_4LightAtten0, o.worldPos, normalWorld);
			


				// SH 光照一部分在顶点中计算，一部分在片段中计算
				#ifdef UNITY_COLORSPACE_GAMMA
		            o.ambient.rgb = GammaToLinearSpace (o.ambient.rgb);
		        #endif
		        o.ambient.rgb += SHEvalLinearL2 (half4(normalWorld, 1.0));

				UNITY_TRANSFER_SHADOW(o, v.uv1);

				return o;
			}
			
			

			struct Move_FragmentData
			{
				 half3 diffColor,specColor;
				 half oneMinusReflectivity,roughness;
				 float3 normalWorld,eyeVec,posWorld;
				 half alpha;
			}; 
			struct SurfaceOutputStandardSpecular
			{
			    half3 Albedo;      // diffuse color
			    half3 Specular;    // specular color
			    float3 Normal;      // tangent space normal, if written
			    half3 Emission;
			    half Smoothness;    // 0=rough, 1=smooth
			    half Occlusion;     // occlusion (default 1)
			    half Alpha;        // alpha for transparencies
			};

			Move_FragmentData SurfaceOutputStandardSpecular2Move_FragmentData(SurfaceOutputStandardSpecular i,v2f i2)
			{
				Move_FragmentData o = (Move_FragmentData)0;
				o.diffColor = i.Albedo;
				o.specColor = i.Specular;
				o.roughness = 1 - i.Smoothness;
				o.alpha = i.Alpha;
				o.eyeVec = normalize(i2.eyeVec);
				o.posWorld = i2.worldPos;
				o.oneMinusReflectivity = (1-o.specColor.r);
				float3 normalTangent = i.Normal;
				o.normalWorld = normalize(i2.tangentToWorld_tangentView[0].xyz * normalTangent.x + i2.tangentToWorld_tangentView[1].xyz * normalTangent.y + i2.tangentToWorld_tangentView[2].xyz * normalTangent.z);
				return o;
			}
			struct Move_GI
			{
				half3 color;
				half3 dir;

				half3 indirectDiffuse;
				half3 indirectSpecular;
			}; 

			float PerceptualRoughnessToMip(float perceptualRoughness,half mipCount)
			{
				half level = 3 - 1.15 * log2(perceptualRoughness);
				return mipCount - 1- level;
			}

			Move_GI Move_FragmentGI(Move_FragmentData s,half occlusion,half4 i_ambient,half atten,half3 lightColor,half3 worldSpaceLightDir)
			{
				Move_GI gi = (Move_GI)0;
				gi.color = lightColor * atten;
				gi.dir = worldSpaceLightDir;

				// SH 光照一部分在顶点中计算，一部分在片段中计算
				half3 ambient_contrib = 0.0;
		        ambient_contrib = SHEvalLinearL0L1 (half4(s.normalWorld, 1.0));
		        gi.indirectDiffuse = max(half3(0, 0, 0), i_ambient + ambient_contrib);
				#ifdef UNITY_COLORSPACE_GAMMA
					gi.indirectDiffuse = LinearToGammaSpace(gi.indirectDiffuse);
				#endif
				gi.indirectDiffuse *= occlusion;
				

				/// EnvCol
				float3 reflUVW = reflect(s.eyeVec,s.normalWorld);
				half perceptualRoughness = s.roughness;

				perceptualRoughness = perceptualRoughness*(1.7 - 0.7*perceptualRoughness);

		
				half mip = perceptualRoughness * UNITY_SPECCUBE_LOD_STEPS;
				half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0,reflUVW,mip) * _EnvColor * _EnvScale;
			

    			half3 envCol = DecodeHDR(rgbm,unity_SpecCube0_HDR);

				gi.indirectSpecular = envCol * occlusion;
				return gi;
			}
		

			inline half Pow5 (half x) { return x*x * x*x * x; }

			// Note: Disney diffuse must be multiply by diffuseAlbedo / PI. This is done outside of this function.
			half DisneyDiffuse(half NdotV, half NdotL, half LdotH, half perceptualRoughness)
			{
			    half fd90 = 0.5 + 2 * LdotH * LdotH * perceptualRoughness;
			    // Two schlick fresnel term
			    half lightScatter   = (1 + (fd90 - 1) * Pow5(1 - NdotL));
			    half viewScatter    = (1 + (fd90 - 1) * Pow5(1 - NdotV));

			    return lightScatter * viewScatter;
			}

			inline float GGXTerm (float NdotH, float roughness)
			{
			    float a2 = roughness * roughness;
			    float d = (NdotH * a2 - NdotH) * NdotH + 1.0f; // 2 mad
			    return UNITY_INV_PI * a2 / (d * d + 1e-7f); // This function is not intended to be running on Mobile,
			                                            // therefore epsilon is smaller than what can be represented by half
			}
			
			inline half SmithJointGGXVisibilityTerm (half NdotL, half NdotV, half roughness)
			{
				half a = roughness;
			    half lambdaV = NdotL * (NdotV * (1 - a) + a);
			    half lambdaL = NdotV * (NdotL * (1 - a) + a);

			    return 0.5f / (lambdaV + lambdaL + 1e-5f);
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
			
			inline half Remap(float Val,float iMin,float iMax,float oMin,float oMax)
			{
				return (oMin + ((Val - iMin) * (oMax - oMin))/(iMax - iMin));
			}

			// inline half3 RemapLerp(half3 F0,half3 F90,half val)
			// {
			// 	half t = saturate(Remap(val,0.95,1,0,1));
			// 	return lerp (0, F0 ,t) ;
			// }

			// Diffuse:Disney
			// Specular: 基于Torrance-Sparrow micro-facet 光照模型
			// 		NDF: GGX ; V项: Smith; Fresnel: Schlick的近似
			//   BRDF = kD / pi + kS * (D * V * F) / 4
			//   I = BRDF * NdotL
			// HACK: 这里没有给漫反射项除 pi，并且给高光项乘pi。
			// 原因是：防止在引擎中的结果和传统的相比太暗；SH和非重要的灯光也得除pi;
			half4 Move_BRDF_PBS(Move_FragmentData s,Move_GI gi)
			{
				float perceptualRoughness = s.roughness;
				float roughness = perceptualRoughness * perceptualRoughness;

				float3 lightDir = gi.dir;
				float3 viewDir = -s.eyeVec; 
				float3 normal = s.normalWorld;
				float3 halfDir = normalize (lightDir + viewDir);

				half nv = abs(dot(normal,viewDir));
				half nl = saturate(dot(normal,lightDir));
				float nh = saturate(dot(normal, halfDir));
				half lv = saturate(dot(lightDir, viewDir));
    			half lh = saturate(dot(lightDir, halfDir));

    			// DiffuseTerm
    			half diffuseTerm = DisneyDiffuse(nv, nl, lh, perceptualRoughness) * nl;

    			// SpecularTerm: GGX
    			roughness = max(roughness,0.002);
    			half V = SmithJointGGXVisibilityTerm (nl, nv, roughness);
    			float D = GGXTerm (nh, roughness);

    			half specularTerm = V*D * UNITY_PI; // Torrance-Sparrow model, Fresnel is applied later
    			#ifdef UNITY_COLORSPACE_GAMMA
        			specularTerm = sqrt(max(1e-4h, specularTerm));
				#endif
        		
        		specularTerm = max(0, specularTerm * nl);

			    half surfaceReduction;
				#ifdef UNITY_COLORSPACE_GAMMA
			        surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;      // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
				#else
			        surfaceReduction = 1.0 / (roughness*roughness + 1.0);           // fade \in [0.5;1]
				#endif

			    half grazingTerm = saturate(1-perceptualRoughness + (1-s.oneMinusReflectivity));

			    half3 color =   s.diffColor * (gi.indirectDiffuse + gi.color * diffuseTerm) 
                    + specularTerm * gi.color * FresnelTerm (s.specColor, lh) 
                    + surfaceReduction * gi.indirectSpecular * FresnelLerp (s.specColor, grazingTerm, nv);

                return half4(color,1);
			}

			inline float2 CenterZoomUVBySize(float2 texcoord,float size)
			{
				return texcoord * size -(size * 0.5 -0.5);
			}

			inline float4 tex2DBySize(sampler2D tex,float2 uv,float size)
			{
				return tex2D(tex,CenterZoomUVBySize(uv,size) );
			}

			// 将MainTex.a 放到_CorneaBump.a中
			fixed4 frag (v2f i) : SV_Target
			{
				SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
				i.uv = i.uv;
				float3 tangentViewDir = float3(i.tangentToWorld_tangentView[0].w,i.tangentToWorld_tangentView[1].w,i.tangentToWorld_tangentView[2].w);
				float3 tangentLightDir = i.tangentLightDir;
				float3 tangentNormalDir = float3(0,0,1);
				// 计算法线贴图
				half4 packNormal = tex2DBySize(_CorneaBump,i.uv,_irisSize);
				half3 cBump = packNormal * 2 - 1;

				// 计算巩膜贴图
				half4 scleratex = tex2D(_MainTex,i.uv);
				scleratex.rgb = lerp(scleratex.rgb,scleratex.rgb*_scleraColor.rgb,_scleraColor.a);

				// 计算虹膜Mask贴图
				irismasktex = packNormal.w;

				// 混合法线
				o.Normal = lerp(tangentNormalDir,cBump,irismasktex);

				// 获取Mask贴图
				half uvMask = 1.0-tex2D(_MaskTex,i.uv).b;

				// 计算虹膜纹理贴图
				half iSize = _irisSize * 0.6;
				float2 irUVc = CenterZoomUVBySize(i.uv,iSize);

				float pupilSize = lerp(0.5 - 0.06 * iSize , 1.2 - 0.09 * iSize , _pupilSize);


				irUVc = irUVc*(-1.0+(uvMask*pupilSize)) - 0.5 * uvMask * pupilSize;

				// 计算视差纹理坐标
				float2 irUVp = CenterZoomUVBySize(i.uv,iSize);

				half plxtex = tex2D(_MaskTex,irUVp).g;
				float _Parallax = lerp(0.0, _parallax * 2.0 ,plxtex);

				// 计算 虹膜和瞳孔 Mask贴图
				// float2 irUV = lerp((i.uv*0.75)-((0.75-1.0)/2.0),(i.uv*pupilSize)-((pupilSize-1.0)/2.0),i.uv);
				float2 irUV = lerp( i.uv*0.75+0.125 , i.uv*pupilSize-(pupilSize-1.0)*0.5 , i.uv);
				

				half3 vDir = -tangentViewDir;
				vDir.xz = clamp(vDir.xz,-0.75,0.75);


				float height = tex2D(_MaskTex,irUV).b;

				float2 offset = ParallaxOffset(height, _Parallax,vDir) * plxtex;
				offset = clamp(offset,-0.1,0.1);

				// 获取虹膜和瞳孔贴图
				half4 irisColTex = tex2D(_IrisColorTex,irUVc-offset);


				half cNdotV2 = saturate(lerp(-0.2,0.25,max(0,dot(tangentNormalDir,tangentViewDir))));
				

				// 混合虹膜和巩膜
				irisColTex.rgb = lerp(irisColTex.rgb,irisColTex.rgb*_irisColor.rgb,_irisColor.a);
				o.Albedo = lerp(scleratex.rgb,irisColTex.rgb,irismasktex);

				// 焦散效果 TODO
				o.Emission = o.Albedo*(2.0*_CausticsColor.a)*_CausticsColor.rgb * irismasktex * (1-irisColTex.a);

				// 计算 透明和裁剪
				o.Alpha = 1.0;
				
				// 计算灯光项
			    half NdotV2 = max(0,dot(cBump,tangentViewDir));
			    half3 tangentHalfDir = normalize(tangentLightDir + tangentViewDir);
			    half NdotH = max(0,dot(cBump,tangentHalfDir));

				// 折射率
				half3 f0 = 0.03f.xxx;
				
				// Fresnel 项(Schlick)
				half3 fresnel;
				fresnel = f0+(1.0-f0)*pow(dot(cBump,tangentHalfDir),5);
				fresnel = fresnel * (f0+(1.0-f0)*pow((1.0-NdotV2),5));
				fresnel = saturate(max(fresnel,f0+(1.0-f0)*pow((1.0-NdotV2),5)));

				// 添加边缘高光
				o.Albedo = (o.Albedo + (fresnel * 0.5 * NdotH));

				// 计算高光
				o.Specular = _SpecularColor;
				o.Smoothness = lerp(_scleraSmoothness, _corneaSmoothness, saturate(lerp(-2,5,irismasktex)) );
				

				o.Albedo = lerp(o.Albedo, o.Albedo * 2, irismasktex * 2);




				Move_FragmentData s = SurfaceOutputStandardSpecular2Move_FragmentData(o,i);
				
				UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld); 

				half occlusion = 1;//lerp(1,tex2D(_OcclusionMap,i.tex.xy).g,_OcclusionStrength);
				// return occlusion.xxxx;
				Move_GI gi = Move_FragmentGI(s,occlusion,i.ambient,atten,_LightColor0.rgb,_WorldSpaceLightPos0.xyz);
				
				half4 col = Move_BRDF_PBS(s,gi);
				
				col.rgb += o.Emission.rgb;
				

				col.a = s.alpha;
				
				return col;

			}

			
			ENDCG
		}
	}
}
