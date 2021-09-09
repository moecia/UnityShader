// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FAE/Water" {
    Properties {
        _WaterColor ("Water Color", Color) = (0.1467344,0.4798458,0.8676471,1)
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _Transparency ("Transparency", Range(0, 1)) = 0
        _Glossiness ("Glossiness", Range(0, 1)) = 0
        _Depth ("Depth", Range(0, 30)) = 0.5
        _Depthdarkness ("Depth darkness", Range(0, 1)) = 1
        _RimSize ("Rim Size", Range(0, 4)) = 1.5
        _Rimfalloff ("Rim falloff", Float ) = 1.5
        _RefractionAmount ("Refraction Amount", Range(0, 0.2)) = 0
        [NoScaleOffset][Normal]_Normals ("Normals", 2D) = "bump" {}
        [NoScaleOffset]_Shadermap ("Shadermap", 2D) = "bump" {}
        _Tiling ("Tiling", Float ) = 0.05
        _FlowSpeed ("FlowSpeed", Float ) = 1
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent-1"
            "RenderType"="Transparent"
        }
        GrabPass{ }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //#define UNITY_PASS_FORWARDBASE
            #define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma exclude_renderers xbox360 ps3 psp2 
            #pragma target 3.0
            uniform sampler2D _GrabTexture;
            uniform sampler2D _CameraDepthTexture;
            uniform float4 _TimeEditor;
            uniform float _RimSize;
            uniform float4 _WaterColor;
            uniform float4 _RimColor;
            uniform float _Rimfalloff;
            uniform sampler2D _Shadermap;
            uniform float _RefractionAmount;
            uniform float _Transparency;
            uniform sampler2D _Normals;
            uniform float _Glossiness;
            uniform float _Depth;
            uniform float _Depthdarkness;
            uniform float _Tiling;
            uniform float _FlowSpeed;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 posWorld : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
                float3 tangentDir : TEXCOORD2;
                float3 bitangentDir : TEXCOORD3;
                float4 screenPos : TEXCOORD4;
                float4 projPos : TEXCOORD5;
                UNITY_FOG_COORDS(6)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                o.projPos = ComputeScreenPos (o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                o.screenPos = o.pos;
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                #if UNITY_UV_STARTS_AT_TOP
                    float grabSign = -_ProjectionParams.x;
                #else
                    float grabSign = _ProjectionParams.x;
                #endif
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                i.screenPos = float4( i.screenPos.xy / i.screenPos.w, 0, 0 );
                i.screenPos.y *= _ProjectionParams.x;
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float4 node_8305 = _Time + _TimeEditor;
                float node_3981 = (node_8305.r*0.8);
                float2 node_4686 = i.posWorld.rgb.rb;
                float2 node_5510 = (node_4686*_Tiling);
                float2 node_9360 = (node_5510+node_3981*float2(0,1.1));
                float3 node_4911 = UnpackNormal(tex2D(_Normals,node_9360));
                float2 node_1488 = (node_5510+node_3981*float2(0.9,0));
                float3 node_49111 = UnpackNormal(tex2D(_Normals,node_1488));
                float3 node_1309_nrm_base = node_4911.rgb + float3(0,0,1);
                float3 node_1309_nrm_detail = node_49111.rgb * float3(-1,-1,1);
                float3 node_1309_nrm_combined = node_1309_nrm_base*dot(node_1309_nrm_base, node_1309_nrm_detail)/node_1309_nrm_base.z - node_1309_nrm_detail;
                float3 node_1309 = node_1309_nrm_combined;
                float3 Normals = node_1309;
                float3 normalLocal = Normals;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
                float sceneZ = max(0,LinearEyeDepth (UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)))) - _ProjectionParams.g);
                float partZ = max(0,i.projPos.z - _ProjectionParams.g);
                float2 Refraction = (float2(node_4911.r,node_49111.g)*_RefractionAmount);
                float2 sceneUVs = float2(1,grabSign)*i.screenPos.xy*0.5+0.5 + Refraction;
                float4 sceneColor = tex2D(_GrabTexture, sceneUVs);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = 1;
                float3 attenColor = attenuation * _LightColor0.xyz;
                float Pi = 3.141592654;
                float InvPi = 0.31830988618;
///////// Gloss:
                float gloss = 1.0 - (saturate(( node_49111.b > 0.5 ? (1.0-(1.0-2.0*(node_49111.b-0.5))*(1.0-node_4911.b)) : (2.0*node_49111.b*node_4911.b) ))*_Glossiness); // Convert roughness to gloss
                float specPow = exp2( gloss * 10.0+1.0);
/////// GI Data:
                UnityLight light;
                #ifdef LIGHTMAP_OFF
                    light.color = lightColor;
                    light.dir = lightDirection;
                    light.ndotl = LambertTerm (normalDirection, light.dir);
                #else
                    light.color = half3(0.f, 0.f, 0.f);
                    light.ndotl = 0.0f;
                    light.dir = half3(0.f, 0.f, 0.f);
                #endif
                UnityGIInput d;
                d.light = light;
                d.worldPos = i.posWorld.xyz;
                d.worldViewDir = viewDirection;
                d.atten = attenuation;
				#if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION) || defined(UNITY_ENABLE_REFLECTION_BUFFERS)
                d.boxMin[0] = unity_SpecCube0_BoxMin;
                d.boxMin[1] = unity_SpecCube1_BoxMin;
				#endif
				#ifdef UNITY_SPECCUBE_BOX_PROJECTION
                d.boxMax[0] = unity_SpecCube0_BoxMax;
                d.boxMax[1] = unity_SpecCube1_BoxMax;
                d.probePosition[0] = unity_SpecCube0_ProbePosition;
                d.probePosition[1] = unity_SpecCube1_ProbePosition;
                #endif
                d.probeHDR[0] = unity_SpecCube0_HDR;
                d.probeHDR[1] = unity_SpecCube1_HDR;
                Unity_GlossyEnvironmentData ugls_en_data;
                ugls_en_data.roughness = 1.0 - gloss;
                ugls_en_data.reflUVW = viewReflectDirection;
                UnityGI gi = UnityGlobalIllumination(d, 1, normalDirection, ugls_en_data );
                lightDirection = gi.light.dir;
                lightColor = gi.light.color;
////// Specular:
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float LdotH = max(0.0,dot(lightDirection, halfDirection));
                float3 specularColor = 0.0;
                float specularMonochrome;
                float2 node_1318 = ((node_4686*0.5)+node_3981*float2(0.9,0));
                float4 node_1028 = tex2D(_Shadermap,node_1318);
                float2 node_6391 = ((0.2*node_4686)+node_3981*float2(0,1.1));
                float4 node_6468 = tex2D(_Shadermap,node_6391);
                float node_8987 = saturate((pow(saturate((sceneZ-partZ)/_RimSize),_Rimfalloff) > 0.5 ?  (1.0-(1.0-2.0*(pow(saturate((sceneZ-partZ)/_RimSize),_Rimfalloff)-0.5))*(1.0-(node_1028.b*node_6468.b))) : (2.0*pow(saturate((sceneZ-partZ)/_RimSize),_Rimfalloff)*(node_1028.b*node_6468.b))) );
                float3 node_5570 = lerp(_RimColor.rgb,_WaterColor.rgb,node_8987);
                float node_4175 = saturate((sceneZ-partZ)/_Depth);
                float2 node_2371 = ((node_5510*0.25)+(node_3981*_FlowSpeed)*float2(0,1));
                float4 _node_1611 = tex2D(_Shadermap,node_2371);
                float3 diffuseColor = (lerp(node_5570,(node_5570*(1.0 - _Depthdarkness)),node_4175)+((1.0 - _node_1611.b)*0.1)); // Need this for specular when using metallic
                diffuseColor = DiffuseAndSpecularFromMetallic( diffuseColor, specularColor, specularColor, specularMonochrome );
                specularMonochrome = 1.0-specularMonochrome;
                float NdotV = max(0.0,dot( normalDirection, viewDirection ));
                float NdotH = max(0.0,dot( normalDirection, halfDirection ));
                float VdotH = max(0.0,dot( viewDirection, halfDirection ));
                float visTerm = SmithJointGGXVisibilityTerm( NdotL, NdotV, 1.0-gloss );
                float normTerm = max(0.0, GGXTerm(NdotH, 1.0-gloss));
                float specularPBL = (NdotL*visTerm*normTerm) * (UNITY_PI / 4);
                if (IsGammaSpace())
                    specularPBL = sqrt(max(1e-4h, specularPBL));
                specularPBL = max(0, specularPBL * NdotL);
                float3 directSpecular = (floor(attenuation) * _LightColor0.xyz)*specularPBL*FresnelTerm(specularColor, LdotH);
                half grazingTerm = saturate( gloss + specularMonochrome );
                float3 indirectSpecular = (gi.indirect.specular);
                indirectSpecular *= FresnelLerp (specularColor, grazingTerm, NdotV);
                float3 specular = (directSpecular + indirectSpecular);
/////// Diffuse:
                NdotL = dot( normalDirection, lightDirection );
                float3 NdotLWrap = NdotL * ( 1.0 );
                float3 forwardLight = max(float3(0.0,0.0,0.0), NdotLWrap);
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                half fd90 = 0.5 + 2 * LdotH * LdotH * (1-gloss);
                float nlPow5 = Pow5(1-NdotLWrap);
                float nvPow5 = Pow5(1-NdotV);
                float3 directDiffuse = (forwardLight + ((1 +(fd90 - 1)*nlPow5) * (1 + (fd90 - 1)*nvPow5) * NdotL)) * attenColor;
                float3 indirectDiffuse = float3(0,0,0);
                indirectDiffuse += UNITY_LIGHTMODEL_AMBIENT.rgb; // Ambient Light
                //indirectDiffuse += UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, viewReflectDirection).rgb * 0.0; // Diffuse Ambient Light
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
/// Final Color:
                float3 finalColor = diffuse + specular;
                fixed4 finalRGBA = fixed4(lerp(sceneColor.rgb, finalColor,saturate(( lerp(1.0,_Transparency,node_8987) > 0.5 ? (1.0-(1.0-2.0*(lerp(1.0,_Transparency,node_8987)-0.5))*(1.0-node_4175)) : (2.0*lerp(1.0,_Transparency,node_8987)*node_4175) ))),1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    //FallBack "Diffuse"
}