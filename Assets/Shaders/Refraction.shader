// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/Refraction" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _IOR ("IOR", float) = 1.45
    }
    SubShader {
        Tags { "Queue" = "Transparent" "RenderType"="Transparent" }
        LOD 100

        ZWrite Off 

        GrabPass{
            // If assigned a name to the grab texture, all objects that use this
            // Shader will also share this texture
            // Otherwise a new _GrabTexture will be created for each object
        }

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct VertexData {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent: TANGENT;
            };

            struct VertexOutput {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenUV: TEXCOORD1;
                float3 normal: TEXCOORD2;
                float3 worldPos: TEXCOORD3;
                float3 tangent: TEXCOORD4;
                float3 bitangent: TEXCOORD5;         
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _GrabTexture;
            float _IOR;

            VertexOutput vert (VertexData v) {
                VertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screenUV = ComputeGrabScreenPos(o.vertex);
                o.normal = v.normal;
                o.worldPos = mul( unity_ObjectToWorld, v.vertex );

                o.bitangent = cross(v.normal, v.tangent.xyz) * v.tangent.w;
                o.tangent = v.tangent.xyz;
                return o;
            }

            float4 frag (VertexOutput i) : SV_Target {
                // sample the texture
                // fixed4 col = tex2D(_MainTex, i.uv);
                float3 normal = normalize(i.normal);
                float3 camPos = _WorldSpaceCameraPos;
                float3 fragToCam = i.worldPos;
                float3 viewVector = normalize(fragToCam - camPos);

                float3 refVector = refract(viewVector, normal, _IOR);
                refVector = float3(
                dot(refVector,i.tangent),
                dot(refVector,i.bitangent),
                dot(refVector,i.normal)
                );

                float4 grab = tex2Dproj(_GrabTexture, 
                (i.screenUV + float4(refVector.xy, 0, 0))
                );

                return float4(grab);
                // return frac(i.screenUV * 16.0);
            }
            ENDCG
        }
    }
}
