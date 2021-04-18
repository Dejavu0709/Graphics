
Shader "ShaderMan/MathEye"
	{

	Properties{
	//Properties
	}

	SubShader
	{
	Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

	Pass
	{
	ZWrite Off
	Blend SrcAlpha OneMinusSrcAlpha

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"

	struct VertexInput {
    float4 vertex : POSITION;
	float2 uv:TEXCOORD0;
    float4 tangent : TANGENT;
    float3 normal : NORMAL;
	//VertexInput
	};


	struct VertexOutput {
	float4 pos : SV_POSITION;
	float2 uv:TEXCOORD0;
	//VertexOutput
	};
    const float2x2 m = float2x2( 0.80,  0.60, -0.60,  0.80 );

    float hash( float n )
    {
        return frac(sin(n)*43758.5453);
    }
    
    float noise( in float2 x )
    {
        float2 p = floor(x);
        float2 f = frac(x);
    
        f = f*f*(3.0-2.0*f);
    
        float n = p.x + p.y*57.0;
    
        return lerp(lerp( hash(n+  0.0), hash(n+  1.0),f.x),
                   lerp( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y);
    }
    
    float fbm( float2 p )
    {
        float f = 0.0;
    
        f += 0.50000*noise( p ); p = m*float2x1(p)*2.02;
        f += 0.25000*noise( p ); p = m*float2x1(p)*2.03;
        f += 0.12500*noise( p ); p = m*float2x1(p)*2.01;
        f += 0.06250*noise( p ); p = m*float2x1(p)*2.04;
        f += 0.03125*noise( p );
    
        return f/0.984375;
    }
    
    float length2( float2 p )
    {
        float2 q = p*p*p*p;
        return pow( q.x + q.y, 1.0/4.0 );
    }





	VertexOutput vert (VertexInput v)
	{
	VertexOutput o;
	o.pos = UnityObjectToClipPos (v.vertex);
	o.uv = v.uv;
	//VertexFactory
	return o;
	}
	float4 frag(VertexOutput i) : SV_Target
	{
	
    float2 q = i.uv/1;
    float2 p = -1.0 + 2.0 * q;
    p.x *= 1/1;

    float r = length( p );
    float a = atan2(p.y,p.x);
    float3 col = float3( 1.0, 1.0, 1.0 );
    
    float ss = 0.5 + 0.5 * sin(7.0 * _Time.y);
    float anim = 1.0 + 0.1 * ss * clamp(1 - r, 0.0 , 1.0);
    r*= anim;
    
    if(r < 0.8)
    {
        col = float3(0.0, 0.3, 0.4);
        float f = fbm(5 * p);
        col = lerp(col, float3(0.2,0.5,0.4),f);
        
        f = 1.0 - smoothstep(0.2, 0.5, r);
        col = lerp(col, float3(0.9,0.6,0.2),f);
        
        a += 0.05 * fbm(20.0 * p);
        f = smoothstep(0.3, 1.0, fbm(float2(6.0 * r, 20.0 * a)));
        col = lerp(col, float3(1.0,1.0,1.0),f);
        
        f = smoothstep(0.4, 0.9, fbm(float2(10.0 * r, 15.0 * a)));
        col *= 1.0 - 0.5 * f;
        f = smoothstep(0.6, 0.8, r);
        col *= 1.0 - 0.5 * f;
        f = smoothstep(0.2, 0.25, r);
        col *= f;
        f = 1.0 - smoothstep(0.0, 0.5 ,length(p - float2(0.24, 0.2))); 
        col += float3(1.0, 0.9, 0.8) * f * 0.9; 
        f = smoothstep(0.75, 0.8, r);
        col = lerp(col, float3(1.0,1.0,1.0),f);
        //col /= 2.2;
    }
    	return float4( col, 1.0 );
    	
	}
	ENDCG
	}
  }
}

