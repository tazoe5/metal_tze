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

// Computation
