Shader "Unlit/SimpleShader" {
    Properties    {
        // All properties are defined for each material that the shader is applied to 
        // To build a color for differnet instances without having to set different materials, use Unity Property Block
        _Color ("Color", Color) = (1, 1, 1, 0)
        _Gloss ("Gloss", float) = 1
        _SpecularIntensity ("Specular Intensity", Range(0,1)) = 1

        // _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader    {
        Tags { "RenderType"="Opaque" }

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            // Mesh data: vertex position, vertex normal, UVs, tangents, vertex colors
            // Define which data from the mesh we are gonna use
            struct VertexInput {
                float4 vertex : POSITION; // Careful with semantics here
                float3 normal: NORMAL;
                // float4 colors: COLOR;
                // float4 tangent: TANGENT;

                // Multiple coordinates may vary from materiaal to material, for example, one may wanna use a texture to map albedo values and another texture to map lighting and specular values. 
                // Also you can use UV for other things that not mapping textures                
                float2 uv0: TEXCOORD0;
                // float uv1: TEXCOORD1;
            };

            // Output of the vertex shader that goes to the Fragment Shader
            struct VertexOutput {
                // The safest variable name here would be "vertex"
                // The actual name is used for pedagogical purposes
                // All shader semantics are treated here
                float4 clipSpacePos : SV_POSITION; // The one that will be read as the clip position in the shader 
                float2 uv0 : TEXCOORD0; 
                float3 normal: TEXCOORD1; // Tex coord in the output is an interpolator, while in the input is used for specifically uv coordinates
                float3 worldPos: TEXCOORD2;
            };

            // Usually tied with the properties declared in the beginning
            // sampler2D _MainTex;
            // float4 _MainTex_ST;

            float4 _Color;
            float _Gloss;
            float _SpecularIntensity;

            // Vertex shader itself
            // Return values here act as a normal C/C++ code. We could skip the structure and return a single value instead. In this case, we would have to treat semantics in the return value and in the Fragment Shader parameter
            VertexOutput vert (VertexInput v) {
                VertexOutput o;
                o.uv0 = v.uv0;
                o.normal = v.normal;
                o.clipSpacePos = UnityObjectToClipPos(v.vertex); // Unity Model View Projection
                o.worldPos = mul( unity_ObjectToWorld, v.vertex );
                return o; 
            }

            // Fragment shader
            // Return parameters may vary precisions as well (depending on the target device)
            float4 frag (VertexOutput o) : SV_Target {
                float2 uv = o.uv0;
                float3 normal = normalize(o.normal);

                float3 lightColor = _LightColor0; //  Unity build first light source
                float3 lightSrc = normalize(_WorldSpaceLightPos0.xyz); // The position of the first light source

                // Ambient Light
                float3 ambientLight = float3(0.37,0.45, 0.5);

                // Diffuse lighting
                float3 lightIntensity = saturate(dot(normal, lightSrc));
                float3 diffuseLight = lightIntensity * lightColor;

                // Specular lighting (Blinn Phong model)
                float3 camPos = _WorldSpaceCameraPos;
                float3 fragToCam = o.worldPos;
                float3 viewVector = normalize(camPos - fragToCam);
                float3 halfwayVector = normalize(lightSrc + viewVector);
                float specular = saturate(dot(normal, halfwayVector));
                specular = pow(specular, _Gloss);

                // Composite 
                float3 finalColor = diffuseLight = (diffuseLight + ambientLight) * _Color.rgb + specular * _SpecularIntensity;

                // Returns a color for the fragment
                return float4(finalColor, 0);
            }
            ENDCG
        }
    }
}
