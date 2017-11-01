// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/PhongPerPixelLightShader" {
	Properties {
		_DiffuseColor ("DiffuseColor", Color) = (1,1,1,1)
		_SpecularColor("SpecularColor", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(0,256)) = 20
	}
	SubShader {Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }
		LOD 200
		
		Pass
		{		
		CGPROGRAM

		    #include "Lighting.cginc"
		
		   #pragma vertex vert
		   #pragma fragment  frag
		  
		   fixed4 _DiffuseColor;
		   fixed4 _SpecularColor;
		   float  _Gloss;

		   struct a2v
		   { 
		       fixed4 vertex : POSITION;
			   fixed3 normal : NORMAL;
		   };

		   struct v2f
		   {
		       fixed4 pos :SV_POSITION;
			   fixed3 worldNormal :TEXCOORD0;
			   fixed3 worldPos :TEXCOORD1;
		   };

		   v2f vert(a2v v)
		   {
		       v2f o;
			   o.pos = mul(UNITY_MATRIX_MVP, v.vertex);		   

			   o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

			   o.worldPos = mul((float3x3)unity_ObjectToWorld,v.vertex).xyz;

			   return o;

		   }

		   fixed4 frag(v2f o) :SV_TARGET
		   {
		      
			  fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

			  fixed3 worldNormal = normalize(o.worldNormal);

			  fixed3 worldPos = normalize(o.worldPos);

			  fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

			  fixed3 diffuse = _LightColor0.rgb * _DiffuseColor.rgb * saturate(dot(worldNormal, worldLightDir));

			  fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));

			  fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, worldPos).xyz);

			  fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(saturate(dot(reflectDir, viewDir)),_Gloss);



		      return fixed4(ambient + diffuse +specular, 1.0);
		   }
		 
		ENDCG
		}
	}
	FallBack "Diffuse"
}
