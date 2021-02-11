//
//  CaptureViewController.swift
//  ExampleOfiOSLiDAR
//
//  Created by TokyoYoshida on 2021/02/10.
//

import RealityKit
import ARKit

class CaptureViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet var arView: ARView!
    
    var orientation: UIInterfaceOrientation {
        guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else {
            fatalError()
        }
        return orientation
    }
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    lazy var imageViewSize: CGSize = {
        CGSize(width: view.bounds.size.width, height: imageViewHeight.constant)
    }()

    override func viewDidLoad() {
        func setARViewOptions() {
            arView.debugOptions.insert(.showSceneUnderstanding)
        }
        func buildConfigure() -> ARWorldTrackingConfiguration {
            let configuration = ARWorldTrackingConfiguration()

            configuration.environmentTexturing = .automatic
            configuration.sceneReconstruction = .mesh
            if type(of: configuration).supportsFrameSemantics(.sceneDepth) {
               configuration.frameSemantics = .sceneDepth
            }

            return configuration
        }
        func initARView() {
            setARViewOptions()
            let configuration = buildConfigure()
            arView.session.run(configuration)
        }
        func addGesture() {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            arView.addGestureRecognizer(tapRecognizer)
        }
        arView.session.delegate = self
        super.viewDidLoad()
        initARView()
        addGesture()
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
    }
    
    @objc
    func handleTap(_ sender: UITapGestureRecognizer) {
        exportMesh()
//        guard let frame = arView.session.currentFrame else {return}
//        guard let device = MTLCreateSystemDefaultDevice() else {
//                    return
//                }
//
//        let meshAnchors = frame.anchors.compactMap({ $0 as? ARMeshAnchor }) as [ARMeshAnchor]
//        print(meshAnchors[0].geometry.toMDLMesh(device: device))
    }
    
    func exportMesh() {
        let meshAnchors = arView.session.currentFrame?.anchors.compactMap({ $0 as? ARMeshAnchor });

        DispatchQueue.global().async {

            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0];
            let filename = directory.appendingPathComponent("MyFirstMesh.obj");

            guard let device = MTLCreateSystemDefaultDevice() else {
                print("metal device could not be created");
                return;
            };

            let asset = MDLAsset();

            for anchor in meshAnchors! {
                let mdlMesh = anchor.geometry.toMDLMesh(device: device);
                asset.add(mdlMesh);
            }

            do {
                try asset.export(to: filename);
            } catch {
                print("failed to write to file");
            }
        }
    }
}
