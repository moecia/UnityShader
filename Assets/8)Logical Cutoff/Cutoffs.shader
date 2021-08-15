Shader "Custom/Cutoffs"
{
    Properties
    {
        _RimColor("Rim Color", Color) = (0,0.5,0.5,0)
        _StripWidth("Strip Width", Range(10, 100)) = 10
        _DiffuseTex("Diffuse Texture", 2D) = "white" {}
    }
        SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert

        float4 _RimColor;
        float _StripWidth;
        sampler2D _DiffuseTex;

        struct Input
        {
            float3 viewDir;
            float3 worldPos;
            float2 uv_DiffuseTex;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = tex2D(_DiffuseTex, IN.uv_DiffuseTex).rgb;
            // saturate: value will between 0 - 1
            half rim = 1 - saturate(dot(normalize(IN.viewDir), o.Normal));
            //o.Emission = _RimColor.rgb * pow(rim, _RimPower);
            // 双层外圈发光
            //o.Emission = rim > 0.5 ? float3(1,0,0) : rim > 0.3? float3(0,1,0) : 0;
            // 类似扫描效果
            //o.Emission = IN.worldPos.y < 1 ? float3(0, 1, 0) : float3(1, 0, 0);
            // 多层strips
            o.Emission = frac(IN.worldPos.y * 1000/_StripWidth * 0.5) > 0.4 ? float3(0, 1, 0) * rim : float3(1, 0, 0) * rim;
        }
        ENDCG
    }
        FallBack "Diffuse"
}
