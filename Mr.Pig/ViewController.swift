//
//  ViewController.swift
//  Mr.Pig
//
//  Created by Andrew Campbell on 13/06/2016.
//  Copyright © 2016 Andrew Campbell. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit

class ViewController: UIViewController {

    let game = GameHelper.sharedInstance
    var scnView:SCNView!
    
    var gameScene:SCNScene!
    var splashScene:SCNScene!
    
    var pigNode: SCNNode!
    var cameraNode: SCNNode!
    var cameraFollowNode: SCNNode!
    var lightFollowNode: SCNNode!
    var trafficNode: SCNNode!
    var wolfNode: SCNNode! //developmental
    
    var collisionNode: SCNNode!
    var frontCollisionNode: SCNNode!
    var backCollisionNode: SCNNode!
    var leftCollisionNode: SCNNode!
    var rightCollisionNode: SCNNode!
    
    var driveLeftAction: SCNAction!
    var driveRightAction: SCNAction!
    var jumpLeftAction: SCNAction!
    var jumpRightAction: SCNAction!
    var jumpForwardAction: SCNAction!
    var jumpBackwardAction: SCNAction!
    var triggerGameOver: SCNAction!
    
//    //wolf developmental
    var jumpUpAndDownAction: SCNAction!
    
    let BitMaskPig = 1
    let BitMaskVehicle = 2
    let BitMaskObstacle = 4
    let BitMaskFront = 8
    let BitMaskBack = 16
    let BitMaskLeft = 32
    let BitMaskRight = 64
    let BitMaskCoin = 128
    let BitMaskHouse = 256
    
    let BitMaskWolf = 3 //developmental
    
    var activeCollisionsBitMask: Int = 0
    var wolfInitialPosition:SCNVector3!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScenes()
        setupNodes()
        setupActions()
        setupTraffic()
        setupGestures()
        setupSounds()
        
        game.state = .tapToPlay
    }
    
    func setupScenes() {
        scnView = SCNView(frame: self.view.frame)
        self.view.addSubview(scnView)
        gameScene = SCNScene(named: "/MrPig.scnassets/GameScene.scn")
        splashScene = SCNScene(named: "/MrPig.scnassets/SplashScene.scn")
        
        scnView.scene = splashScene
        
        scnView.delegate = self
        gameScene.physicsWorld.contactDelegate = self
        
    }
    
    func setupNodes() {
        pigNode = gameScene.rootNode.childNode(withName: "MrPig", recursively:
            true)!
        cameraNode = gameScene.rootNode.childNode(withName: "camera", recursively: true)!
        cameraNode.addChildNode(game.hudNode)
        cameraFollowNode = gameScene.rootNode.childNode(withName: "FollowCamera", recursively: true)!
        lightFollowNode = gameScene.rootNode.childNode(withName: "FollowLight",
                                                               recursively: true)!
        trafficNode = gameScene.rootNode.childNode(withName: "Traffic", recursively: true)!
        
        collisionNode = gameScene.rootNode.childNode(withName: "Collision",
                                                             recursively: true)!
        frontCollisionNode = gameScene.rootNode.childNode(withName: "Front",
                                                                  recursively: true)!
        backCollisionNode = gameScene.rootNode.childNode(withName: "Back",
                                                                 recursively: true)!
        leftCollisionNode = gameScene.rootNode.childNode(withName: "Left",
                                                                 recursively: true)!
        rightCollisionNode = gameScene.rootNode.childNode(withName: "Right",
                                                                  recursively: true)!
        
        wolfNode = gameScene.rootNode.childNode(withName: "Wolfs", recursively:
            true)!.childNodes[0]  // developmental
        
        // 1
        pigNode.physicsBody?.contactTestBitMask = BitMaskVehicle | BitMaskCoin |
        BitMaskHouse | BitMaskWolf //Wolf is developmental
        // 2
        frontCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
        backCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
        leftCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
        rightCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
        
        wolfInitialPosition = SCNVector3Make(-5,0,-17)
    }
    
    func setupActions() {
        //cars
        driveLeftAction =
            SCNAction.repeatForever(SCNAction.move(by: SCNVector3Make(-2.0, 0,
                0), duration: 1.0))
        driveRightAction =
            SCNAction.repeatForever(SCNAction.move(by: SCNVector3Make(2.0, 0, 0),
                duration: 1.0))
        
        
        //Pig
        // 1
        let duration = 0.2
        // 2
        let bounceUpAction = SCNAction.moveBy(x: 0, y: 1.0, z: 0, duration:
            duration * 0.5)
        let bounceDownAction = SCNAction.moveBy(x: 0, y: -1.0, z: 0, duration:
            duration * 0.5)
        // 3
        bounceUpAction.timingMode = .easeOut
        bounceDownAction.timingMode = .easeIn
        // 4
        let bounceAction = SCNAction.sequence([bounceUpAction, bounceDownAction])
        // 5
        let moveLeftAction = SCNAction.moveBy(x: -1.0, y: 0, z: 0, duration:
            duration)
        let moveRightAction = SCNAction.moveBy(x: 1.0, y: 0, z: 0, duration:
            duration)
        let moveForwardAction = SCNAction.moveBy(x: 0, y: 0, z: -1.0, duration:
            duration)
        let moveBackwardAction = SCNAction.moveBy(x: 0, y: 0, z: 1.0, duration:
            duration)
        // 6
        let turnLeftAction = SCNAction.rotateTo(x: 0, y: convertToRadians(-90), z:0, duration: duration, shortestUnitArc: true)
        let turnRightAction = SCNAction.rotateTo(x: 0, y: convertToRadians(90), z:
            0, duration: duration, shortestUnitArc: true)
        let turnForwardAction = SCNAction.rotateTo(x: 0, y: convertToRadians(180),
                                                    z: 0, duration: duration, shortestUnitArc: true)
        let turnBackwardAction = SCNAction.rotateTo(x: 0, y: convertToRadians(0),
                                                     z: 0, duration: duration, shortestUnitArc: true)
        // 7
        jumpLeftAction = SCNAction.group([turnLeftAction, bounceAction,
            moveLeftAction])
        jumpRightAction = SCNAction.group([turnRightAction, bounceAction,
            moveRightAction])
        jumpForwardAction = SCNAction.group([turnForwardAction, bounceAction,
            moveForwardAction])
        jumpBackwardAction = SCNAction.group([turnBackwardAction, bounceAction,
            moveBackwardAction])
        
        //wolf
        jumpUpAndDownAction = SCNAction.group([turnLeftAction, bounceAction, turnRightAction])
        
        //Gameover
        // 1
        let spinAround = SCNAction.rotateBy(x: 0, y: convertToRadians(720), z: 0,
                                             duration: 2.0)
        let riseUp = SCNAction.moveBy(x: 0, y: 10, z: 0, duration: 2.0)
        let fadeOut = SCNAction.fadeOpacity(to: 0, duration: 2.0)
        let goodByePig = SCNAction.group([spinAround, riseUp, fadeOut])
        // 2
        let gameOver = SCNAction.run { (node:SCNNode) -> Void in
            self.pigNode.position = SCNVector3(x:0, y:0, z:0)
            self.pigNode.opacity = 1.0
            self.cameraFollowNode.position = SCNVector3Make(0, 0, 0)
            self.lightFollowNode.position = self.cameraFollowNode.position
            self.startSplash()
        }
        // 3
        triggerGameOver = SCNAction.sequence([goodByePig, gameOver])
        
    }
    
    func setupTraffic() {
        for node in trafficNode.childNodes {
            //Buses are slow, the rest are speed demons
            if node.name?.contains("Bus") == true {
                driveLeftAction.speed = 1.0
                driveRightAction.speed = 1.0
            } else {
                driveLeftAction.speed = 2.0
                driveRightAction.speed = 2.0
            }
            // Let vehicle drive towards its facing direction
            if node.eulerAngles.y > 0 {
                node.run(driveLeftAction)
            } else {
                node.run(driveRightAction)
            }
        }
    }
    
    func setupGestures() {
        let swipeRight:UISwipeGestureRecognizer =
            UISwipeGestureRecognizer(target: self, action:
                #selector(ViewController.handleGesture(_:)))
        swipeRight.direction = .right
        scnView.addGestureRecognizer(swipeRight)
        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target:
            self, action: #selector(ViewController.handleGesture(_:)))
        swipeLeft.direction = .left
        scnView.addGestureRecognizer(swipeLeft)
        let swipeForward:UISwipeGestureRecognizer =
            UISwipeGestureRecognizer(target: self, action:
                #selector(ViewController.handleGesture(_:)))
        swipeForward.direction = .up
        scnView.addGestureRecognizer(swipeForward)
        let swipeBackward:UISwipeGestureRecognizer =
            UISwipeGestureRecognizer(target: self, action:
                #selector(ViewController.handleGesture(_:)))
        swipeBackward.direction = .down
        scnView.addGestureRecognizer(swipeBackward)
    }
    
    func setupSounds() {
        // 1
        if game.state == .tapToPlay {
            // 2
            let music = SCNAudioSource(fileNamed: "MrPig.scnassets/Audio/Music.mp3")!
                // 3
                music.volume = 0.3
                music.loops = true
                music.shouldStream = true
                music.isPositional = false
            // 4
            let musicPlayer = SCNAudioPlayer(source: music)
            // 5
            splashScene.rootNode.addAudioPlayer(musicPlayer)
        } else if game.state == .playing {
            // 2
            let traffic = SCNAudioSource(fileNamed: "MrPig.scnassets/Audio/Traffic.mp3")!
                traffic.volume = 0.3
                traffic.loops = true
                traffic.shouldStream = true
                traffic.isPositional = true
            // 3
            let trafficPlayer = SCNAudioPlayer(source: traffic)
            gameScene.rootNode.addAudioPlayer(trafficPlayer)
            // 4
            game.loadSound("Jump", fileNamed: "MrPig.scnassets/Audio/Jump.wav")
            game.loadSound("Blocked", fileNamed: "MrPig.scnassets/Audio/Blocked.wav")
            game.loadSound("Crash", fileNamed: "MrPig.scnassets/Audio/Crash.wav")
            game.loadSound("CollectCoin", fileNamed: "MrPig.scnassets/Audio/CollectCoin.wav")
            game.loadSound("BankCoin", fileNamed: "MrPig.scnassets/Audio/BankCoin.wav")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event:
        UIEvent?) {
        if game.state == .tapToPlay {
            startGame()
        }
    }
    
    func startGame() {
        splashScene.isPaused = true

        let transition = SKTransition.doorsOpenVertical(withDuration: 1.0)

        scnView.present(gameScene, with: transition,
                             incomingPointOfView: nil, completionHandler: {
                                // 4
                                self.game.state = .playing
                                self.setupSounds()
                                self.gameScene.isPaused = false
        }) }
    
    func stopGame() {
        game.state = .gameOver
        game.reset()
        pigNode.run(triggerGameOver)
    }
    
    func startSplash() {
        gameScene.isPaused = true
        
        let transition = SKTransition.doorsOpenVertical(withDuration: 1.0)
        scnView.present(splashScene, with: transition,
                             incomingPointOfView: nil, completionHandler: {
                                self.game.state = .tapToPlay
                                self.setupSounds()
                                self.splashScene.isPaused = false
        })
    }
    
    // 1
    func handleGesture(_ sender:UISwipeGestureRecognizer){
        // 2
        guard game.state == .playing else {
            return
        }
        
        // 1
        let activeFrontCollision = activeCollisionsBitMask & BitMaskFront ==
        BitMaskFront
        let activeBackCollision = activeCollisionsBitMask & BitMaskBack ==
        BitMaskBack
        let activeLeftCollision = activeCollisionsBitMask & BitMaskLeft ==
        BitMaskLeft
        let activeRightCollision = activeCollisionsBitMask & BitMaskRight ==
        BitMaskRight
        
        // 2
        guard (sender.direction == .up && !activeFrontCollision) ||
            (sender.direction == .down && !activeBackCollision) ||
            (sender.direction == .left && !activeLeftCollision) ||
            (sender.direction == .right && !activeRightCollision) else {
                game.playSound(pigNode, name: "Blocked")
                return
        }
        
        // 3
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.up:
            pigNode.run(jumpForwardAction)
        case UISwipeGestureRecognizerDirection.down:
            pigNode.run(jumpBackwardAction)
        case UISwipeGestureRecognizerDirection.left:
            if pigNode.position.x >  -15 {
                pigNode.run(jumpLeftAction)
            }
        case UISwipeGestureRecognizerDirection.right:
            if pigNode.position.x < 15 {
                pigNode.run(jumpRightAction)}
        default:
            break
        }
        game.playSound(pigNode, name: "Jump")
    }
    
    func updatePositions() {
        collisionNode.position = pigNode.presentation.position
        let lerpX = (pigNode.position.x - cameraFollowNode.position.x) * 0.05
        let lerpZ = (pigNode.position.z - cameraFollowNode.position.z) * 0.05
        cameraFollowNode.position.x += lerpX
        cameraFollowNode.position.z += lerpZ
        
        lightFollowNode.position = cameraFollowNode.position
    }
    
    func updateTraffic() {
        // 1
        for node in trafficNode.childNodes {
            // 2
            if node.position.x > 25 {
                node.position.x = -25
            } else if node.position.x < -25 {
                node.position.x = 25
            }
        }
    }
    
    //Developmental
    func updateWolf() {
        // if the wolf is in the camera view, and the is within bounds (for pig and wolf) start heading towards the pig
        let nodesInView = scnView.nodesInsideFrustum(withPointOfView: cameraNode)
        if nodesInView.contains(wolfNode){
            
            // turn wolf towards and move towards pig
            if pigNode.position.isInsideWolfPatrolBounds(){
                let yAngle = atan2f((pigNode.position.x - wolfNode.position.x), (pigNode.position.z - wolfNode.position.z))
                wolfNode.run(SCNAction.rotateTo(x: 0, y: CGFloat(yAngle), z: 0, duration: 0.2, shortestUnitArc: true))
                wolfNode.run(SCNAction.move(to: pigNode.position, duration: 2.0))
            }
        } else {
            wolfNode.run(SCNAction.move(to: wolfInitialPosition, duration: 2.0))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
}

extension ViewController : SCNSceneRendererDelegate {
    // 2
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime
        time: TimeInterval) {
        // 3
        guard game.state == .playing else {
            return
        }
        
        game.updateHUD()
        
        updatePositions()
        
        updateTraffic()
        
        updateWolf() // developmental
    }
}

extension ViewController : SCNPhysicsContactDelegate {
    // 2
    func physicsWorld(_ world: SCNPhysicsWorld,
                      didBegin contact: SCNPhysicsContact) {
        // 3
        guard game.state == .playing else {
            return
        }
        // 4
        var collisionBoxNode: SCNNode!
        if contact.nodeA.physicsBody?.categoryBitMask == BitMaskObstacle {
            collisionBoxNode = contact.nodeB
        } else {
            collisionBoxNode = contact.nodeA
        }
        // 5
        activeCollisionsBitMask |=
            collisionBoxNode.physicsBody!.categoryBitMask
        
        var contactNode: SCNNode!
        if contact.nodeA.physicsBody?.categoryBitMask == BitMaskPig {
            contactNode = contact.nodeB
        } else {
            contactNode = contact.nodeA
        }
        // 2
        if contactNode.physicsBody?.categoryBitMask == BitMaskVehicle {
            game.playSound(pigNode, name: "Crash")
            stopGame()
        }
        
        if contactNode.physicsBody?.categoryBitMask == BitMaskWolf {
            game.playSound(pigNode, name: "Crash")
            wolfNode.run(jumpUpAndDownAction)
            stopGame()
        }
        
        // 1
        if contactNode.physicsBody?.categoryBitMask == BitMaskCoin {
            // 2
            contactNode.isHidden = true
            contactNode.run(SCNAction.waitForDurationThenRunBlock(60)
            { (node: SCNNode!) -> Void in
                node.isHidden = false
                })
            // 3
            game.playSound(pigNode, name: "CollectCoin")
            game.collectCoin()
        }
        
        if contactNode.physicsBody?.categoryBitMask == BitMaskHouse {
            if game.bankCoins() == true {
                game.playSound(pigNode, name: "BankCoin")
            }
        }
        
    }
    // 6
    func physicsWorld(_ world: SCNPhysicsWorld,
                      didEnd contact: SCNPhysicsContact) {
        // 8
        guard game.state == .playing else {
            return
        }
        // 8
        var collisionBoxNode: SCNNode!
        if contact.nodeA.physicsBody?.categoryBitMask == BitMaskObstacle {
            collisionBoxNode = contact.nodeB
        } else {
            collisionBoxNode = contact.nodeA
        }
        // 9
        activeCollisionsBitMask &=
            ~collisionBoxNode.physicsBody!.categoryBitMask
    }
}

extension SCNVector3{
    
    enum wolfBounds : Float{
        case left = -18
        case right = 0
        case top = -14
        case bottom = -22
    }
    
    func isInsideWolfPatrolBounds() -> Bool{
        return (self.x < wolfBounds.right.rawValue && self.x > wolfBounds.left.rawValue) && (self.z < wolfBounds.top.rawValue && self.z > wolfBounds.bottom.rawValue)
    }
}

