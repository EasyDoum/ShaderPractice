Shader "My Shader/NormalMapTangentSpace"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)//颜色属性
		_Specular("Specular",Color) = (1,1,1,1)//高光颜色
		_Gloss("Gloss",Range(8,256)) = 20      //高光区域大小
		_MainTex("Main Tex",2D) = "white" {}   //纹理
		_BumpMap("Bump Map",2D) = "bump" {}    //法线贴图
		_BumpScale("Bump Scale",Float) = 1.0   //缩放
	}

	SubShader
	{

		Pass 
		{
			Tags { "LightMode" = "ForwardBase"}  //前向渲染

			CGPROGRAM

			//定义着色器
			#pragma vertex vert 
			#pragma fragment frag 

			//包含文件
			#include "Lighting.cginc"
			#include "UnityCG.cginc"

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
				float3 normal : NORMAL;//法线信息
				float4 tangent : TANGENT;//切线信息
				float4 texcoord : TEXCOORD0;//纹理信息
			};

			struct v2f
			{
				float4 pos : SV_POSITION;//顶点信息
				float4 uv : TEXCOORD0;//uv信息
				float3 lightDir : TEXCOORD1;//入射光
				float3 viewDir : TEXCOORD2;//视角方向
			};

			//顶点着色器
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);//裁剪顶点
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;//漫反射贴图信息
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;//法线贴图信息
				//float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz))+v.tangent.w;//获取副切线
				//float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);//切线空间矩阵
				TANGENT_SPACE_ROTATION;                              //使用unity内置宏得到切线空间矩阵
				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;  //获取切线空间的光照
				o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;    //获取切线空间的视角

				return o;
			}

			//片元着色器
			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 tangentLightDir = normalize(i.lightDir);//归一化入射光
				fixed3 tangentViewDir = normalize(i.viewDir);//归一化视角
				fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);//法线贴图采样
				fixed3 tangentNormal;
				//手动映射得到切线空间的法线
				//tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
				//tangentNormal.z = sprt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));
 
                //unity自己转换
                tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;//漫反射贴图采样
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;//获取环境光
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal,tangentLightDir));//计算漫反射

				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);//h
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal,halfDir)),_Gloss);//计算高光

				fixed3 color = ambient + diffuse + specular;//环境光加漫反射加高光

				return fixed4(color,1.0);
			}
		

			ENDCG
		}
	}
}
