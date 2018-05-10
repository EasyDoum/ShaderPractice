Shader "Unlit/AlphaTextBothSide"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)//漫反射颜色
		_MainTex("Main Tex",2D) = "white" {}  //贴图纹理
		_CutOff("Cut Off",Range(0,1)) = 0.5   //透明度测试阈值
	}

	SubShader
	{
		Tags {"Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout"}//透明队列和渲染类型

		Pass 
		{
			Tags {"LightMode" = "ForwardBase"}  //前向光照

			Cull Off   //关闭剔除

			CGPROGRAM

			//定义着色器
			#pragma vertex vert 
			#pragma fragment frag 

			//包含文件
			#include "Lighting.cginc"

			//定义属性
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _CutOff;

			struct a2v
			{
				float4 vertex : POSITION;//顶点信息
				float3 normal : NORMAL;  //法线信息
				float4 texcoord : TEXCOORD0;//贴图信息
			};

			struct v2f
			{
				float4 pos : SV_POSITION;//顶点信息
				float3 worldNormal : TEXCOORD0;//世界法线
				float2 uv : TEXCOORD1;     //uv信息
				float3 worldPos :TEXCOORD2; //世界顶点
			};

			//顶点着色器
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);//裁剪顶点
				o.worldNormal = UnityObjectToWorldNormal(v.normal);//法线转换
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);//顶点转换
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);//uv转换

				return o;
			}

			//片元着色器
			fixed4 frag(v2f i) : SV_TARGET
			{
				//fixed3 worldPos = normalize(i.worldPos);//顶点归一化
				fixed3 worldNormal = normalize(i.worldNormal);//法线归一化
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));//光源
				fixed4 texColor = tex2D(_MainTex,i.uv);//贴图采样
				clip(texColor - _CutOff);//透明度测试

				fixed3 albedo = texColor.rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz *albedo;//环境光
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(lightDir,worldNormal));//漫反射

				fixed3 color = ambient + diffuse;  //环境光加漫反射

				return fixed4(color,1.0);

			}

			ENDCG
		}
	}
	Fallback "Transparent/Cutout/VertexLit"
}
