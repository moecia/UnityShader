 Shader "Custom/BumpDiffuse"
{
    Properties
    {
        _DiffuseTex ("Diffuse Texture", 2D) = "white" {}
        _BumpTex("Bump Texture", 2D) = "bump" {}
        _BumpAmount("Bump Amount", Range(0, 10)) = 1
        _BumpScale("Bump Scale", Range(0.5, 2)) = 1
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _DiffuseTex;
        sampler2D _BumpTex;
        half _BumpAmount;
        half _BumpScale;

        struct Input
        {
            float2 uv_DiffuseTex;
            float2 uv_BumpTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = tex2D(_DiffuseTex, IN.uv_DiffuseTex).rgb;
            o.Normal = UnpackNormal(tex2D(_BumpTex, IN.uv_BumpTex * _BumpScale));
            o.Normal *= float3(_BumpAmount, _BumpAmount, 1);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
