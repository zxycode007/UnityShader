// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/SingleTextureShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_SpecularColor ("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(0,256)) = 20
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
		  
		   fixed4 _Color;
		   sampler2D _MainTex;
		   float4 _MainTex_ST;
		   fixed4 _SpecularColor;
		   float  _Gloss;

		   struct a2v
		   { 
		       fixed4 vertex : POSITION;
			   fixed3 normal : NORMAL;
			   float4 texcoord : TEXCOORD0;
		   };

		   struct v2f
		   {
		       fixed4 pos :SV_POSITION;
			   float3 worldNormal : TEXCOORD0;
			   float3 worldPos : TEXCOORD1;
			   float2 uv : TEXCOORD2;
		   };

		   v2f vert(a2v v)
		   {
		       v2f o;
			   o.pos = UnityObjectToClipPos(v.vertex);
			   
			   o.worldPos = mul(unity_WorldToObject, v.vertex).xyz;
			   //计算法线
			   o.worldNormal = UnityObjectToWorldNormal(v.normal);
			   //uv = 纹理坐标*坐标缩放+坐标偏移
			   o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			   //内置函数包含上面功能
			  // o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

			   return o;

		   }

		   fixed4 frag(v2f i) :SV_TARGET
		   {
		      //取出世界空间的法线
		      fixed3  worldNormal = normalize(i.worldNormal);
			  //世界空间光照方向
			  fixed3  worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

			//用纹理去取样漫反射颜色
			 fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

			 fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

			 fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
			 //float3 UnityWorldSpaceViewDir(float4 v) 输入一个世界空间中的顶点位置,返回世界空间中从该点到摄像机的观察方向
			 fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
			 fixed3 halfDir = normalize(worldLightDir + viewDir);

			 fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
				
			 return fixed4(ambient + diffuse + specular, 1.0);
		   }
		 
		ENDCG
		}
	}	
}
