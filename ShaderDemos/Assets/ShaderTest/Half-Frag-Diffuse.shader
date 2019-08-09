Shader "Unlit/Half-Frag-Diffuse"
{
	Properties
	{
		//_MainTex ("Texture", 2D) = "white" {}

		// 颜色值.
		// 这里为什么会有参数. 光是输入 表面物体法线也是实际存在.

		_Diffuse("Diffuse", Color) = (1,1,1,1)

	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag


			#include "UnityCG.cginc"
			#include "Lighting.cginc"


			// 定义变量.
			fixed4 _Diffuse;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;

				float3 normal : NORMAL;
			};

			struct v2f
			{
				//float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;

				//fixed3 color : Color;

				fixed3 worldNormal : TEXCOORD0;
				fixed3 worldLight : TEXCOORD1;

			};


			// 为什么在顶点着色器里面写? 函数和光照模型

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				// uv和雾不用管.
				//o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//UNITY_TRANSFER_FOG(o,o.vertex);


				// 光源颜色. 本身光源颜色 还有一个环境光

				//// 获得环境光颜色.
				//fixed ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				// 获得世界法线.
				// 模型空间的法线转到世界空间.
				// 这个v还是模型空间的值.
				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				// 光源方向.
				// 世界空间的光源方向
				// 归一化之后的光源方向.
				o.worldLight = normalize(UnityWorldSpaceLightDir(mul(unity_ObjectToWorld, v.vertex).xyz));

				//// 感觉这里方向反了.
				//o.worldLight = 0 - o.worldLight;

				//// 漫发射颜色.
				//fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLight));


				// worldNormal和worldLight放到顶点着色器里算 难道为省计算量?

				// 传到片元着色器里面去.
				//o.color = diffuse;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				//// sample the texture
				//fixed4 col = tex2D(_MainTex, i.uv);
				//// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);
				//return col;

				// 获得环境光颜色.
				fixed ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

			// 漫发射颜色.
			// worldNormal和worldLight没有传递过来. 
			fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (dot(i.worldNormal, i.worldLight) * 0.5 + 0.5);

			return fixed4(diffuse, 1);
		}
		ENDCG
	}
	}
}
