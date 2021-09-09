Shader "Custom/HelloShader" 
{
	
	Properties 
	{
	     _myColour ("Example Colour", Color) = (1,1,1,1)
	     _myEmission ("Example Emission", Color) = (1,1,1,1)
	}
	
	SubShader 
	{
		CGPROGRAM
		// 声明编译指令: surface表面着色器的方法名叫surf
		// 声明格式：#pragma shaderType shaderName
		#pragma surface surf Lambert

		struct Input 
		{
			float2 uvMainTex;
		};
		
		// CG代码需要定义和Properties类型和名称完全一样的变量来使用
		fixed4 _myColour;
		fixed4 _myEmission;
			
		void surf (Input IN, inout SurfaceOutput o)
		{
			o.Albedo = _myColour.rgb;
			o.Emission = _myEmission.rgb;
		}
		ENDCG
	}
	
	FallBack "Diffuse"
}