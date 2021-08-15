Shader "Custom/MetallicReflectiveBump"
{
    Properties
    {
        _BumpTex("Bump Texture", 2D) = "bump" {}
        _BumpAmount("Bump Amount", Range(0, 10)) = 1
        _Brightness("Brightness", Range(0, 10)) = 1
        _CubeMap("Cube Map", CUBE) = "white" {}
    }
        SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _BumpTex;
        half _BumpAmount;
        half _Brightness;
        samplerCUBE _CubeMap;

        struct Input
        {
            float2 uv_BumpTex;
            float3 worldRefl; INTERNAL_DATA
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Normal = UnpackNormal(tex2D(_BumpTex, IN.uv_BumpTex)) * _Brightness;
            o.Normal *= float3(_BumpAmount, _BumpAmount, 1);
            o.Albedo = texCUBE(_CubeMap, WorldReflectionVector(IN, o.Normal)).rgb;
        }
        ENDCG
    }
        FallBack "Diffuse"
}
