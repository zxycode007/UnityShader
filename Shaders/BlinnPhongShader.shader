// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/BlinnPhongShader" {
	Properties {
		_DiffuseColor ("DiffuseColor", Color) = (1,1,1,1)
		_SpecularColor("SpecularColor", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(0,256)) = 20
	}
	SubShader {
		Tags {  "RenderType"="Opaque" }
		LOD 200
		
		Pass
		{
		 Tags { "LightMode"="ForwardBase" }
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
			   fixed3 color : COLOR;
		   };

		   v2f vert(a2v v)
		   {
		       v2f o;
			   o.pos = UnityObjectToClipPos(v.vertex);

			   fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

			   fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

			   fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

			   fixed3 diffuse = _LightColor0.rgb * _DiffuseColor.rgb * saturate(dot(worldNormal, worldLightDir));

			   fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);

			   //fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));

			   fixed3 halfDir = normalize(worldLightDir + viewDir);

			   fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(saturate(dot(worldNormal, halfDir)),_Gloss);

			   o.color = ambient + diffuse +specular;
			   return o;

		   }

		   fixed4 frag(v2f o) :SV_TARGET
		   {
		      return fixed4(o.color, 1.0);
		   }
		 
		ENDCG
		
		}

		
	}
	FallBack "Diffuse"
}
