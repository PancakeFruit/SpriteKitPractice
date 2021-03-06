//
//  testScene.swift
//  MagicTower
//
//  Created by 胡杨林 on 2017/5/8.
//  Copyright © 2017年 胡杨林. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
//import GameplayKit

class logicMap: NSObject {
    
    static var logic = logicMap.init()
    var Map0:NSMutableArray? = nil
    var Map1:NSMutableArray? = nil
    var Map2:NSMutableArray? = nil
    var Map3:NSMutableArray? = nil
    
    class func shareInstance() -> logicMap{
        return self.logic
    }
    
    func getLogicMap(Floor:Int)->NSMutableArray{
        if Floor == 0 {
            return self.Map0!
        }else if Floor == 1 {
            return self.Map1!
        }else if Floor == 2 {
            return self.Map2!
        }else {
            return self.Map3!
        }
    }
    
    
    override init() {
        super.init()
        self.Map0 = buildLogicMap(MapStr: "00000100000.00000100000.00000100000.00000100000.00000100000.00000100000.00000100000.00001110000.00000100000.00000100000.00000100000")
        self.Map1 = buildLogicMap(MapStr: "11111111111.00000000001.11111011101.11101011101.01001000101.11101111101.11101000001.01001111111.11100100010.11101110111.11101110111")
        self.Map2 = buildLogicMap(MapStr: "10111011110.10101011110.10101011110.10101000010.10101111110.10100100100.11111101110.10100101010.10101101010.10101101010.10101101010")
        self.Map3 = buildLogicMap(MapStr: "11100100000.11101110111.11100100101.01001110101.11100010101.10111110101.10000011101.11111001001.00001011101.01111011101.11000011101")
    }
    
    func buildLogicMap(MapStr:String)->NSMutableArray{
        
        let LogicMapStr = MapStr
        let LogicMaptemp = LogicMapStr.components(separatedBy: ".")
        //        print("\(LogicMaptemp)")
        let LogicMap:NSMutableArray = NSMutableArray.init()
        for line in LogicMaptemp {
            let temp:NSMutableArray = NSMutableArray.init()
            for ch in line.characters {
                let s:String = "\(ch)"
                temp.add(s)
            }
            LogicMap.add(temp)
            //            print("本行分割结果为\(temp)")
        }
        //        print("最终结果为.\(LogicMap)")
        //到这里LogicMap中存在一个正确的二维数组，可用
        //该方法可正确切割汉语字符串为单字
        
        //另外，这里第0行储存的实际是最上面一行的逻辑地图信息，因此需要对LogicMap进行翻转来契合Spritekit坐标系，方便开发
        for i in 0...4 {  //定长11长度的队列
            let temp = LogicMap[i]
            LogicMap[i] = LogicMap[10-i]
            LogicMap[10-i] = temp
        }
        return LogicMap
    }
    
}

class Player: SKSpriteNode {
    static let player = Player.init()
    var Mainscene:testScene? = nil
    //六维属性
    var health:Int = 1000
    var attack:Int = 10
    var defence:Int = 10
    var level:Int = 1
    var experience:Int = 0
    var money:Int = 100
    //钥匙持有量
    var yellowKey:Int = 1
    var blueKey:Int = 1
    var redKey:Int = 1
    //所在地图层数
    var AtFloor:Int = 0
    
    let upA = SKTexture(imageNamed: "f-864.jpg")
    let upB = SKTexture(imageNamed: "f-894.jpg")
    let leftA = SKTexture(imageNamed: "f-862.jpg")
    let leftB = SKTexture(imageNamed: "f-892.jpg")
    let rightA = SKTexture(imageNamed: "f-863.jpg")
    let rightB = SKTexture(imageNamed: "f-893.jpg")
    let downA = SKTexture(imageNamed: "f-865.jpg")
    let downB = SKTexture(imageNamed: "f-895.jpg")
    
    init() {
        super.init(texture: upA, color: SKColor.clear, size: CGSize(width: 32, height: 32))
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.zPosition = 2.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func shareInstance()-> Player{
        return self.player
    }
    
    func moveAction(WithDirection:String, EventNodes:[SKNode]) {
        let P = Player.shareInstance()
        let L = logicMap.shareInstance()
        let LogicMap = L.getLogicMap(Floor: P.AtFloor)  //获取本层逻辑地图
        let playerPosition = P.position
        let line = Int((playerPosition.y - 16) / 32)
        let row = Int((playerPosition.x - 16) / 32)
        
        switch WithDirection {
        case "上":
            print("向上走一步")
            //之所以先变动画后移动是因为你即使是对着墙走了一步，至少也要在屏幕上给予玩家一个操作的反馈
            //因此立绘一定要有所改变，面向或者动画的变化来体现这个操作已经被输入了
            //然后才是判断能否前进是否触发事件等等
            if P.texture == upA {
                let Action = SKAction.setTexture(upB)
                P.run(Action)
            }else{
                let Action = SKAction.setTexture(upA)
                P.run(Action)
            }
            //判断逻辑地图是否允许通过，以及是否存在事件
            if line + 1 > 10 {
                return //到达地图上界
            }
            let a:NSArray = LogicMap[line+1] as! NSArray
            let a1:String = a[row] as! String
            print("取到的逻辑地图值为\(a1)")
            if  a1 == "1"{
                //允许移动
                print("允许移动")
                if  EventNodes.count > 0 {
                    //处理事件
                    print("检测到事件触发点")
                    self.dealEvents(eventNodes: EventNodes)
                }else{
                    //进行移动
                    let move = SKAction.move(by: CGVector(dx: 0, dy: 32), duration: 0.0)
                    P.run(move, completion: {
                        let p2 = P.position
                        print("现在位置坐标为x = \(p2.x) y = \(p2.y)")
                    })
                }
            }else{
                //不可移动
                print("禁止移动")
            }
            
            
            
            
            break
        case "下":
            print("向下走一步")
            if P.texture == downA {
                let Action = SKAction.setTexture(downB)
                P.run(Action)
            }else{
                let Action = SKAction.setTexture(downA)
                P.run(Action)
            }
            if line - 1 < 0 {
                return //到达地图下界
            }
            let a:NSArray = LogicMap[line-1] as! NSArray
            let a1:String = a[row] as! String
            print("取到的逻辑地图值为\(a1)")
            if  a1 == "1"{
                //允许移动
                print("允许移动")
                if  EventNodes.count > 0 {
                    //处理事件
                    print("检测到事件触发点")
                    self.dealEvents(eventNodes: EventNodes)
                }else{
                    //进行移动
                    let move = SKAction.move(by: CGVector(dx: 0, dy: -32), duration: 0.0)
                    P.run(move, completion: {
                        let p2 = P.position
                        print("现在位置坐标为x = \(p2.x) y = \(p2.y)")
                    })
                }
            }else{
                //不可移动
                print("禁止移动")
            }
            break
        case "左":
            print("向左走一步")
            if P.texture == leftA {
                let Action = SKAction.setTexture(leftB)
                P.run(Action)
            }else{
                let Action = SKAction.setTexture(leftA)
                P.run(Action)
            }
            //边缘检测
            if row == 0 {
                return //到达地图左边缘
            }
            
            let a:NSArray = LogicMap[line] as! NSArray
            let a1:String = a[row-1] as! String
            
            print("取到的逻辑地图值为\(a1)")
            if  a1 == "1"{
                //允许移动
                print("允许移动")
                if  EventNodes.count > 0 {
                    //处理事件
                    print("检测到事件触发点")
                    self.dealEvents(eventNodes: EventNodes)
                }else{
                    //进行移动
                    let move = SKAction.move(by: CGVector(dx: -32, dy: 0), duration: 0.0)
                    P.run(move, completion: {
                        let p2 = P.position
                        print("现在位置坐标为x = \(p2.x) y = \(p2.y)")
                    })
                }
            }else{
                //不可移动
                print("禁止移动")
            }
            break
        case "右":
            print("向右走一步")
            if P.texture == rightA {
                let Action = SKAction.setTexture(rightB)
                P.run(Action)
            }else{
                let Action = SKAction.setTexture(rightA)
                P.run(Action)
            }
            
            //边缘检测
            if row == 10 {
                return //到达地图左边缘
            }
            
            let a:NSArray = LogicMap[line] as! NSArray
            let a1:String = a[row+1] as! String
            
            print("取到的逻辑地图值为\(a1)")
            if  a1 == "1"{
                //允许移动
                print("允许移动")
                if  EventNodes.count > 0 {
                    //处理事件
                    print("检测到事件触发点")
                    self.dealEvents(eventNodes: EventNodes)
                }else{
                    //进行移动
                    let move = SKAction.move(by: CGVector(dx: 32, dy: 0), duration: 0.0)
                    P.run(move, completion: {
                        let p2 = P.position
                        print("现在位置坐标为x = \(p2.x) y = \(p2.y)")
                    })
                }
            }else{
                //不可移动
                print("禁止移动")
            }
            break
            
        default:
            break
        }
    }
    
    func dealEvents(eventNodes:[SKNode]) {
        for w in eventNodes {
            if w is GameItem {
                // 类型判断三个写法
                //                w.isMember(of: GameItem.self)
                //                w.isKind(of: GameItem.self)
                //                w is GameItem
                let w2 = w as! GameItem
                w2.ItemEvent()
            }else if w is MonsterNode{
                print("怪物节点")
                self.Mainscene?.isFighting = true
                let a = w as! MonsterNode
                let playerInfo = Player.shareInstance()
                //计算损伤，如果损伤超过玩家现有生命值，同样不触发战斗
                let MonA = a.monsterAttack
                let MonD = a.monsterDefence
                let PlayA = playerInfo.attack
                let PlayD = playerInfo.defence
                
                var damageFlag = true  //用来标记损伤是否超过现有生命值
                
                if PlayA > MonD {  //能打动
                    if PlayD >= MonA {  //自身不破防，0损伤
                        damageFlag = true
                    }else{
                        var D1 = Int(a.monsterHealth / (PlayA - MonD))  //回合数
                        let D2 = a.monsterHealth % (PlayA - MonD)
                        if D2 != 0 {  //如果不是整数倍，回合数+1
                            D1 += 1
                        }
                        let D3 = D1 * (MonA - PlayD)  //计算损伤
                        if D3 >= playerInfo.health {  //超过可承受损伤
                            damageFlag = false
                        }
                        
                    }
                }else{
                    damageFlag = false
                }
                
                if a.monsterDefence >= playerInfo.attack || !damageFlag {
                    let view = refuseView.init(text: "你太弱了，练练再来吧！")
                    let vc = UIApplication.shared.keyWindow?.rootViewController
                    vc?.view.addSubview(view)
                    self.Mainscene?.isFighting = false
                    return
                }else{
                    let model = MonsterModel.init(HeadImage: a.monsterPicture!, Name: a.monsterName, Attack: a.monsterAttack, Defence: a.monsterDefence, Health: a.monsterHealth, Money: a.monsterMoney, Exper: a.monsterExperience)
                    let view = FightCalculateView.showView(Enemy: model)
                    view.frame = CGRect(x: 31, y: 50, width: 352, height: 245)
                    let vc = UIApplication.shared.keyWindow?.rootViewController
                    vc?.view.addSubview(view)
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: { (timer) in
                        let a1 = Int(view.monsterHealth.text!)
                        view.calculate()
                        
                        if a1! <= 0 {
                            timer.invalidate()
                            view.removeFromSuperview()
                            let health = Int(view.playerHealth.text!)
                            playerInfo.health = health!
                            playerInfo.money = playerInfo.money + a.monsterMoney
                            playerInfo.experience = playerInfo.experience + a.monsterExperience
                            w.isHidden = true
                            self.Mainscene?.isFighting = false
                        }
                    })
                    timer.fire()
                    
                }
            }else if w is staircaseNode{  //上下楼节点
                print("楼梯节点")
                let a = w as! staircaseNode
                var floor = 0
                if a.isupstairs == true{  //上楼
                    floor = a.presentFloor + 1
                }else{
                    floor = a.presentFloor - 1
                }
                let floorStr = "mapcover\(floor)"
                self.Mainscene?.map = self.Mainscene?.mapmask?.childNode(withName: floorStr) as? SKSpriteNode  //更换cover层
                let p1 = CGPoint(x: 31 - 352 * floor, y: 364)
                self.Mainscene?.mapmask?.position = p1
                let nodes = self.Mainscene?.map?.children
                for k in nodes! {
                    if k is staircaseNode {  //查询新楼层的楼梯节点，将主角位置移动过去
                        let k2 = k as! staircaseNode
                        if a.isupstairs == true {  //是上楼，查询本层下楼节点
                            if !k2.isupstairs {
                                self.Mainscene?.player?.position = k2.position
                                self.Mainscene?.player?.removeFromParent()
                                self.Mainscene?.map?.addChild((self.Mainscene?.player)!)
                                self.Mainscene?.player?.AtFloor = floor  //更新player模组中所在楼层数据，逻辑地图根据此数据刷新
                                return
                            }
                        }else{  //是下楼，查询新楼层上楼节点
                            if k2.isupstairs {
                                self.Mainscene?.player?.position = k2.position
                                self.Mainscene?.player?.removeFromParent()
                                self.Mainscene?.map?.addChild((self.Mainscene?.player)!)
                                self.Mainscene?.player?.AtFloor = floor  //更新player模组中所在楼层数据，逻辑地图根据此数据刷新
                                return
                            }
                            
                        }
                    }
                }
            }else if w is ShopNode {
                let a = w as! ShopNode
                    //在这里根据节点名字灌输数据来源          
                    let shop = ShopTableView.buildView(NodeName: a.NodeName, isMoneyShop: a.isMoneyShop)
                    let vc = UIApplication.shared.keyWindow?.rootViewController
                    vc?.view.addSubview(shop)

            }
 
        }
    }
    
    
    func updateData(){
        print("刷新数据")  //在player数值改变以后，对界面数据进行刷新
        
    }
    
    
    
}
class FightCalculateView: UIView {
    
    @IBOutlet weak var playerImage: UIImageView!
    @IBOutlet weak var playerHealth: UILabel!
    @IBOutlet weak var playerAttack: UILabel!
    @IBOutlet weak var playerDefence: UILabel!
    
    @IBOutlet weak var monsterImage: UIImageView!
    
    @IBOutlet weak var monsterDefence: UILabel!
    @IBOutlet weak var monsterAttack: UILabel!
    @IBOutlet weak var monsterHealth: UILabel!
    var timer:Timer? = nil
    
    class func showView(Enemy:MonsterModel)->FightCalculateView{
        let view = Bundle.main.loadNibNamed("FightCalculateView", owner: nil, options: nil)?.first as! FightCalculateView
        let player = Player.shareInstance()
        view.playerImage.image = UIImage.init(named: "f-865.jpg")
        view.playerHealth.text = "\(player.health)"
        view.playerAttack.text = "\(player.attack)"
        view.playerDefence.text = "\(player.defence)"
        view.monsterImage.image = Enemy.headImage
        view.monsterHealth.text = Enemy.health
        view.monsterAttack.text = Enemy.attack
        view.monsterDefence.text = Enemy.defence
        return view
    }
    func calculate(){
        
        var ph = Int(self.playerHealth.text!)
        let pa = Int(self.playerAttack.text!)
        let pd = Int(self.playerDefence.text!)
        var mh = Int(self.monsterHealth.text!)
        let ma = Int(self.monsterAttack.text!)
        let md = Int(self.monsterDefence.text!)
        
        var playerdamage:Int = 0
        let monsterdamage:Int = pa! - md!
        if ma! > pd! {
            playerdamage = ma! - pd!
        }
        ph = ph! - playerdamage
        mh = mh! - monsterdamage
        if mh! < 0 {
            mh = 0
        }
        self.playerHealth.text = "\(ph!)"
        self.monsterHealth.text = "\(mh!)"
        
        
        
        
        
        
    }
    
    
    
}

class testScene: SKScene {
    
    var player:Player? = nil
    var map:SKSpriteNode? = nil   //地图层或者地图cover层
    var mapmask:SKNode? = nil    //地图背景层
    var isFighting:Bool = false  //是否战斗中
    var isShowingAlertView:Bool = false //是否在显示警告窗口
    
    override func didMove(to view: SKView) {
        self.buildtestScene()
        self.buildBtn()
        _ = logicMap.init()
        
    }
    
    func buildBtn() {
        //试试画一个扇形的view来制作自定义按钮
        let view = UIView.init(frame: CGRect(x: 20, y: 500, width: 200, height: 200))
        view.backgroundColor = SKColor.white
        self.view?.addSubview(view)
        //        let size =  view.frame.size
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 40))
        path.addLine(to: CGPoint(x: 0, y: 80))
        path.addLine(to: CGPoint(x: 200, y: 80))
        path.addLine(to: CGPoint(x: 200, y: 40))  //右上的点
        path.addQuadCurve(to: CGPoint(x: 0, y: 40), controlPoint: CGPoint(x: 100, y: 0))  //回到左上的点，带上中上的控制点
        let layer = CAShapeLayer.init()
        layer.strokeColor = SKColor.purple.cgColor
        layer.fillColor = SKColor.black.cgColor
        layer.path = path.cgPath
        view.layer.addSublayer(layer)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        let view2 = UIView.init(frame: view.frame)
        view2.backgroundColor = SKColor.red
        //蒙版
        let maskLayer = CAShapeLayer.init()
        maskLayer.fillColor = UIColor.red.cgColor
        maskLayer.frame = view2.frame
        view2.layer.mask = maskLayer
        
        //边框蒙版
        let borderLayer = CAShapeLayer.init()
        //    maskBorderLayer.path = [bezierPath CGPath];
        borderLayer.path = path.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.blue.cgColor //边框颜色
        borderLayer.lineWidth = 2  //边框宽度
        view2.layer.addSublayer(borderLayer)
        view.addSubview(view2)
        view2.addGestureRecognizer(tap)
        
    }
    func tapAction(){
        print("view2被点击了")
    }
    
    func buildtestScene(){
        
        //被吃掉的道具和被击败的怪物已经全面改为isHidden = true  重置地图时遍历子节点全部改false即可
        
        
        //建立地图第0层   除这一层外其他层地图无波动效果不需要这么麻烦
        //这里的地图指的是所有可交互物品全部被清空的地图，包括但不限于 怪物 门 钥匙 道具（血瓶，宝石，剑盾）
        //这些可互动的道具后期作为单独节点进行添加，方便进行移除
        //如果墙壁和道路使用背景图来进行描绘的话，如何进行墙壁的检测？是否加入逻辑地图用来记录地图信息？
        let mapmask = SKCropNode.init()
        let mapmaskwindow = SKSpriteNode.init(color: SKColor.black, size: CGSize(width: 352, height: 352))
        mapmaskwindow.anchorPoint = CGPoint.zero
        mapmaskwindow.position = CGPoint(x: (414 - 352) / 2, y: ((self.view?.frame.size.height)! - 352 - 20))
        mapmask.maskNode = mapmaskwindow
        addChild(mapmask)
        let mapBackgroundNode = SKSpriteNode(color: SKColor.clear, size: CGSize(width: 352.0 * 17, height: 352.0))
        mapBackgroundNode.anchorPoint = CGPoint.zero
        mapBackgroundNode.zPosition = -2.0
        mapBackgroundNode.position = CGPoint(x: (414 - 352) / 2, y: ((self.view?.frame.size.height)! - 352 - 20))
        mapmask.addChild(mapBackgroundNode)
        self.mapmask = mapBackgroundNode
        /*
         地图遮盖  -----   -----    -----   -----   -----
         地图本身  -----   -----    -----   -----   -----
         地图背景  --------------------------------------
         层数跳转的时候移动地图背景，使用向量或者直接设定position，不要使用movetoPoint，会导致以maskwindow参考来移动
         */
        
        //建立第0层地图
        let map = SKSpriteNode(color: SKColor.clear, size: CGSize(width: 352, height: 352))
        map.anchorPoint = CGPoint.zero
        map.zPosition = -1.0
        map.position = CGPoint(x: 0, y: 0)
        let F0A:SKTexture = SKTexture(imageNamed: "Floor0_A")
        let F0B:SKTexture = SKTexture(imageNamed: "Floor0_B")
        let t1 = SKAction.setTexture(F0A)
        let t2 = SKAction.setTexture(F0B)
        let t3 = SKAction.wait(forDuration: 0.8)
        let flash = SKAction.sequence([t1, t3, t2, t3])
        let loop = SKAction.repeatForever(flash)
        map.run(loop)
        self.mapmask?.addChild(map)
        //建立第1层地图
        let map1 = SKSpriteNode.init(color: SKColor.clear, size: CGSize(width: 352, height: 352))
        map1.anchorPoint = CGPoint.zero
        map1.position = CGPoint(x: 352, y: 0)
        map1.texture = SKTexture(imageNamed: "Floor1")
        map1.name = "mapcover1"  //必须设定为"mapcover+数字"形式，否则无法正确寻找
        map1.zPosition = -1.0
        self.mapmask?.addChild(map1)
        self.buildmap1(map1: map1)
        //建立第2层地图
        let map2 = SKSpriteNode.init(color: SKColor.clear, size: CGSize(width: 352, height: 352))
        map2.anchorPoint = CGPoint.zero
        map2.position = CGPoint(x: 352.0 * 2, y: 0)
        map2.texture = SKTexture(imageNamed: "floor2")
        map2.name = "mapcover2"
        map2.zPosition = -1.0
        self.mapmask?.addChild(map2)
        self.buildmap2(map: map2)
        //建立第三层地图
        let map3 = SKSpriteNode.init(color: SKColor.clear, size: CGSize(width: 352, height: 352))
        map3.anchorPoint = CGPoint.zero
        map3.position = CGPoint(x: 352 * 3, y: 0)
        map3.zPosition = -1.0
        map3.name = "mapcover3"
        map3.texture = SKTexture(imageNamed: "floor3")
        self.mapmask?.addChild(map3)
        self.buildmap3(map: map3)
        
        
        
        
        
        
        
        
        
        let mapcover = SKSpriteNode(color: SKColor.clear, size: map.size)
        //仅地图第0层需要用到地图覆盖层，因为背景的纹理置换会导致后添加的子节点被遮盖，其他地图无替换动作不需要这一步
        //map和mapcover都是直接添加到self.mapMask的子节点上，如果不需要双层结构的话可以直接将cover层添加而去掉地图本身
        mapcover.anchorPoint = CGPoint.zero
        mapcover.position = map.position
        mapcover.zPosition = 0.0  //确保cover在地图上方
        mapcover.name = "mapcover0"
        mapBackgroundNode.addChild(mapcover)
        
        //放置玩家节点
        let a1 = Player.shareInstance()
        a1.position = CGPoint(x: 176, y: 16)
        mapcover.addChild(a1)
        self.map = mapcover   //默认初始化游戏之后地图是第零层
        self.player = a1
        a1.Mainscene = self.scene as? testScene
        
        //测试用节点
//        let ItemA = GameItem.buildyellowDoor()
//        ItemA.setPosition(hang: 5, lie: 6)
//        mapcover.addChild(ItemA)
//        let ItemB = GameItem.buildyellowDoor()
//        ItemB.setPosition(hang: 6, lie: 6)
//        mapcover.addChild(ItemB)
        
            //商店节点加载方法
//        let D1 = ShopNode.buildShopNode(isMoneyShop: true, Name: "Floor3Shop")
//        D1.setPosition(hang: 6, lie: 6)
//        mapcover.addChild(D1)
        
        
//                let ItemA = GameItem.buildsmallHealth()
//                ItemA.position = CGPoint(x: 176, y: 208)
//                mapcover.addChild(ItemA)
//                let monA = MonsterNode.buildMonster(Name: "绿头怪", Texture1Name: "f-23.jpg", Texture2Name: "f-53.jpg", Health: 50, Attack: 20, Defence: 1, Money: 1, Exper: 1)
//                monA.position = CGPoint(x: 176, y: 176)
//                mapcover.addChild(monA)
//        
//                let monB = MonsterNode.buildMonster(Name: "红头怪", Texture1Name: "f-24.jpg", Texture2Name: "f-54.jpg", Health: 50, Attack: 11, Defence: 1, Money: 1, Exper: 1)
//                monB.position = CGPoint(x: 176, y: 240)
//                mapcover.addChild(monB)
        
        
        let stairA = staircaseNode.init(presentFloor: 0, position: CGPoint(x: 176, y: 336), isUp: true)
        mapcover.addChild(stairA)
        
        
        
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isFighting || isShowingAlertView {
            return
        }
        for touch in touches {
            let p2 = self.player!.position
            let player = Player.shareInstance()
            print("移动前位置坐标为x = \(p2.x) y = \(p2.y)")
            let location = touch.location(in: self.map!)
            //获取点击位置
            if location.x < 0 || location.x > 352 || location.y < 0 || location.y > 352 {// 这个括号的内容以后会转移到按钮
                print("触摸点不在区域内")
                //展示怪物信息列表
                let list = MonsterListView.init(frame: CGRect(x: 15, y: 20, width: 384, height: 300))
                list.tag = 400
                let map = self.mapmask?.childNode(withName: "mapcover\(player.AtFloor)")
                let mapnode = map!.children
                for node in mapnode {
                    if node is MonsterNode && node.isHidden == false {
                        let node2 = node as! MonsterNode
                        //纹理集中的图片可以使用SKTexture正确读出但是不能用UIImage读出，很奇怪
                        let model = MonsterModel.init(HeadImage:node2.monsterPicture!, Name: node2.monsterName, Attack: node2.monsterAttack, Defence: node2.monsterDefence, Health: node2.monsterHealth, Money: node2.monsterMoney, Exper: node2.monsterExperience)
                        var flag = false
                        for model2 in list.DataArr! {
                            let model3 = model2 as! MonsterModel
                            if model3.name == model.name {
                                flag = true
                            }
                        }
                        if !flag {
                            list.DataArr?.add(model)
                        }
                        
                    }
                }
                let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenInfoList))
                list.addGestureRecognizer(tap)
                self.view?.addSubview(list)
            }else{
                if location.x <= location.y {
                    if location.x + location.y >= 352.0 {  //四分上区域
                        
                        let a = CGPoint(x: p2.x, y: p2.y + 32)
                        let cover = self.mapmask?.childNode(withName: "mapcover\(player.AtFloor)") as! SKSpriteNode
                        let t = cover.nodes(at: a)
                        self.player?.moveAction(WithDirection: "上", EventNodes: t)
                        
                        //下面代码已经废弃，事件处理和逻辑判断均转交player类进行处理，将对应方向的节点传递进去
                        //这里可以顺利检测到player的父节点上的其他子节点并触发事件，且节点hidden后不会继续触发，重置游戏后遍历所有子节点更改为ishidden = false 即可
                        //                        let a = CGPoint(x: p2.x, y: p2.y + 32)
                        //                        let cover = self.childNode(withName: "mapcover") as! SKSpriteNode
                        //                        let t = cover.nodes(at: a)
                        //                        if t.count > 0 {
                        //                            print("检测到事件触发点")
                        //                            for w in t {
                        //                                let w2 = w as! SKSpriteNode
                        //                                w2.isHidden = true
                        //                            }
                        //                        }else{  //如果没有触发事件，则进行移动
                        //                            self.player?.moveAction(WithDirection: "上")  //逻辑地图的判断内置在
                        //                        }
                    }else{  //四分区域左侧
                        let a = CGPoint(x: p2.x - 32, y: p2.y)
                        let cover = self.mapmask?.childNode(withName: "mapcover\(player.AtFloor)") as! SKSpriteNode
                        let t = cover.nodes(at: a)
                        self.player?.moveAction(WithDirection: "左", EventNodes: t)
                    }
                }else{
                    if location.x + location.y >= 352.0 { //四分区域右侧
                        let a = CGPoint(x: p2.x + 32, y: p2.y)
                        let cover = self.mapmask?.childNode(withName: "mapcover\(player.AtFloor)") as! SKSpriteNode
                        let t = cover.nodes(at: a)
                        self.player?.moveAction(WithDirection: "右", EventNodes: t)
                    }else{ //四分区域下侧
                        let a = CGPoint(x: p2.x, y: p2.y - 32)
                        let cover = self.mapmask?.childNode(withName: "mapcover\(player.AtFloor)") as! SKSpriteNode
                        let t = cover.nodes(at: a)
                        self.player?.moveAction(WithDirection: "下", EventNodes: t)
                    }
                }
            }
        }
    }
    
    func hiddenInfoList(){
        let view = self.view?.viewWithTag(400)
        view?.removeFromSuperview()
    }
    
    func buildmap1(map1:SKSpriteNode){
        let downStairs1 = staircaseNode.init(presentFloor: 1, position: CGPoint(x: 176, y: 16), isUp: false)
        map1.addChild(downStairs1)
        let upStairs1 = staircaseNode.init(presentFloor: 1, position: CGPoint(x: 16, y: 336), isUp: true)
        map1.addChild(upStairs1)
        let key1 = GameItem.buildyellowKey()
        key1.setPosition(hang: 11, lie: 3)
        map1.addChild(key1)
        let mon1 = MonsterNode.buildMonster(Name: "绿头怪", Texture1Name: "f-23.jpg", Texture2Name: "f-53.jpg", Health: 50, Attack: 20, Defence: 1, Money: 1, Exper: 1)
        mon1.setPosition(hang: 11, lie: 4)
        map1.addChild(mon1)
        let mon2 = MonsterNode.buildMonster(Name: "红头怪", Texture1Name: "f-20.jpg", Texture2Name: "f-50.jpg", Health: 70, Attack: 15, Defence: 2, Money: 2, Exper: 2)
        mon2.setPosition(hang: 11, lie: 5)
        map1.addChild(mon2)
        let mon3 = MonsterNode.buildMonster(Name: "绿头怪", Texture1Name: "f-23.jpg", Texture2Name: "f-53.jpg", Health: 50, Attack: 20, Defence: 1, Money: 1, Exper: 1)
        mon3.setPosition(hang: 11, lie: 6)
        map1.addChild(mon3)
        let Item1 = GameItem.buildsmallHealth()
        Item1.setPosition(hang: 9, lie: 1)
        map1.addChild(Item1)
        let mon4 = MonsterNode.buildMonster(Name: "骷髅人", Texture1Name: "f-87.jpg", Texture2Name: "f-117.jpg", Health: 110, Attack: 25, Defence: 5, Money: 5, Exper: 4)
        mon4.setPosition(hang: 9, lie: 3)
        map1.addChild(mon4)
        let Item2 = GameItem.buildsmallHealth()
        Item2.setPosition(hang: 9, lie: 7)
        map1.addChild(Item2)
        let Item3 = GameItem.buildsmallHealth()
        Item3.setPosition(hang: 9, lie: 9)
        map1.addChild(Item3)
        let Item4 = GameItem.buildsmallHealth()
        Item4.setPosition(hang: 8, lie: 7)
        map1.addChild(Item4)
        let Item5 = GameItem.buildsmallHealth()
        Item5.setPosition(hang: 8, lie: 9)
        map1.addChild(Item5)
        let Item6 = GameItem.buildyellowKey()
        Item6.setPosition(hang: 8, lie: 1)
        map1.addChild(Item6)
        let Item7 = GameItem.buildattackDiamond()
        Item7.setPosition(hang: 8, lie: 3)
        map1.addChild(Item7)
        let mon5 = MonsterNode.buildMonster(Name: "骷髅人", Texture1Name: "f-87.jpg", Texture2Name: "f-117.jpg", Health: 110, Attack: 25, Defence: 5, Money: 5, Exper: 4)
        mon5.setPosition(hang: 8, lie: 2)
        map1.addChild(mon5)
        let Item8 = GameItem.buildsmallHealth()
        Item8.setPosition(hang: 9, lie: 9)
        map1.addChild(Item8)
        let Item9 = GameItem.buildyellowKey()
        Item9.setPosition(hang: 9, lie: 8)
        map1.addChild(Item9)
        let Item10 = GameItem.buildyellowKey()
        Item10.setPosition(hang: 8, lie: 8)
        map1.addChild(Item10)
        let mon6 = MonsterNode.buildMonster(Name: "骷髅兵", Texture1Name: "f-141.jpg", Texture2Name: "f-171.jpg", Health: 150, Attack: 40, Defence: 20, Money: 8, Exper: 6)
        mon6.setPosition(hang: 6, lie: 2)
        map1.addChild(mon6)
        let Item11 = GameItem.buildyellowKey()
        Item11.setPosition(hang: 6, lie: 1)
        map1.addChild(Item11)
        let Item12 = GameItem.buildDefenceDiamond()
        Item12.setPosition(hang: 5, lie: 1)
        map1.addChild(Item12)
        let Item13 = GameItem.buildblueKey()
        Item13.setPosition(hang: 5, lie: 3)
        map1.addChild(Item13)
        let mon7 = MonsterNode.buildMonster(Name: "骷髅兵", Texture1Name: "f-141.jpg", Texture2Name: "f-171.jpg", Health: 150, Attack: 40, Defence: 20, Money: 8, Exper: 6)
        mon7.setPosition(hang: 3, lie: 2)
        map1.addChild(mon7)
        let Item14 = GameItem.buildsmallHealth()
        Item14.setPosition(hang: 2, lie: 1)
        map1.addChild(Item14)
        let Item15 = GameItem.buildmediumHealth()
        Item15.setPosition(hang: 2, lie: 2)
        map1.addChild(Item15)
        let Item16 = GameItem.buildyellowKey()
        Item16.setPosition(hang: 2, lie: 3)
        map1.addChild(Item16)
        let Item17 = GameItem.buildsmallHealth()
        Item17.setPosition(hang: 1, lie: 1)
        map1.addChild(Item17)
        let Item18 = GameItem.buildbalanceDiamond()
        Item18.setPosition(hang: 1, lie: 2)
        map1.addChild(Item18)
        let Item19 = GameItem.buildyellowKey()
        Item19.setPosition(hang: 1, lie: 3)
        map1.addChild(Item19)
        let Item20 = GameItem.buildredKey()
        Item20.setPosition(hang: 2, lie: 5)
        map1.addChild(Item20)
        let Item21 = GameItem.buildyellowKey()
        Item21.setPosition(hang: 2, lie: 9)
        map1.addChild(Item21)
        let Item22 = GameItem.buildyellowKey()
        Item22.setPosition(hang: 1, lie: 9)
        map1.addChild(Item22)
        let Item23 = GameItem.buildyellowKey()
        Item23.setPosition(hang: 1, lie: 10)
        map1.addChild(Item23)
        let Item24 = GameItem.buildyellowKey()
        Item24.setPosition(hang: 1, lie: 11)
        map1.addChild(Item24)
        let Item25 = GameItem.buildblueKey()
        Item25.setPosition(hang: 2, lie: 11)
        map1.addChild(Item25)
        let Item26 = GameItem.buildyellowDoor()
        Item26.setPosition(hang: 9, lie: 4)
        map1.addChild(Item26)
        let Item27 = GameItem.buildyellowDoor()
        Item27.setPosition(hang: 7, lie: 2)
        map1.addChild(Item27)
        let Item28 = GameItem.buildyellowDoor()
        Item28.setPosition(hang: 4, lie: 2)
        map1.addChild(Item28)
        let Item29 = GameItem.buildredDoor()
        Item29.setPosition(hang: 3, lie: 6)
        map1.addChild(Item29)
        let mon8 = MonsterNode.buildMonster(Name: "小法师", Texture1Name: "f-207.jpg", Texture2Name: "f-237.jpg", Health: 125, Attack: 50, Defence: 25, Money: 10, Exper: 7)
        mon8.setPosition(hang: 6, lie: 7)
        map1.addChild(mon8)
        let mon9 = MonsterNode.buildMonster(Name: "绿头怪", Texture1Name: "f-23.jpg", Texture2Name: "f-53.jpg", Health: 50, Attack: 20, Defence: 1, Money: 1, Exper: 1)
        mon9.setPosition(hang: 6, lie: 8)
        map1.addChild(mon9)
        let mon10 = MonsterNode.buildMonster(Name: "小蝙蝠", Texture1Name: "f-28.jpg", Texture2Name: "f-58.jpg", Health: 100, Attack: 20, Defence: 5, Money: 3, Exper: 3)
        mon10.setPosition(hang: 6, lie: 9)
        map1.addChild(mon10)
        let mon11 = MonsterNode.buildMonster(Name: "青头怪", Texture1Name: "f-26.jpg", Texture2Name: "f-56.jpg", Health: 200, Attack: 35, Defence: 10, Money: 5, Exper: 5)
        mon11.setPosition(hang: 7, lie: 9)
        map1.addChild(mon11)
        let Item30 = GameItem.buildyellowDoor()
        Item30.setPosition(hang: 6, lie: 6)
        map1.addChild(Item30)
        let Item31 = GameItem.buildyellowDoor()
        Item31.setPosition(hang: 3, lie: 10)
        map1.addChild(Item31)
        let mon12 = MonsterNode.buildMonster(Name: "兽面人", Texture1Name: "f-146.jpg", Texture2Name: "f-176.jpg", Health: 300, Attack: 75, Defence: 45, Money: 13, Exper: 10)
        mon12.setPosition(hang: 2, lie: 10)
        map1.addChild(mon12)
        

    }
    
    func buildmap2(map:SKSpriteNode){
        let downStairs1 = staircaseNode.init(presentFloor: 2, position: CGPoint(x: 16, y: 336), isUp: false)
        map.addChild(downStairs1)
        let upStairs1 = staircaseNode.init(presentFloor: 2, position: CGPoint(x: 16, y: 16), isUp: true)
        map.addChild(upStairs1)
        let mon1 = MonsterNode.buildMonster(Name: "金队长", Texture1Name: "f-440.jpg", Texture2Name: "f-470.jpg", Health: 900, Attack: 750, Defence: 650, Money: 77, Exper: 70)
        mon1.setPosition(hang: 11, lie: 4)
        map.addChild(mon1)
        let mon2 = MonsterNode.buildMonster(Name: "金卫士", Texture1Name: "f-441.jpg", Texture2Name: "f-471.jpg", Health: 850, Attack: 350, Defence: 200, Money: 45, Exper: 40)
        mon2.setPosition(hang: 5, lie: 9)
        map.addChild(mon2)
        let mon3 = MonsterNode.buildMonster(Name: "金卫士", Texture1Name: "f-441.jpg", Texture2Name: "f-471.jpg", Health: 850, Attack: 350, Defence: 200, Money: 45, Exper: 40)
        mon3.setPosition(hang: 9, lie: 10)
        map.addChild(mon3)
        let Item1 = GameItem.buildDefenceDiamond()
        Item1.setPosition(hang: 10, lie: 3)
        map.addChild(Item1)
        let Item2 = GameItem.buildyellowKey()
        Item2.setPosition(hang: 9, lie: 3)
        map.addChild(Item2)
        let Item3 = GameItem.buildyellowKey()
        Item3.setPosition(hang: 8, lie: 3)
        map.addChild(Item3)
        let Item4 = GameItem.buildyellowDoor()
        Item4.setPosition(hang: 6, lie: 3)
        map.addChild(Item4)
        let Item5 = GameItem.buildyellowDoor()
        Item5.setPosition(hang: 4, lie: 3)
        map.addChild(Item5)
        let Item6 = GameItem.buildyellowKey()
        Item6.setPosition(hang: 3, lie: 3)
        map.addChild(Item6)
        let Item7 = GameItem.buildyellowKey()
        Item7.setPosition(hang: 2, lie: 3)
        map.addChild(Item7)
        let Item8 = GameItem.buildattackDiamond()
        Item8.setPosition(hang: 1, lie: 3)
        map.addChild(Item8)
        
        let Item9 = GameItem.buildmediumHealth()
        Item9.setPosition(hang: 10, lie: 5)
        map.addChild(Item9)
        let Item10 = GameItem.buildyellowKey()
        Item10.setPosition(hang: 9, lie: 5)
        map.addChild(Item10)
        let Item11 = GameItem.buildyellowKey()
        Item11.setPosition(hang: 8, lie: 5)
        map.addChild(Item11)
        let Item12 = GameItem.buildmediumHealth()
        Item12.setPosition(hang: 3, lie: 5)
        map.addChild(Item12)
        let Item13 = GameItem.buildmediumHealth()
        Item13.setPosition(hang: 2, lie: 5)
        map.addChild(Item13)
        let Item14 = GameItem.buildmediumHealth()
        Item14.setPosition(hang: 1, lie: 5)
        map.addChild(Item14)
        let Item15 = GameItem.buildyellowDoor()
        Item15.setPosition(hang: 6, lie: 6)
        map.addChild(Item15)
        let Item16 = GameItem.buildblueDoor()
        Item16.setPosition(hang: 4, lie: 6)
        map.addChild(Item16)
        let Item17 = GameItem.buildsmallHealth()
        Item17.setPosition(hang: 3, lie: 6)
        map.addChild(Item17)
        let Item18 = GameItem.buildsmallHealth()
        Item18.setPosition(hang: 2, lie: 6)
        map.addChild(Item18)
        let Item19 = GameItem.buildsmallHealth()
        Item19.setPosition(hang: 1, lie: 6)
        map.addChild(Item19)
        
        let Item20 = GameItem.buildattackDiamond()
        Item20.setPosition(hang: 11, lie: 7)
        map.addChild(Item20)
        let Item21 = GameItem.buildattackDiamond()
        Item21.setPosition(hang: 10, lie: 7)
        map.addChild(Item21)
        let Item22 = GameItem.buildattackDiamond()
        Item22.setPosition(hang: 9, lie: 7)
        map.addChild(Item22)
        
        let Item23 = GameItem.buildDefenceDiamond()
        Item23.setPosition(hang: 11, lie: 8)
        map.addChild(Item23)
        let Item24 = GameItem.buildDefenceDiamond()
        Item24.setPosition(hang: 10, lie: 8)
        map.addChild(Item24)
        let Item25 = GameItem.buildDefenceDiamond()
        Item25.setPosition(hang: 9, lie: 8)
        map.addChild(Item25)
        let Item26 = GameItem.buildyellowDoor()
        Item26.setPosition(hang: 7, lie: 8)
        map.addChild(Item26)
        let Item27 = GameItem.buildyellowKey()
        Item27.setPosition(hang: 11, lie: 9)
        map.addChild(Item27)
        let Item28 = GameItem.buildyellowKey()
        Item28.setPosition(hang: 10, lie: 9)
        map.addChild(Item28)
        let Item29 = GameItem.buildyellowKey()
        Item29.setPosition(hang: 9, lie: 9)
        map.addChild(Item29)
        let Item30 = GameItem.buildyellowDoor()
        Item30.setPosition(hang: 6, lie: 9)
        map.addChild(Item30)
        let Item31 = GameItem.buildredKey()
        Item31.setPosition(hang: 11, lie: 10)
        map.addChild(Item31)
        let Item32 = GameItem.buildblueKey()
        Item32.setPosition(hang: 10, lie: 10)
        map.addChild(Item32)
        let Item33 = GameItem.buildyellowDoor()
        Item33.setPosition(hang: 8, lie: 10)
        map.addChild(Item33)
        
        let Item34 = GameItem.buildRailing()
        Item34.setPosition(hang: 4, lie: 8)
        map.addChild(Item34)
        let Item35 = GameItem.buildRailing()
        Item35.setPosition(hang: 4, lie: 10)
        map.addChild(Item35)
        
        let Item36 = GameItem.SbuildFloor2Hinder()
        Item36.setPosition(hang: 5, lie: 2)
        map.addChild(Item36)
        let Item37 = GameItem.SbuildFloor2Person1()
        Item37.setPosition(hang: 1, lie: 8)
        map.addChild(Item37)
        let Item38 = GameItem.SbuildFloor2Person2()
        Item38.setPosition(hang: 1, lie: 10)
        map.addChild(Item38)
        
        
    }
    func buildmap3(map:SKSpriteNode){
        let downStairs1 = staircaseNode.init(presentFloor: 3, position: CGPoint(x: 16, y: 16), isUp: false)
        map.addChild(downStairs1)
        let upStairs1 = staircaseNode.init(presentFloor: 3, position: CGPoint(x: 336, y: 16), isUp: true)
        map.addChild(upStairs1)
//        let shopNode = GameItem.
        
        
        
        
    }
    
}
