// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
//逐顶点 单光源 平行光 漫反射

Shader "My Shader/DiffuseVertexLevel"
{
	Properties
	{
		_Diffuse("Diffuse",Color)=(1,1,1,1)//漫反射系数
	}
	SubShader
	{
		Tags { "LightMode"="ForwardBase" }//光照类型

		Pass
		{
			CGPROGRAM
			//定义顶点着色器和片元着色器
			#pragma vertex vert
			#pragma fragment frag
            //文件包含
			#include "Lighting.cginc"
			//定义属性变量
			fixed4 _Diffuse;


			struct a2v
			{
				float4 vertex : POSITION;//顶点信息
				float2 normal : NORMAL;//法线信息
			};

			struct v2f
			{
				float4 pos : SV_POSITION;//顶点信息
				fixed3 color : Color;//颜色信息
			};
            
			//顶点着色器
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);//转换裁剪坐标
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;//获取环境光
				fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));//转换为世界空间法线
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);//获取光照
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));//计算漫反射
				o.color = ambient + diffuse;//漫反射加环境光
				return o;
			}
			
			//片元着色器
			fixed4 frag (v2f i) : SV_Target
			{
				return fixed4(i.color,1.0);
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
