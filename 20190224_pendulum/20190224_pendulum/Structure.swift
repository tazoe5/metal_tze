//
//  Structure.swift
//  20190224_pendulum
//
//  Created by Kouhei Tazoe on 2019/02/24.
//  Copyright © 2019年 Kouhei Tazoe. All rights reserved.
//

import MetalKit

struct Pendulum {
    var position: float3x4
    var color: float4
}

func createPendulum(length: Float, theta1: Float, theta2: Float, color: float4) -> Pendulum {
    let pos1 = float4(0.0, 0.0, 0.0, 1.0)
    let pos2 = float4(length*cos(theta1), length*sin(theta1), 0.0, 1.0)
    let pos3 = float4(pos2[0] + length*cos(theta2), pos2[1] + length*sin(theta2), 0.0, 1.0)
    let pendulum = Pendulum(position: float3x4([pos1, pos2, pos3]), color: color)
    return pendulum
}

struct PendulumStruct {
    var m: float3 = float3(1.0, 1.0, 1.0)
    var l: float2 = float2(0.4, 0.4)
    var theta: float3 = float3(3.0, 3.5, 1.5)
    var dtheta: float3 = float3(0.8, 0.5, -9.0)
}

//Kinetic Energy
func calcT(ps: PendulumStruct) -> Float {
    return (1/6*ps.m[0] + 1/2*ps.m[1] + 1/2*ps.m[2])*ps.l[0]*ps.l[0]*ps.theta[0]*ps.theta[0]
        + (1/6*ps.m[1] + 1/2*ps.m[2]) * ps.l[1]*ps.l[1] * ps.theta[1]*ps.theta[1]
        + (1/6*ps.m[2]) * ps.l[2]
}
