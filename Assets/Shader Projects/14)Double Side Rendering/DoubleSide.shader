Shader "Custom/DoubleSide" 
{
    Properties
    {
        _MainTex("Albedo (RGB)", 2D) = "black" {}
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        Pass
        {
            SetTexture[_MainTex] { combine texture }
        }
    }
}
