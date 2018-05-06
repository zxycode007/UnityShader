﻿Shader "Custom/Illumination_Bump"
{
	Properties
	{
		_Color("Color",Color) = (0.5,0.5,0.5,1)
		_MainTex("Texture", 2D) = "white" {}
		[NoScaleOffset]_BumpTex("Bump",2D) = "white" {}
		_Illum("Illumination",Color) = (1,1,0,1)
		_ProjectionColor("ProjectionColor",Color) = (0,0,0,.75)
		_ProjectionLength("ProjectionLength",Range(0,100)) = 10
		_ProjectionFadeout("Fadeout distance",float) = 5
	}
		SubShader
		{
			CGINCLUDE
			#pragma vertex vert
			#pragma fragment frag
			//多通道雾化
			#pragma multi_compile_fog
			#include "UnityCG.cginc"  
			ENDCG
			Tags{ "RenderType" = "Transparent"
			"Queue" = "Transparent" }
			LOD 100
			//Base通道
			//渲染环境光和平行光
			Pass
			{
				Tags{ "LightMode" = "ForwardBase" }
				CGPROGRAM
				#pragma multi_compile_fwdbase_fullshadows
				#define projection_illm
				#define projection_bump
				//第一个通道渲染光照模型
				#include "LightModel.cginc"
				ENDCG
			}
			//Base通道
			//渲染环境光和平行光
			Pass
			{
				Tags{ "LightMode" = "ForwardBase" }
				ZWrite Off
				Cull Off
				Blend SrcAlpha OneMinusSrcAlpha
				CGPROGRAM
				//第二个通道渲染投影
				#include "LightProjection.cginc"
				ENDCG
			}
			//Add通道
			//渲染点光源
			Pass
			{
				Blend One One
				Tags{ "LightMode" = "ForwardAdd" }
				CGPROGRAM
				#pragma multi_compile_fwdadd_fullshadows
				#define projection_illm
				#define projection_bump
				#include "LightModel.cginc"
				ENDCG
			}
			//Add通道
			//渲染点光源
			Pass
			{
				Blend SrcAlpha OneMinusSrcAlpha
				Tags{ "LightMode" = "ForwardAdd" }
				ZWrite Off
				Cull Off
				CGPROGRAM
				#include "LightProjection.cginc"
				ENDCG
			}
		}
		FallBack "Diffuse"
}
