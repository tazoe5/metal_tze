//
//  Renderer.swift
//  20190224_pendulum
//
//  Created by Kouhei Tazoe on 2019/02/24.
//  Copyright © 2019年 Kouhei Tazoe. All rights reserved.
//

import MetalKit

class Renderer: NSObject {
    // var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState!
    
    // Data of pendulums
    var vertexBuffer: MTLBuffer!
    var colorBuffer: MTLBuffer!
    var pendulumData: [DoublePendulum]!
    var pendulumBuffer: MTLBuffer!
    var pendulumStructData: [DoublePendulumStruct]!
    var pendulumStructBuffer: MTLBuffer!
    
    var pIndex: [UInt16]!
    var lIndex: [UInt16]!
    var pIndexBuffer: MTLBuffer!
    var lIndexBuffer: MTLBuffer!
    
    let N = 10
    let dt: Float = 0.02
    let alpha: Float = 0.000001
    var timer: Int = 0
    // Data oto draw pendulums?
    
    init(metalView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice() else { fatalError("GPU is not abailable")}
        metalView.device = device
        super.init()
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
        metalView.delegate = self
        // 振り子の座標と色を定義
        
        let size: Float = 0.4
        
        pendulumStructData = []
        pendulumData = []
        pIndex = []
        lIndex = []
        
        for i in 0..<N {
            let i = Float(i)
            let ps = DoublePendulumStruct(m: float2(1.0, 2.0),
                                          l: float2(size/3*4, size*3/4),
                                          theta: float2(7/3*Float.pi+alpha*i, 3/4*Float.pi+alpha*i),
                                          dtheta: float2(0.0, 0.0))
            let pendulum = DoublePendulum(position: calcDoublePendulumPosition(doublePendulumStruct: ps),
                                          color: float4(1.0, 0.0, 1.0, 1.0))
            pendulumStructData.append(ps)
            pendulumData.append(pendulum)
            let index = Int(i)
            for j in 0..<4 {
                lIndex.append(UInt16(index*4 + j))
                if j != 2 {
                    pIndex.append(UInt16(index*4 + j))
                }
            }
        }
        /* // Indexを用いて描画しようとした痕跡
        for i in 0..<N {
            eIndex.append(UInt16(i))
            eIndex.append(UInt16(i+1))
        } */
        createCommandQueue(device: device)
        createPipelineState(device: device)
        createBuffer(device: device)
    }
    
    func createCommandQueue(device: MTLDevice) {
        commandQueue = device.makeCommandQueue()
    }
    
    func createPipelineState(device: MTLDevice) {
        let library = device.makeDefaultLibrary()
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        // pipeline state
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func createBuffer(device: MTLDevice) {
        pendulumBuffer = device.makeBuffer(bytes: pendulumData,
                                           length: MemoryLayout<DoublePendulum>.stride * pendulumData.count,
                                           options: [])
        pIndexBuffer = device.makeBuffer(bytes: pIndex,
                                         length: MemoryLayout<UInt16>.stride * pIndex.count)
        lIndexBuffer = device.makeBuffer(bytes: lIndex,
                                         length: MemoryLayout<UInt16>.stride * lIndex.count)
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
        timer += 1
        if timer != 1 && timer < 100 {
            return
        }
        guard let drawable = view.currentDrawable,
            let renderPassDescriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            else { return }
        
        // write drawing code in the below
        for i in 0..<N {
            pendulumStructData[i] = calcRungeKutta(doublePendulumStruct: pendulumStructData[i], dt: dt)
            pendulumData[i].position = calcDoublePendulumPosition(doublePendulumStruct: pendulumStructData[i])
            let bufferDate = pendulumBuffer.contents()
            let nbufferData = bufferDate.bindMemory(to: DoublePendulum.self, capacity: pendulumData.count)
            nbufferData[i].position = pendulumData[i].position
        }
        renderEncoder.setRenderPipelineState(renderPipelineState)
        renderEncoder.setVertexBuffer(pendulumBuffer, offset: 0, index: 0)
        /*
        renderEncoder.drawPrimitives(type: .line,
                                     vertexStart: 0,
                                     vertexCount: pendulumData.count*4)
        renderEncoder.drawPrimitives(type: .point,
                                     vertexStart: 0,
                                     vertexCount: pendulumData.count*4)
        */
        renderEncoder.drawIndexedPrimitives(type: .point,
            indexCount: pIndex.count, indexType: .uint16, indexBuffer: pIndexBuffer, indexBufferOffset: 0)
        renderEncoder.drawIndexedPrimitives(type: .line, indexCount: lIndex.count, indexType: .uint16, indexBuffer: lIndexBuffer, indexBufferOffset: 0)
        // write drawing code in the aboce
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
}
