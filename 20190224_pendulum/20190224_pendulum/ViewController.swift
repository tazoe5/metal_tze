//
//  ViewController.swift
//  20190224_pendulum
//
//  Created by Kouhei Tazoe on 2019/02/24.
//  Copyright © 2019年 Kouhei Tazoe. All rights reserved.
//

import MetalKit

class ViewController: NSViewController {
    var renderer: Renderer!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Metal で使用可能なGPUかどうかを判定．なければエラー
        guard let metalView = view as? MTKView else { fatalError("metal view not set up in StoryBoard.")}
        // 描画について　(Renderer.swift)
        renderer = Renderer(metalView: metalView)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}
