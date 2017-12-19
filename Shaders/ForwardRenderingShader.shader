// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/ForwardRenderingShader" {
	Properties {
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		

		//Forword Base
		//Forward Base 计算环境光和第一个逐像素光源（平行光）
		Pass
		{
		  //使用前向渲染
		  Tags {"LightMode"="ForwardBase"}
		  CGPROGRAM

		   //这个	条件编译保证在Shader中使用的光照衰减变量可以正确被赋值
		   #pragma multi_compile_fwdbase

		    #include "Lighting.cginc"
		
		   #pragma vertex vert
		   #pragma fragment  frag
		  
		   fixed4 _Diffuse;
		   fixed4 _Specular;
		   float  _Gloss;

		   struct a2v
		   { 
		       fixed4 vertex : POSITION;
			   fixed3 normal : NORMAL;
		   };

		   struct v2f
		   {
		       fixed4 pos :SV_POSITION;
			   float3 worldNormal : TEXCOORD0;
			   float3 worldPos : TEXCOORD1;
		   };

		   v2f vert(a2v v)
		   {
		        v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				return o;

		   }

		   fixed4 frag(v2f i) : SV_Target 
		   {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
			 	fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

			 	fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
			 	fixed3 halfDir = normalize(worldLightDir + viewDir);
			 	fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				fixed atten = 1.0;
				
				return fixed4(ambient + (diffuse + specular) * atten, 1.0);
			}
		 
		ENDCG
		
		}

		Pass
		{
		    //其它的逐像素光源由Forward Add计算
			//和Forward Base区别是去掉环境光/自发光/逐顶点光照/球谐光照,并添加一些对不同光源类型的支持（点光源，聚光灯）
			Tags { "LightMode"="ForwardAdd" }
			
			//混合模式 1+1
			Blend One One
		
			CGPROGRAM
			
			#pragma multi_compile_fwdadd
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				//判断是光源是否平行光
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
				#endif
				
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));
				
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
				//平行光不衰减
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;
				#else
					#if defined (POINT)
					    //点光源衰减根据距离来
						//_LightMatrix0世界空间到光源空间的变换矩阵
				        float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;   //光源坐标
						//用数学计算衰减消耗性能过大，这里使用一张纹理做查找表,来取得衰减值
				        fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #elif defined (SPOT)
					    //聚光灯衰减
				        float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
				        fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #else
				        fixed atten = 1.0;
				    #endif
				#endif

				return fixed4((diffuse + specular) * atten, 1.0);
			}
			
			ENDCG
		    
		}

		
	}
	FallBack "Diffuse"
}
