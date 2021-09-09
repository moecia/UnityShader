// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FAE/Grass"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[HDR]_ColorTop("ColorTop", Color) = (0.3001064,0.6838235,0,1)
		[HDR]_ColorBottom("Color Bottom", Color) = (0.232,0.5,0,1)
		[NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
		[NoScaleOffset][Normal]_BumpMap("BumpMap", 2D) = "bump" {}
		_ColorVariation("ColorVariation", Range( 0 , 0.2)) = 0.05
		_AmbientOcclusion("AmbientOcclusion", Range( 0 , 1)) = 0
		_TransmissionSize("Transmission Size", Range( 0 , 20)) = 1
		_TransmissionAmount("Transmission Amount", Range( 0 , 10)) = 2.696819
		_MaxWindStrength("Max Wind Strength", Range( 0 , 1)) = 0.126967
		_WindSwinging("WindSwinging", Range( 0 , 1)) = 0.25
		_WindAmplitudeMultiplier("WindAmplitudeMultiplier", Float) = 1
		_HeightmapInfluence("HeightmapInfluence", Range( 0 , 1)) = 0
		_MinHeight("MinHeight", Range( -1 , 0)) = -0.5
		_MaxHeight("MaxHeight", Range( -1 , 1)) = 0
		_BendingInfluence("BendingInfluence", Range( 0 , 1)) = 0
		_PigmentMapInfluence("PigmentMapInfluence", Range( 0 , 1)) = 0
		_PigmentMapHeight("PigmentMapHeight", Range( 0 , 1)) = 0
		_BendingTint("BendingTint", Range( -0.1 , 0.1)) = -0.05
		[Toggle(_VS_TOUCHBEND_ON)] _VS_TOUCHBEND("VS_TOUCHBEND", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" }
		Cull Off
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityStandardUtils.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma shader_feature _VS_TOUCHBEND_ON
		#include "VS_InstancedIndirect.cginc"
		#pragma multi_compile GPU_FRUSTUM_ON __
		#pragma instancing_options assumeuniformscaling lodfade maxcount:50 procedural:setupScale forwardadd
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float4 vertexColor : COLOR;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _MaxWindStrength;
		uniform float _WindStrength;
		uniform sampler2D _WindVectors;
		uniform float _WindAmplitudeMultiplier;
		uniform float _WindAmplitude;
		uniform float _WindSpeed;
		uniform float4 _WindDirection;
		uniform float _WindSwinging;
		uniform float4 _ObstaclePosition;
		uniform float _BendingStrength;
		uniform float _BendingRadius;
		uniform float _BendingInfluence;
		uniform sampler2D _PigmentMap;
		uniform float4 _TerrainUV;
		uniform float _PigmentMapInfluence;
		uniform float _MinHeight;
		uniform float _HeightmapInfluence;
		uniform float _MaxHeight;
		uniform sampler2D _MainTex;
		uniform float _WindDebug;
		uniform float4 _ColorTop;
		uniform float4 _ColorBottom;
		uniform float _PigmentMapHeight;
		uniform float _ColorVariation;
		uniform float _TransmissionSize;
		uniform float _TransmissionAmount;
		uniform float _BendingTint;
		uniform float _AmbientOcclusion;
		uniform sampler2D _BumpMap;
		uniform float _Cutoff = 0.5;


		sampler2D	_TouchReact_Buffer;
		float4 _TouchReact_Pos;
		 
		float3 TouchReactAdjustVertex(float3 pos)
		{
		   float3 worldPos = mul(unity_ObjectToWorld, float4(pos,1));
		   float2 tbPos = saturate((float2(worldPos.x,-worldPos.z) - _TouchReact_Pos.xz)/_TouchReact_Pos.w);
		   float2 touchBend  = tex2Dlod(_TouchReact_Buffer, float4(tbPos,0,0));
		   touchBend.y *= 1.0 - length(tbPos - 0.5) * 2;
		   if(touchBend.y > 0.01)
		   {
		      worldPos.y = min(worldPos.y, touchBend.x * 10000);
		   }
		
		   float3 changedLocalPos = mul(unity_WorldToObject, float4(worldPos,1)).xyz;
		   return changedLocalPos - pos;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float WindStrength522 = _WindStrength;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 appendResult469 = (float2(_WindDirection.x , _WindDirection.z));
			float3 WindVector91 = UnpackNormal( tex2Dlod( _WindVectors, float4( ( ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) + ( ( ( _WindSpeed * 0.05 ) * _Time.w ) * appendResult469 ) ), 0, 0.0) ) );
			float3 break277 = WindVector91;
			float3 appendResult495 = (float3(break277.x , 0.0 , break277.y));
			float3 temp_cast_0 = (-1.0).xxx;
			float3 lerpResult249 = lerp( (float3( 0,0,0 ) + (appendResult495 - temp_cast_0) * (float3( 1,0,0 ) - float3( 0,0,0 )) / (float3( 1,0,0 ) - temp_cast_0)) , appendResult495 , _WindSwinging);
			float3 lerpResult74 = lerp( ( ( _MaxWindStrength * WindStrength522 ) * lerpResult249 ) , float3( 0,0,0 ) , ( 1.0 - v.color.r ));
			float3 Wind84 = lerpResult74;
			float3 temp_output_571_0 = (_ObstaclePosition).xyz;
			float3 normalizeResult184 = normalize( ( temp_output_571_0 - ase_worldPos ) );
			float3 worldToObjDir689 = mul( unity_WorldToObject, float4( normalizeResult184, 0 ) ).xyz;
			float temp_output_186_0 = ( _BendingStrength * 0.1 );
			float3 appendResult468 = (float3(temp_output_186_0 , 0.0 , temp_output_186_0));
			float3 Bending201 = ( v.color.r * -( ( ( worldToObjDir689 * appendResult468 ) * ( 1.0 - saturate( ( distance( temp_output_571_0 , ase_worldPos ) / _BendingRadius ) ) ) ) * _BendingInfluence ) );
			float3 temp_output_203_0 = ( Wind84 + Bending201 );
			float2 appendResult483 = (float2(_TerrainUV.z , _TerrainUV.w));
			float2 TerrainUV324 = ( ( ( 1.0 - appendResult483 ) / _TerrainUV.x ) + ( ( _TerrainUV.x / ( _TerrainUV.x * _TerrainUV.x ) ) * (ase_worldPos).xz ) );
			float4 PigmentMapTex320 = tex2Dlod( _PigmentMap, float4( TerrainUV324, 0, 1.0) );
			float temp_output_467_0 = (PigmentMapTex320).a;
			float Heightmap518 = temp_output_467_0;
			float PigmentMapInfluence528 = _PigmentMapInfluence;
			float3 lerpResult508 = lerp( temp_output_203_0 , ( temp_output_203_0 * Heightmap518 ) , PigmentMapInfluence528);
			float3 break437 = lerpResult508;
			float3 ase_vertex3Pos = v.vertex.xyz;
			#ifdef _VS_TOUCHBEND_ON
				float staticSwitch659 = (TouchReactAdjustVertex(float4( ase_vertex3Pos , 0.0 ).xyz)).y;
			#else
				float staticSwitch659 = 0.0;
			#endif
			float TouchBendPos613 = staticSwitch659;
			float temp_output_499_0 = ( 1.0 - v.color.r );
			float lerpResult344 = lerp( ( saturate( ( ( 1.0 - temp_output_467_0 ) - TouchBendPos613 ) ) * _MinHeight ) , 0.0 , temp_output_499_0);
			float lerpResult388 = lerp( _MaxHeight , 0.0 , temp_output_499_0);
			float GrassLength365 = ( ( lerpResult344 * _HeightmapInfluence ) + lerpResult388 );
			float3 appendResult391 = (float3(break437.x , GrassLength365 , break437.z));
			float3 VertexOffset330 = appendResult391;
			v.vertex.xyz += VertexOffset330;
			v.normal = float3(0,1,0);
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_MainTex97 = i.uv_texcoord;
			float4 tex2DNode97 = tex2D( _MainTex, uv_MainTex97 );
			float Alpha98 = tex2DNode97.a;
			float lerpResult313 = lerp( Alpha98 , 1.0 , _WindDebug);
			SurfaceOutputStandard s592 = (SurfaceOutputStandard ) 0;
			float4 lerpResult363 = lerp( _ColorTop , _ColorBottom , ( 1.0 - i.vertexColor.r ));
			float4 BaseColor551 = ( lerpResult363 * tex2DNode97 );
			float4 TopColor549 = _ColorTop;
			float2 appendResult483 = (float2(_TerrainUV.z , _TerrainUV.w));
			float3 ase_worldPos = i.worldPos;
			float2 TerrainUV324 = ( ( ( 1.0 - appendResult483 ) / _TerrainUV.x ) + ( ( _TerrainUV.x / ( _TerrainUV.x * _TerrainUV.x ) ) * (ase_worldPos).xz ) );
			float4 PigmentMapTex320 = tex2D( _PigmentMap, TerrainUV324 );
			float lerpResult416 = lerp( ( 1.0 - i.vertexColor.r ) , 1.0 , _PigmentMapHeight);
			float4 lerpResult376 = lerp( TopColor549 , PigmentMapTex320 , lerpResult416);
			float4 lerpResult290 = lerp( BaseColor551 , lerpResult376 , _PigmentMapInfluence);
			float4 PigmentMapColor526 = lerpResult290;
			float2 appendResult469 = (float2(_WindDirection.x , _WindDirection.z));
			float3 WindVector91 = UnpackNormal( tex2D( _WindVectors, ( ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) + ( ( ( _WindSpeed * 0.05 ) * _Time.w ) * appendResult469 ) ) ) );
			float3 break240 = WindVector91;
			float WindStrength522 = _WindStrength;
			float WindTint523 = saturate( ( ( ( break240.x * break240.y ) * i.vertexColor.r ) * _ColorVariation * WindStrength522 ) );
			float3 Color161 = ( (PigmentMapColor526).rgb + WindTint523 );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult141 = dot( -ase_worldViewDir , ase_worldlightDir );
			float temp_output_467_0 = (PigmentMapTex320).a;
			float Heightmap518 = temp_output_467_0;
			float Subsurface153 = saturate( ( ( ( ( pow( max( dotResult141 , 0.0 ) , _TransmissionSize ) * _TransmissionAmount ) * i.vertexColor.r ) * Heightmap518 ) * ase_lightAtten ) );
			float3 lerpResult106 = lerp( Color161 , ( Color161 * 2.0 ) , Subsurface153);
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			#ifdef _VS_TOUCHBEND_ON
				float staticSwitch659 = (TouchReactAdjustVertex(float4( ase_vertex3Pos , 0.0 ).xyz)).y;
			#else
				float staticSwitch659 = 0.0;
			#endif
			float TouchBendPos613 = staticSwitch659;
			float3 temp_cast_1 = (( TouchBendPos613 * _BendingTint )).xxx;
			float clampResult302 = clamp( ( ( i.vertexColor.r * 1.33 ) * _AmbientOcclusion ) , 0.0 , 1.0 );
			float lerpResult115 = lerp( 1.0 , clampResult302 , _AmbientOcclusion);
			float AmbientOcclusion207 = lerpResult115;
			float3 FinalColor205 = ( ( lerpResult106 - temp_cast_1 ) * AmbientOcclusion207 );
			float3 lerpResult310 = lerp( FinalColor205 , WindVector91 , _WindDebug);
			s592.Albedo = lerpResult310;
			float2 uv_BumpMap172 = i.uv_texcoord;
			float3 Normals174 = UnpackScaleNormal( tex2D( _BumpMap, uv_BumpMap172 ), 1.0 );
			s592.Normal = WorldNormalVector( i , Normals174 );
			s592.Emission = float3( 0,0,0 );
			s592.Metallic = 0.0;
			s592.Smoothness = 0.0;
			s592.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi592 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g592 = UnityGlossyEnvironmentSetup( s592.Smoothness, data.worldViewDir, s592.Normal, float3(0,0,0));
			gi592 = UnityGlobalIllumination( data, s592.Occlusion, s592.Normal, g592 );
			#endif

			float3 surfResult592 = LightingStandard ( s592, viewDir, gi592 ).rgb;
			surfResult592 += s592.Emission;

			#ifdef UNITY_PASS_FORWARDADD//592
			surfResult592 -= s592.Emission;
			#endif//592
			c.rgb = surfResult592;
			c.a = 1;
			clip( lerpResult313 - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma exclude_renderers xbox360 psp2 n3ds wiiu 
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows nolightmap  nodirlightmap dithercrossfade vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				half4 color : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.vertexColor = IN.color;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "FAE.GrassShaderGUI"
}
/*ASEBEGIN
Version=17400
1927;29;1906;1004;2251.282;2536.348;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;494;-4616.219,-36.44699;Inherit;False;1616.341;554.3467;Comment;11;324;491;489;490;484;487;485;486;488;483;493;TerrainUV;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;368;-4626.298,-1189.271;Inherit;False;2299.111;956.0105;Comment;18;91;410;222;298;221;72;297;79;520;469;75;308;384;69;67;77;319;383;Wind vectors;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;319;-4571.499,-844.1255;Float;False;Global;_WindSpeed;_WindSpeed;11;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;493;-4566.219,98.85242;Float;False;Global;_TerrainUV;_TerrainUV;2;0;Create;True;0;0;False;0;0,0,0,0;500,500,251,251;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;77;-4482.71,-1063.982;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;383;-4473.01,-744.6186;Float;False;Constant;_Float7;Float 7;19;0;Create;True;0;0;False;0;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;384;-4261.245,-952.3274;Float;False;Constant;_Float8;Float 8;19;0;Create;True;0;0;False;0;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;485;-4252.418,211.5534;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;75;-4256.11,-1063.99;Inherit;False;FLOAT2;0;2;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TimeNode;69;-4267.893,-645.5446;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-4142.394,-791.1456;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;483;-4236.418,14.55324;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;308;-4253.298,-447.8275;Float;False;Global;_WindDirection;_WindDirection;13;0;Create;True;0;0;False;0;1,0,0,0;-0.9450631,0,-0.326888,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;484;-4261.365,342.0453;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;487;-4013.361,345.0453;Inherit;False;FLOAT2;0;2;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-3930.196,-690.6456;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;297;-3930.545,-974.5492;Float;False;Property;_WindAmplitudeMultiplier;WindAmplitudeMultiplier;12;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;486;-4015.417,165.5533;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;520;-3931.458,-888.7498;Float;False;Global;_WindAmplitude;_WindAmplitude;20;0;Create;True;0;0;False;0;1;3;1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;488;-4052.417,13.55305;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;469;-3949.837,-411.0562;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-4054.306,-1068.048;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;298;-3587.035,-1024.596;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;489;-3747.159,276.6454;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;221;-3689.792,-564.3065;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;490;-3739.417,30.55324;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;371;-2159.553,-389.6831;Inherit;False;1807.377;845.9116;Comment;10;98;551;549;293;363;97;501;292;362;364;Base color;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;222;-3383.589,-914.0057;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;491;-3506.654,157.7434;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;324;-3331.81,149.9584;Float;False;TerrainUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexColorNode;364;-2104.4,156.0724;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;410;-3200.582,-939.1251;Inherit;True;Global;_WindVectors;_WindVectors;9;2;[NoScaleOffset];[Normal];Create;True;0;0;False;0;-1;None;6c795dd1d1d319e479e68164001557e8;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;202;-2142.645,-2259.974;Inherit;False;2627.3;775.1997;Bending;23;181;183;186;188;184;194;189;191;193;195;196;197;200;198;201;231;232;234;386;468;571;679;689;Foliage bending away from obstacle;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;372;-2169.662,764.7435;Inherit;False;2290.708;651.5013;Comment;15;554;553;417;418;416;376;552;291;528;290;526;320;458;325;550;Pigment map;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;160;-2158.058,2130.086;Inherit;False;2711.621;557.9603;Subsurface scattering;17;153;147;148;146;145;141;143;139;140;138;454;455;517;580;590;591;677;Subsurface color simulation;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;138;-2082.26,2183.486;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;91;-2805.208,-938.3988;Float;False;WindVector;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node;231;-2095.184,-2104.723;Float;False;Global;_ObstaclePosition;_ObstaclePosition;18;1;[HideInInspector];Create;True;0;0;False;0;0,0,0,0;-16.275,0.496358,-151.273,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;501;-1906.319,177.3479;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;325;-2093.259,862.8002;Inherit;False;324;TerrainUV;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;373;-2151.307,1610.689;Inherit;False;1792.004;391.326;Comment;10;523;514;274;101;511;239;86;240;93;525;Color through wind;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;362;-2105.6,-131.9273;Float;False;Property;_ColorBottom;Color Bottom;2;1;[HDR];Create;True;0;0;False;0;0.232,0.5,0,1;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;292;-2109.553,-339.6831;Float;False;Property;_ColorTop;ColorTop;1;1;[HDR];Create;True;0;0;False;0;0.3001064,0.6838235,0,1;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;93;-2101.308,1660.688;Inherit;False;91;WindVector;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;458;-1818.367,841.5786;Inherit;True;Global;_PigmentMap;_PigmentMap;19;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;a728bf1dc39cb0e4dad5aba35411306d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;181;-2078.544,-1822.477;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.VertexColorNode;553;-1730.855,1081.685;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;139;-1852.259,2187.486;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;363;-1669.001,-181.4273;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;571;-1848.695,-2077.154;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;140;-2110.257,2346.486;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;97;-1599.225,-27.15059;Inherit;True;Property;_MainTex;MainTex;3;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;369;-2173.667,-1224.785;Inherit;False;2670.73;665.021;Comment;16;277;248;16;83;249;66;70;74;84;385;408;495;500;521;522;687;Wind animations;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;234;-1698.183,-1884.723;Float;False;Global;_BendingStrength;_BendingStrength;15;1;[HideInInspector];Create;True;0;0;False;0;0;11.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;554;-1492.835,1104.332;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;367;-5009.526,-2311.25;Inherit;False;2652.407;770.0325;Comment;20;577;578;365;389;388;360;344;361;71;342;499;392;343;518;467;466;628;655;662;676;Grass length;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;141;-1650.26,2244.486;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;320;-1391.236,971.0171;Float;False;PigmentMapTex;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;183;-1662.445,-2071.378;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;549;-1803.634,-324.2867;Float;False;TopColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;664;-4853.995,-2785.871;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;418;-1553.225,1287.669;Float;False;Property;_PigmentMapHeight;PigmentMapHeight;18;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;386;-1679.209,-1805.235;Float;False;Constant;_Float10;Float 10;19;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;189;-1673.746,-1722.773;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;417;-1387.538,1202.529;Float;False;Constant;_Float17;Float 17;22;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;385;-1102.412,-1079.697;Float;False;Global;_WindStrength;_WindStrength;19;0;Create;True;0;0;False;0;1;0.46;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;293;-1266.153,-190.7834;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;232;-1716.183,-1588.722;Float;False;Global;_BendingRadius;_BendingRadius;14;1;[HideInInspector];Create;True;0;0;False;0;0;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;240;-1853.897,1663.845;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;522;-875.6971,-1086.247;Float;False;WindStrength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;416;-1150.131,1169.972;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;191;-1459.945,-1676.773;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;184;-1461.75,-2076.465;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;550;-1041.996,914.0365;Inherit;False;549;TopColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;466;-4895.62,-2190.839;Inherit;False;320;PigmentMapTex;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TouchReactNode;688;-4616.609,-2759.072;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;677;-1471.816,2277.8;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;239;-1576.098,1662.443;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;551;-916.9384,-188.8136;Float;False;BaseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;521;-2113.14,-973.3709;Inherit;False;91;WindVector;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-1470.544,-1875.676;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;86;-1620.504,1798.089;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;143;-1802.957,2520.286;Float;False;Property;_TransmissionSize;Transmission Size;7;0;Create;True;0;0;False;0;1;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;146;-1372.059,2403.886;Float;False;Property;_TransmissionAmount;Transmission Amount;8;0;Create;True;0;0;False;0;2.696819;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;277;-1874.768,-977.4964;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;291;-844.2086,1132.682;Float;False;Property;_PigmentMapInfluence;PigmentMapInfluence;17;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;660;-4245.799,-2886.684;Float;False;Constant;_Float9;Float 9;22;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;689;-1294.282,-2144.348;Inherit;False;World;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;101;-1383.694,1796.119;Float;False;Property;_ColorVariation;ColorVariation;5;0;Create;True;0;0;False;0;0.05;0;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;511;-1369.941,1663.164;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;467;-4572.831,-2184.625;Inherit;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;468;-1264.144,-1894.772;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;679;-1254.215,-1664.649;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;376;-764.7234,954.6284;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;665;-4226.258,-2789.499;Inherit;False;FLOAT;1;1;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;525;-1320.113,1918.377;Inherit;False;522;WindStrength;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;552;-606.5386,886.5524;Inherit;False;551;BaseColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;145;-1268.258,2248.486;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;-1049.659,2246.286;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;495;-1579.352,-980.8199;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;148;-870.4499,2347.415;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;290;-381.0104,925.5381;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;274;-967.168,1664.503;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;518;-4264.615,-2069.821;Float;False;Heightmap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;193;-1044.945,-1674.773;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;188;-1024.545,-2065.675;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;659;-4002.933,-2818.131;Float;False;Property;_VS_TOUCHBEND;VS_TOUCHBEND;21;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;408;-1439.413,-884.2699;Float;False;Constant;_Float14;Float 14;20;0;Create;True;0;0;False;0;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1152.243,-1165.787;Float;False;Property;_MaxWindStrength;Max Wind Strength;10;0;Create;True;0;0;False;0;0.126967;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;195;-714.9434,-1777.574;Float;False;Property;_BendingInfluence;BendingInfluence;16;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;580;-572.8826,2257.451;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;613;-3725.462,-2817.573;Float;False;TouchBendPos;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;526;-136.4222,922.5243;Float;False;PigmentMapColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;687;-1231.985,-994.9933;Inherit;False;5;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;1,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-1181.874,-797.9662;Float;False;Property;_WindSwinging;WindSwinging;11;0;Create;True;0;0;False;0;0.25;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;455;-606.7513,2416.463;Inherit;False;518;Heightmap;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;514;-797.2388,1667.527;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;194;-786.7443,-1906.174;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;236;1488.743,-1237.9;Inherit;False;3425.277;437.2272;;16;205;519;208;534;106;532;530;295;531;161;296;513;527;524;542;589;Final color;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;159;-2143.86,2840.496;Inherit;False;1813.59;398.8397;AO;11;207;115;114;117;301;118;113;111;302;381;382;Ambient Occlusion;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;83;-521.2678,-946.241;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;655;-4481.993,-2268.909;Inherit;False;613;TouchBendPos;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;454;-320.7513,2265.364;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;111;-2093.859,2890.496;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;523;-601.9745,1656.407;Float;False;WindTint;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;590;-338.0136,2410.466;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;196;-398.1443,-1904.475;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;628;-4210.881,-2171.815;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;527;1519.337,-1175.906;Inherit;False;526;PigmentMapColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-520.265,-1143.746;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;382;-1814.028,3002.569;Float;False;Constant;_Float6;Float 6;19;0;Create;True;0;0;False;0;1.33;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;249;-798.6658,-999.0773;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;591;-71.40287,2266.934;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;589;1776.174,-1167.5;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;524;1663.473,-1020.088;Inherit;False;523;WindTint;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;197;-216.6443,-1902.474;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;198;-252.5788,-2130.417;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;113;-2025.64,3098.476;Float;False;Property;_AmbientOcclusion;AmbientOcclusion;6;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;301;-1574.174,2911.218;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-252.8295,-1087.164;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;500;-274.7222,-946.4897;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;676;-3948.233,-2261.571;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-1371.343,2935.675;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;343;-4345.815,-1858.752;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;513;1975.78,-1093.37;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;118;-1256.54,3116.476;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;381;-1349.626,3147.969;Float;False;Constant;_Float5;Float 5;19;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;200;7.856029,-2045.574;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;517;129.3594,2268.925;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;392;-3990.975,-2051.045;Float;False;Property;_MinHeight;MinHeight;14;0;Create;True;0;0;False;0;-0.5;0;-1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;74;-6.421254,-1078.501;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;662;-3702.495,-2214.783;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;374;1831.836,-489.6089;Inherit;False;2217.195;546.4841;Comment;11;204;85;203;330;508;456;529;426;366;437;391;Vertex function layer blend;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;296;2288.118,-1013.211;Float;False;Constant;_Float1;Float 1;21;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;153;327.6834,2271.676;Float;False;Subsurface;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;84;247.4628,-1074.753;Float;False;Wind;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;342;-3546.63,-2131.383;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;117;-1218.442,3055.776;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;499;-4112.737,-1845.776;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;201;241.656,-2050.775;Float;False;Bending;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;302;-1138.474,2918.418;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;161;2145.16,-1162.154;Float;False;Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;1935.874,-422.8134;Inherit;False;84;Wind;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;344;-3375.759,-2129.614;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;531;3035.332,-1052.988;Inherit;False;613;TouchBendPos;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;532;2972.651,-977.2318;Float;False;Property;_BendingTint;BendingTint;20;0;Create;True;0;0;False;0;-0.05;1;-0.1;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;115;-856.2404,2935.676;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;530;2443.737,-968.2028;Inherit;False;153;Subsurface;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;1947.242,-316.3543;Inherit;False;201;Bending;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-4001.294,-1946.098;Float;False;Property;_MaxHeight;MaxHeight;15;0;Create;True;0;0;False;0;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;361;-3435.164,-1966.095;Float;False;Property;_HeightmapInfluence;HeightmapInfluence;13;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;295;2487.116,-1075.211;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;534;3485.771,-1019.796;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;528;-394.4799,1203.902;Float;False;PigmentMapInfluence;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;203;2298.659,-410.8396;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;207;-636.6566,2929.231;Float;False;AmbientOcclusion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;388;-3237.73,-1833.117;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;360;-3095.494,-2113.002;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;106;2795.013,-1177.939;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;426;2488.814,-319.9986;Inherit;False;219;183;Mask wind/bending by height;1;420;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;456;2089.852,-134.6054;Inherit;False;518;Heightmap;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;208;4239.477,-1030.722;Inherit;False;207;AmbientOcclusion;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;529;2456.923,-94.14083;Inherit;False;528;PigmentMapInfluence;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;237;-2119.915,3380.083;Inherit;False;978.701;287.5597;;3;174;172;419;Normal map;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;542;3706.971,-1153.228;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;420;2540.814,-269.9979;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;389;-2854.729,-2117.818;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;508;2935.445,-394.5296;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;365;-2607.386,-2127.475;Float;False;GrassLength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;419;-2007.296,3508.627;Float;False;Constant;_Float18;Float 18;21;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;519;4481.406,-1148.504;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;235;2843.666,889.9761;Inherit;False;452.9371;811.1447;Final;4;99;175;206;331;Outputs;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;375;2964.505,1790.556;Inherit;False;352;249.0994;Comment;2;312;311;Debug switch;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;205;4658.84,-1159.965;Float;False;FinalColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;172;-1768.914,3434.642;Inherit;True;Property;_BumpMap;BumpMap;4;2;[NoScaleOffset];[Normal];Create;True;0;0;True;0;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;366;3260.787,-234.4643;Inherit;False;365;GrassLength;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;437;3225.992,-389.9932;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;391;3551.427,-385.0264;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;312;3073.705,1840.556;Inherit;False;91;WindVector;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;311;3014.505,1924.656;Float;False;Global;_WindDebug;_WindDebug;20;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;-1263.066,66.81864;Float;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;3072.166,941.4243;Inherit;False;205;FinalColor;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;174;-1384.214,3430.082;Float;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;406;3416.104,1297.26;Float;False;Constant;_Float12;Float 12;20;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;330;3743.457,-384.6883;Float;False;VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;310;3589.109,973.5546;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;3096.573,1235.245;Inherit;False;98;Alpha;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;175;3082.283,1039.971;Inherit;False;174;Normals;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;313;3587.307,1254.955;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomStandardSurface;592;3873.019,1086.018;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;577;-3500.577,-1735.096;Float;False;GrassMinMaxHeight;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;578;-3687.778,-1996.696;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;331;3064.599,1369.667;Inherit;False;330;VertexOffset;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;451;3614.484,1439.282;Float;False;Constant;_UpNormalVector;UpNormalVector;21;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;4279.866,1027.348;Float;False;True;-1;2;FAE.GrassShaderGUI;0;0;CustomLighting;FAE/Grass;False;False;False;False;False;False;True;False;True;False;False;False;True;False;False;False;True;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;10;d3d9;d3d11_9x;d3d11;glcore;gles;gles3;metal;vulkan;xboxone;ps4;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;3;Include;VS_InstancedIndirect.cginc;False;;Custom;Pragma;multi_compile GPU_FRUSTUM_ON __;False;;Custom;Pragma;instancing_options assumeuniformscaling lodfade maxcount:50 procedural:setupScale forwardadd;False;;Custom;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;566;2867.522,531.4199;Inherit;False;339.8231;101.9985;Copyright Staggart Creations;0;FAE Grass Shader;1,1,1,1;0;0
WireConnection;485;0;493;1
WireConnection;485;1;493;1
WireConnection;75;0;77;0
WireConnection;67;0;319;0
WireConnection;67;1;383;0
WireConnection;483;0;493;3
WireConnection;483;1;493;4
WireConnection;487;0;484;0
WireConnection;79;0;67;0
WireConnection;79;1;69;4
WireConnection;486;0;493;1
WireConnection;486;1;485;0
WireConnection;488;0;483;0
WireConnection;469;0;308;1
WireConnection;469;1;308;3
WireConnection;72;0;75;0
WireConnection;72;1;384;0
WireConnection;298;0;72;0
WireConnection;298;1;297;0
WireConnection;298;2;520;0
WireConnection;489;0;486;0
WireConnection;489;1;487;0
WireConnection;221;0;79;0
WireConnection;221;1;469;0
WireConnection;490;0;488;0
WireConnection;490;1;493;1
WireConnection;222;0;298;0
WireConnection;222;1;221;0
WireConnection;491;0;490;0
WireConnection;491;1;489;0
WireConnection;324;0;491;0
WireConnection;410;1;222;0
WireConnection;91;0;410;0
WireConnection;501;0;364;1
WireConnection;458;1;325;0
WireConnection;139;0;138;0
WireConnection;363;0;292;0
WireConnection;363;1;362;0
WireConnection;363;2;501;0
WireConnection;571;0;231;0
WireConnection;554;0;553;1
WireConnection;141;0;139;0
WireConnection;141;1;140;0
WireConnection;320;0;458;0
WireConnection;183;0;571;0
WireConnection;183;1;181;0
WireConnection;549;0;292;0
WireConnection;189;0;571;0
WireConnection;189;1;181;0
WireConnection;293;0;363;0
WireConnection;293;1;97;0
WireConnection;240;0;93;0
WireConnection;522;0;385;0
WireConnection;416;0;554;0
WireConnection;416;1;417;0
WireConnection;416;2;418;0
WireConnection;191;0;189;0
WireConnection;191;1;232;0
WireConnection;184;0;183;0
WireConnection;688;0;664;0
WireConnection;677;0;141;0
WireConnection;239;0;240;0
WireConnection;239;1;240;1
WireConnection;551;0;293;0
WireConnection;186;0;234;0
WireConnection;186;1;386;0
WireConnection;277;0;521;0
WireConnection;689;0;184;0
WireConnection;511;0;239;0
WireConnection;511;1;86;1
WireConnection;467;0;466;0
WireConnection;468;0;186;0
WireConnection;468;2;186;0
WireConnection;679;0;191;0
WireConnection;376;0;550;0
WireConnection;376;1;320;0
WireConnection;376;2;416;0
WireConnection;665;0;688;0
WireConnection;145;0;677;0
WireConnection;145;1;143;0
WireConnection;147;0;145;0
WireConnection;147;1;146;0
WireConnection;495;0;277;0
WireConnection;495;2;277;1
WireConnection;290;0;552;0
WireConnection;290;1;376;0
WireConnection;290;2;291;0
WireConnection;274;0;511;0
WireConnection;274;1;101;0
WireConnection;274;2;525;0
WireConnection;518;0;467;0
WireConnection;193;0;679;0
WireConnection;188;0;689;0
WireConnection;188;1;468;0
WireConnection;659;1;660;0
WireConnection;659;0;665;0
WireConnection;580;0;147;0
WireConnection;580;1;148;1
WireConnection;613;0;659;0
WireConnection;526;0;290;0
WireConnection;687;0;495;0
WireConnection;687;1;408;0
WireConnection;514;0;274;0
WireConnection;194;0;188;0
WireConnection;194;1;193;0
WireConnection;454;0;580;0
WireConnection;454;1;455;0
WireConnection;523;0;514;0
WireConnection;196;0;194;0
WireConnection;196;1;195;0
WireConnection;628;0;467;0
WireConnection;66;0;16;0
WireConnection;66;1;522;0
WireConnection;249;0;687;0
WireConnection;249;1;495;0
WireConnection;249;2;248;0
WireConnection;591;0;454;0
WireConnection;591;1;590;0
WireConnection;589;0;527;0
WireConnection;197;0;196;0
WireConnection;301;0;111;1
WireConnection;301;1;382;0
WireConnection;70;0;66;0
WireConnection;70;1;249;0
WireConnection;500;0;83;1
WireConnection;676;0;628;0
WireConnection;676;1;655;0
WireConnection;114;0;301;0
WireConnection;114;1;113;0
WireConnection;513;0;589;0
WireConnection;513;1;524;0
WireConnection;118;0;113;0
WireConnection;200;0;198;1
WireConnection;200;1;197;0
WireConnection;517;0;591;0
WireConnection;74;0;70;0
WireConnection;74;2;500;0
WireConnection;662;0;676;0
WireConnection;153;0;517;0
WireConnection;84;0;74;0
WireConnection;342;0;662;0
WireConnection;342;1;392;0
WireConnection;117;0;118;0
WireConnection;499;0;343;1
WireConnection;201;0;200;0
WireConnection;302;0;114;0
WireConnection;302;2;381;0
WireConnection;161;0;513;0
WireConnection;344;0;342;0
WireConnection;344;2;499;0
WireConnection;115;0;381;0
WireConnection;115;1;302;0
WireConnection;115;2;117;0
WireConnection;295;0;161;0
WireConnection;295;1;296;0
WireConnection;534;0;531;0
WireConnection;534;1;532;0
WireConnection;528;0;291;0
WireConnection;203;0;85;0
WireConnection;203;1;204;0
WireConnection;207;0;115;0
WireConnection;388;0;71;0
WireConnection;388;2;499;0
WireConnection;360;0;344;0
WireConnection;360;1;361;0
WireConnection;106;0;161;0
WireConnection;106;1;295;0
WireConnection;106;2;530;0
WireConnection;542;0;106;0
WireConnection;542;1;534;0
WireConnection;420;0;203;0
WireConnection;420;1;456;0
WireConnection;389;0;360;0
WireConnection;389;1;388;0
WireConnection;508;0;203;0
WireConnection;508;1;420;0
WireConnection;508;2;529;0
WireConnection;365;0;389;0
WireConnection;519;0;542;0
WireConnection;519;1;208;0
WireConnection;205;0;519;0
WireConnection;172;5;419;0
WireConnection;437;0;508;0
WireConnection;391;0;437;0
WireConnection;391;1;366;0
WireConnection;391;2;437;2
WireConnection;98;0;97;4
WireConnection;174;0;172;0
WireConnection;330;0;391;0
WireConnection;310;0;206;0
WireConnection;310;1;312;0
WireConnection;310;2;311;0
WireConnection;313;0;99;0
WireConnection;313;1;406;0
WireConnection;313;2;311;0
WireConnection;592;0;310;0
WireConnection;592;1;175;0
WireConnection;577;0;578;0
WireConnection;578;0;392;0
WireConnection;578;1;71;0
WireConnection;0;10;313;0
WireConnection;0;13;592;0
WireConnection;0;11;331;0
WireConnection;0;12;451;0
ASEEND*/
//CHKSM=D57499D15B961733A3E026455CEC3C65D1D15C49