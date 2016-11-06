//
//  CanvasViewController.swift
//  Canvas
//
//  Created by Akash Ungarala on 11/6/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit

class CanvasViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var trayView: UIView!
    @IBOutlet weak var downArrowImageView: UIImageView!
    
    var trayOriginalCenter: CGPoint!
    var trayCenterWhenOpen: CGPoint!
    var trayCenterWhenClose: CGPoint!
    var newlyCreatedFace: UIImageView!
    var smileyOriginalCenter: CGPoint!
    var smileyRotation:CGFloat!
    var smileyScale:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trayCenterWhenOpen = CGPoint.init(x: trayView.center.x, y: view.frame.size.height - (trayView.frame.size.height/2))
        trayCenterWhenClose = CGPoint.init(x: trayView.center.x, y: view.frame.size.height + (trayView.frame.size.height/2) - 40)
        trayView.center = trayCenterWhenClose
        self.downArrowImageView.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
    }
    
    @IBAction func onTrayPanGesture(_ sender: UIPanGestureRecognizer) {
        _ = sender.location(in: view)
        _ = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        if sender.state == .began {
            trayOriginalCenter = trayView.center
        } else if sender.state == .ended {
            if (velocity.y > 0) { //moving down
                UIView.animate(withDuration: 0.3, animations: {
                    self.trayView.center = self.trayCenterWhenClose
                    self.downArrowImageView.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
                })
            } else { //moving up
                UIView.animate(withDuration: 0.3, animations: {
                    self.trayView.center = self.trayCenterWhenOpen
                    self.downArrowImageView.transform = CGAffineTransform.init(rotationAngle: 0)
                })
            }
        }
    }
    
    @IBAction func onSmileyPanGesture(_ sender: UIPanGestureRecognizer) {
        _ = sender.location(in: view)
        let translation = sender.translation(in: view)
        _ = sender.velocity(in: view)
        if sender.state == .began {
            let imageView = sender.view as! UIImageView
            newlyCreatedFace = UIImageView(image: imageView.image)
            view.addSubview(newlyCreatedFace)
            newlyCreatedFace.center = imageView.center
            newlyCreatedFace.center.y += trayView.frame.origin.y
            smileyOriginalCenter = newlyCreatedFace.center
            newlyCreatedFace.isUserInteractionEnabled = true
            newlyCreatedFace.isMultipleTouchEnabled = true
            UIView.animate(withDuration: 0.1, animations: {
                self.newlyCreatedFace.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            })
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(CanvasViewController.newFacePanned))
            panGestureRecognizer.delegate = self
            newlyCreatedFace.addGestureRecognizer(panGestureRecognizer)
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(CanvasViewController.newFacePinched))
            pinchGestureRecognizer.delegate = self
            newlyCreatedFace.addGestureRecognizer(pinchGestureRecognizer)
            let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(CanvasViewController.newFaceRotated))
            rotationGestureRecognizer.delegate = self
            newlyCreatedFace.addGestureRecognizer(rotationGestureRecognizer)
        } else if sender.state == .changed {
            newlyCreatedFace.center = CGPoint.init(x: smileyOriginalCenter.x + translation.x, y: smileyOriginalCenter.y + translation.y)
        } else if sender.state == .ended {
            UIView.animate(withDuration: 0.1, animations: {
                self.newlyCreatedFace.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func newFacePanned(sender: UIPanGestureRecognizer) {
        _ = sender.location(in: view)
        let translation = sender.translation(in: view)
        _ = sender.velocity(in: view)
        if sender.state == .began {
            smileyOriginalCenter = sender.view?.center
        } else if sender.state == .changed {
            sender.view?.center = CGPoint(x: smileyOriginalCenter.x + translation.x, y: smileyOriginalCenter.y + translation.y)
        }
    }
    
    func newFacePinched(sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        if sender.state == .changed {
            smileyScale = scale
            handlePinchNRotate()
        }
    }
    
    func newFaceRotated(sender: UIRotationGestureRecognizer) {
        let rotation = sender.rotation
        if sender.state == .changed {
            smileyRotation = rotation
            handlePinchNRotate()
        }
    }
    
    func handlePinchNRotate() {
        var transform = CGAffineTransform.identity
        if let smileyRotation = smileyRotation {
            transform = transform.rotated(by: smileyRotation)
        }
        if let smileyScale = smileyScale {
            transform = transform.scaledBy(x: smileyScale, y: smileyScale)
        }
        UIView.animate(withDuration: 0.1, animations: {
            self.newlyCreatedFace.transform = transform
        })
    }
    
}
