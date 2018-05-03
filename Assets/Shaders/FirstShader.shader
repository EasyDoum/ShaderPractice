// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "My shader/First shader"
{
	Properties
	{
		_Color("Color Tint",Color)=(1.0,1.0,1.0,1.0)
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;

			struct a2v
			{
				float4 vertex:POSITION;//顶点坐标
				float3 normal:NORMAL;//法线方向
				float4 texcoord:TEXCOORD0;//纹理坐标
			};

			struct v2f
			{
				float4 pos:SV_POSITION;//顶点裁剪坐标
				fixed3 color:COLOR0;//颜色信息
			};
            
			v2f vert(a2v v)//顶点着色器
            {
				v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);//顶点裁剪坐标
				o.color=v.normal*0.5+fixed3(0.5,0.5,0.5);//颜色信息
				return o;
            }
            
            fixed4 frag(v2f i):SV_Target//片元着色器
            {
				fixed3 c=i.color;
				c *= _Color;
                return fixed4(c,1.0);
            }

			ENDCG
		}
	}
}
