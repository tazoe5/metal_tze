//
//  Structure.swift
//  20190224_pendulum
//
//  Created by Kouhei Tazoe on 2019/02/24.
//  Copyright © 2019年 Kouhei Tazoe. All rights reserved.
//

import MetalKit
import Cocoa

struct DoublePendulum {
    var position:float3x4
    var color: float4
}

func createDoublePendulum(length: Float, theta1: Float, theta2: Float, color: float4) -> DoublePendulum {
    let pos1 = float4(0.0, 0.0, 0.0, 1.0)
    let pos2 = float4(length*cos(theta1), length*sin(theta1), 0.0, 1.0)
    let pos3 = float4(pos2[0] + length*cos(theta2), pos2[1] + length*sin(theta2), 0.0, 1.0)
    let pendulum = DoublePendulum(position: float3x4([pos1, pos2, pos3]), color: color)
    return pendulum
}

struct DoublePendulumStruct {
    var m: float2
    var l: float2
    var theta: float2
    var dtheta: float2
}

//Kinetic Energy
func calcRungeKutta(doublePendulumStruct ps: DoublePendulumStruct, dt: Float) -> DoublePendulumStruct {
    var ps = ps
    let g: Float = 9.8
    // calc delta^2 theta0
    let a1 = (ps.m[0] + ps.m[1])*ps.l[0]*ps.l[0]
    let a2 = ps.m[1]*ps.l[1]*ps.l[1]
    
    let b = ps.m[1]*ps.l[0]*ps.l[1]*cos(ps.theta[0] - ps.theta[1])
    let d1 = -ps.m[1]*ps.l[0]*ps.l[1]*ps.dtheta[1]*ps.dtheta[1]*sin(ps.theta[0] - ps.theta[1]) - (ps.m[0] + ps.m[1]) * g * ps.l[0]*sin(ps.theta[0])
    let d2 = ps.m[1]*ps.l[0]*ps.l[1] * ps.dtheta[0]*ps.dtheta[0]*sin(ps.theta[0] - ps.theta[1]) - ps.m[1]*g*ps.l[1]*sin(ps.theta[1])
    
    let ddtheta0 = (a2*d1 - b*d2) / (a1*a2 - b*b)
    if ((a1*a2 - b*b) == 0 ){
        print("0 division")
        
    }
    let ddtheta1 = (a1*d2 - b*d1) / (a1*a2 - b*b)

    // calc delta theta
    ps.dtheta[0] += ddtheta0*dt
    ps.dtheta[1] += ddtheta1*dt
    ps.theta[0] += ps.dtheta[0]*dt
    ps.theta[1] += ps.dtheta[1]*dt
    return ps
}

func calcDoublePendulumPosition(doublePendulumStruct ps: DoublePendulumStruct) -> float3x4 {
    let theta0 = ps.theta[0] - Float.pi
    let theta1 = ps.theta[1] - Float.pi
    
    let first = float4(0.0, 0.0, 0.0, 1.0)
    let second = float4(ps.l[0]*sin(theta0), ps.l[0]*cos(theta0), 0.0, 1.0)
    let third = float4(second[0] + ps.l[1]*sin(theta1), second[1] + ps.l[1]*cos(theta1), 0.0, 1.0)
    return float3x4(columns: (first, second, third))
}

func calcDoubleL(ps: DoublePendulumStruct) -> Float {
    let g: Float = 9.8
    let term1 = 1/2*ps.m[0]*pow(ps.l[0]*ps.dtheta[0], 2)
    let term2 = 1/2*ps.m[1]*(pow(ps.l[0]*ps.dtheta[0], 2) + pow(ps.l[1]*ps.dtheta[1], 2) + 2*ps.l[0]*ps.l[1]*ps.dtheta[2]*ps.dtheta[1]*cos(ps.theta[0] - ps.theta[1]))
    let term3 = ps.m[0]*g*ps.l[0]*cos(ps.theta[0])
    let term4 = ps.m[1]*g*(ps.l[0]*cos(ps.theta[0]) + ps.l[1]*cos(ps.theta[1]))
    let lagrangian: Float = term1 + term2 + term3 + term4
    return Float(lagrangian)
}
