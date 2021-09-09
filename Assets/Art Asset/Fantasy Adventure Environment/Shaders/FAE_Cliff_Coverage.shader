// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FAE/Cliff coverage"
{
	Properties
	{
		_ObjectColor("Object Color", Color) = (1,1,1,0)
		_Objectalbedo("Object albedo", 2D) = "white" {}
		[Normal]_Objectnormals("Object normals", 2D) = "bump" {}
		_GlobalColor("Global Color", Color) = (1,1,1,0)
		[NoScaleOffset]_Globalalbedo("Global albedo", 2D) = "gray" {}
		_Globaltiling("Global tiling", Float) = 1.56
		[NoScaleOffset][Normal]_Detailnormal("Detail normal", 2D) = "bump" {}
		_Detailstrength("Detail strength", Range( 0 , 1)) = 1
		[NoScaleOffset]_CoverageAlbedo("Coverage Albedo", 2D) = "white" {}
		[NoScaleOffset][Normal]_CoverageNormals("Coverage Normals", 2D) = "bump" {}
		_Roughness("Roughness", Range( 0 , 1)) = 0.5
		_CoverageAmount("CoverageAmount", Range( 0 , 2)) = 0.13
		_CoverageTiling("CoverageTiling", Range( 0 , 5)) = 0
		_CoverageMap("CoverageMap", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.5
		#pragma multi_compile_instancing
		#include "VS_InstancedIndirect.cginc"
		#pragma multi_compile GPU_FRUSTUM_ON __
		#pragma instancing_options assumeuniformscaling lodfade maxcount:50 procedural:setupScale
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
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			float4 vertexColor : COLOR;
		};

		uniform sampler2D _Objectnormals;
		uniform float4 _Objectnormals_ST;
		uniform sampler2D _Detailnormal;
		uniform float _Detailstrength;
		uniform sampler2D _CoverageNormals;
		uniform float _CoverageTiling;
		uniform sampler2D _CoverageMap;
		uniform float4 _TerrainUV;
		uniform float _CoverageAmount;
		uniform float4 _GlobalColor;
		uniform sampler2D _Globalalbedo;
		uniform float _Globaltiling;
		uniform float4 _ObjectColor;
		uniform sampler2D _Objectalbedo;
		uniform float4 _Objectalbedo_ST;
		uniform sampler2D _CoverageAlbedo;
		uniform float _Roughness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Objectnormals = i.uv_texcoord * _Objectnormals_ST.xy + _Objectnormals_ST.zw;
			float3 tex2DNode2 = UnpackScaleNormal( tex2D( _Objectnormals, uv_Objectnormals ), 1.0 );
			float2 uv_Detailnormal48 = i.uv_texcoord;
			float3 lerpResult57 = lerp( tex2DNode2 , BlendNormals( tex2DNode2 , UnpackScaleNormal( tex2D( _Detailnormal, uv_Detailnormal48 ), 1.0 ) ) , _Detailstrength);
			float2 temp_output_113_0 = ( i.uv_texcoord * _CoverageTiling );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float2 appendResult117 = (float2(_TerrainUV.z , _TerrainUV.w));
			float3 ase_worldPos = i.worldPos;
			float2 TerrainUV125 = ( ( ( 1.0 - appendResult117 ) / _TerrainUV.x ) + ( ( _TerrainUV.x / ( _TerrainUV.x * _TerrainUV.x ) ) * (ase_worldPos).xz ) );
			float temp_output_127_0 = ( tex2D( _CoverageMap, TerrainUV125 ).r * _CoverageAmount );
			float3 lerpResult105 = lerp( lerpResult57 , UnpackNormal( tex2D( _CoverageNormals, temp_output_113_0 ) ) , saturate( ( ase_worldNormal.y * temp_output_127_0 ) ));
			o.Normal = lerpResult105;
			float2 appendResult96 = (float2(ase_worldPos.y , ase_worldPos.z));
			float cos68 = cos( 1.55 );
			float sin68 = sin( 1.55 );
			float2 rotator68 = mul( appendResult96 - float2( 0,0 ) , float2x2( cos68 , -sin68 , sin68 , cos68 )) + float2( 0,0 );
			float3 temp_output_7_0 = abs( mul( unity_WorldToObject, float4( ase_worldNormal , 0.0 ) ).xyz );
			float dotResult9 = dot( temp_output_7_0 , float3(1,1,1) );
			float3 BlendComponents11 = ( temp_output_7_0 / dotResult9 );
			float2 appendResult94 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 appendResult95 = (float2(ase_worldPos.x , ase_worldPos.y));
			float2 uv_Objectalbedo = i.uv_texcoord * _Objectalbedo_ST.xy + _Objectalbedo_ST.zw;
			float4 tex2DNode1 = tex2D( _Objectalbedo, uv_Objectalbedo );
			float4 blendOpSrc42 = ( _GlobalColor * ( ( ( tex2D( _Globalalbedo, ( _Globaltiling * rotator68 ) ) * BlendComponents11.x ) + ( tex2D( _Globalalbedo, ( _Globaltiling * appendResult94 ) ) * BlendComponents11.y ) ) + ( tex2D( _Globalalbedo, ( _Globaltiling * appendResult95 ) ) * BlendComponents11.z ) ) );
			float4 blendOpDest42 = ( _ObjectColor * tex2DNode1 );
			float temp_output_110_0 = saturate( ( (WorldNormalVector( i , lerpResult105 )).y * temp_output_127_0 ) );
			float4 lerpResult97 = lerp( ( saturate( (( blendOpDest42 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest42 ) * ( 1.0 - blendOpSrc42 ) ) : ( 2.0 * blendOpDest42 * blendOpSrc42 ) ) )) , tex2D( _CoverageAlbedo, temp_output_113_0 ) , temp_output_110_0);
			o.Albedo = lerpResult97.rgb;
			float lerpResult74 = lerp( 0.0 , ( _Roughness * tex2DNode1.a ) , i.vertexColor.g);
			o.Smoothness = lerpResult74;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma exclude_renderers xbox360 psp2 n3ds wiiu 
		#pragma surface surf Standard keepalpha fullforwardshadows dithercrossfade 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.5
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
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
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Standard"
}
/*ASEBEGIN
Version=17400
1927;31;1906;981;1553.693;-303.8397;1.2038;True;False
Node;AmplifyShaderEditor.WorldToObjectMatrix;4;-4214.666,-415.3753;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.WorldNormalVector;5;-4214.666,-319.3753;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;114;-2412.519,1341.045;Inherit;False;1606.407;683.4922;Comment;11;125;124;123;122;121;120;119;118;117;116;115;TerrainUV;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-3942.662,-351.3753;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node;115;-2362.519,1476.344;Float;False;Global;_TerrainUV;_TerrainUV;2;0;Create;True;0;0;False;0;0,0,0,0;500,500,251,251;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.AbsOpNode;7;-3782.662,-351.3753;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;8;-3815.781,-170.9255;Float;False;Constant;_Vector1;Vector 1;-1;0;Create;True;0;0;False;0;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;116;-2089.665,1845.536;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;9;-3608.761,-284.9775;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;-2047.719,1705.045;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;117;-2032.719,1392.045;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;119;-1850.719,1626.045;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;121;-1848.719,1391.045;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;10;-3465.661,-383.3753;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;120;-1790.662,1842.536;Inherit;False;FLOAT2;0;2;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;122;-1489.719,1417.045;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-1526.461,1662.137;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-3286.66,-351.3753;Float;True;BlendComponents;1;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;12;-2897.719,-713.4802;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;13;-2924.659,-492.3754;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;124;-1247.955,1547.235;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;14;-2924.659,-204.3754;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;96;-2428.904,-784.8954;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;17;-2630.659,-542.3754;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;125;-1049.11,1562.45;Float;False;TerrainUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-2453.705,-680.8949;Float;False;Constant;_Float0;Float 0;9;0;Create;True;0;0;False;0;1.55;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;68;-2234.705,-757.8949;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;20;-2598.659,-574.3754;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;43;-2647.998,-70.79846;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-2245.521,-1016.58;Float;False;Property;_Globaltiling;Global tiling;5;0;Create;True;0;0;False;0;1.56;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;94;-2250.805,-530.095;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-1185.708,886.2039;Float;False;Constant;_Float2;Float 2;10;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-592.8126,1661.028;Float;False;Property;_CoverageAmount;CoverageAmount;11;0;Create;True;0;0;False;0;0.13;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;126;-603.3663,1438.713;Inherit;True;Property;_CoverageMap;CoverageMap;13;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;48;-968.3984,950.5027;Inherit;True;Property;_Detailnormal;Detail normal;6;2;[NoScaleOffset];[Normal];Create;True;0;0;False;0;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;99;-155.0948,1121.618;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1932.421,-505.3806;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;44;-2595.498,-28.29846;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1908.322,-782.7806;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;25;-1479.861,-567.7754;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-967.5005,739.1008;Inherit;True;Property;_Objectnormals;Object normals;2;1;[Normal];Create;True;0;0;False;0;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;111;-404.2006,280.4061;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;95;-2244.304,-240.1948;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;127;-184.8133,1497.627;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-469.2005,453.3063;Float;False;Property;_CoverageTiling;CoverageTiling;12;0;Create;True;0;0;False;0;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;29;-1447.861,-599.7754;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-501.5017,984.6024;Float;False;Property;_Detailstrength;Detail strength;7;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;221.0875,1142.559;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;49;-543.7987,863.202;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;45;-1497.998,-33.29846;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-1916.722,-231.7806;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;41;-1737.643,-501.2136;Inherit;True;Property;_TextureSample5;Texture Sample 5;4;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Instance;40;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;-127.3006,383.1063;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;40;-1732.56,-756.6757;Inherit;True;Property;_Globalalbedo;Global albedo;4;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;22;-2924.659,-348.3754;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SaturateNode;102;533.9547,1026.74;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;30;-1734.858,-223.2767;Inherit;True;Property;_TextureSample1;Texture Sample 1;4;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Instance;40;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;57;-157.002,762.103;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;104;140.6917,489.8538;Inherit;True;Property;_CoverageNormals;Coverage Normals;9;2;[NoScaleOffset];[Normal];Create;True;0;0;False;0;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-1367.861,-503.7754;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-1367.861,-775.7754;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;46;-1452.998,-68.29846;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;105;737.2924,597.7535;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-1367.861,-263.7754;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-1127.86,-663.7754;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;58;-682.3034,-232.3961;Float;False;Property;_ObjectColor;Object Color;0;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;106;1035.687,630.4573;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;38;-871.8605,-407.7754;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;61;-783.5037,-641.4963;Float;False;Property;_GlobalColor;Global Color;3;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-1020.2,-111.2999;Inherit;True;Property;_Objectalbedo;Object albedo;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-279.8035,-445.5962;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;63;2.497352,58.20351;Float;False;Property;_Roughness;Roughness;10;0;Create;True;0;0;False;0;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-18.20354,-125.6962;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;1249.392,708.4533;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;110;1404.487,714.5562;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;351.8972,98.90351;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;42;231.9997,-358.6998;Inherit;False;Overlay;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;72;-990.6075,176.604;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;75;753.7921,87.00389;Float;False;Constant;_Float1;Float 1;9;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;109;628.4915,332.7543;Inherit;True;Property;_CoverageAlbedo;Coverage Albedo;8;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;128;1633.3,726.5054;Float;False;CoverageMapResult;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;74;964.9921,119.0039;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;97;1501.792,-11.84607;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1969.099,-112.4;Float;False;True;-1;3;;0;0;Standard;FAE/Cliff coverage;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;10;d3d9;d3d11_9x;d3d11;glcore;gles;gles3;metal;vulkan;xboxone;ps4;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;Standard;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;3;Include;VS_InstancedIndirect.cginc;False;;Custom;Pragma;multi_compile GPU_FRUSTUM_ON __;False;;Custom;Pragma;instancing_options assumeuniformscaling lodfade maxcount:50 procedural:setupScale;False;;Custom;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;4;0
WireConnection;6;1;5;0
WireConnection;7;0;6;0
WireConnection;9;0;7;0
WireConnection;9;1;8;0
WireConnection;118;0;115;1
WireConnection;118;1;115;1
WireConnection;117;0;115;3
WireConnection;117;1;115;4
WireConnection;119;0;115;1
WireConnection;119;1;118;0
WireConnection;121;0;117;0
WireConnection;10;0;7;0
WireConnection;10;1;9;0
WireConnection;120;0;116;0
WireConnection;122;0;121;0
WireConnection;122;1;115;1
WireConnection;123;0;119;0
WireConnection;123;1;120;0
WireConnection;11;0;10;0
WireConnection;13;0;11;0
WireConnection;124;0;122;0
WireConnection;124;1;123;0
WireConnection;14;0;11;0
WireConnection;96;0;12;2
WireConnection;96;1;12;3
WireConnection;17;0;13;0
WireConnection;125;0;124;0
WireConnection;68;0;96;0
WireConnection;68;2;69;0
WireConnection;20;0;17;0
WireConnection;43;0;14;2
WireConnection;94;0;12;1
WireConnection;94;1;12;3
WireConnection;126;1;125;0
WireConnection;48;5;93;0
WireConnection;28;0;16;0
WireConnection;28;1;94;0
WireConnection;44;0;43;0
WireConnection;27;0;16;0
WireConnection;27;1;68;0
WireConnection;25;0;20;0
WireConnection;2;5;93;0
WireConnection;95;0;12;1
WireConnection;95;1;12;2
WireConnection;127;0;126;1
WireConnection;127;1;100;0
WireConnection;29;0;25;0
WireConnection;101;0;99;2
WireConnection;101;1;127;0
WireConnection;49;0;2;0
WireConnection;49;1;48;0
WireConnection;45;0;44;0
WireConnection;24;0;16;0
WireConnection;24;1;95;0
WireConnection;41;1;28;0
WireConnection;113;0;111;0
WireConnection;113;1;112;0
WireConnection;40;1;27;0
WireConnection;22;0;11;0
WireConnection;102;0;101;0
WireConnection;30;1;24;0
WireConnection;57;0;2;0
WireConnection;57;1;49;0
WireConnection;57;2;56;0
WireConnection;104;1;113;0
WireConnection;35;0;41;0
WireConnection;35;1;22;1
WireConnection;33;0;40;0
WireConnection;33;1;29;0
WireConnection;46;0;45;0
WireConnection;105;0;57;0
WireConnection;105;1;104;0
WireConnection;105;2;102;0
WireConnection;34;0;30;0
WireConnection;34;1;46;0
WireConnection;36;0;33;0
WireConnection;36;1;35;0
WireConnection;106;0;105;0
WireConnection;38;0;36;0
WireConnection;38;1;34;0
WireConnection;59;0;61;0
WireConnection;59;1;38;0
WireConnection;62;0;58;0
WireConnection;62;1;1;0
WireConnection;107;0;106;2
WireConnection;107;1;127;0
WireConnection;110;0;107;0
WireConnection;64;0;63;0
WireConnection;64;1;1;4
WireConnection;42;0;59;0
WireConnection;42;1;62;0
WireConnection;109;1;113;0
WireConnection;128;0;110;0
WireConnection;74;0;75;0
WireConnection;74;1;64;0
WireConnection;74;2;72;2
WireConnection;97;0;42;0
WireConnection;97;1;109;0
WireConnection;97;2;110;0
WireConnection;0;0;97;0
WireConnection;0;1;105;0
WireConnection;0;4;74;0
ASEEND*/
//CHKSM=BE0ACBB4B2C9E0C36CABF837807B613D8F526801