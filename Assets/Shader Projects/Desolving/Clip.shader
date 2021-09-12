Shader "Course/ClipFunction"
{
    Properties
    {
        _CutOff("CutOff",Range(0,1)) = 0
        _MainTex("MainTex",2D) = "white"{}
    }

        SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            float _CutOff;
            sampler2D _MainTex;

            struct a2v
            {
                float4 localPosition:POSITION;
                float2 uv:TEXCOORD0;
            };

            struct v2f
            {
                float4 position:SV_POSITION;
                float2 uv:TEXCOORD0;
            };

            v2f vert(a2v a)
            {
                v2f v;
                v.position = UnityObjectToClipPos(a.localPosition);
                v.uv = a.uv;
                return v;
            }

            fixed4 frag(v2f i) :SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);

                clip(color.rgb - _CutOff);
                // is equal to the following code
                //if(color.a <_CutOff)
                //{
                //  discard;
                //}
                return color;
            }

            ENDCG
        }
    }
}