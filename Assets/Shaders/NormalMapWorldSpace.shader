// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "My Shader/NormalMapWorldSpace"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)//漫反射颜色
        _Specular("Specular",Color) = (1,1,1,1)//高光颜色
		_Gloss("Gloss",Range(8.0,256)) = 20  //高光区域大小
		_MainTex("Main Tex",2D) = "white" {}  //漫反射贴图
		_BumpMap("Bump Map",2D) = "bump" {}//法线贴图
		_BumpScale("Bump Scale",Float) = 1.0   //法线凹凸程度
	}

	SubShader
	{
		Pass 
		{
			Tags { "LightMode" = "ForwardBase" }  //前向渲染

			CGPROGRAM

			//定义着色器
			#pragma vertex vert 
			#pragma fragment frag 

			//包含文件
			#include "Lighting.cginc"
			//#include "UnityCG.cginc"

			//定义属性
			fixed4 _Color;
			fixed4 _Specular;
			float _Gloss;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;

			struct a2v
			{
				float4 vertex : POSITION;//顶点信息
                float3 normal : NORMAL;  //法线信息
                float4 tangent : TANGENT;//切线信息
				float4 texcoord : TEXCOORD0;//贴图信息
			};

			struct v2f
			{
				float4 pos : SV_POSITION;//顶点信息
				float4 uv : TEXCOORD0;   //uv信息
				float4 T2W0 : TEXCOORD1; //切线转世界
				float4 T2W1 : TEXCOORD2; //切线转世界
				float4 T2W2 : TEXCOORD3; //切线转世界
			};

			//顶点着色器
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);//裁剪顶点
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;//漫反射贴图
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;//法线贴图
				
				float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz; //世界顶点
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);//世界法线
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);//世界切线
				fixed3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;//世界副切线

				o.T2W0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);//x分量
				o.T2W1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);//y分量
				o.T2W2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);//z分量

				return o;
			}

			//片元着色器
			fixed4 frag(v2f i) : SV_Target
			{
				float3 worldPos = float3(i.T2W0.w,i.T2W1.w,i.T2W2.w);//顶点信息
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));//入射光方向
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));//视角方向

				fixed3 bump = UnpackNormal(tex2D(_BumpMap,i.uv.zw));//uv法线采样
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy,bump.xy)));
				bump = normalize(half3(dot(i.T2W0.xyz,bump),dot(i.T2W1.xyz,bump),dot(i.T2W2.xyz,bump)));//切线空间转世界空间

				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;//获取环境光

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(bump,lightDir));//计算漫反射
				
				fixed3 halfDir = normalize(lightDir + viewDir);//h
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(bump,halfDir)),_Gloss);//计算高光

				fixed3 color = ambient + diffuse + specular;//环境光加漫反射加高光

				return fixed4(color,1.0);
			}

		    ENDCG
		}
	}
	Fallback "Specular"
}
