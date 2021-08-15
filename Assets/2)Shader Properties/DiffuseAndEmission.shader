Shader "Custom/DifuseAndEmission"
{
    Properties
    {
        _DiffuseTex("Diffuse Texture", 2D) = "white" {}
        _EmissionTex("Emission Texture", 2D) = "black" {}
    }
    SubShader
    {
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _DiffuseTex;
        sampler2D _EmissionTex;

        struct Input
        {
            float2 uv_DiffuseTex;
            float2 uv_EmissionTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = (tex2D(_DiffuseTex, IN.uv_DiffuseTex)).rgb;
            o.Emission = (tex2D(_EmissionTex, IN.uv_EmissionTex)).rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
