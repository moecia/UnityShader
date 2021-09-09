 Shader "Unlit/VertexShaderTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            
            struct appdata
            {
                // 传入模型空间的顶点坐标
                float4 vertex : POSITION;
                // 传入纹理坐标
                float2 uv : TEXCOORD0;
            };

            // 定义传入片元着色的参数结构体
            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                // POSITION: 模型空间的顶点坐标
                // SV_POSITION: 裁剪空间的顶点坐标
                // 通常情况POSITION等价于SV_POSITION，但是PS4只识别SV_POSITION
                // 同样的还有COLOR vs SV_TARGET
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
