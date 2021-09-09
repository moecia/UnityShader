Shader "Custom/IlluminationModel"
{
    Properties
    {
        _DiffuseTex("Diffuse Texture", 2D) = "white" {}
        _BumpTex("Bump Texture", 2D) = "bump" {}
        _BumpAmount("Bump Amount", Range(0, 10)) = 1
        _Brightness("Brightness", Range(0, 10)) = 1
        _CubeMap("Cube Map", CUBE) = "white" {}
    }
        SubShader
        {
            CGPROGRAM
            #pragma surface surf Lambert

            sampler2D _DiffuseTex;
            sampler2D _BumpTex;
            half _BumpAmount;
            half _Brightness;
            samplerCUBE _CubeMap;

            struct Input
            {
                float2 uv_DiffuseTex;
                float2 uv_BumpTex;
                float3 worldRefl; INTERNAL_DATA
            };

            void surf(Input IN, inout SurfaceOutput o)
            {
                o.Albedo = tex2D(_DiffuseTex, IN.uv_DiffuseTex).rgb;
                o.Normal = UnpackNormal(tex2D(_BumpTex, IN.uv_BumpTex)) * _Brightness;
                o.Normal *= float3(_BumpAmount, _BumpAmount, 1);
                o.Emission = texCUBE(_CubeMap, WorldReflectionVector(IN, o.Normal)).rgb;
            }
            ENDCG
        }
            FallBack "Diffuse"
}
