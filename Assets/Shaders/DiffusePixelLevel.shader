// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
//逐像素 单光源 平行光 漫反射

Shader "My Shader/DiffusePixelLevel"
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
				float3 normal : NORMAL;//法线信息
			};

			struct v2f
			{
				float4 pos : SV_POSITION;//顶点信息
				fixed3 worldNormal : TEXCOORD0;//颜色信息
			};
            
			//顶点着色器
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);//转换裁剪坐标
				o.worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));//转换为世界空间法线
				return o;
			}
			
			//片元着色器
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;//获取环境光
				fixed3 worldNormal = i.worldNormal;//获取法线信息
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);//获取光照
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));//计算漫反射
				fixed3 color = ambient + diffuse;//漫反射加环境光
				return fixed4(color,1.0);
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
