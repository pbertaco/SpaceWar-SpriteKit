//
//  SocialScene.swift
//  Game
//
//  Created by Paulo Henrique dos Santos on 31/05/16.
//  Copyright © 2016 PabloHenri91. All rights reserved.
//

import SpriteKit
import FBSDKLoginKit
import FBSDKShareKit


class SocialScene: GameScene {
    
    var playerData = MemoryCard.sharedInstance.playerData
    
     var buttonInvite:Button!
    
    //facebook Request
    var after:String = ""
    var idFriendArray = NSMutableArray()
    var idFriendPushArray = NSMutableArray()
    var blockedArray = NSMutableArray()
    var nameFriendArray = NSMutableArray()
    var picsArray = NSMutableArray()
    var loadingImage:SKSpriteNode!
    var fbID: String!
    var picNodes = Array<Control>()

    
    lazy var deathEffect:SKAction = {
        return SKAction.repeatActionForever(SKAction.rotateByAngle(CGFloat(M_PI * 2), duration: 1))
    }()
    
    enum states : String {
        //Estado principal
        case normal
        
        //Estados de saida da scene
        case mothership
        
        //Estado de convidar amigos
        case invite
    }
    
    //Estados iniciais
    var state = states.normal
    var nextState = states.normal
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        self.buttonInvite = Button(textureName: "button", text: "invite", x: 93, y: 247, xAlign: .center, yAlign: .center)
        self.addChild(self.buttonInvite)
        
        print((self.view?.window?.rootViewController))
        
       

    }
    

    override func update(currentTime: NSTimeInterval) {
        super.update(currentTime)
        
        if(self.state == self.nextState) {
            //Estado atual
            switch (self.state) {
                
                
            default:
                break
            }
        } else {
            //Próximo estado
            switch (self.nextState) {
                
            case states.invite:
                
                self.loadingImage = SKSpriteNode(imageNamed: "circleLoading")
                self.loadingImage.position = CGPoint(x: 1334/4, y: -750/4)
                self.addChild(self.loadingImage)
                
                self.loadingImage.runAction(self.deathEffect)
                
                self.blackSpriteNode.hidden = false
                self.blackSpriteNode.zPosition = 1000
                self.loadingImage.zPosition = self.blackSpriteNode.zPosition + 1
                
                //self.inviteFriends(nil, limit: 50)
                
                break
                
            case states.normal:
                self.blackSpriteNode.hidden = true
                
                if let teste = self.loadingImage {
                    teste.removeFromParent()
                }
                
                break

                
            case .mothership:
                self.view?.presentScene(MothershipScene(), transition: self.transition)
                break
            default:
                #if DEBUG
                    fatalError()
                #endif
                break
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>) {
        super.touchesEnded(touches)
        
        //Estado atual
        if(self.state == self.nextState) {
            for touch in touches {
                switch (self.state) {
                case states.normal:
                    if(self.buttonInvite.containsPoint(touch.locationInNode(self))) {
                       FacebookGameInviter.sharedInstance.invite()
                        return
                    }
                    break
                    
                default:
                    break
                }
            }
        }
        
    }
    
       
       
}