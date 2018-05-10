Shader "Unlit/AlphaBlendBothSide"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1) //漫反射颜色
		_MainTex("Main Tex",2D) = "white" {}   //贴图纹理
		_AlphaScale("Alpha Scale",Range(0,1)) = 0.5 //透明度调节
	}

	SubShader
	{
		Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}

		Pass 
		{
			Tags {"LightMode" = "ForwardBase"} //前向光照

            Cull Front      //剔除前面
			ZWrite Off              //关闭深度写入
			Blend SrcAlpha OneMinusSrcAlpha  //混合方式

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
			fixed _AlphaScale;

			struct a2v
			{
				float4 vertex : POSITION;//顶点信息
				float3 normal : NORMAL;  //法线信息
				float4 texcoord : TEXCOORD0;//贴图纹理
			};

			struct v2f
			{
				float4 pos : SV_POSITION;//顶点信息
				float3 worldNormal : TEXCOORD0;//世界法线
				float3 worldPos : TEXCOORD1;   //世界顶点
				float2 uv : TEXCOORD2;     //uv信息
			};

			//顶点着色器
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);//裁剪顶点
				o.worldNormal = UnityObjectToWorldNormal(v.normal);//世界法线
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);  //世界顶点
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);//uv信息

				return o;
			}

			//片元着色器
			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed3 worldNormal = normalize(i.worldNormal);//归一化法线
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));//光源方向
				fixed4 texColor = tex2D(_MainTex,i.uv);//贴图采样

				fixed3 albedo = texColor.rgb * _Color.rgb;//颜色系数
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;//环境光
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,lightDir));//漫反射

				return fixed4(ambient + diffuse,texColor.a * _AlphaScale); 
			}

			ENDCG
		}

        //剔除前面
		Pass 
		{
			Tags {"LightMode" = "ForwardBase"} //前向光照

            Cull Back      //剔除背面
			ZWrite Off              //关闭深度写入
			Blend SrcAlpha OneMinusSrcAlpha  //混合方式

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
			fixed _AlphaScale;

			struct a2v
			{
				float4 vertex : POSITION;//顶点信息
				float3 normal : NORMAL;  //法线信息
				float4 texcoord : TEXCOORD0;//贴图纹理
			};

			struct v2f
			{
				float4 pos : SV_POSITION;//顶点信息
				float3 worldNormal : TEXCOORD0;//世界法线
				float3 worldPos : TEXCOORD1;   //世界顶点
				float2 uv : TEXCOORD2;     //uv信息
			};

			//顶点着色器
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);//裁剪顶点
				o.worldNormal = UnityObjectToWorldNormal(v.normal);//世界法线
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);  //世界顶点
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);//uv信息

				return o;
			}

			//片元着色器
			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed3 worldNormal = normalize(i.worldNormal);//归一化法线
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));//光源方向
				fixed4 texColor = tex2D(_MainTex,i.uv);//贴图采样

				fixed3 albedo = texColor.rgb * _Color.rgb;//颜色系数
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;//环境光
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,lightDir));//漫反射

				return fixed4(ambient + diffuse,texColor.a * _AlphaScale); 
			}

			ENDCG
		}

	}
	Fallback "Transparent/VertexLit"
}
