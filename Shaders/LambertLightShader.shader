// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/LambertLightShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		 
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Pass 
		{

		Tags { "LightMode"="ForwardBase" }

		CGPROGRAM
		   
		   #include "Lighting.cginc"

		   #pragma vertex vert
		   #pragma fragment  frag

		   fixed4  _Color;

		   struct a2v
		   {
		       float4 vertex : POSITION;
			   float3 normal : NORMAL;
		   };

		   struct v2f
		   {
		       float4 pos : SV_POSITION;
			   fixed3 worldNormal : TEXCOORD0;
		   };

		   v2f vert(a2v v)
		   {
		      v2f o;

		      o.pos = UnityObjectToClipPos(v.vertex);

			  fixed3 ambient =  UNITY_LIGHTMODEL_AMBIENT.xyz;  //环境光参数

			  o.worldNormal =  normalize(mul(v.normal, (float3x3)unity_WorldToObject));  //顶点法线变化到世界空间是法线乘以逆转置矩阵(调换位置相当于乘以转置矩阵 )

			  return o;
		   };

		   fixed4  frag(v2f i): SV_TARGET
		   {
		        //逐像素光照的计算通过像素着色器完成，法线信息由硬件插值完成
				//与漫反射着色器不同是，漫反射是对颜色插值

		        fixed3 ambient =  UNITY_LIGHTMODEL_AMBIENT.xyz;  //环境光参数

				fixed3 worldNormal = normalize(i.worldNormal);

				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);  //世界空间光源位置  平行光的相当于光照方向

				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal , worldLight));   //漫反射光技术Cdiffuse =   Clight * CdiffuseColor * (n * l)

				fixed3 color = ambient + diffuse;

		        return fixed4(color, 1.0);
		   }
		ENDCG
	}
	//FallBack "Diffuse"
}
}