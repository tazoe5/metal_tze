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
func calcRungeKutta(ps: DoublePendulumStruct) -> DoublePendulumStruct {
    var ps = ps
    let g: Float = 9.8
    // calc delta^2 theta0
    let term11 = (-2*ps.l[1]*pow(ps.dtheta[1], 2)*sin(ps.theta[0] - ps.theta[1]) - (2 + ps.m[0]/ps.m[1])*g*sin(ps.theta[0]))
    let term12 = 2*(g*sin(ps.theta[1] - 2*ps.l[0]*pow(ps.dtheta[0], 2)*sin(ps.theta[0] - ps.theta[1])*cos(ps.theta[0] - ps.theta[1])))
    let term13 = ps.l[0]*(ps.m[0]/ps.m[1] + 4*pow(sin(ps.theta[0] - ps.theta[1]), 2))
    let ddtheta0 = (term11+term12) / term13
    
    // calc delta^2 theta1
    let term21 = (4 + ps.m[0]/ps.m[1])*(2*ps.l[0]*pow(ps.theta[0], 2)*sin(ps.theta[0] - ps.theta[1]) - g*sin(ps.theta[1]))
    let term22 = 2*((2 + ps.m[0]/ps.m[1])*g*sin(ps.theta[0]) + 2*ps.l[1]*pow(ps.dtheta[1], 2)*sin(ps.theta[0] - ps.theta[1])*cos(ps.theta[0] - ps.theta[1]))
    let term23 = ps.l[1]*(ps.m[0]/ps.m[1] + 4*pow(sin(ps.theta[0] - ps.theta[1]), 2))
    let ddtheta1 = (term21+term22) / term23
    
    // calc delta theta
    ps.dtheta[0] += ddtheta0
    ps.dtheta[1] += ddtheta1
    ps.theta[0] += ps.dtheta[0]
    ps.theta[1] += ps.dtheta[1]
    return ps
}

func calcDoublePendulumPosition(doublePendulumStruct ps: DoublePendulumStruct) -> float3x4 {
    let first = float4(0.0, 0.0, 0.0, 1.0)
    let second = float4(ps.l[0]*cos(ps.theta[0]), ps.l[0]*sin(ps.theta[0]), 0.0, 1.0)
    let third = float4(second[0] + ps.l[1]*cos(ps.theta[1]), second[1] + ps.l[1]*sin(ps.theta[1]), 0.0, 1.0)
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
