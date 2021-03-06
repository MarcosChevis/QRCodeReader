//
//  ViewController.swift
//  SwiftUIARView
//
//  Created by Sarang Borude on 4/10/20.
//  Copyright © 2020 Sarang Borude. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SwiftUI
import AVFoundation

class ViewController2: UIViewController, ARSCNViewDelegate {
    
    var string: String
    
    var sceneView: ARSCNView = {
        let s: ARSCNView = .init(frame: .zero)
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
        
    }()
    
    init(string: String) {
        self.string = string
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        self.view.addSubview(sceneView)
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: self.view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)


    // Create a session configuration
        
    let configuration = ARImageTrackingConfiguration()
//        configuration.
        
    if let imagesToTrack = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) {
        
        configuration.trackingImages = imagesToTrack
        
        // this tells ARKit how many images it is supposed to track simultaneously, ARKit can do upto 100
        configuration.maximumNumberOfTrackedImages = 1
    }
       // let videoInput = try AVCaptureDeviceInput(device: sceneView.device)
        
    // Run the view's session
    sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    

     //Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        // Cast the found anchor as image anchor
        guard let imageAnchor = anchor as? ARImageAnchor else { return nil }
        
        // get the name of the image from the anchor
        guard let imageName = imageAnchor.name else { return nil }
        
        // Check if the name of the detected image is the one you want
        if imageName == "Cart" {
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width,
                                 height: imageAnchor.referenceImage.physicalSize.height)
            
            
            let planeNode = SCNNode(geometry: plane)
            // When a plane geometry is created, by default it is oriented vertically
            // so we have to rotate it on X-axis by -90 degrees to
            // make it flat to the image detected
            planeNode.eulerAngles.x = -.pi / 2
            
            createHostingController(for: planeNode)
            
            node.addChildNode(planeNode)
            return node
        } else {
            return nil
        }
    }
    
    func createHostingController(for node: SCNNode) {
        // create a hosting controller with SwiftUI view
        
        guard let url = URL(string: string) else {
            
            print("ruim")
            return
            
        }

        
        // Do this on the main thread
        DispatchQueue.main.async {
            let arVC = UIHostingController(rootView: WebView(url: url))

            arVC.willMove(toParent: self)
            // make the hosting VC a child to the main view controller
            self.addChild(arVC)
            
            // set the pixel size of the Card View
            arVC.view.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
            
            // add the ar card view as a subview to the main view
            self.view.addSubview(arVC.view)
            
            // render the view on the plane geometry as a material
            self.show(hostingVC: arVC, on: node)
        }
    }
    
    func show(hostingVC: UIHostingController<WebView>, on node: SCNNode) {
        // create a new material
        let material = SCNMaterial()
        
        // this allows the card to render transparent parts the right way
        hostingVC.view.isOpaque = false
        
        // set the diffuse of the material to the view of the Hosting View Controller
        material.diffuse.contents = hostingVC.view
        
        // Set the material to the geometry of the node (plane geometry)
        node.geometry?.materials = [material]
        
        hostingVC.view.backgroundColor = UIColor.clear
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}



import WebKit
 
struct WebView: UIViewRepresentable {
 
    var url: URL
 
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
