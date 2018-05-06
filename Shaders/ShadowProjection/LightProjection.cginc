struct a2v
{
	float4 vertex : POSITION;
	float3 normal:NORMAL;
};

struct v2f
{
	float4 vertex : SV_POSITION;
	float3 wPos:TEXCOORD1;
	float3 normal:TEXCOORD2;
};
//投影颜色
uniform fixed4 _ProjectionColor;
//投影长度
uniform float _ProjectionLength;
//投影淡入
uniform float _ProjectionFadeout;
v2f vert(a2v v)
{
	v2f o;
	o.wPos = mul(unity_ObjectToWorld, v.vertex);
	o.normal = UnityObjectToWorldNormal(v.normal);
	float3 lightDir = normalize(UnityWorldSpaceLightDir(o.wPos)); //获取该点世界空间的光照方向
	v.vertex.xyz += v.normal*0.01;//该点坐标向法线方向移动
	v.vertex = mul(UNITY_MATRIX_M, v.vertex);  //模型空间转到世界空间
	float NdotL = min(0, dot(o.normal, lightDir)); //法线方向和光照夹角
	v.vertex.xyz += lightDir *NdotL* _ProjectionLength; //再想光照方向延伸
	o.vertex = v.vertex = mul(UNITY_MATRIX_VP, v.vertex); //转到时间空间
	return o;
}
fixed4 frag(v2f i) : SV_Target
{
	fixed4 col = _ProjectionColor;
	float NdotL = dot(i.normal, normalize(UnityWorldSpaceLightDir(i.wPos)));
	col.a = min(_ProjectionColor.a,(pow(1.1 - abs(NdotL), 8))); //透明度的计算
	col.a *= pow(min(distance(_WorldSpaceCameraPos.xyz, i.wPos), _ProjectionFadeout) / _ProjectionFadeout, 3);//根据距离计算衰减
	return col;
}