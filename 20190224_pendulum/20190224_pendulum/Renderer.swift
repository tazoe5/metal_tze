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
    var pendulumData: [Pendulum]!
    var pendulumBuffer: MTLBuffer!
    
    // Data oto draw pendulums?
    
    init(metalView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice() else { fatalError("GPU is not abailable")}
        metalView.device = device
        super.init()
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
        metalView.delegate = self
        // 振り子の座標と色を定義
        
        let size: Float = 0.4
        
        /*
         let pendulum = Pendulum(position: float3x4([float4(0.0, 0.0, 0.0, 1.0),
         float4(0.3*size, 0.5*size, 0.0, 1.0),
         float4(-0.2*size, 0.8*size, 0.0, 1.0)]),
         color: float4(1.0, 0.0, 0.0, 1.0))
         */
        pendulumData = [createPendulum(length: size, theta1: 0.4*Float.pi, theta2: 0.3*Float.pi,
                                       color: float4(1.0, 0.0, 0.0, 1.0)),
                        createPendulum(length: size, theta1: 0.8*Float.pi, theta2: 0.5*Float.pi,
                                       color: float4(0.0, 1.0, 0.0, 1.0))]
        
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
                                           length: MemoryLayout<Pendulum>.stride * pendulumData.count,
                                           options: [])
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
            let renderPassDescriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            else { return }
        
        // write drawing code in the below
        renderEncoder.setRenderPipelineState(renderPipelineState)
        renderEncoder.setVertexBuffer(pendulumBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .line,
                                     vertexStart: 0,
                                     vertexCount: pendulumData.count*4)
        // write drawing code in the aboce
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
