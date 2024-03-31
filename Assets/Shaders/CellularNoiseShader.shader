Shader "Hidden/CellularNoiseShader"
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float2 random(float2 p) {
                return frac(sin(float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)))) * 43758.5453);
            }

            sampler2D _MainTex;

            fixed4 frag(v2f i) : SV_Target
            {
                float2 st = i.vertex.xy / _ScreenParams.xy;
                st.x *= _ScreenParams.x / _ScreenParams.y;
                float4 color = float4(0, 0, 0, 1);

                st *= 3;

                float2 i_st = floor(st);
                float2 f_st = frac(st);

                float m_dist = 1;
                float2 m_point = float2(0, 0);

                for (int y = -1; y <= 1; y++)
                {
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 neighbor = float2(float(x), float(y));

                        float2 pt = random(i_st + neighbor);

                        pt = 0.5 + 0.5 * sin(_Time.y + 6.2831 * pt);

                        float2 diff = neighbor + pt - f_st;

                        float dist = length(diff);

                        m_dist = min(m_dist, dist);

                        /*m_point = pt;*/
                    }
                }

                //color += m_dist;

                float3 cellColor = float3(m_dist, m_dist, m_dist);

               /* color.rg = m_point;*/

                color = float4(cellColor, 1.0);
                color = 1 - color;
                return float4(color);
            }
            ENDCG
        }
    }
}
