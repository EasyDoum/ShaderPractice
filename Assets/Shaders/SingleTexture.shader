//加入纹理的blinn-phong模型，如果不加纹理贴图，模型渲染的颜色要比无纹理计算的更深一些，应该是纹理采样导致的

Shader "My Shader/SingleTexture"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)//颜色属性
		_MainTex("Main Tex",2D) = "white" {}  //2d纹理
		_Specualar("Specular",Color) = (1,1,1,1)//高光颜色
		_Gloss("Gloss",Range(8.0,256)) = 20     //高光区域大小
	}

	SubShader
	{

		Pass 
		{
			Tags{ "LigthMode" = "ForwardBase" }  //前向渲染

            CGPROGRAM

			//定义顶点着色器和片元着色器
			#pragma vertex vert
			#pragma fragment frag

			//包含文件
			#include "Lighting.cginc"

			//定义属性
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Specualar;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;//顶点信息
				float3 normal : NORMAL;  //法线信息
				float4 texcoord : TEXCOORD0;//纹理信息
			};

			struct v2f
			{
				float4 pos : SV_POSITION;//顶点信息
				float3 worldNormal : TEXCOORD0;//世界法线
				float3 worldPos : TEXCOORD1;//世界顶点
				float2 uv : TEXCOORD2;      //uv信息
			};

			//顶点着色器
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);//裁剪后顶点
				o.worldNormal = UnityObjectToWorldNormal(v.normal);//世界法线转换
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);    //世界顶点转换
				//o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;//uv信息
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);//使用unity内置函数获取uv信息

				return o;
			}

			//片元着色器
			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);//归一化顶点
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));//归一化光源
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));//归一化视线
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb; //纹理采样
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldLight,worldNormal));//计算漫反射
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;//环境光
				fixed3 halfDir = normalize(worldLight + viewDir);//h
				fixed3 specular = _LightColor0.rgb * _Specualar.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);//计算高光
				fixed3 color = diffuse + specular + ambient;//漫反射加高光加环境光

				return fixed4(color,1.0);
			}

			ENDCG
		}
	}
	Fallback "Specular"
}
