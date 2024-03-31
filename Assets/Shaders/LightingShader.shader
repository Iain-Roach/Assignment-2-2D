Shader "Hidden/LightingShader"
{
    Properties
    {
        _Angle("Angle", Float) = -0.3
        _Position("Position", Float) = -0.2
        _Spread("Spread", Range(0.0, 1.0)) = 0.5
        _Cutoff("Cutoff", Range(-1.0, 1.0)) = 0.1
        _Falloff("Falloff", Range(0.0, 1.0)) = 0.2
        _EdgeFade("EdgeFade", Range(0.0, 1.0)) = 0.15
        _Speed("Speed", Float) = 1.0
        _Ray1Density("Ray1 Density", Float) = 8.0
        _Ray2Density("Ray2 Density", Float) = 30.0
        _Ray2Intensity("Ray2 Intensity", Range(0.0, 1.0)) = 0.3
        _Color("Color", Color) = (1.0, 0.9, 0.65, 0.8)
        _HDR("HDR", Int) = 0
        _Seed("Seed", Float) = 5.0
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float _Angle;
            float _Position;
            float _Spread;
            float _Cutoff;
            float _Falloff;
            float _EdgeFade;
            float _Speed;
            float _Ray1Density;
            float _Ray2Density;
            float _Ray2Intensity;
            float4 _Color;
            float _HDR;
            float _Seed;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

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

            float2x2 rotate(float _angle)
            {
                float c = cos(_angle);
                float s = sin(_angle);
                return float2x2(c, -s, s, c);
            }

            float4 frag(v2f i) : SV_Target
            {
                float2 transformed_uv = mul(rotate(_Angle), (i.uv - float2(_Position, 0.0))) / ((_Spread + i.uv.y) - (i.uv.y * _Spread));
                float2 ray1 = float2(transformed_uv.x * _Ray1Density + sin(_Time.y * 0.1 * _Speed) * (_Ray1Density * 0.2) + _Time.y, 1.0);
                float2 ray2 = float2(transformed_uv.x * _Ray2Density + sin(_Time.y * 0.2 * _Speed) * (_Ray1Density * 0.2) + _Time.y, 1.0);
                float cut = step(_Cutoff, transformed_uv.x) * step(_Cutoff, 1.0 - transformed_uv.x);
                ray1 *= cut;
                ray2 *= cut;
                float rays;
                if (_HDR == 1)
                {
                    rays = noise(ray1) + (noise(ray2) * _Ray2Intensity);
                }
                else
                {
                    rays = saturate(noise(ray1) + (noise(ray2) * _Ray2Intensity));
                }
                rays *= smoothstep(0.0, _Falloff, (1.0 - i.uv.y));
                rays *= smoothstep(0.0 + _Cutoff, _EdgeFade + _Cutoff, transformed_uv.x);
                rays *= smoothstep(0.0 + _Cutoff, _EdgeFade + _Cutoff, 1.0 - transformed_uv.x);
                float3 shine = rays * _Color.rgb;
                return float4(shine, rays * _Color.a);
            }
            ENDCG
        }
    }
}
