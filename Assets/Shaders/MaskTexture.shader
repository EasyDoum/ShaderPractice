Shader "My Shader/MaskTexture"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1) //漫反射颜色
		_MainTex("Main Tex",2D) = "white" {}   //漫反射贴图
		_BumpTex("Bump Tex",2D) = "white" {}   //法线贴图
		_BumpScale("Bump Scale",float) = 1.0   //凹凸度
		_SpecularMask("Specular Mask",2D) = "white" {}//遮罩纹理
		_SpecularScale("Specular Scale",float) = 1.0 //遮罩系数
		_Specular("Specular",Color) = (1,1,1,1)  //高光颜色
		_Gloss("Gloss",Range(8.0,256)) = 20      //高光区域
	}

	SubShader
	{
		Pass 
		{
			Tags { "LightMode" = "ForwardBase" }//前向光照

			CGPROGRAM

			//定义着色器
			#pragma vertex vert
			#pragma fragment frag 

			//包含文件
			#include "Lighting.cginc"

			//定义属性
			fixed4 _Color;
			sampler2D _MainTex;
			sampler2D _BumpTex;
			float _BumpScale;
			sampler2D _SpecularMask;
			float _SpecularScale;
			fixed4 _Specular;
			float _Gloss;
			float4 _MainTex_ST;

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
                float2 uv : TEXCOORD0;   //uv信息
				float3 lightDir : TEXCOORD1;//光源方向
				float3 viewDir : TEXCOORD2; //视角方向
			};

			//顶点着色器
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);//顶点信息
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;//uv信息

				TANGENT_SPACE_ROTATION;
				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;//光源信息
				o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;//视角方向

				return o;
			}

			//片元着色器
			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed3 lightDir = normalize(i.lightDir);//光源方向
				fixed3 viewDir = normalize(i.viewDir);  //视角方向
				fixed3 bump = UnpackNormal(tex2D(_BumpTex,i.uv.xy));//法线采样
				bump *= _BumpScale;
				fixed3 albedo = tex2D(_MainTex,i.uv.xy).rgb * _Color.rgb;//颜色
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;//环境光
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(lightDir,bump));//计算漫反射
				fixed3 halfDir = normalize(lightDir + viewDir);//h
				fixed specularMask = tex2D(_SpecularMask,i.uv.r) * _SpecularScale;//遮罩采样
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(lightDir,bump)),_Gloss) * specularMask;//计算高光
                fixed3 color = ambient + diffuse + specular;  //环境光加漫反射加高光

				return fixed4(color,1.0);        
			}

			ENDCG
		}
	}
	Fallback "Specular"
}
