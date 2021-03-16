Shader "Unlit/holographicShader"{
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _TintColor ("Tint color", Color) = (0, 0, 0, 0)
        _Transparency ("Transparency", Range(0.0, 0.5)) = 0.25
        _CutOutThresh ( "Cutout threshold", Range(0.0, 1.0)) = 0.2
        _Distance ("Distance", float) = 1.0
        _Amplitude ("Amplitude", float) = 1.0
        _Speed ("Speed", float) = 1.0
        _Frequency("Frequency", float) = 1.0
        _Amount ("Amount", Range(0.0, 1.0)) = 1.0

    }
    SubShader    {
        Tags { "Queue" = "Transparent" "RenderType"="Transparent" }
        LOD 100

        ZWrite Off 
        Blend SrcAlpha OneMinusSrcAlpha

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct VertexData {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct VertexOutput {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _TintColor;
            float _Transparency;
            float _CutOutThresh;
            float _Distance;
            float _Amplitude;
            float _Frequency;
            float _Speed;
            float _Amount;

            VertexOutput vert (VertexData v) {
                VertexOutput o;
                v.vertex.x  += sin(_Frequency*(_Time.y * _Speed + v.vertex.y * _Amplitude)) * _Distance * _Amount;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (VertexOutput i) : SV_Target { 
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) + _TintColor;
                col.a = _Transparency;
                clip(col.r - _CutOutThresh);

                return float4(col);
            }
            ENDCG
        }
    }
}
