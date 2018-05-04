// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
//逐像素高光 高光区域明显比逐顶点渲染圆滑

Shader "My Shader/SpecularPixelLevel"
{
	Properties
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)//漫反射颜色
		_Specular("Specular",Color) = (1,1,1,1)//高光颜色
		_Gloss("Gloss",Range(8.0,256)) = 20    //高光区域大小
	}

	SubShader
	{
		Tags { "LightMode" = "ForwardBase" }//光照类型

		Pass
		{
			CGPROGRAM

            //定义顶点着色器和片元着色器
			#pragma vertex vert
			#pragma fragment frag

			//包含文件
			#include "Lighting.cginc"

			//定义属性
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;//顶点信息
				float3 normal : NORMAL;  //法线信息
			};

			struct v2f
			{
				float4 pos : SV_POSITION;//顶点信息
				float3 worldNormal : TEXCOORD0;//世界法线
				float4 worldPos : TEXCOORD1;   //世界顶点信息
			};

			//顶点着色器
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);//裁剪后顶点信息
				o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);//世界法线转换
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);//世界顶点转换

				return o;
			}

			//片元着色器
			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;//获取环境光
				fixed3 worldNormal = normalize(i.worldNormal);//获取法线
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);//获取光照
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));//计算漫反射
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);//获取视线方向
				fixed3 reflectDir = normalize(reflect(-worldLight,worldNormal));//获取反射方向r
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir,viewDir)),_Gloss);//计算高光
				fixed3 color;
				color = ambient + diffuse + specular;//环境光加漫反射加高光
				return fixed4(color,1.0);

			}

			ENDCG
		}
	}
	Fallback "Specular"
}
