// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/TransparentShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Alpha  ("Alpha", Range(0.0,1.0)) = 0.5
	}
	SubShader {
		Tags {  "RenderType"="Transparent" "Queue="="Transparent" }
		LOD 100
		
		Pass
		{
		   Blend SrcAlpha  OneMinusSrcAlpha
		   CGPROGRAM
		     
			 #pragma vertex vert
			 #pragma fragment   frag

			 fixed4 _Color;
			 sampler2D  _MainTex;
			 fixed _Alpha;

			 struct appIn
			 {
			    fixed4 vertex :POSITION;
				fixed4 normal :NORMAL;
				fixed2 uv     :TEXCOORD0;
			 };

			 struct v2f
			 {
			    fixed4 vertex :SV_POSITION;
				fixed4 normal :NORMAL;
				fixed2 uv     :TEXCOORD0;
				fixed3 color  :COLOR;
			 };


			 v2f vert(appIn i)
			 {
			     v2f v;
				 v.vertex = i.vertex;
				 v.uv = i.uv;
				 float  f1 = 0.5;
				 //v.color = fixed3(f1,0,0);
				 v.color = f1;
				 v.vertex = UnityObjectToClipPos(v.vertex);
				 return v;
			 }

			 fixed4 frag(v2f v) : SV_Target
			 {
			      fixed4 col = tex2D(_MainTex, v.uv);
				  col.a = _Alpha;
				  col =  fixed4(v.color.r, v.color.g, v.color.b, _Alpha);
				  return col;
			 }
			  

		   ENDCG
		}
		 
	}
	FallBack "Diffuse"
}
