///光线锥效果
//使用雾化和透明来实现光线的淡入淡出
Shader "Custom/LightRay"
{
	Properties
	{
		_ProjectionEdge("ProjectionEdge",Range(0,10)) = 4
		_ProjectionLength("ProjectionLength",Range(0,100)) = 10
		_ProjectionFadeout("Fadeout distance",float) = 5
	}
		SubShader
	{
		Tags{ "RenderType" = "Transparent"
		"Queue" = "Transparent" }
		LOD 100
		CGINCLUDE
		#pragma vertex vert
		#pragma fragment lfrag
		#pragma multi_compile_fog 
		#include "UnityCG.cginc"  
		//利用LightProjection来生成光线锥
		#include "LightProjection.cginc"

		uniform float4 _LightColor0;
		uniform float _ProjectionEdge;
		//多通道共用fragshader，不必写在每个pass中
		fixed4 lfrag(v2f i) : SV_Target
		{
			//光源颜色
			fixed4 col = _LightColor0;
			float3 lDir = normalize(UnityWorldSpaceLightDir(i.wPos));
			float NdotL = dot(i.normal, lDir);
			col.a = min(1,(pow(1 + NdotL, 8)));

			float3 vDir = normalize(UnityWorldSpaceLightDir(_WorldSpaceCameraPos.xyz));
			float3 NcrossL = cross(i.normal,lDir);
			float3 VcrossL = cross(vDir,lDir);
			float NLdotVL = dot(NcrossL, VcrossL);
			float VdotL = dot(vDir,lDir);
			col.a *= pow(max(abs(NLdotVL), pow(VdotL,4)),_ProjectionEdge);

			col.a *= pow(min(distance(_WorldSpaceCameraPos.xyz, i.wPos), _ProjectionFadeout) / _ProjectionFadeout, 3);
			return col;
		}
		ENDCG
		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }
			ZWrite Off
			Cull Off
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			ENDCG
		}
		Pass
		{
		Tags{ "LightMode" = "ForwardAdd" }
		ZWrite Off
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha
		CGPROGRAM
		ENDCG
		}
	}
}
