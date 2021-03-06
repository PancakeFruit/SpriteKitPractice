//
//  GameScene.swift
//  MagicTower
//
//  Created by 胡杨林 on 2017/4/28.
//  Copyright © 2017年 胡杨林. All rights reserved.
//

import SpriteKit
//import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    var List:UIView? = nil
    var btn:UIButton? = nil
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.yellow
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        let jump = UIButton.init(frame: CGRect(x: 50, y: 600, width: 80, height: 30))
        jump.setTitle("跳转", for: .normal)
        jump.addTarget(self, action: #selector(totestScene), for: .touchUpInside)
        self.btn = jump
        self.view?.addSubview(jump)
    }
    func totestScene() {
        let next = testScene(size: (self.view?.frame.size)!)
        self.view?.presentScene(next)
        self.btn?.removeFromSuperview()
    }

    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        if self.List == nil {
            let list = MonsterListView.init(frame: CGRect(x: 15, y: 20, width: 384, height: 300))
            self.List = list
            self.view?.addSubview(self.List!)
            let ges = UITapGestureRecognizer.init(target: self, action: #selector(hiddenList))
            self.List?.addGestureRecognizer(ges)
            //这里验证了这样可以正常添加view并且无需bringyoFront也可以正常显示
//            let view = UIView.init(frame: CGRect(x: 200, y: 200, width: 40, height: 40))
//            view.backgroundColor = SKColor.blue
//            self.view?.addSubview(view)
//            self.view?.bringSubview(toFront: view)
        }
        for t in touches {
            self.touchDown(atPoint: t.location(in: self))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    func hiddenList(){
        self.List?.removeFromSuperview()
        self.List = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
