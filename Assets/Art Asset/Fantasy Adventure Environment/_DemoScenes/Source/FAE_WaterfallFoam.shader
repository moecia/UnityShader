// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FAE/Waterfall foam"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_Texture0("Texture 0", 2D) = "white" {}
		_Normals("Normals", 2D) = "bump" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+1" "DisableBatching" = "True" }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma exclude_renderers xbox360 psp2 n3ds wiiu 
		#pragma surface surf Standard keepalpha noshadow nolightmap  nodirlightmap vertex:vertexDataFunc 
		struct Input
		{
			float2 texcoord_0;
			float2 texcoord_1;
		};

		uniform sampler2D _Normals;
		uniform sampler2D _Texture0;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.texcoord_0.xy = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
			o.texcoord_1.xy = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
			float2 temp_output_3_0 = (abs( o.texcoord_1+( _Time.y * 0.55 ) * float2(0,1 )));
			float4 tex2DNode2 = tex2Dlod( _Texture0, float4( temp_output_3_0, 0.0 , 0.0 ) );
			v.vertex.xyz += ( ( tex2DNode2.b * 5.0 ) * float3(-1,0,0) );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 temp_output_3_0 = (abs( i.texcoord_0+( _Time.y * 0.55 ) * float2(0,1 )));
			o.Normal = UnpackScaleNormal( tex2D( _Normals, temp_output_3_0 ) ,0.0 );
			float4 tex2DNode2 = tex2D( _Texture0, temp_output_3_0 );
			float lerpResult23 = lerp( 1.0 , tex2DNode2.b , 0.2);
			float3 temp_cast_0 = (lerpResult23).xxx;
			o.Albedo = temp_cast_0;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Standard"
}
/*ASEBEGIN
Version=11011
1927;29;1906;1004;-213.8019;317.2063;1;True;True
Node;AmplifyShaderEditor.TimeNode;5;-541.8002,-295.6;Float;False;0;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;16;-510.3001,-63.1999;Float;False;Constant;_Speed;Speed;2;0;0.55;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-292.4,-408.2001;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-249.2997,-163.1999;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.TexturePropertyNode;1;-53.00005,53.8;Float;True;Property;_Texture0;Texture 0;0;0;None;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.PannerNode;3;42.00003,-372.6;Float;False;0;1;2;0;FLOAT2;0,0;False;1;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.RangedFloatNode;7;608.5,324.2001;Float;False;Constant;_Strength;Strength;1;0;5;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;2;400.8001,50.20002;Float;True;Property;_TextureSample0;Texture Sample 0;1;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0.0;False;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.Vector3Node;8;1142.3,385.8;Float;False;Constant;_Vector0;Vector 0;2;0;-1,0,0;0;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;24;993.1022,131.3942;Float;False;Constant;_Coloring;Coloring;4;0;0.2;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;10;1112,-90.40001;Float;False;Constant;_Float0;Float 0;2;0;1;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;932.9,242.2;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;23;1337.802,53.59424;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;1385.5,264.8;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT3;0.0;False;1;FLOAT3
Node;AmplifyShaderEditor.SamplerNode;14;1063.1,-314.0001;Float;True;Property;_Normals;Normals;1;0;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0.0;False;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1718.553,30.57446;Float;False;True;2;Float;;0;Standard;FAE/Waterfall foam;False;False;False;False;False;False;True;False;True;False;False;False;False;True;False;False;False;Back;0;0;False;0;0;Opaque;0.5;True;False;1;False;Opaque;Geometry;All;True;True;True;True;True;True;True;False;True;True;False;False;False;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;False;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;Standard;-1;-1;-1;-1;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;15;0;5;2
WireConnection;15;1;16;0
WireConnection;3;0;4;0
WireConnection;3;1;15;0
WireConnection;2;0;1;0
WireConnection;2;1;3;0
WireConnection;6;0;2;3
WireConnection;6;1;7;0
WireConnection;23;0;10;0
WireConnection;23;1;2;3
WireConnection;23;2;24;0
WireConnection;9;0;6;0
WireConnection;9;1;8;0
WireConnection;14;1;3;0
WireConnection;0;0;23;0
WireConnection;0;1;14;0
WireConnection;0;11;9;0
ASEEND*/
//CHKSM=85708257E8BFE0B94BB85D02F281A6DB40DCA4E8