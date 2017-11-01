Shader "Custom/OutlineShader" {
	Properties {
		_OutlineColor ("Color", Color) = (1,1,1,1)
		_MainTex ("MainTex (RGB)", 2D) = "white" {}
		_OutlineSize ("OutLineSize", Range(0,0.1)) = 0.0
	
	}
	SubShader {
		Tags { "Queue"="Geometry" "RenderType"="Opaque" }
		LOD 200
		
		
		 
		 Pass
		 {
		     CULL FRONT
		     CGPROGRAM
		     #pragma vertex vert
			 #pragma fragment frag

			 fixed4 _OutlineColor;
			 sampler2D  _MainTex;
			 fixed   _OutlineSize;

             struct appIn
			 {
			      fixed4 vertex : POSITION;
				  fixed4 normal : NORMAL;
				  fixed2 uv     : TEXCOORD0;

			 };

			 struct ver2Frag
			 {
			     fixed4  vertex :SV_POSITION;
				 fixed4  normal :NORMAL;
			     fixed2  uv     :TEXCOORD0;
			 };


			 ver2Frag vert(appIn i)
			 {
			     ver2Frag v2f;
				 v2f.vertex = i.vertex;
				 v2f.vertex += normalize(i.normal)*_OutlineSize ;
				 v2f.vertex = mul(UNITY_MATRIX_MVP, v2f.vertex);
				 v2f.normal = i.normal;
				 v2f.uv = i.uv;

				 return v2f;
			 }

			 fixed4  frag(ver2Frag v) : SV_Target
			 {
			     return _OutlineColor;
			 }
			 ENDCG
		     
		 }

		  Pass
		 {
		     CGPROGRAM
		     #pragma vertex vert
			 #pragma fragment frag

			 fixed4 _OutlineColor;
			 sampler2D  _MainTex;
			 fixed   _OutlineSize;

             struct appIn
			 {
			      fixed4 vertex : POSITION;
				  fixed4 normal : NORMAL;
				  fixed2 uv     : TEXCOORD0;

			 };

			 struct ver2Frag
			 {
			     fixed4  vertex :SV_POSITION;
				 fixed4  normal :NORMAL;
			     fixed2  uv     :TEXCOORD0;
			 };


			 ver2Frag vert(appIn i)
			 {
			     ver2Frag v2f;
				 v2f.vertex = i.vertex;
				 v2f.vertex = mul(UNITY_MATRIX_MVP, v2f.vertex);
				 v2f.normal = i.normal;
				 v2f.uv = i.uv;

				 return v2f;
			 }

			 fixed4  frag(ver2Frag v) : SV_Target
			 {
			     return tex2D(_MainTex, v.uv);
			 }
			 ENDCG
		     
		 }
 
		
	}
	FallBack "Diffuse"
}
