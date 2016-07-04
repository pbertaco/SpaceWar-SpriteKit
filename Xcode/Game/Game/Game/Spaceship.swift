//
//  Spaceship.swift
//  Game
//
//  Created by Pablo Henrique Bertaco on 5/19/16.
//  Copyright © 2016 PabloHenri91. All rights reserved.
//

import SpriteKit

class Spaceship: Control {
    
    static var selectedSpaceship:Spaceship?
    
    var type:SpaceShipType!
    var level:Int!
    
    //Vida e Escudo de Energia
    var health:Int!
    var maxHealth:Int!
    var energyShield:Int!
    var maxEnergyShield:Int!

    
    var speedAtribute:Int!
    var shieldPower:Int!
    var shieldRecharge:Int!
    
    var weapon:Weapon?
    var weaponRangeBonus:CGFloat = 0
    
    var spaceshipData:SpaceshipData?
    
    var spriteNode:SKSpriteNode!
    
    var targetNode:SKNode?
    
    //Movement
    var destination = CGPoint.zero
    var needToMove = false
    var rotationToDestination:CGFloat = 0
    var totalRotationToDestination:CGFloat = 0
    var startingPosition = CGPoint.zero
    
    var maxAngularVelocity:CGFloat = 3
    var force:CGFloat = 20
    var angularImpulse:CGFloat = 0.0005
    var maxVelocitySquared:CGFloat = 0
    
    var isInsideAMothership = true
    
    var healthBar:HealthBar!
    var weaponRangeSprite:SKShapeNode!
    
    override var description: String {
        return "\nSpaceship\n" +
            "level: " + level.description + "\n" +
            "health: " + health.description  + "\n" +
            "maxHealth: " + maxHealth.description  + "\n" +
            "energyShield: " + energyShield.description  + "\n" +
            "maxEnergyShield: " + maxEnergyShield.description  + "\n" +
            "speedAtribute: " + speedAtribute.description  + "\n" +
            "shieldPower: " + shieldPower.description  + "\n" +
            "shieldRecharge: " + shieldRecharge.description  + "\n"
    }

    
    override init() {
        fatalError("NÃO IMPLEMENTADO")
    }
    
    init(type:Int, level:Int) {
        super.init()
        self.load(type: type, level: level)
    }
    
    init(spaceshipData:SpaceshipData) {
        super.init()
        self.spaceshipData = spaceshipData
        self.load(type: spaceshipData.type.integerValue, level: spaceshipData.level.integerValue)
        
        if let weaponData = spaceshipData.weapons.anyObject() as? WeaponData {
            self.weapon = (Weapon(weaponData: weaponData))
        }
        
        if let weapon = self.weapon {
            self.addChild(weapon)
        }
    }
    
    func loadHealthBar(gameWorld:GameWorld, borderColor:SKColor) {
        self.healthBar = HealthBar(size: self.calculateAccumulatedFrame().size, borderColor: borderColor)
        gameWorld.addChild(self.healthBar)
    }
    
    func loadWeaponRangeSprite(gameWorld:GameWorld) {
        if let weapon = self.weapon {
            self.weaponRangeSprite = SKShapeNode(circleOfRadius: weapon.rangeInPoints)
            self.weaponRangeSprite.strokeColor = SKColor.whiteColor()
            self.weaponRangeSprite.fillColor = SKColor.clearColor()
            self.weaponRangeSprite.position = self.position
            self.weaponRangeSprite.alpha = 0
            gameWorld.addChild(self.weaponRangeSprite)
        }
    }
    
    func showWeaponRangeSprite() {
        self.weaponRangeSprite.alpha = 1
    }
    
    func loadAllyDetails() {
        let spriteNode = SKSpriteNode(imageNamed: "spaceshipAlly")
        spriteNode.texture?.filteringMode = Display.filteringMode
        self.spriteNode.addChild(spriteNode)
    }
    
    func loadEnemyDetails() {
        let spriteNode = SKSpriteNode(imageNamed: "spaceshipEnemy")
        spriteNode.texture?.filteringMode = Display.filteringMode
        self.spriteNode.addChild(spriteNode)
    }
    
    func increaseTouchArea() {
        let spriteNodeTest = SKSpriteNode(color: SKColor.clearColor(), size: CGSize(width: 64, height: 64))
        spriteNodeTest.texture?.filteringMode = Display.filteringMode
        self.spriteNode.addChild(spriteNodeTest)
    }
    
    private func load(type type:Int, level:Int) {
        
        self.type = Spaceship.types[type]
        
        self.level = level
        
        self.speedAtribute = GameMath.spaceshipSpeedAtribute(level: self.level, type: self.type)
        self.health = GameMath.spaceshipMaxHealth(level: self.level, type: self.type)
        self.maxHealth = health
        self.shieldPower = GameMath.spaceshipShieldPower(level: self.level, type: self.type)
        self.shieldRecharge = GameMath.spaceshipShieldRecharge(level: self.level, type: self.type)
        
        self.energyShield = GameMath.spaceshipShieldPower(level: self.level, type: self.type)
        self.maxEnergyShield = energyShield
        
        //Gráfico
        self.spriteNode = SKSpriteNode(imageNamed: GameMath.spaceshipSkinImageName(level: self.level, type: self.type))
        self.spriteNode.texture?.filteringMode = Display.filteringMode
        self.addChild(self.spriteNode)
        
        self.weaponRangeBonus = self.spriteNode.size.height/2
        
        self.loadPhysics(rectangleOfSize: self.spriteNode.size)
        
        self.increaseTouchArea()
    }
    
    func loadPhysics(rectangleOfSize size:CGSize) {
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.physicsBody?.dynamic = false
        
        self.setBitMasksToMothershipSpaceship()
        
        self.physicsBody?.linearDamping = 2
        self.physicsBody?.angularDamping = 2
        self.physicsBody?.friction = 0
        
        self.maxVelocitySquared = GameMath.spaceshipMaxVelocitySquared(speed: self.speedAtribute)
        self.force = self.maxVelocitySquared / 60
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMoveArrowToDestination() {
        let spriteNode = SKSpriteNode(imageNamed: "moveArrows")
        spriteNode.position = self.destination
        self.parent?.addChild(spriteNode)
        
        spriteNode.runAction(SKAction.resizeToWidth(0, height: 1, duration: 0.5))
        spriteNode.runAction(SKAction.fadeOutWithDuration(0.5), completion: { [weak spriteNode] in
            spriteNode?.removeFromParent()
        })
        self.showWeaponRangeSprite()
    }
    
    func touchEnded() {
        
        if self == Spaceship.selectedSpaceship {
            //esqueca o que está fazendo
            self.targetNode = nil
            self.needToMove = false
            self.showWeaponRangeSprite()
            
        } else {
            if let spaceship = Spaceship.selectedSpaceship {
                //TODO: Quebrou aqui
                spaceship.spriteNode.color = SKColor.blackColor()
                spaceship.spriteNode.colorBlendFactor = 0
            }
            
            if self.health > 0 {
                Spaceship.selectedSpaceship = self
                self.showWeaponRangeSprite()
                
                self.physicsBody?.dynamic = true
                self.spriteNode.color = SKColor.blackColor()
                self.spriteNode.colorBlendFactor = 0.5
            }
        }
    }
    
    static func touchEnded(touch: UITouch) {
        if let spaceship = Spaceship.selectedSpaceship {
            if let parent = spaceship.parent {
                
                //Precisa mover, esqueca o que está fazendo
                spaceship.targetNode = nil
                
                spaceship.destination = touch.locationInNode(parent)
                spaceship.needToMove = true
                spaceship.setMoveArrowToDestination()
            }
        }
    }
    
    static func retreat() {
        if let spaceship = Spaceship.selectedSpaceship {
            //Precisa mover, esqueca o que está fazendo
            spaceship.targetNode = nil
            
            spaceship.destination = spaceship.startingPosition
            spaceship.needToMove = true
            
            spaceship.spriteNode.color = SKColor.blackColor()
            spaceship.spriteNode.colorBlendFactor = 0
            
            spaceship.setBitMasksToMothershipSpaceship()
        }
        
        Spaceship.selectedSpaceship = nil
    }
    
    func update(enemyMothership enemyMothership:Mothership, enemySpaceships:[Spaceship], allySpaceships:[Spaceship]) {
        
        self.move(enemyMothership: enemyMothership, enemySpaceships: enemySpaceships, allySpaceships:allySpaceships)
        
        self.healthBar.updateUp(position: self.position)
        
        //TODO: exportar para função
        //TODO: Quebrou aqui se nave nao tiver arma equipada
        self.weaponRangeSprite.position = self.position
        if self.weaponRangeSprite.alpha > 0 {
            self.weaponRangeSprite.alpha -= 0.01666666667
        }
        //
    }
    
    func setBitMasksToMothershipSpaceship() {
        self.physicsBody?.categoryBitMask = GameWorld.categoryBitMask.mothershipSpaceship.rawValue
        self.physicsBody?.collisionBitMask = GameWorld.collisionBitMask.mothershipSpaceship
        self.physicsBody?.contactTestBitMask = GameWorld.contactTestBitMask.mothershipSpaceship
    }
    
    func setBitMasksToSpaceship() {
        self.physicsBody?.categoryBitMask = GameWorld.categoryBitMask.spaceship.rawValue
        self.physicsBody?.collisionBitMask = GameWorld.collisionBitMask.spaceship
        self.physicsBody?.contactTestBitMask = GameWorld.contactTestBitMask.spaceship
    }
    
    func resetToStartingPosition() {
        self.position = self.startingPosition
        self.zRotation = 0
        self.physicsBody?.velocity = CGVector.zero
        self.physicsBody?.angularVelocity = 0
        self.physicsBody?.dynamic = false
    }
    
    func canBeTarget(spaceship:Spaceship) -> Bool {
        
        if let spaceshipWeapon = spaceship.weapon {
            let range = spaceshipWeapon.rangeInPoints + spaceship.weaponRangeBonus
            if CGPoint.distance(self.position, spaceship.position) > range {
                return false
            }
        } else {
            return false
        }
        
        if self.isInsideAMothership {
            return false
        }
        
        if self.health <= 0 {
            return false
        }
        
        return true
    }
    
    func nearestTarget(enemyMothership enemyMothership:Mothership, enemySpaceships:[Spaceship]) -> SKNode? {
        
        var currentTarget:SKNode? = nil
        
        for targetPriorityType in self.type.targetPriority {
            switch targetPriorityType {
            case TargetType.spaceships:
                for enemySpaceship in enemySpaceships {
                    
                    if enemySpaceship.canBeTarget(self) {
                        
                        if currentTarget != nil {
                            if CGPoint.distanceSquared(self.destination, enemySpaceship.position) < CGPoint.distanceSquared(self.position, currentTarget!.position) {
                                currentTarget = enemySpaceship
                            }
                        } else {
                            currentTarget = enemySpaceship
                        }
                        
                    }
                }
                break
                
            case TargetType.mothership:
                if enemyMothership.canBeTarget(self) {
                    currentTarget = enemyMothership
                }
                break
                
            default:
                break
            }
            
            if currentTarget != nil {
                break
            }
        }
        
        return currentTarget
    }
    
    func fire(allySpaceships allySpaceships:[Spaceship]) {
        var canfire = true
        
        for allySpaceship in allySpaceships {
            
            if allySpaceship != self {
                if CGPoint.distanceSquared(self.position, allySpaceship.position) < CGPoint.distanceSquared(self.position, self.targetNode!.position) {
                    let point = allySpaceship.position
                    let dx = Float(point.x - self.position.x)
                    let dy = Float(point.y - self.position.y)
                    
                    let rotationToDestination = CGFloat(-atan2f(dx, dy))
                    
                    var totalRotationToDestination = rotationToDestination - self.zRotation
                    
                    while(totalRotationToDestination < -CGFloat(M_PI)) { totalRotationToDestination += CGFloat(M_PI * 2) }
                    while(totalRotationToDestination >  CGFloat(M_PI)) { totalRotationToDestination -= CGFloat(M_PI * 2) }
                    
                    if abs(totalRotationToDestination) <= 0.2 {
                        canfire = false
                        break
                    }
                }
            }
        }
        
        if canfire {
            self.weapon?.fire(self.weaponRangeBonus)
        }
        
    }
    
    func getShot(shot:Shot?) {
        if let someShot = shot {
            self.health = self.health - someShot.damage
            someShot.damage = 0
            someShot.removeFromParent()
            
            self.healthBar.update(self.health, maxHealth: self.maxHealth)
        }
    }
    
    func move(enemyMothership enemyMothership:Mothership, enemySpaceships:[Spaceship], allySpaceships:[Spaceship]) {
       
        if self.health > 0 {
            if (self.needToMove) {

                if CGPoint.distanceSquared(self.position, self.destination) < 1024 {
               
                    self.needToMove = false
                    
                    if self.destination == self.startingPosition {
                        self.resetToStartingPosition()
                    } else {
                        if !self.isInsideAMothership {
                            self.targetNode = self.nearestTarget(enemyMothership: enemyMothership, enemySpaceships: enemySpaceships)
                        }
                    }
                    
                } else {
    
                    self.rotateToPoint(self.destination)
                    
                    
                    if let physicsBody = self.physicsBody {
                        
                        if abs(self.totalRotationToDestination) <= 1 {
                            let velocitySquared = (physicsBody.velocity.dx * physicsBody.velocity.dx) + (physicsBody.velocity.dy * physicsBody.velocity.dy)
                           
                            if velocitySquared < self.maxVelocitySquared {
                                self.physicsBody?.applyForce(CGVector(dx: -sin(self.zRotation) * self.force, dy: cos(self.zRotation) * self.force))
                            }
                        }
                    }
                }
                
            } else {
                
                if let targetNode = self.targetNode {
                    
                    if let mothership = targetNode as? Mothership {
                        if mothership.health <= 0 {
                            self.targetNode = nil
                        } else {
                            self.rotateToPoint(targetNode.position)
                            if abs(self.totalRotationToDestination) <= 0.1 {
                                self.fire(allySpaceships: allySpaceships)
                            }
                        }
                    }
                    
                    if let spaceship = targetNode as? Spaceship {
                        
                        if !spaceship.canBeTarget(self) {
                            self.targetNode = nil
                        } else {
                            self.rotateToPoint(targetNode.position)
                            if abs(self.totalRotationToDestination) <= 0.1 {
                                self.fire(allySpaceships: allySpaceships)
                            }
                        }
                    }
                    
                } else {
                    if !self.isInsideAMothership {
                        self.targetNode = self.nearestTarget(enemyMothership: enemyMothership, enemySpaceships: enemySpaceships)
                    }
                }
            }
        }
    }
    
    func rotateToPoint(point:CGPoint) {
        
        if let physicsBody = self.physicsBody {
            
            let dx = Float(point.x - self.position.x)
            let dy = Float(point.y - self.position.y)
            
            self.rotationToDestination = CGFloat(-atan2f(dx, dy))
            
            if(abs(physicsBody.angularVelocity) < self.maxAngularVelocity) {
                
                self.totalRotationToDestination = self.rotationToDestination - self.zRotation
                
                while(self.totalRotationToDestination < -CGFloat(M_PI)) { self.totalRotationToDestination += CGFloat(M_PI * 2) }
                while(self.totalRotationToDestination >  CGFloat(M_PI)) { self.totalRotationToDestination -= CGFloat(M_PI * 2) }
                
                physicsBody.applyAngularImpulse(self.totalRotationToDestination * self.angularImpulse)
            }
        }
    }
    
    func didBeginContact(otherPhysicsBody:SKPhysicsBody, contact: SKPhysicsContact) {
        if let myPhysicsBody = self.physicsBody {
            
            switch myPhysicsBody.categoryBitMask {
                
            case GameWorld.categoryBitMask.spaceship.rawValue:
                {
                    switch otherPhysicsBody.categoryBitMask {
                        
                    default:
                        #if DEBUG
                            fatalError()
                        #endif
                        break
                    }
                }()
                break
                
            case GameWorld.categoryBitMask.mothershipSpaceship.rawValue:
                {
                    switch otherPhysicsBody.categoryBitMask {
                        
                    case GameWorld.categoryBitMask.mothership.rawValue:
                        self.isInsideAMothership = true
                        break
                        
                    default:
                        #if DEBUG
                            fatalError()
                        #endif
                        break
                    }
                }()
                break
                
            default:
                #if DEBUG
                    fatalError()
                #endif
                break
            }
        }
    }
    
    func didEndContact(otherPhysicsBody:SKPhysicsBody, contact: SKPhysicsContact) {
        
        if let myPhysicsBody = self.physicsBody {
            
            switch myPhysicsBody.categoryBitMask {
                
            case GameWorld.categoryBitMask.spaceship.rawValue:
                {
                    switch otherPhysicsBody.categoryBitMask {
                    case GameWorld.categoryBitMask.spaceshipShot.rawValue:
                        (otherPhysicsBody.node as? Shot)?.resetBitMasks()
                        break
                        
                    default:
                        #if DEBUG
                            fatalError()
                        #endif
                        break
                    }
                }()
                break
                
            case GameWorld.categoryBitMask.mothershipSpaceship.rawValue:
                {
                    switch otherPhysicsBody.categoryBitMask {
                        
                    case GameWorld.categoryBitMask.mothership.rawValue:
                        self.isInsideAMothership = false
                        if self.destination != self.startingPosition {
                            self.setBitMasksToSpaceship()
                        }
                        break
                        
                    default:
                        #if DEBUG
                            fatalError()
                        #endif
                        break
                    }
                }()
                break
                
            default:
                #if DEBUG
                    fatalError()
                #endif
                break
            }
        }
    }
    
    func addWeapon(weapon:Weapon) {
        self.weapon = weapon
        
        if let spaceshipData = self.spaceshipData {
            if let weaponData = weapon.weaponData {
                spaceshipData.addWeaponData(weaponData)
                if let player = spaceshipData.parentPlayer {
                    player.removeWeaponData(weaponData)
                }
            }
        }
    }
    
    func removeWeapon(weapon:Weapon) {
        self.weapon = nil
        
        if let spaceshipData = self.spaceshipData {
            if let weaponData = weapon.weaponData {
                spaceshipData.removeWeaponData(weaponData)
                if let player = spaceshipData.parentPlayer {
                    player.addWeaponData(weaponData)
                }
            }
        }
    }
    
    func updateSpaceshipData() {
        if let spaceshipData = self.spaceshipData {
            spaceshipData.level = self.level
        }
    }
    
    func upgrade() {
        if let spaceshipData = self.spaceshipData {
            
            spaceshipData.level = NSNumber(integer: spaceshipData.level.integerValue + 1)
            self.level = spaceshipData.level.integerValue
            
        }
    }
}

public enum TargetType:Int {
    case mothership
    case spaceships
    case towers
}

public enum RarityType:Int {
    case commom
    case rare
    case epic
    case legendary
}

class SpaceShipType {
    
    var rarity: RarityType!
    
    var skins = [String]()
    
    var maxLevel:Int
    
    var targetPriority:[TargetType]
    
    var name:String = ""
    var spaceshipDescription:String = ""
    
    var speedBonus:Int
    var healthBonus:Int
    var shieldPowerBonus:Int
    var shieldRechargeBonus:Int
    
    var index:Int!


    
    init(maxLevel:Int, targetPriorityType:Int, speed:Int, health:Int, shieldPower:Int, shieldRecharge:Int) {
        
        self.maxLevel = maxLevel
        
        self.targetPriority = Spaceship.targetPriorityTypes[targetPriorityType]
        
        self.speedBonus = speed
        self.healthBonus = health
        self.shieldPowerBonus = shieldPower
        self.shieldRechargeBonus = shieldRecharge

    }
}

extension Spaceship {
    
    static var targetPriorityTypes = [
        [TargetType.spaceships, TargetType.towers, TargetType.mothership],
        
        [TargetType.towers, TargetType.mothership]
    ]
    
    static var types:[SpaceShipType] = [
        {
            let spaceShipType = SpaceShipType(maxLevel: 100, targetPriorityType: 0,
                speed: 10, health: 5, shieldPower: 5, shieldRecharge: 5)
            spaceShipType.skins = [
                "spaceshipBA",
                "spaceshipBB"
            ]
            spaceShipType.name = "Space Speeder"
            spaceShipType.spaceshipDescription = "A very fast Spaceship"
            spaceShipType.rarity = .commom
            spaceShipType.index = 0
            return spaceShipType
        }(),
        
        {
            let spaceShipType = SpaceShipType(maxLevel: 100, targetPriorityType: 0,
            speed: 5, health: 10, shieldPower: 5, shieldRecharge: 5)
            spaceShipType.skins = [
                "spaceshipAA",
                "spaceshipAB"
            ]
            spaceShipType.name = "Space tanker"
            spaceShipType.spaceshipDescription = "Can hold a great amount of damage"
            spaceShipType.rarity = .commom
            spaceShipType.index = 1
            return spaceShipType
        }(),
        
        {
            let spaceShipType = SpaceShipType(maxLevel: 100, targetPriorityType: 0,
            speed: 5, health: 5, shieldPower: 10, shieldRecharge: 5)
            spaceShipType.skins = [
                "spaceshipCA",
                "spaceshipCB"
            ]
            
            spaceShipType.name = "Space Shielder"
            spaceShipType.spaceshipDescription = "Have the best defense"
            spaceShipType.rarity = .commom
            spaceShipType.index = 2
            return spaceShipType
        }(),
        
        {
            let spaceShipType = SpaceShipType(maxLevel: 100, targetPriorityType: 0,
                speed: 5, health: 5, shieldPower: 5, shieldRecharge: 10)
            spaceShipType.skins = [
                "spaceshipFA",
                "spaceshipFB"
            ]
            
            spaceShipType.name = "Space Techno"
            spaceShipType.spaceshipDescription = "Recharge your defanse in the light speed"
            spaceShipType.rarity = .commom
            spaceShipType.index = 3
            return spaceShipType
        }()
    ]
}
