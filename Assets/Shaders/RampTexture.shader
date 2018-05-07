Shader "My Shader/RampTexture"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)//漫反射颜色
		_Specular("Specular",Color) = (1,1,1,1)//高光颜色
		_Gloss("Gloss",Range(8.0,256)) = 20    //高光区域
		_RampTex("Ramp Tex",2D) = "white" {}   //渐变贴图
	}

	SubShader
	{
		Pass 
		{
			Tags { "LightMode" = "ForwardBase" } //前向光照

			CGPROGRAM

			//定义着色器
			#pragma vertex vert 
			#pragma fragment frag 

			//包含文件
			#include "Lighting.cginc"

			//定义属性
			fixed4 _Color;
			fixed4 _Specular;
			float _Gloss;
			sampler2D _RampTex;
			float4 _RampTex_ST;

			struct a2v
			{
				float4 vertex : POSITION;//顶点信息
				float3 normal : NORMAL;  //法线信息
				float4 texcoord : TEXCOORD0;//渐变纹理
			};

			struct v2f
			{
				float4 pos : SV_POSITION;  //顶点信息
				float3 worldNormal : TEXCOORD0;//世界法线
				float3 worldPos : TEXCOORD1;  //世界顶点
				float2 uv : TEXCOORD2;        //uv信息
			};

			//顶点着色器
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);//裁剪顶点
				o.worldNormal = UnityObjectToWorldNormal(v.normal);//世界法线
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;//世界顶点
				o.uv = TRANSFORM_TEX(v.texcoord,_RampTex);//uv信息

				return o;
			}

			//片元着色器
			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed3 worldNormal = normalize(i.worldNormal);//法线方向
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));//入射光方向
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));//视角方向

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;  //环境光

				fixed halfLambert = 0.5 * dot(lightDir,worldNormal) + 0.5;//半兰伯特模型
				fixed3 diffuseColor = tex2D(_RampTex,fixed2(halfLambert,halfLambert)).rgb * _Color.rgb;//渐变采样
				fixed3 diffuse = diffuseColor * _LightColor0.rgb;//漫反射

				fixed3 halfDir = normalize(lightDir + viewDir);//h
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal,halfDir)),_Gloss);//高光

				fixed3 color = ambient + diffuse + specular;//环境光加漫反射加高光

				return fixed4 (color,1.0);
			}

			ENDCG
		}
	}
}
