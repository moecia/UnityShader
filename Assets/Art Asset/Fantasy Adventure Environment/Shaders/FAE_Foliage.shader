// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FAE/Foliage"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
		[NoScaleOffset][Normal]_BumpMap("BumpMap", 2D) = "bump" {}
		_WindTint("WindTint", Range( -0.5 , 0.5)) = 0.1
		_AmbientOcclusion("AmbientOcclusion", Range( 0 , 1)) = 0
		_TransmissionSize("Transmission Size", Range( 0 , 20)) = 1
		_TransmissionAmount("Transmission Amount", Range( 0 , 10)) = 2.696819
		_WindSwinging("WindSwinging", Range( 0 , 1)) = 0
		_BendingInfluence("BendingInfluence", Range( 0 , 1)) = 0
		_FlatLighting("FlatLighting", Range( 0 , 1)) = 0
		_WindAmplitudeMultiplier("WindAmplitudeMultiplier", Float) = 10
		_MaxWindStrength("Max Wind Strength", Range( 0 , 1)) = 0.126967
		_GlobalWindMotion("GlobalWindMotion", Range( 0 , 1)) = 1
		_LeafFlutter("LeafFlutter", Range( 0 , 1)) = 0.495
		[HDR]_Color("Color", Color) = (1,1,1,1)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#include "VS_InstancedIndirect.cginc"
		#pragma instancing_options assumeuniformscaling lodfade maxcount:50 procedural:setupScale  forwardadd
		#pragma multi_compile GPU_FRUSTUM_ON __
		#pragma exclude_renderers xbox360 psp2 n3ds wiiu 
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows nolightmap  nodirlightmap dithercrossfade vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		uniform float _GlobalWindMotion;
		uniform float _WindSpeed;
		uniform float4 _WindDirection;
		uniform float _WindSwinging;
		uniform float _LeafFlutter;
		uniform sampler2D _WindVectors;
		uniform float _WindAmplitudeMultiplier;
		uniform float _WindAmplitude;
		uniform float _MaxWindStrength;
		uniform float _WindStrength;
		uniform float4 _ObstaclePosition;
		uniform float _BendingStrength;
		uniform float _BendingRadius;
		uniform float _BendingInfluence;
		uniform float _FlatLighting;
		uniform sampler2D _BumpMap;
		uniform float4 _Color;
		uniform sampler2D _MainTex;
		uniform float _WindTint;
		uniform float _TransmissionSize;
		uniform float _TransmissionAmount;
		uniform float _WindDebug;
		uniform float _AmbientOcclusion;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float temp_output_514_0 = ( _WindSpeed * _Time.w );
			float3 ase_objectScale = float3( length( unity_ObjectToWorld[ 0 ].xyz ), length( unity_ObjectToWorld[ 1 ].xyz ), length( unity_ObjectToWorld[ 2 ].xyz ) );
			float2 appendResult518 = (float2(_WindDirection.x , _WindDirection.z));
			float3 temp_output_524_0 = sin( ( ( temp_output_514_0 * ase_objectScale ) * float3( appendResult518 ,  0.0 ) ) );
			float3 temp_cast_1 = (-1.0).xxx;
			float3 lerpResult544 = lerp( (float3( 0,0,0 ) + (temp_output_524_0 - temp_cast_1) * (float3( 1,0,0 ) - float3( 0,0,0 )) / (float3( 1,0,0 ) - temp_cast_1)) , temp_output_524_0 , _WindSwinging);
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 WindVector577 = UnpackNormal( tex2Dlod( _WindVectors, float4( ( ( ( temp_output_514_0 * 0.05 ) * appendResult518 ) + ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) ), 0, 0.0) ) );
			float2 break584 = ( ( _GlobalWindMotion * (lerpResult544).x ) + ( _LeafFlutter * (WindVector577).xy ) );
			float3 appendResult583 = (float3(break584.x , 0.0 , break584.y));
			float3 GlobalWind84 = ( appendResult583 * _MaxWindStrength * v.color.r * _WindStrength );
			float4 normalizeResult184 = normalize( ( _ObstaclePosition - float4( ase_worldPos , 0.0 ) ) );
			float3 worldToObjDir589 = mul( unity_WorldToObject, float4( normalizeResult184.xyz, 0 ) ).xyz;
			float temp_output_186_0 = ( _BendingStrength * 0.1 );
			float3 appendResult468 = (float3(temp_output_186_0 , 0.0 , temp_output_186_0));
			float clampResult192 = clamp( ( distance( _ObstaclePosition , float4( ase_worldPos , 0.0 ) ) / _BendingRadius ) , 0.0 , 1.0 );
			float3 Bending201 = ( v.color.r * -( ( ( worldToObjDir589 * appendResult468 ) * ( 1.0 - clampResult192 ) ) * _BendingInfluence ) );
			float3 VertexOffset330 = ( GlobalWind84 + Bending201 );
			v.vertex.xyz += VertexOffset330;
			float3 ase_vertexNormal = v.normal.xyz;
			float3 lerpResult552 = lerp( ase_vertexNormal , float3(0,1,0) , _FlatLighting);
			v.normal = lerpResult552;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_BumpMap172 = i.uv_texcoord;
			float3 Normals174 = UnpackScaleNormal( tex2D( _BumpMap, uv_BumpMap172 ), 1.0 );
			o.Normal = Normals174;
			float2 uv_MainTex97 = i.uv_texcoord;
			float4 tex2DNode97 = tex2D( _MainTex, uv_MainTex97 );
			float4 temp_cast_0 = (2.0).xxxx;
			float temp_output_514_0 = ( _WindSpeed * _Time.w );
			float3 ase_objectScale = float3( length( unity_ObjectToWorld[ 0 ].xyz ), length( unity_ObjectToWorld[ 1 ].xyz ), length( unity_ObjectToWorld[ 2 ].xyz ) );
			float2 appendResult518 = (float2(_WindDirection.x , _WindDirection.z));
			float3 temp_output_524_0 = sin( ( ( temp_output_514_0 * ase_objectScale ) * float3( appendResult518 ,  0.0 ) ) );
			float3 temp_cast_2 = (-1.0).xxx;
			float3 lerpResult544 = lerp( (float3( 0,0,0 ) + (temp_output_524_0 - temp_cast_2) * (float3( 1,0,0 ) - float3( 0,0,0 )) / (float3( 1,0,0 ) - temp_cast_2)) , temp_output_524_0 , _WindSwinging);
			float3 ase_worldPos = i.worldPos;
			float3 WindVector577 = UnpackNormal( tex2D( _WindVectors, ( ( ( temp_output_514_0 * 0.05 ) * appendResult518 ) + ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) ) ) );
			float2 break584 = ( ( _GlobalWindMotion * (lerpResult544).x ) + ( _LeafFlutter * (WindVector577).xy ) );
			float3 appendResult583 = (float3(break584.x , 0.0 , break584.y));
			float3 GlobalWind84 = ( appendResult583 * _MaxWindStrength * i.vertexColor.r * _WindStrength );
			float lerpResult271 = lerp( (GlobalWind84).x , 0.0 , ( 1.0 - i.vertexColor.r ));
			float WindTint548 = ( ( lerpResult271 * _WindTint ) * 2.0 );
			float4 lerpResult273 = lerp( ( _Color * tex2DNode97 ) , temp_cast_0 , WindTint548);
			float4 Color161 = lerpResult273;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult141 = dot( -ase_worldViewDir , ase_worldlightDir );
			float lerpResult151 = lerp( ( pow( max( dotResult141 , 0.0 ) , _TransmissionSize ) * _TransmissionAmount ) , 0.0 , ( ( 1.0 - i.vertexColor.r ) * 1.33 ));
			float clampResult152 = clamp( lerpResult151 , 0.0 , 1.0 );
			float Subsurface153 = clampResult152;
			float4 lerpResult106 = lerp( Color161 , ( Color161 * 2.0 ) , Subsurface153);
			float4 FinalColor205 = lerpResult106;
			float4 lerpResult310 = lerp( FinalColor205 , float4( WindVector577 , 0.0 ) , _WindDebug);
			o.Albedo = lerpResult310.rgb;
			float lerpResult557 = lerp( 1.0 , i.vertexColor.r , _AmbientOcclusion);
			float AmbientOcclusion207 = lerpResult557;
			o.Occlusion = AmbientOcclusion207;
			o.Alpha = 1;
			float Alpha98 = tex2DNode97.a;
			float lerpResult313 = lerp( Alpha98 , 1.0 , _WindDebug);
			clip( lerpResult313 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Nature/SpeedTree"
	CustomEditor "FAE.FoliageShaderGUI"
}
/*ASEBEGIN
Version=17400
7;1;1906;1010;2921.86;-2824.872;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;507;-4066.512,-3186.75;Inherit;False;4223.285;1155.072;;38;534;84;583;584;581;582;577;385;16;527;580;544;526;576;248;561;543;524;520;560;568;571;565;518;517;570;562;516;514;511;567;564;563;319;513;573;586;588;Global wind motion;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;319;-3937.326,-3132.458;Float;False;Global;_WindSpeed;_WindSpeed;11;0;Create;True;0;0;False;0;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;513;-3715.418,-3017.448;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;573;-3697.419,-2433.168;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;567;-3472.122,-2317.767;Float;False;Constant;_Float8;Float 8;19;0;Create;True;0;0;False;0;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;514;-3415.012,-3081.15;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;563;-3451.174,-2440.566;Inherit;False;FLOAT2;0;2;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;564;-3140.257,-2684.31;Float;False;Constant;_Float7;Float 7;19;0;Create;True;0;0;False;0;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;516;-3691.352,-2718.526;Float;False;Global;_WindDirection;_WindDirection;9;0;Create;True;0;0;False;0;1,0,0,0;-0.9450631,0,-0.326888,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectScaleNode;511;-3447.5,-2873.395;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;562;-2962.2,-2732.018;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;571;-3638.923,-2138.373;Float;False;Global;_WindAmplitude;_WindAmplitude;20;0;Create;True;0;0;False;0;1;3;1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;570;-3223.371,-2438.942;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;517;-3202.916,-2977.488;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;518;-3418.178,-2697.826;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;565;-3636.875,-2224.849;Float;False;Property;_WindAmplitudeMultiplier;WindAmplitudeMultiplier;11;0;Create;True;0;0;False;0;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;560;-2832.244,-2499.469;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;520;-2957.145,-2879.598;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;568;-2996.431,-2370.207;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SinOpNode;524;-2735.857,-2890.221;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;561;-2649.573,-2414.612;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;543;-2702.433,-3019.491;Float;False;Constant;_Float2;Float 2;13;0;Create;True;0;0;False;0;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;576;-2458.675,-2449.087;Inherit;True;Global;_WindVectors;_WindVectors;8;2;[NoScaleOffset];[Normal];Create;True;0;0;False;0;-1;None;6c795dd1d1d319e479e68164001557e8;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;248;-2550.377,-2800.018;Float;False;Property;_WindSwinging;WindSwinging;7;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;526;-2470.363,-3036.312;Inherit;False;5;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;1,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;544;-2207.111,-2912.084;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;577;-2119.198,-2444.151;Float;False;WindVector;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;588;-2122.579,-2651.492;Float;False;Property;_LeafFlutter;LeafFlutter;14;0;Create;True;0;0;False;0;0.495;0.495;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;580;-2005.865,-2919.054;Inherit;False;FLOAT;0;1;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;586;-2054.995,-3070.913;Float;False;Property;_GlobalWindMotion;GlobalWindMotion;13;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;582;-1856.577,-2450.862;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;587;-1708.298,-2667.625;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;585;-1709.203,-2955.683;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;581;-1546.871,-2894.326;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;584;-1395.815,-2901.544;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;583;-1107.815,-2871.544;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1069.807,-2732.127;Float;False;Property;_MaxWindStrength;Max Wind Strength;12;0;Create;True;0;0;False;0;0.126967;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;527;-962.0208,-2647.322;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;385;-1000.576,-2451.538;Float;False;Global;_WindStrength;_WindStrength;19;0;Create;True;0;0;False;0;2;0.46;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;202;-3197.001,-177.1511;Inherit;False;2627.3;775.1997;Bending;24;181;183;186;188;184;194;189;191;192;193;195;196;197;200;198;201;231;232;234;386;387;468;506;589;Foliage bending away from obstacle;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;534;-558.2651,-2880.917;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;181;-3132.901,260.3462;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector4Node;231;-3149.54,-21.90026;Float;False;Global;_ObstaclePosition;_ObstaclePosition;18;1;[HideInInspector];Create;True;0;0;False;0;0,0,0,0;-208.8438,1.208046,-198.0533,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;84;-373.5839,-2893.495;Float;False;GlobalWind;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;160;-3251.288,1459.145;Inherit;False;2711.621;557.9603;Subsurface scattering;17;153;152;380;151;149;147;148;146;145;150;141;143;139;140;138;503;550;Subsurface color simulation;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;373;-2588.356,831.4046;Inherit;False;2020.167;388.1052;Comment;10;307;274;407;271;101;502;86;93;548;558;Color through wind;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;234;-2752.54,198.0997;Float;False;Global;_BendingStrength;_BendingStrength;15;1;[HideInInspector];Create;True;0;0;False;0;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;86;-2249.954,1022.705;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;138;-3105.49,1513.545;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;386;-2733.566,277.5881;Float;False;Constant;_Float10;Float 10;19;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-2429.357,883.4036;Inherit;False;84;GlobalWind;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;232;-2770.54,494.1013;Float;False;Global;_BendingRadius;_BendingRadius;14;1;[HideInInspector];Create;True;0;0;False;0;0;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;189;-2728.102,360.0503;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;183;-2821.801,3.44478;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;387;-2491.766,512.8883;Float;False;Constant;_Float11;Float 11;19;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;191;-2514.301,406.0505;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-2524.901,207.147;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;502;-1979.193,1046.495;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;139;-2909.05,1510.851;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;140;-3203.488,1675.545;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;558;-2021.708,896.4333;Inherit;False;FLOAT;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;184;-2671.904,2.64699;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ClampOpNode;192;-2343.301,406.0505;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-1761.713,1083.204;Float;False;Property;_WindTint;WindTint;3;0;Create;True;0;0;False;0;0.1;0;-0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;141;-2743.491,1573.545;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;468;-2318.499,188.0509;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;589;-2416.308,-19.84277;Inherit;False;World;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;271;-1787.723,909.8607;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;148;-2149.892,1710.745;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;550;-2540.499,1578.627;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;274;-1430.625,905.5606;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;188;-2078.9,17.14789;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-2757.122,1735.206;Float;False;Property;_TransmissionSize;Transmission Size;5;0;Create;True;0;0;False;0;1;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;193;-2099.301,408.0505;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;407;-1410.77,1037.111;Float;False;Constant;_Float13;Float 13;20;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;145;-2350.844,1569.851;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;195;-1833.604,412.4233;Float;False;Property;_BendingInfluence;BendingInfluence;9;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;236;-2419.377,3192.074;Inherit;False;1901.952;536.7815;SSS Blending with color;13;205;106;547;296;295;161;549;98;273;497;97;592;591;Final color;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;307;-1206.763,921.5057;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;150;-2075.692,1892.346;Float;False;Constant;_TransmissionHeight;TransmissionHeight;12;0;Create;True;0;0;False;0;1.33;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;503;-1959.698,1730.817;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;194;-1841.1,176.6488;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;146;-2465.291,1732.945;Float;False;Property;_TransmissionAmount;Transmission Amount;6;0;Create;True;0;0;False;0;2.696819;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;548;-987.9922,910.64;Float;False;WindTint;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;591;-2303.638,3194.224;Inherit;False;Property;_Color;Color;15;1;[HDR];Create;True;0;0;False;0;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;97;-2382.277,3365.45;Inherit;True;Property;_MainTex;MainTex;1;1;[NoScaleOffset];Create;True;0;0;True;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;-1789.491,1741.945;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;196;-1526.547,180.2964;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;-2142.892,1575.345;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;549;-2287.758,3646.538;Inherit;False;548;WindTint;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;497;-2288.694,3561.267;Float;False;Constant;_Float0;Float 0;20;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;592;-1938.638,3263.224;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NegateNode;197;-1352.842,182.2973;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;198;-1395.148,-4.388111;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;380;-1241.679,1774.337;Float;False;Constant;_Float4;Float 4;19;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;151;-1589.291,1574.945;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;200;-1163.417,146.3718;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;273;-1765.839,3382.538;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;152;-1035.492,1567.445;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;153;-858.9927,1570.345;Float;False;Subsurface;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;506;-1007.616,142.1316;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;161;-1574.614,3327.875;Float;False;Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;296;-1579.436,3466.872;Float;False;Constant;_Float1;Float 1;21;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;547;-1256.909,3553.238;Inherit;False;153;Subsurface;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;237;-1533.39,2770.484;Inherit;False;978.701;287.5597;;3;174;172;419;Normal map;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;201;-818.7435,139.0677;Float;False;Bending;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;159;-2367.693,2262.087;Inherit;False;1813.59;398.8397;AO;4;207;113;111;557;Ambient Occlusion by Red vertex color channel;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;295;-1333.547,3428.735;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;374;254.2972,-61.15241;Inherit;False;1307.47;528.0521;Comment;4;330;203;85;204;Vertex function layer blend;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;419;-1420.771,2899.029;Float;False;Constant;_Float18;Float 18;21;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;485.497,143.4051;Inherit;False;201;Bending;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;113;-2171.473,2528.067;Float;False;Property;_AmbientOcclusion;AmbientOcclusion;4;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;111;-2317.692,2312.087;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;106;-965.9405,3349.727;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;339.7766,-11.15247;Inherit;False;84;GlobalWind;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;557;-1832.394,2336.545;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;235;2843.666,889.9761;Inherit;False;452.9371;811.1447;Final;5;99;208;175;206;331;Outputs;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;205;-771.8661,3343.871;Float;False;FinalColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;-1983.471,3366.42;Float;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;172;-1182.389,2825.043;Inherit;True;Property;_BumpMap;BumpMap;2;2;[NoScaleOffset];[Normal];Create;True;0;0;True;0;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;203;780.7659,11.02355;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;375;2964.505,1790.556;Inherit;False;352;249.0994;Comment;2;312;311;Debug switch;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;551;2933.198,2422.128;Float;False;Property;_FlatLighting;FlatLighting;10;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;3072.166,941.4243;Inherit;False;205;FinalColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;207;-1642.589,2346.922;Float;False;AmbientOcclusion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;311;3014.505,1924.656;Float;False;Global;_WindDebug;_WindDebug;20;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;553;2922.633,2246;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;330;1331.807,33.5835;Float;False;VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;451;2937.299,2066.65;Float;False;Constant;_Vector0;Vector 0;21;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;174;-797.689,2820.483;Float;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;3096.573,1235.245;Inherit;False;98;Alpha;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;312;3073.705,1840.556;Inherit;False;577;WindVector;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;406;3416.104,1297.26;Float;False;Constant;_Float12;Float 12;20;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;310;3589.109,973.5546;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;331;3064.599,1369.667;Inherit;False;330;VertexOffset;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;208;3025.767,1141.224;Inherit;False;207;AmbientOcclusion;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;175;3082.283,1039.971;Inherit;False;174;Normals;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;552;3356.692,2087.125;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;313;3587.307,1254.955;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3894.866,1047.348;Float;False;True;-1;2;FAE.FoliageShaderGUI;0;0;Standard;FAE/Foliage;False;False;False;False;False;False;True;False;True;False;False;False;True;False;False;False;True;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;10;d3d9;d3d11_9x;d3d11;glcore;gles;gles3;metal;vulkan;xboxone;ps4;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;Nature/SpeedTree;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;3;Include;VS_InstancedIndirect.cginc;False;;Custom;Pragma;instancing_options assumeuniformscaling lodfade maxcount:50 procedural:setupScale  forwardadd;False;;Custom;Pragma;multi_compile GPU_FRUSTUM_ON __;False;;Custom;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;514;0;319;0
WireConnection;514;1;513;4
WireConnection;563;0;573;0
WireConnection;562;0;514;0
WireConnection;562;1;564;0
WireConnection;570;0;563;0
WireConnection;570;1;567;0
WireConnection;517;0;514;0
WireConnection;517;1;511;0
WireConnection;518;0;516;1
WireConnection;518;1;516;3
WireConnection;560;0;562;0
WireConnection;560;1;518;0
WireConnection;520;0;517;0
WireConnection;520;1;518;0
WireConnection;568;0;570;0
WireConnection;568;1;565;0
WireConnection;568;2;571;0
WireConnection;524;0;520;0
WireConnection;561;0;560;0
WireConnection;561;1;568;0
WireConnection;576;1;561;0
WireConnection;526;0;524;0
WireConnection;526;1;543;0
WireConnection;544;0;526;0
WireConnection;544;1;524;0
WireConnection;544;2;248;0
WireConnection;577;0;576;0
WireConnection;580;0;544;0
WireConnection;582;0;577;0
WireConnection;587;0;588;0
WireConnection;587;1;582;0
WireConnection;585;0;586;0
WireConnection;585;1;580;0
WireConnection;581;0;585;0
WireConnection;581;1;587;0
WireConnection;584;0;581;0
WireConnection;583;0;584;0
WireConnection;583;2;584;1
WireConnection;534;0;583;0
WireConnection;534;1;16;0
WireConnection;534;2;527;1
WireConnection;534;3;385;0
WireConnection;84;0;534;0
WireConnection;189;0;231;0
WireConnection;189;1;181;0
WireConnection;183;0;231;0
WireConnection;183;1;181;0
WireConnection;191;0;189;0
WireConnection;191;1;232;0
WireConnection;186;0;234;0
WireConnection;186;1;386;0
WireConnection;502;0;86;1
WireConnection;139;0;138;0
WireConnection;558;0;93;0
WireConnection;184;0;183;0
WireConnection;192;0;191;0
WireConnection;192;2;387;0
WireConnection;141;0;139;0
WireConnection;141;1;140;0
WireConnection;468;0;186;0
WireConnection;468;2;186;0
WireConnection;589;0;184;0
WireConnection;271;0;558;0
WireConnection;271;2;502;0
WireConnection;550;0;141;0
WireConnection;274;0;271;0
WireConnection;274;1;101;0
WireConnection;188;0;589;0
WireConnection;188;1;468;0
WireConnection;193;0;192;0
WireConnection;145;0;550;0
WireConnection;145;1;143;0
WireConnection;307;0;274;0
WireConnection;307;1;407;0
WireConnection;503;0;148;1
WireConnection;194;0;188;0
WireConnection;194;1;193;0
WireConnection;548;0;307;0
WireConnection;149;0;503;0
WireConnection;149;1;150;0
WireConnection;196;0;194;0
WireConnection;196;1;195;0
WireConnection;147;0;145;0
WireConnection;147;1;146;0
WireConnection;592;0;591;0
WireConnection;592;1;97;0
WireConnection;197;0;196;0
WireConnection;151;0;147;0
WireConnection;151;2;149;0
WireConnection;200;0;198;1
WireConnection;200;1;197;0
WireConnection;273;0;592;0
WireConnection;273;1;497;0
WireConnection;273;2;549;0
WireConnection;152;0;151;0
WireConnection;152;2;380;0
WireConnection;153;0;152;0
WireConnection;506;0;200;0
WireConnection;161;0;273;0
WireConnection;201;0;506;0
WireConnection;295;0;161;0
WireConnection;295;1;296;0
WireConnection;106;0;161;0
WireConnection;106;1;295;0
WireConnection;106;2;547;0
WireConnection;557;1;111;1
WireConnection;557;2;113;0
WireConnection;205;0;106;0
WireConnection;98;0;97;4
WireConnection;172;5;419;0
WireConnection;203;0;85;0
WireConnection;203;1;204;0
WireConnection;207;0;557;0
WireConnection;330;0;203;0
WireConnection;174;0;172;0
WireConnection;310;0;206;0
WireConnection;310;1;312;0
WireConnection;310;2;311;0
WireConnection;552;0;553;0
WireConnection;552;1;451;0
WireConnection;552;2;551;0
WireConnection;313;0;99;0
WireConnection;313;1;406;0
WireConnection;313;2;311;0
WireConnection;0;0;310;0
WireConnection;0;1;175;0
WireConnection;0;5;208;0
WireConnection;0;10;313;0
WireConnection;0;11;331;0
WireConnection;0;12;552;0
ASEEND*/
//CHKSM=EFE601762393A4C7B7E69B372306B9ECCB859F3C