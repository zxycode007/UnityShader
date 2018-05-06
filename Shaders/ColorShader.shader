// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//Shader名
Shader "Custom/ColorShader" 
{
    //属性定义 变量名（“面板名称”， 类型) = 预设值
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_NormalScale("VertexScale", Range(0,1)) = 0.0
	}
	SubShader 
	{
	    //定义Tag
		//Tag类型包括
		//Queue渲染队列：指明渲染先后顺序 Geometry 2000  BackGround 1000   AlphaTest2450
		//LOD  用于性能调整用
		//RenderType着色器的分类（透明、不透明）opaque   transparent   transparentCountout   Background   overplay
		//RenderSetup：Cull(Back Front)  ZTest  ZWrite  Blend(SrcFactor DstFactor)
		//DisableBatching关闭批处理/ForceNoShadowCasting强制该shader的物体不投射阴影/IgnoreProjector不受Projector/CanUseSpriteAtlas用于精灵时设为false/PreviewType
		//指明""材质预览类型
		Tags { "Queue"="Geometry" "RenderType"="Opaque"}
		LOD 100
		//UsePass 
		//Pass
		Pass
		{
		    //使用CG语言`		
		    CGPROGRAM

			//声明顶点着色器
			#pragma vertex vert
			//声明像素着色器
			#pragma fragment frag

			//低精度
			fixed4 _Color;
			//纹理贴图
			sampler2D _MainTex;
			fixed    _NormalScale;

			//定义输入输出结构
			struct appInput
			{
			     fixed4 vertex : POSITION;   //声明变量是顶点位置
				 fixed2 uv     : TEXCOORD0;    //声明纹理坐标0
				 fixed4 nomal  : NORMAL;
			};

			struct vert2Frag
			{
			     fixed4 vertex : SV_POSITION;     //特定值， 表示透视投影变化到ClipSpac的位置
				 fixed2 uv     : TEXCOORD0;
				 fixed4 nomal  : NORMAL;
			};


			vert2Frag vert(appInput i)
			{
			      vert2Frag ov;
				  ov.uv = i.uv;
				  //对顶点向发现方向偏移
				  i.vertex.xyz += i.nomal * _NormalScale;
				  //将顶点投影的视锥剪裁空间中
				  ov.vertex =  UnityObjectToClipPos(i.vertex);
				  
				  
			      //UNITY_MATRIX_MVP unity的mvp矩阵
			      return ov;
			}

			fixed4 frag(vert2Frag v) : SV_Target   //定义这个颜色值的语义是个RenderTarget
			{
			       
			      return tex2D(_MainTex, v.uv) * _Color;
			}

		
		      //GrabPass
		 
		     ENDCG
	     }
	//FallBack "Diffuse"
}

}