// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'  
  
Shader "Custom/DepthGrayscale" {  
SubShader {  
Tags { "RenderType"="Opaque" }  
  
Pass{  
CGPROGRAM  
#pragma vertex vert  
#pragma fragment frag  
#include "UnityCG.cginc"  
 
//相机深度纹理,来获取保存的场景的深度信息
//sampler2D _CameraDepthTexture;  
sampler2D _CameraDepthNormalsTexture;
  
struct v2f {  
   float4 pos : SV_POSITION;  
   float4 scrPos:TEXCOORD1;   //计算屏幕坐标
};  
  
//Vertex Shader  
v2f vert (appdata_base v){  
   v2f o;  
   o.pos = UnityObjectToClipPos (v.vertex);  
   o.scrPos=ComputeScreenPos(o.pos);  //计算屏幕坐标
   //for some reason, the y position of the depth texture comes out inverted  
   //o.scrPos.y = 1 - o.scrPos.y;   
   return o;  
}  
  
//Fragment Shader  
half4 frag (v2f i) : COLOR{  
	//从深度纹理中提取深度值
  // float depthValue = Linear01Depth (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r);  
   //多平台兼容性
  // float depthValue = SMAPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv);
  // half4 depth;  
  
  // depth.r = depthValue;  
  // depth.g = depthValue;  
  // depth.b = depthValue;  

  // fixed3 normal = 1.0; 
    
  
   //depth.a = 1;  
   //return depth; 
   float3 normalValues = 0;
   float depthValue = 0;
   //提取深度值和法线值信息
   DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.scrPos.xy), depthValue, normalValues);
   return fixed4(normalValues,1.0f); 
   //return fixed4(depthValue,depthValue,depthValue,1.0f); 
}  
ENDCG  
}  
}  
FallBack "Diffuse"  
}  