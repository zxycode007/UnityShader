// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/NormalMapForWorldSpaceShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap ("Bump Map", 2D) = "bump" {}
		_BumpScale ("Bump Scale", Float) = 1.0
		_SpecularColor ("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(0,256)) = 20

	}SubShader {
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
		   sampler2D _BumpMap;
		   float   _BumpScale;
		   float4 _MainTex_ST;
		   float4 _BumpMap_ST;
		   fixed4 _SpecularColor;
		   float  _Gloss;

		   struct a2v
		   { 
		       fixed4 vertex : POSITION;
			   fixed3 normal : NORMAL;
			   float4 tangent : TANGENT;
			   float4 texcoord : TEXCOORD0;
		   };

		   struct v2f
		   {
		       fixed4 pos :SV_POSITION;
			   float4 uv : TEXCOORD0;  //由于使用两张纹理，需要两个纹理坐标。其中uv.xy存储_MainTex的纹理坐标，uv.zw存储_BumpMap的纹理坐标(以减少插值寄存器的使用数目)
			   float4 T2W0 : TEXCOORD1;  //将切线空间变化世界空间的矩阵
			   float4 T2W1 : TEXCOORD2;
			   float4 T2W2 : TEXCOORD3;
		   };

		   v2f vert(a2v v)
		   {
		       v2f o;
			   o.pos = UnityObjectToClipPos(v.vertex);
			   
			   o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			   o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
			   //计算计算副法线
			   ////副法线 = 叉积（单位化的法向量，单位化的切线向量）*切线向量的w分量来确定副切线的方向性
			   //float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz)) * v.tangent.w;
			   
			   fixed3 worldPos =  mul(unity_ObjectToWorld,v.vertex).xyz;
			   //将法线由对象空间变为世界空间()
			   fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
			   //将切线向量由对象空间变为世界空间
			   fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);

			   fixed3 worldBinormal = cross(worldNormal, worldTangent)* v.tangent.w;

			   //构成切线空间转世界空间矩阵
			   o.T2W0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
			   o.T2W1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.x);
			   o.T2W2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.x);

			   return o;

		   }

		   fixed4 frag(v2f i) :SV_TARGET
		   {
		      //世界坐标
			  float3  worldPos = float3(i.T2W0.w, i.T2W1.w, i.T2W2.w);
			  //计算世界空间下光照和观察向量
			  float3  worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
			  float3  worldViewDir  = normalize(UnityWorldSpaceViewDir(worldPos));
			  //取出法线贴图中扰动后的法线方向
			  fixed3  packedNormal =  UnpackNormal(tex2D(_BumpMap, i.uv.zw));
			  fixed3  worldNormal = packedNormal;
			  //映射到-1,1的范围
			  worldNormal.xy *= _BumpScale;
			  worldNormal.z = sqrt(1.0 - saturate( dot(worldNormal.xy, worldNormal.xy)));
			  //将扰动法线由切线空间变化到世界空间
			  worldNormal = normalize(half3(dot(i.T2W0,worldNormal), dot(i.T2W1,worldNormal), dot(i.T2W2, worldNormal)));

			  //去主纹理颜色
			  fixed3  albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
			  //环境光颜色
			  fixed3  ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

			  fixed3  diffuse =  _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

			  fixed3  halfDir =  normalize(worldLightDir + worldViewDir);

			  fixed3  specular = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0,dot(worldNormal, halfDir)), _Gloss);


		   //   //切线空间的光照和观察向量
		   //   fixed3 tangentLightDir = normalize(i.lightDir);
			  //fixed3 tangentViewDir = normalize(i.viewDir);

			  ////从法线贴图中取出扰动后的法线向量
			  //fixed4  packedNormal = tex2D(_BumpMap, i.uv.zw);
			  ////切线空间下的法线向量
			  //fixed3  tangentNormal;
			  ////如果纹理未被打包成Normal Map
			  ////反应射到-1,1的范围
			  //tangentNormal.xy = (packedNormal.xy * 2 -1) *_BumpScale;
			  ////x^2+y^2+z^2 = 1    z = sqrt(1 - (x^2+ y^2));
			  //tangentNormal.z = sqrt(1.0 - saturate( dot(tangentNormal.xy, tangentNormal.xy)));
			  ////或者纹理已经被标记为NORMAL MAP
			  //tangentNormal = UnpackNormal(packedNormal);
			  //tangentNormal.xy = tangentNormal.xy * _BumpScale;
			  //tangentNormal.z = sqrt(1.0 - saturate( dot(tangentNormal.xy, tangentNormal.xy)));

			  //fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;

			  //fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			  ////_LightColor0 引用的是你场景中的灯光的颜色
			  //fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

			  //fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);

			  //fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0,dot(tangentNormal, halfDir)),_Gloss);

				
			 return fixed4(ambient + diffuse + specular, 1.0);
		   }
		 
		ENDCG
		}
	}	
}
