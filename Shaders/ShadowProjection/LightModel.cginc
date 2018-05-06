// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

struct a2v
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
	float3 normal:NORMAL;
};
#include "AutoLight.cginc"
struct v2f
{
	float2 uv : TEXCOORD0;
	float4 pos : SV_POSITION; //裁剪坐标
	float4 wPos:TEXCOORD1; //世界坐标
	float3 normal:TEXCOORD2;
	LIGHTING_COORDS(3, 4)    //LIGHTING_COORDS定义了阴影贴图和光照贴图采样所需的变量，参数数字表示所占用的的TEXCOORD##
		UNITY_FOG_COORDS(5)  //UNITY_FOG_COORDS定义雾化所需的坐标变量，参数数字表示占用的TEXCOORD##
};

uniform float4 _LightColor0;
uniform fixed4 _Color;
uniform sampler2D _MainTex;
uniform float4 _MainTex_ST;
#if defined(projection_bump)
uniform sampler2D _BumpTex;
#endif
#if defined(projection_illm)
uniform fixed4 _Illum;
#endif

v2f vert(a2v v)
{
	v2f o;
	o.pos = UnityObjectToClipPos(v.vertex);
	o.wPos = mul(unity_ObjectToWorld, v.vertex);
	_MainTex_ST.zw *= _Time.x;
	o.uv = TRANSFORM_TEX(v.uv, _MainTex);
	o.normal = UnityObjectToWorldNormal(v.normal);
	//计算雾化坐标并保存到v2f结构体中,事先用UNITY_FOG_COORDS定义
	UNITY_TRANSFER_FOG(o, o.pos);
	//转换顶点坐标到光源坐标系下,计算LIGHTING_COORDS定义的阴影坐标
	TRANSFER_VERTEX_TO_FRAGMENT(o)
		return o;
}

float3 lightDir;
float3 normal;

fixed4 lambert(v2f i)
{
//使用凹凸贴图
#if defined(projection_bump)
	half3 nor = UnpackNormal(tex2D(_BumpTex, i.uv));//提取扰动后的法向量
	normal = normalize(i.normal + nor.xyy * half3(2.2, 0, 2.2)); //对法线进行扰动
#else
	normal = i.normal;
#endif
	lightDir = normalize(UnityWorldSpaceLightDir(i.wPos));
	float NdotL = max(-0.3, dot(normal, lightDir));  //法线与光照方向夹角
	float atten = LIGHT_ATTENUATION(i)  * NdotL * 1.1;  //采样光照图取计算光照衰减值
	fixed4 col = tex2D(_MainTex, i.uv) * _Color; //主纹理颜色值
	col.rgb *= atten * _LightColor0.rgb + UNITY_LIGHTMODEL_AMBIENT.rgb;
	return col;
}

fixed4 frag(v2f i) : SV_Target
{
	fixed4 col = lambert(i);
#if defined(projection_illm)
	float NdotL = max(0, -dot(normal, lightDir));
	col.rgb += _Illum.rgb * clamp(NdotL, 0, col.a) * _Illum.a;
#endif
	UNITY_APPLY_FOG(i.fogCoord, col);
	return col;
}