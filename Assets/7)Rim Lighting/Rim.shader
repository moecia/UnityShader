Shader "Custom/Rim"
{
    Properties
    {
        _RimColor ("Rim Color", Color) = (0,0.5,0.5,0)
        _RimPower("Rim Power", Range(0.5, 8.0)) = 3.0
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert

        float4 _RimColor;
        float _RimPower;

        struct Input
        {
            float3 viewDir;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            // saturate: value will between 0 - 1
            half rim = 1 - saturate(dot(normalize(IN.viewDir), o.Normal));
            o.Emission = _RimColor.rgb * pow(rim, _RimPower);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
