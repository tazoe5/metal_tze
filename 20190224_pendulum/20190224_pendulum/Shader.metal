//
//  Shader.metal
//  20190224_pendulum
//
//  Created by Kouhei Tazoe on 2019/02/24.
//  Copyright © 2019年 Kouhei Tazoe. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3x4 position;
    float4 color;
};

struct floatPendulumStruct {
    float2 l;
    float2 m;
    float2 theta;
    float2 dtheta;
};

struct VertexOut { // from vertex function to fragment function
    float4 position [[ position ]];
    float4 color;
    float pointsize [[ point_size ]];
};

vertex VertexOut vertex_main(const device VertexIn *pendulumData [[ buffer(0) ]],
                             uint vertexID [[ vertex_id ]]) {
    VertexOut vOut;
    int pendulumID = vertexID / 4;
    int pointIndex = vertexID % 4;
    if (pointIndex == 2) {
        pointIndex = 1;
    } else if (pointIndex == 3) {
        pointIndex = 2;
    }
    // pendulum 中のどのインデックスかを計算
    
    
    vOut.position = float4(pendulumData[pendulumID].position[pointIndex]);
    vOut.color = pendulumData[pendulumID].color;
    vOut.pointsize = 20;
    return vOut;
}

fragment float4 fragment_main(VertexOut vIn [[ stage_in ]]) {
    return vIn.color;
}

kernel void calcRungeKutta(const device floatPendulumStruct *ps) {
    float dt = 0.02;
    float g = 9.8;
    // calc delta^2 theta0
    float a1 = (ps->m[0] + ps->m[1])*ps->l[0]*ps->l[0];
    float a2 = ps->m[1]*ps->l[1]*ps->l[1];
        
    float b = ps->m[1]*ps->l[0]*ps->l[1]*cos(ps->theta[0] - ps->theta[1]);
    float d1 = -ps->m[1]*ps->l[0]*ps->l[1]*ps->dtheta[1]*ps->dtheta[1]*sin(ps->theta[0] - ps->theta[1]) - (ps->m[0] + ps->m[1]) * g * ps->l[0]*sin(ps->theta[0]);
    float d2 = ps->m[1]*ps->l[0]*ps->l[1] * ps->dtheta[0]*ps->dtheta[0]*sin(ps->theta[0] - ps->theta[1]) - ps->m[1]*g*ps->l[1]*sin(ps->theta[1]);
        
    float ddtheta0 = (a2*d1 - b*d2) / (a1*a2 - b*b);
    float ddtheta1 = (a1*d2 - b*d1) / (a1*a2 - b*b);
    // calc delta theta
    ps->dtheta[0] += ddtheta0*dt;
    ps->dtheta[1] += ddtheta1*dt;
    ps->theta[0] += ps->dtheta[0]*dt;
    ps->theta[1] += ps->dtheta[1]*dt;
};
// Computation

