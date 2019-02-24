//
//  Compute.swift
//  20190224_pendulum
//
//  Created by Kouhei Tazoe on 2019/02/24.
//  Copyright © 2019年 Kouhei Tazoe. All rights reserved.
//

import MetalKit

// for caluclate each point movement
class Compute: NSObject {
    var commandQueue: MTLCommandQueue!
    var computePipelineState: MTLComputePipelineState!
    var timer: Float = 0
    init(device: MTLDevice) {
        super.init()
    }
    
    private func createCommandQueue(device: MTLDevice) {
        commandQueue = device.makeCommandQueue()
    }
    
    private func createComputePipelineState(device: MTLDevice) {
        guard let library = device.makeDefaultLibrary() else { return }
        let cs_function = library.makeFunction(name: "compute")!
        do {
            computePipelineState = try device.makeComputePipelineState(function: cs_function)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func update() {
        timer += 0.1
    }
    func compute(pendulumBuffer: MTLBuffer, numPendulum: Int) {
        guard let computeCommandBuffer = commandQueue.makeCommandBuffer(),
            let computeCommandEncoder = computeCommandBuffer.makeComputeCommandEncoder()
            else { return }
        
        update()
        computeCommandEncoder.setBuffer(pendulumBuffer, offset:0, index: 0)
        
        computeCommandEncoder.endEncoding()
        computeCommandBuffer.commit()
        computeCommandBuffer.waitUntilCompleted()
    }
    func calulatePos(pendulum: DoublePendulum) -> DoublePendulum {
        return pendulum
    }
}
