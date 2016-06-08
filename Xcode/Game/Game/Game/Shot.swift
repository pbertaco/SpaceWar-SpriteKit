//
//  Laser.swift
//  Game
//
//  Created by Pablo Henrique Bertaco on 1/5/16.
//  Copyright © 2016 Pablo Henrique Bertaco. All rights reserved.
//

import SpriteKit

class Shot: Control {
    
    init(texture:SKTexture, position: CGPoint, zRotation: CGFloat, shooterPhysicsBody:SKPhysicsBody) {
        super.init()
        
        let spriteNode = SKSpriteNode(texture: texture)
        spriteNode.texture?.filteringMode = .Linear
        
        self.addChild(spriteNode)
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: spriteNode.size)
        self.physicsBody?.categoryBitMask = GameWorld.categoryBitMask.myShot.rawValue
        self.physicsBody?.collisionBitMask = GameWorld.collisionBitMask.myShot
        self.physicsBody?.contactTestBitMask = GameWorld.contactTestBitMask.myShot
        
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.angularDamping = 0
        
        self.position = position
        self.zRotation = zRotation
        self.physicsBody?.velocity = CGVector(dx: (-sin(zRotation) * 1000) + shooterPhysicsBody.velocity.dx, dy: (cos(zRotation) * 1000) + shooterPhysicsBody.velocity.dy)
        
        self.runAction({ let a = SKAction(); a.duration = 3; return a }()) { [weak self] in
            guard let laser = self else { return }
            laser.removeFromParent()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetBitMasks() {
        self.physicsBody?.categoryBitMask = GameWorld.categoryBitMask.shot.rawValue
        self.physicsBody?.collisionBitMask = GameWorld.collisionBitMask.shot
        self.physicsBody?.contactTestBitMask = GameWorld.contactTestBitMask.shot
    }
}
