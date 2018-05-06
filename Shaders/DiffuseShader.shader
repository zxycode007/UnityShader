// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/DiffuseShader" {
	Properties {
		_DiffuseColor ("DiffuseColor", Color) = (1,1,1,1)
	}
	SubShader {
		Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }
		LOD 200

		Pass
		{
		CGPROGRAM
		  

		   #include "Lighting.cginc"

		   #pragma vertex vert
		   #pragma fragment  frag

		   fixed4  _DiffuseColor;

		   struct a2v
		   {
		       float4 vertex : POSITION;
			   float3 normal : NORMAL;
		   };

		   struct v2f
		   {
		       float4 pos : SV_POSITION;
			   fixed3 color : COLOR;
		   };

		   v2f vert(a2v v)
		   {
		      v2f o;

		      o.pos = UnityObjectToClipPos(v.vertex);

			  fixed3 ambient =  UNITY_LIGHTMODEL_AMBIENT.xyz;  //环境光参数

			  fixed3 worldNormal =  normalize(mul(v.normal, (float3x3)unity_WorldToObject));  //顶点法线变化到世界空间是法线乘以逆转置矩阵(调换位置相当于乘以转置矩阵 )

			  fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);  //世界空间光源位置  平行光的相当于光照方向

			  fixed3 diffuse = _LightColor0.rgb * _DiffuseColor.rgb * saturate(dot(worldNormal , worldLight));   //漫反射光技术Cdiffuse =   Clight * CdiffuseColor * (n * l)

			  o.color = diffuse;

			  return o;
		   };

		   fixed4  frag(v2f i): SV_TARGET
		   {
		        return fixed4(i.color, 1.0);
		   }
		   ENDCG
		   
		}
		
		
		 
		
	}
	//FallBack "Diffuse"
}
