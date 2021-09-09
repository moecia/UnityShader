// Fantasy Adventure Environment
// Copyright Staggart Creations
// staggart.xyz

Shader "Hidden/PigmentMapComposite"
{
	Properties
	{
		[NoScaleOffset] _MainTex("Input pigment map", 2D) = "white" {}
		[NoScaleOffset] _SplatMap("Splatmap", 2D) = "white" {}
		_SplatMask("SplatMask", Vector) = (1,1,1,1) //RGBA component masks
		_Transform("Transform", Vector) = (0,0,0,0)
			//X: Horizontal
			//Y: Vertical
			//Z: Rotation
			//W: ...

	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _SplatMap;
				uniform float4 _SplatMask;
				uniform float4 _Transform;

				float2 RotateUV(float2 uv, float rotation) {
					float cosine = cos(rotation);
					float sine = sin(rotation);
					float2 pivot = float2(0.5, 0.5);
					float2 rotator = (mul(uv - pivot, float2x2(cosine, -sine, sine, cosine)) + pivot);
					return saturate(rotator);
				}

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);

					float2 uv = TRANSFORM_TEX(v.uv, _MainTex);
					if (_Transform.x == 1) uv.x = 1 - uv.x;
					if (_Transform.y == 1) uv.y = 1 - uv.y;
					uv = RotateUV(uv, _Transform.z);

					o.uv = uv;

					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					//Tex samples
					float3 col = tex2D(_MainTex, i.uv).rgb;
					float4 splatMap = tex2D(_SplatMap, i.uv);

					//Isolate splatmap channel
					float alpha = 0;
					alpha += splatMap.r * _SplatMask.r;
					alpha += splatMap.g * _SplatMask.g;
					alpha += splatMap.b * _SplatMask.b;
					alpha += splatMap.a * _SplatMask.a;

					//return float4(alpha, alpha, alpha, 1);

					//return float4(0, 1, 0, alpha);

					return float4(col.rgb, alpha);
				}
				ENDCG
			}
		}
}
