Shader "Custom/Toon"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_RampTex("Ramp Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_Outline("Outline Width", Range(.002, 2.0)) = .005
	}

	SubShader
	{
		// Ramp texture
		CGPROGRAM
		#pragma surface surf ToonRamp

		sampler2D _MainTex;
		sampler2D _RampTex;
		fixed4 _Color;

		float4 LightingToonRamp(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			// Value between 0 - 1 based on the dot product result
			// It will decide the light intensity
			float diff = dot(s.Normal, lightDir);
			// h will decide the UV where indicate which color to use in Ramp texture
			float h = diff * 0.5 + 0.5;
			float3 ramp = tex2D(_RampTex, h).rgb;
			
			// Calculate specular
			half3 blinnHalf = normalize(lightDir + viewDir);
			half blinnDiff = max(0, dot(s.Normal, lightDir));
			float blinnNormalhalf = max(0, dot(s.Normal, blinnHalf));
			float3 spec = pow(blinnNormalhalf, 96.0);
			
			float4 c;
			// Multiply spec for specular if needed
			c.rgb = (s.Albedo * _LightColor0.rgb * ramp) * atten;
			c.a = s.Alpha;

			return c;
		}

		struct Input
		{
			float2 uv_MainTex;
			float3 viewDir;
		};

		void surf(Input IN, inout SurfaceOutput o)
		{
			float diff = dot(o.Normal, IN.viewDir);
			float h = diff * 0.5 + 0.5;
			float2 rh = h;
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Color.rgb;
		}
		ENDCG

		// Advanced outline
		Pass
		{
			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed4 color : COLOR;
			};

			float _Outline;
			float4 _OutlineColor;

			v2f vert(appdata v)
			{
				v2f o;
				// Transform to clip space
				o.pos = UnityObjectToClipPos(v.vertex);

				// Get the normal of a world coordinate
				float3 norm = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
				// Transform to screen view coord 
				float2 offset = TransformViewToProjection(norm.xy);

				o.pos.xy += offset * o.pos.z * _Outline;
				o.color = _OutlineColor;
				return o;
			}


			fixed4 frag(v2f i) : SV_Target
			{
				return i.color;
			}
			ENDCG
		}

	}
	Fallback "Diffuse"
}
