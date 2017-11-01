Shader "Custom/NormalMapShader" {
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
			   float3 lightDir :TEXCOORD1;  //从VS到PS传自定义数据，一般用TEXCOORD
			   float3 viewDir :TEXCOORD2;
		   };

		   v2f vert(a2v v)
		   {
		       v2f o;
			   o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			   
			   o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			   o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
			   //计算计算副法线
			   ////副法线 = 叉积（单位化的法向量，单位化的切线向量）*切线向量的w分量来确定副切线的方向性
			   float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz)) * v.tangent.w;
			   //构建切线空间变换矩阵,将对象空间变化到切线空间
			   float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
			   //或者使用TANGENT_SPACE_ROTATION宏
			   //将对象空间的光照向量变化到切线空间
			   o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex).xyz);
			   //将对象空间观察向量变换到切线空间
			   o.viewDir  = mul(rotation, ObjSpaceViewDir(v.vertex).xyz);

			   return o;

		   }

		   fixed4 frag(v2f i) :SV_TARGET
		   {
		      //切线空间的光照和观察向量
		      fixed3 tangentLightDir = normalize(i.lightDir);
			  fixed3 tangentViewDir = normalize(i.viewDir);

			  //从法线贴图中取出扰动后的法线向量
			  fixed4  packedNormal = tex2D(_BumpMap, i.uv.zw);
			  //切线空间下的法线向量
			  fixed3  tangentNormal;
			  //如果纹理未被打包成Normal Map
			  //反应射到-1,1的范围
			  tangentNormal.xy = (packedNormal.xy * 2 -1) *_BumpScale;
			  //x^2+y^2+z^2 = 1    z = sqrt(1 - (x^2+ y^2));
			  tangentNormal.z = sqrt(1.0 - saturate( dot(tangentNormal.xy, tangentNormal.xy)));
			  //或者纹理已经被标记为NORMAL MAP
			  tangentNormal = UnpackNormal(packedNormal);
			  tangentNormal.xy = tangentNormal.xy * _BumpScale;
			  tangentNormal.z = sqrt(1.0 - saturate( dot(tangentNormal.xy, tangentNormal.xy)));

			  fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;

			  fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			  //_LightColor0 引用的是你场景中的灯光的颜色
			  fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

			  fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);

			  fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0,dot(tangentNormal, halfDir)),_Gloss);

				
			 return fixed4(ambient + diffuse + specular, 1.0);
		   }
		 
		ENDCG
		}
	}	
}
