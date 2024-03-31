Shader "Hidden/FractalBrownianMotionShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float random(float2 _uv)
            {
                return frac(sin(dot(_uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float noise(float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                float a = random(i);
                float b = random(i + float2(1.0, 0.0));
                float c = random(i + float2(0.0, 1.0));
                float d = random(i + float2(1.0, 1.0));
                float2 u = f * f * (3.0 - 2.0 * f);
                return lerp(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
            }

            #define NUM_OCTAVES 5

            float fbm(float2 st)
            {
                float v = 0.0;
                float a = 0.5;
                float2 shift = float2(100.0,100.0);
                // Rotate to reduce axial bias
                float2x2 rot = float2x2(cos(0.5), sin(0.5),
                    -sin(0.5), cos(0.50));
                for (int i = 0; i < NUM_OCTAVES; ++i) {
                    v += a * noise(st);
                    //st = rot * st * 2.0 + shift;
                    st = mul(rot, st) * 2.0 + shift;
                    a *= 0.5;
                }
                return v;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 st = i.vertex.xy / _ScreenParams.xy * 5.0f;
                float3 color;

                float2 q;
                q.x = fbm(st + 0.00 * unity_DeltaTime.xy);
                q.y = fbm(st + float2(1.0, 1.0));
                
                float2 r;
                r.x = fbm(st + 1.0 * q + float2(1.7, 9.2) + 1.15 * _Time.y);
                r.y = fbm(st + 1.0 * q + float2(8.3, 2.8) + 1.126 * _Time.y);

                float f = fbm(st + r);

                color = lerp(float3(0.1019, 0.619, 0.666), float3(0.666, 0.666, 0.5), clamp((f * f) * 4.0, 0.0, 1.0));

                color = lerp(color, float3(0, 0, 0.164), clamp(length(q), 0.0, 1.0));

                color = lerp(color, float3(0.666, 1, 1), clamp(length(r.x), 0.0, 1.0));

                return float4((f * f * f + .6 * f * f + .5 * f) * color, 1.0);






                fixed4 col = tex2D(_MainTex, i.uv);
                // just invert the colors
                col.rgb = 1 - col.rgb;
                return col;
            }
            ENDCG
        }
    }
}
