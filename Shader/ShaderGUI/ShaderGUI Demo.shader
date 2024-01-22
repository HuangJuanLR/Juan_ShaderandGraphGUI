Shader "Juan/ShaderGUI Demo/ShaderGUI Demo"
{
    Properties
    {
        // #########################################
        // Begin Surface Options Folder
        // #########################################

        [Folder(Surface Options)]
        _RegularFloat("Regular Float", Range(0, 1)) = 0.0
        _RegularColor("Regular Color", Color) = (1,1,1,1)
        [Close]  
        
        // ----------------------------
        // End Surface Options Folder
        // ----------------------------
        
        // #########################################
        // Begin Surface Inputs Folder
        // #########################################
        
        [Folder(Surface Inputs)]
        
        [Texture(_Color)]_MainTex ("Albedo (RGB)", 2D) = "white" {}
        [HideInInspector]_Color ("Color", Color) = (1,1,1,1)

        [Texture(#_BumpScale)]_BumpMap("Normal Map", 2D) = "bump"{}
        [hIdeiNInsPeCtoR]_BumpScale ("Normal Map Scale", Range(0.0, 5.0)) = 1.0
        
        [Text(Use Smoothness and Metallic Slider if Mask Map not specified, info)]
        
        [Texture]_MaskMap("Mask Map(MADS)", 2D) = "white"{}
        
        // Begin MaskMap Condition Folder
        [ConditionFolder(_MaskMap)]
        
        [Remapping]_MetallicRemap ("Metallic Remapping", Float) = 1.0
        [hIdeiNInsPeCtoR]_MetallicRemapMax ("Metallic Remap Max", Float) = 1.0
        [hIdeiNInsPeCtoR]_MetallicRemapMin ("Metallic Remap Min", Float) = 0.0

        [Remapping]_SmoothnessRemap ("Smoothness Remapping", Float) = 1.0
        [hIdeiNInsPeCtoR]_SmoothnessRemapMax ("Smoothness Remap Max", Float) = 1.0
        [hIdeiNInsPeCtoR]_SmoothnessRemapMin ("Smoothness Remap Min", Float) = 0.0

        [Remapping]_AORemap ("AO Remapping", Float) = 1.0
        [hIdeiNInsPeCtoR]_AORemapMax ("AO Remap Max", Float) = 1.0
        [hIdeiNInsPeCtoR]_AORemapMin ("AO Remap Min", Float) = 0.0  
        
        [Close]
        // End MaskMap Condition Folder
        
        // Begin MaskMap Off Condition Folder
        [ConditionFolder(_MaskMap, OFF)]
        _Smoothness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        [Close]
        // End MaskMap Off Condition Folder
        
        [QuickSlider]_FloatMinMax("Float Min Max", Float) = 1.0
        
        [ScaleOffset(_MainTex)]_MainTexScaleOffset("Tiling & Offset", Vector) = (1,1,0,0)
        
        [Close]
        
        // ----------------------------
        // End Surface Inputs Folder
        // ----------------------------
        
        // #########################################
        // Begin Emission Folder
        // #########################################

        [FeatureFolder(Emission, _EMISSION)] 

        [Texture(_EmissionColor, HDR)]_EmissionMap("Emission", 2D) = "white" {}
        [HideInInspector]_EmissionColor("Color", Color) = (1,1,1,1)

        [QuickSlider(0.0, 2.0)]_EmissionIntensity("Emission Intensity", Float) = 1.0
        
        // ----------------------------
        // End Emission Folder
        // ----------------------------
    }
    SubShader
    {
        Tags{"RenderPipeline" = "UniversalPipeline"}

        Pass{
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}
            
            
            HLSLPROGRAM

            #pragma shader_feature_local_fragment _SHADER_FEATURE_ONE
            #pragma shader_feature_local_fragment _SHADER_FEATURE_TWO
            #pragma shader_feature_local_fragment _SHADER_FEATURE_THREE
            #pragma shader_feature_local_fragment _SHOW_BLOCK_TWO
            #pragma shader_feature_local_fragment _SHADOW_CUTOFF
            #pragma shader_feature_local_fragment _EMISSION

            #pragma shader_feature_local_fragment _ALPHATEST_ON

            // GPU Instancing
            // Instancing Field only shows up when these directives are defined
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex LitPassVertexBasic
            #pragma fragment LitPassFragmentBasic
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            TEXTURE2D(_EmissionMap); SAMPLER(sampler_EmissionMap);
            float4 _MainTex_ST;

            struct Input
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            struct Varying
            {
                float4 positionCS: SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
            };
            
            float4 _Color;
            float4 _Color2;
            float4 _Color3;
            float4 _EmissionColor;
            float _EmissionIntensity;

            Varying LitPassVertexBasic(Input input)
            {
                Varying output;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);

                output.positionCS = vertexInput.positionCS;
                output.uv0 = TRANSFORM_TEX(input.uv0, _MainTex);
                output.normalWS = normalize(normalInput.normalWS);
                output.positionWS = vertexInput.positionWS;

                return output;
            }

            float4 LitPassFragmentBasic(Varying input): SV_TARGET
            {
                // Albedo comes from a texture tinted by color
                float4 c = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv0) * _Color;
                
                #ifdef _SHADER_FEATURE_ONE
                    c = _Color2;
                #elif defined(_SHADER_FEATURE_TWO)
                    c = _Color3;
                #endif

                #ifdef _EMISSION
                    float4 emissionMap = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, input.uv0);
                    c += _EmissionColor * _EmissionIntensity * emissionMap;
                #endif
                
                return c;
            }
            ENDHLSL

        }

        // For testing lightmap emissive property
        Pass
        {
            Name "Meta"
            Tags{"LightMode" = "Meta"}

            Cull Off

            HLSLPROGRAM
            
            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMetaLit

             #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/MetaPass.hlsl"
            
            #pragma shader_feature_local_fragment _EMISSION

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            TEXTURE2D(_EmissionMap); SAMPLER(sampler_EmissionMap);

            float4 _MainTex_ST;
            float4 _EmissionColor;
            float _EmissionIntensity;
            float4 _Color;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };

            Varyings UniversalVertexMeta(Attributes input)
            {
                Varyings output = (Varyings)0;
                output.uv0 = TRANSFORM_TEX(input.uv0, _MainTex);
                output.positionCS = UnityMetaVertexPosition(input.positionOS.xyz, input.uv1, input.uv2);
                return output;
            }
            
            #define MetaInput UnityMetaInput
            
            half4 UniversalFragmentMetaLit(Varyings input) : SV_Target
            {
                MetaInput metaInput = (MetaInput)0;
                metaInput.Albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv0) * _Color;
                metaInput.Emission = _EmissionColor * _EmissionIntensity;
                return UnityMetaFragment(metaInput);
            }
           

            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            HLSLPROGRAM

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 position     : POSITION;
                float2 texcoord     : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv           : TEXCOORD0;
                float4 positionCS   : SV_POSITION;
            };

            Varyings DepthOnlyVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = TransformObjectToHClip(input.position.xyz);
                return output;
            }

            half4 DepthOnlyFragment(Varyings input) : SV_TARGET
            {
                return 0;
            }

            ENDHLSL
        }

        Pass
        {
            Name "DepthNormalsOnly"
            Tags{"LightMode" = "DepthNormalsOnly"}

            HLSLPROGRAM

            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float3 normal       : NORMAL;
                float4 positionOS   : POSITION;
                float4 tangentOS    : TANGENT;
            };

            struct Varyings
            {
                float4 positionCS   : SV_POSITION;
                float3 normalWS     : TEXCOORD1;
            };

            Varyings DepthNormalsVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                return output;
            }

            float4 DepthNormalsFragment(Varyings input) : SV_TARGET
            {
                return 0;
            }

            ENDHLSL
        }
    }
    CustomEditor "JuanShaderGUI"
}
