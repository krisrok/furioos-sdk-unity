// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Observ3d/Light Independent/Textured/Transparent/LI-Texture-Alpha-Reflect-Mask-Cutout" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		
		_MainTex ("Diffuse (RGB)", 2D) = "white" {}
		
		_MaskMap ("Mask (Gray)", 2D) = "white" {}
		
		_Cutoff ("Cutout Offset", Range (0, 1)) = 0.95
		
		_ReflectMap ("Reflect Map", Cube) = "gray" { TexGen CubeReflect }
		_ReflectColor ("Reflect Color", Color) = (1,1,1,1)
		_ReflectContrast ("Reflect Contrast", Range (0, 3)) = 1
		_ReflectOffset ("Reflect Offset", Range (-1, 0)) = -0.5
		_Normal_Reflect_Alpha ("Normal Reflect Alpha", Range (0, 1)) = 0.05
		_Fresnel_Curve ("Fresnel Curve", Range (1, 10)) = 4
		_Tangent_Reflect_Alpha ("Tangent Reflect Alpha", Range (0.01, 1)) = 0.5
		
		_AntiFlick ("AntiFlick", Range (0, 0.0001)) = 0
	}
	SubShader {
		Tags { "Queue"="Transparent" "RenderType"="TransparentCutout" "IgnoreProjector"="True" }
		
		Pass {
			ZWrite On
			Lighting Off
			Cull Back
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct VertInput {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};
			
			struct FragInput {
				float4 vertex : POSITION;
				float2 uv_MainTex : TEXCOORD0;
				float4 worldPosition:TEXCOORD4;
				float3 worldNormal:TEXCOORD3;
				float2 uv_MaskMap : TEXCOORD7;
			};
			
			fixed4 _Color;
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			sampler2D _MaskMap;
			float4 _MaskMap_ST;
		
			float _Cutoff;
		
			samplerCUBE _ReflectMap;
			fixed _Normal_Reflect_Alpha;
			fixed _Fresnel_Curve;
			fixed _Tangent_Reflect_Alpha;
			fixed _ReflectContrast;
			fixed _ReflectOffset;
			fixed3 _ReflectColor;
			
			half _AntiFlick;
			
			FragInput vert (VertInput v) {
				FragInput o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.vertex.z -= _AntiFlick*o.vertex.w;
				o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv_MaskMap = TRANSFORM_TEX(v.texcoord, _MaskMap);
				o.worldPosition = mul(unity_ObjectToWorld,v.vertex);
				o.worldNormal = normalize( mul((float3x3)unity_ObjectToWorld,v.normal));
				return o;
			}
			
			half4 frag (FragInput IN) : COLOR{
				half4 albedo = tex2D(_MainTex, IN.uv_MainTex) * half4(_Color.rgb,1);
				half3 mask = tex2D(_MaskMap, IN.uv_MaskMap).rgb;
				albedo.a *= (mask.r + mask.g + mask.b) / 3 ;
				clip(albedo.a-_Cutoff);
				half3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - IN.worldPosition.xyz);
				half3 worldNormal = IN.worldNormal;
				half viewDotProduct = dot(worldViewDir,worldNormal);
				half3 reflecDir =  - worldViewDir + 2.0 * ( worldNormal * viewDotProduct );
				viewDotProduct = abs(viewDotProduct);
				half reflectQty = (_Tangent_Reflect_Alpha - _Normal_Reflect_Alpha) * pow(( 1-viewDotProduct),_Fresnel_Curve) + _Normal_Reflect_Alpha;
				half3 reflectCol = (_ReflectOffset + texCUBE(_ReflectMap, reflecDir ).rgb * _ReflectColor) * _ReflectContrast;
				half reflectLum = (reflectCol.r + reflectCol.g + reflectCol.b)/12;
				half alpha = (_Color.a + reflectQty + reflectLum) * albedo.a;
				return half4((albedo.rgb * (1.0-reflectQty)  + (albedo.rgb * (1-_ReflectColor) + reflectCol + 0.5) * reflectQty ) ,alpha);
			}
			
			ENDCG
		}
		Pass {
			ZWrite Off
			Lighting Off
			Cull Back
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct VertInput {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};
			
			struct FragInput {
				float4 vertex : POSITION;
				float2 uv_MainTex : TEXCOORD0;
				float4 worldPosition:TEXCOORD4;
				float3 worldNormal:TEXCOORD3;
				float2 uv_MaskMap : TEXCOORD7;
			};
			
			fixed4 _Color;
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			sampler2D _MaskMap;
			float4 _MaskMap_ST;
		
			float _Cutoff;
		
			samplerCUBE _ReflectMap;
			fixed _Normal_Reflect_Alpha;
			fixed _Fresnel_Curve;
			fixed _Tangent_Reflect_Alpha;
			fixed _ReflectContrast;
			fixed _ReflectOffset;
			fixed3 _ReflectColor;
			
			half _AntiFlick;
			
			FragInput vert (VertInput v) {
				FragInput o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.vertex.z -= _AntiFlick*o.vertex.w;
				o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv_MaskMap = TRANSFORM_TEX(v.texcoord, _MaskMap);
				o.worldPosition = mul(unity_ObjectToWorld,v.vertex);
				o.worldNormal = normalize( mul((float3x3)unity_ObjectToWorld,v.normal));
				return o;
			}
			
			half4 frag (FragInput IN) : COLOR{
				half4 albedo = tex2D(_MainTex, IN.uv_MainTex) * half4(_Color.rgb,1);
				half3 mask = tex2D(_MaskMap, IN.uv_MaskMap).rgb;
				albedo.a *= (mask.r + mask.g + mask.b) / 3 ;
				clip(_Cutoff-albedo.a);
				clip(albedo.a-0.004);
				half3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - IN.worldPosition.xyz);
				half3 worldNormal = IN.worldNormal;
				half viewDotProduct = dot(worldViewDir,worldNormal);
				half3 reflecDir =  - worldViewDir + 2.0 * ( worldNormal * viewDotProduct );
				viewDotProduct = abs(viewDotProduct);
				half reflectQty = (_Tangent_Reflect_Alpha - _Normal_Reflect_Alpha) * pow(( 1-viewDotProduct),_Fresnel_Curve) + _Normal_Reflect_Alpha;
				half3 reflectCol = (_ReflectOffset + texCUBE(_ReflectMap, reflecDir ).rgb * _ReflectColor) * _ReflectContrast;
				half reflectLum = (reflectCol.r + reflectCol.g + reflectCol.b)/12;
				half alpha = (_Color.a + reflectQty + reflectLum) * albedo.a;
				return half4((albedo.rgb * (1.0-reflectQty)  + (albedo.rgb * (1-_ReflectColor) + reflectCol + 0.5) * reflectQty ) ,alpha);
			}
			
			ENDCG
		}
	}
		Fallback "Transparent/Cutout/VertexLit"
		CustomEditor "OBSMaterialInspector"
}