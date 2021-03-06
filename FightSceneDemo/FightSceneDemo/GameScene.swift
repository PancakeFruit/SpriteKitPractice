//
//  GameScene.swift
//  FightSceneDemo
//
//  Created by 胡杨林 on 17/2/27.
//  Copyright © 2017年 胡杨林. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var enemy1:UnitNode?
    private var enemy2:UnitNode?
    private var enemy3:UnitNode?
    
    private var friend1:UnitNode?
    private var friend2:UnitNode?
    private var friend3:UnitNode?
    
    private var ActionArr:NSMutableArray?
    private var NowActionUnit:UnitNode?
    private var nextActionUnit:UnitNode?
    
    private var Mainmenu:UIView? = nil
    private var MagicMenu:UIView? = nil
    private var NowMagicName:String = ""
    
    
    private var coverView:UIView? = nil
    private var MagicTag:Int = 0
    
    private var isNextActionReady:Bool = false
    
    
    
    private var FightState:String? = nil
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.white
        self.buildPlayerAndMonsters()
        self.buildMenu()
        self.buildfightcircle()
        self.fightcirclerun()

        
    }
    func buildfightcircle() {
        //将所有参与战斗的单位添加进一个队列，并给予两个指针用来指向当前行动单位和下一个行动单位
        self.ActionArr = NSMutableArray()
        if ((self.friend1) != nil) {
            self.ActionArr?.add(self.friend1!)
        }
        if ((self.friend2) != nil) {
            self.ActionArr?.add(self.friend2!)
        }
        if ((self.friend3) != nil) {
            self.ActionArr?.add(self.friend3!)
        }
        if ((self.enemy1) != nil) {
            self.ActionArr?.add(self.enemy1!)
        }
        if ((self.enemy2) != nil) {
            self.ActionArr?.add(self.enemy2!)
        }
        if ((self.enemy3 != nil)) {
            self.ActionArr?.add(self.enemy3!)
        }
        self.NowActionUnit = self.ActionArr?[0] as? UnitNode
        self.nextActionUnit = self.ActionArr?[1] as? UnitNode
    }
    
    func fightcirclerun() {
        self.isNextActionReady = false  //阻止下一次update对本函数调用，直到怪物AI行动完成或者玩家方进行了行动效果结算
        //这一句必须写在前面，不然在后续的行动中将值置为true后回调到这里又会改写为false导致卡死

        //战斗刚开始时，轮到主角行动
        if NowActionUnit == self.friend1 || NowActionUnit == self.friend2 || NowActionUnit == self.friend3 {
            self.view?.addSubview(self.Mainmenu!)  //如果是己方行动，展示主菜单进入玩家操作时间
            self.Mainmenu?.isHidden = false
            //这里应该调用一个函数来处理玩家选择操作的问题，使得相关动作执行结束后能够通过回调返回到这里
            
        }else{
            if (self.view?.subviews.contains(self.Mainmenu!))! { //如果不是我方行动，隐藏主菜单并执行怪物行动逻辑
                self.Mainmenu?.removeFromSuperview()
            }
            //怪物行动的AI选择
            self.monsterAction(NowActer: (self.NowActionUnit)!)
            
        }
        self.NowActionUnit = self.nextActionUnit
        let a = self.ActionArr?.count
        for u in 0..<a! {
            let b = self.ActionArr?[u] as! UnitNode
            if b == self.nextActionUnit {
                if u == a!-1 {  //队列尾
                    self.nextActionUnit = self.ActionArr?.firstObject as! UnitNode?
                }else{
                    self.nextActionUnit = self.ActionArr?[u+1] as! UnitNode?
                }
                break
            }
        }
        
    }
    func monsterAction(NowActer:UnitNode) {
        if (NowActionUnit?.Health)! / (NowActionUnit?.MaxHealth)! < 0.4 {  //血量低于40%，施放自我治疗
            print("怪物施放了治疗术")
            self.MagicEffectcalculate(from: self.NowActionUnit!, to: [NowActionUnit!], skill: "治疗术")
        
        }else{
            let z = arc4random()%100
            if z <= 70 {  // 血量不危险的前提下，70%概率使用普通物理攻击
            /*
                 //这里仅当己方三人参战时打开，目前目标锁定为friend1
            let a = arc4random()%3
            let b:UnitNode?
            if a == 0 {
                b = self.friend1
            }else if a == 1 {
                b = self.friend2
            }else {
                b = self.friend3
            }
            */
            let b = self.friend1
            self.attackcalculate(from: NowActionUnit!, to: b!)
            }else{
                if ((self.enemy1?.physicsAttack)! <= 60) {
                //释放了辅助魔法，敌方全体攻击提升
                self.enemy1?.physicsAttack += 20
                self.enemy2?.physicsAttack += 20
                self.enemy3?.physicsAttack += 20
                self.enemy1?.physicsDefences += 10
                self.enemy2?.physicsDefences += 10
                self.enemy3?.physicsDefences += 10
                self.isNextActionReady = true
                }else{
                    self.isNextActionReady = true
                }
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.FightState == "攻击响应" {  //这里有必要连续使用if else，如果state是非玩家响应期间，可以有效的快速ruturn
            for i in touches {
                let loc = i.location(in: self)
                let node = nodes(at: loc).first
                if node == self.enemy1 || node == enemy2 || node == enemy3 {
                    print("你成功的选择到了敌人")
                    print("转入物理攻击命中计算及伤害计算")
                    self.attackcalculate(from: self.friend1!, to: node as! UnitNode)
                }else{
                    self.cancelAction()
                }
            }
            return
        }else if self.FightState == "法术选择响应" { //在法术选择状态下，点击法术图标，进入法术目标选择，点击其他区域退回主菜单
            //该响应状态下，法术图标作为UIButton，其响应级高于tap轻点手势
            for i in touches {
                let loc = i.location(in: self)
                let node = nodes(at: loc).first
                
                if node == self.enemy1 || node == enemy2 || node == enemy3 {
                    print("你成功的选择到了敌人")
                    print("转入法术攻击命中计算及伤害计算")
                }else{
                    self.cancelAction()
                }
            }
            return
        }else if self.FightState == "法术目标选择响应_进攻类魔法" {
            for i in touches {
                let loc = i.location(in: self)
                let node = nodes(at: loc).first
                if node == self.enemy1 || node == self.enemy2 || node == self.enemy3  {
                    print("进攻类魔法选择目标成功，转入魔法伤害攻击结算")
                    let a = node as! UnitNode
                    self.MagicEffectcalculate(from: self.friend1!, to: [a], skill: self.NowMagicName)
                }else{
                    self.FightState = "法术选择响应"
                    self.MagicMenu?.isHidden = false
                }
            }
            return
        }else if self.FightState == "法术目标选择响应_辅助类魔法" {
            for i in touches {
                let loc = i.location(in: self)
                let node = nodes(at: loc).first
                if node == self.friend1 || node == self.friend2 || node == self.friend3 {
                    print("辅助类魔法选择目标成功，转入辅助/治疗魔法效果结算")
                }else{
                    self.FightState = "法术选择响应"
                    self.MagicMenu?.isHidden = false
                }
            }
        }
    }
    
    func buildPlayerAndMonsters() {
        let node = UnitNode(CGSize(width: 80, height: 150) , MaxHealth: 400)
        node.position = CGPoint(x: 500, y: 40)
        node.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        let texture = SKTexture(imageNamed: "41")
        node.texture = texture
        node.physicsAttack = 120
        node.physicsDefences = 30
        node.MagicAttack = 150
        addChild(node)
        self.friend1 = node
        let texture_monster = SKTexture(imageNamed: "monster1")
        let mon1 = UnitNode.init(CGSize(width: 73, height: 93), MaxHealth: 200)
        mon1.texture = texture_monster
        mon1.anchorPoint = CGPoint.zero
        mon1.position = CGPoint(x: 100, y: 100)
        mon1.physicsAttack = 35
        mon1.physicsDefences = 25
        self.enemy1 = mon1
        addChild(mon1)
        let mon2 = UnitNode.init(CGSize(width: 73, height: 93), MaxHealth: 240)
        mon2.texture = texture_monster
        mon2.anchorPoint = CGPoint.zero
        mon2.position = CGPoint(x: 130, y: 200)
        mon2.physicsAttack = 40
        mon2.physicsDefences = 30
        self.enemy2 = mon2
        addChild(mon2)
        let mon3 = UnitNode.init(CGSize(width: 73, height: 93), MaxHealth: 200)
        mon3.texture = texture_monster
        mon3.anchorPoint = CGPoint.zero
        mon3.position = CGPoint(x: 160, y: 300)
        mon3.physicsAttack = 35
        mon3.physicsDefences = 25
        self.enemy3 = mon3
        addChild(mon3)
        

    }
    
    func buildMenu() {
        self.Mainmenu = UIView(frame: CGRect(x: 600, y: 150, width: 90, height: 135))
        self.Mainmenu?.backgroundColor = SKColor.init(colorLiteralRed: 64.0/255, green: 64.0/255, blue: 64.0/255, alpha: 1.0)
        let btn1 = UIButton(type: UIButtonType.custom)
        btn1.frame = CGRect(x: 5, y: 3, width: 80, height: 30)
        btn1.setTitle("攻击", for: UIControlState.normal)
        btn1.backgroundColor = SKColor.black
        btn1.setTitleColor(SKColor.white, for: UIControlState.normal)
        btn1.addTarget(self, action: #selector(MainmenuAttack), for: UIControlEvents.touchUpInside)
        self.Mainmenu?.addSubview(btn1)
        let btn2 = UIButton(type: UIButtonType.custom)
        btn2.frame = CGRect(x: 5, y: 36, width: 80, height: 30)
        btn2.setTitle("法术", for: UIControlState.normal)
        btn2.backgroundColor = SKColor.black
        btn2.setTitleColor(SKColor.white, for: UIControlState.normal)
        btn2.addTarget(self, action: #selector(MainmenuMagic), for: UIControlEvents.touchUpInside)
        self.Mainmenu?.addSubview(btn2)
        let btn3 = UIButton(type: UIButtonType.custom)
        btn3.frame = CGRect(x: 5, y: 69, width: 80, height: 30)
        btn3.setTitle("道具", for: UIControlState.normal)
        btn3.backgroundColor = SKColor.black
        btn3.setTitleColor(SKColor.white, for: UIControlState.normal)
        btn3.addTarget(self, action: #selector(MainmenuItem), for: UIControlEvents.touchUpInside)
        self.Mainmenu?.addSubview(btn3)
        let btn4 = UIButton(type: UIButtonType.custom)
        btn4.frame = CGRect(x: 5, y: 102, width: 80, height: 30)
        btn4.setTitle("跑路", for: UIControlState.normal)
        btn4.backgroundColor = SKColor.black
        btn4.setTitleColor(SKColor.white, for: UIControlState.normal)
        btn4.addTarget(self, action: #selector(MainmenuEscape), for: UIControlEvents.touchUpInside)
        self.Mainmenu?.addSubview(btn4)
        //以上为主菜单构建
        
        self.coverView = UIView(frame: (self.view?.frame)!)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.cancelAction))
        self.coverView?.addGestureRecognizer(tap)
        
        self.MagicMenu = UIView(frame: CGRect(x: 220, y: 100, width: 175, height: 260))
        self.MagicMenu?.backgroundColor = SKColor.init(colorLiteralRed: 64.0/255, green: 64.0/255, blue: 64.0/255, alpha: 1.0)
        self.view?.addSubview(self.MagicMenu!)
        self.MagicMenu?.isHidden = true
        let Magic1 = UIButton(type: UIButtonType.custom)
        Magic1.frame = CGRect(x: 5, y: 5, width: 80, height: 80)
        Magic1.setImage(UIImage.init(named: "44-1"), for: UIControlState.normal)
        Magic1.addTarget(self, action: #selector(MainmenuMagicChange(btn:)), for: UIControlEvents.touchUpInside)
        Magic1.tag = 1008601
        self.MagicMenu?.addSubview(Magic1)
        let Magic2 = UIButton(type: UIButtonType.custom)
        Magic2.frame = CGRect(x: 90, y: 5, width: 80, height: 80)
        Magic2.setImage(UIImage.init(named: "44-2"), for: UIControlState.normal)
        Magic2.addTarget(self, action: #selector(MainmenuMagicChange(btn:)), for: UIControlEvents.touchUpInside)
        Magic2.tag = 1008602
        self.MagicMenu?.addSubview(Magic2)
        let Magic3 = UIButton(type: UIButtonType.custom)
        Magic3.frame = CGRect(x: 5, y: 90, width: 80, height: 80)
        Magic3.setImage(UIImage.init(named: "44-3"), for: UIControlState.normal)
        Magic3.addTarget(self, action: #selector(MainmenuMagicChange(btn:)), for: UIControlEvents.touchUpInside)
        Magic3.tag = 1008603
        self.MagicMenu?.addSubview(Magic3)
        let Magic4 = UIButton(type: UIButtonType.custom)
        Magic4.frame = CGRect(x: 90, y: 90, width: 80, height: 80)
        Magic4.setImage(UIImage.init(named: "44-4"), for: UIControlState.normal)
        Magic4.addTarget(self, action: #selector(MainmenuMagicChange(btn:)), for: UIControlEvents.touchUpInside)
        Magic4.tag = 1008604
        self.MagicMenu?.addSubview(Magic4)
        let Magic5 = UIButton(type: UIButtonType.custom)
        Magic5.frame = CGRect(x: 5, y: 175, width: 80, height: 80)
        Magic5.setImage(UIImage.init(named: "44-5"), for: UIControlState.normal)
        Magic5.addTarget(self, action: #selector(MainmenuMagicChange(btn:)), for: UIControlEvents.touchUpInside)
        Magic5.tag = 1008605
        self.MagicMenu?.addSubview(Magic5)
        let Magic6 = UIButton(type: UIButtonType.custom)
        Magic6.frame = CGRect(x: 90, y: 175, width: 80, height: 80)
        Magic6.setImage(UIImage.init(named: "44-6"), for: UIControlState.normal)
        Magic6.addTarget(self, action: #selector(MainmenuMagicChange(btn:)), for: UIControlEvents.touchUpInside)
        Magic6.tag = 1008606
        self.MagicMenu?.addSubview(Magic6)
        
        
        
    }
    func MainmenuAttack() {
        self.FightState = "攻击响应"
        self.Mainmenu?.isHidden = true   //进入攻击选择状态，隐藏主菜单
//        self.view?.addSubview(self.coverView!)
        
    }
    func MainmenuMagic() {
        print("法术菜单响应")
        self.FightState = "法术选择响应"  //在法术选择状态下，点击法术图标，进入法术目标选择，点击其他区域退回主菜单
        self.Mainmenu?.isHidden = true
        self.MagicMenu?.isHidden = false
        
    }
    func MainmenuMagicChange(btn:UIButton) {
        let tag = btn.tag
        self.MagicTag = tag
        switch tag {
        case 1008601:
            print("法术响应——第一个法术")
            self.FightState = "法术目标选择响应_进攻类魔法"
            self.NowMagicName = "风刃术"
            //单体伤害魔法
            break
        case 1008602:
            print("法术响应——第二个法术")
            self.FightState = "法术目标选择响应_进攻类魔法"
            self.NowMagicName = "雷击术"
            //单体伤害魔法——附加异常状态
            break
        case 1008603:
            print("法术响应——第三个法术")
            self.FightState = "法术目标选择响应_进攻类魔法"
            self.NowMagicName = "燎原烈火"
            //群体伤害魔法
            break
        case 1008604:
            print("法术响应——第四个法术")
            self.FightState = "法术目标选择响应_进攻类魔法"
            self.NowMagicName = "雷霆万钧"
            //群体伤害魔法——附加降低防御
            break
        case 1008605:
            print("法术响应——第五个法术")
            self.FightState = "法术目标选择响应_辅助类魔法"
            self.NowMagicName = "圣光术"
            //单体治疗魔法
            break
        case 1008606:
            print("法术响应——第六个法术")
            self.FightState = "法术目标选择响应_辅助类魔法"
            self.NowMagicName = "赐福"
            //属性提升魔法
            break
        default:
            break
        }

        self.MagicMenu?.isHidden = true
        
    }
    func MainmenuItem() {
                print("道具响应")
    }
    func MainmenuEscape() {
                print("跑路响应")
        let a = "逃跑成功计算率公式"
        if  a != "逃跑" {  //根据敏捷等属性来计算逃跑成功率
            print("逃跑成功")
        }else{
            print("逃跑失败")
            print("转入下一个战斗环节")
        }
    }
    func cancelAction() {
        if self.FightState == "攻击响应" {
            self.FightState = ""  //退出攻击状态
        }else if self.FightState == "法术选择响应" {
            self.FightState = ""
        }
        
        //这里需要加入隐藏道具栏的语句
        self.MagicMenu?.isHidden = true
        self.Mainmenu?.isHidden = false
    }
    
    func attackcalculate(from:UnitNode, to:UnitNode) {
        let a = from.physicsAttack - to.physicsDefences
        to.HealthBar(HealthChanged: a)  //该方法的调用参数传入为变动值，正数为扣血，负数为加血
        print("剩余血量为\(to.Health)")
        let movebackPoint = from.position;
        var movetoPoint:CGPoint = CGPoint.zero;
        if to.position.x > (self.view?.frame.size.width)! / 2 {  //被攻击单位处于屏幕右侧
            movetoPoint = CGPoint(x: to.position.x - 80, y: to.position.y)
        }else{
            movetoPoint = CGPoint(x: to.position.x + 80, y: to.position.y)
        }
        let moveout = SKAction.move(to: movetoPoint, duration: 0.1)
        let moveback = SKAction.move(to: movebackPoint, duration: 0.1)
        let wait = SKAction.wait(forDuration: 0.1)
        let MoveAction = SKAction.sequence([moveout,wait,moveback])
        from.run(MoveAction) {
            self.isNextActionReady = true
        }
        
        let fadein = SKAction.fadeOut(withDuration: 0.05)
        let fadeout = SKAction.fadeIn(withDuration: 0.05)
        let fade = SKAction.sequence([wait,fadein,fadeout,wait])
        to.run(fade)  //被攻击时的闪烁特效
        if to.Health <= 0 {
            let disappear = SKAction.fadeOut(withDuration: 0.5)
            to.run(disappear)
            self.ActionArr?.remove(to)
            
        }
        self.FightState = ""
    }
    func MagicEffectcalculate(from:UnitNode, to:[UnitNode], skill:String) {  //以后skill应该单独提取成一个类
        //这里开始结算伤害/治疗/辅助效果，并在结算完成后重新清零MagicTag
        if skill == "治疗术" {
            let a = to.first as UnitNode!
            a?.HealthBar(HealthChanged: -50)
        }else if skill == "风刃术" {
            for i in to {
                i.HealthBar(HealthChanged: 50)
            }
        }else if skill == "燎原烈火" {
            for i in to {
                i.HealthBar(HealthChanged: 50)
                if self.enemy1 == i {
                    if (self.enemy2?.Health)! > CGFloat(0.0) {
                        self.enemy2?.HealthBar(HealthChanged: 50)
                    }else if (self.enemy3?.Health)! > CGFloat(0.0) {
                        self.enemy3?.HealthBar(HealthChanged: 50)
                    }
                }
                if self.enemy2 == i {
                    if (self.enemy1?.Health)! > CGFloat(0.0) {
                        self.enemy1?.HealthBar(HealthChanged: 50)
                    }else if (self.enemy3?.Health)! > CGFloat(0.0) {
                        self.enemy3?.HealthBar(HealthChanged: 50)
                    }
                }
                if self.enemy3 == i {
                    if (self.enemy2?.Health)! > CGFloat(0.0) {
                        self.enemy2?.HealthBar(HealthChanged: 50)
                    }else if (self.enemy1?.Health)! > CGFloat(0.0) {
                        self.enemy1?.HealthBar(HealthChanged: 50)
                    }
                }
            }
        }
        
        self.FightState = ""
        self.isNextActionReady = true
    }
    
    override func update(_ currentTime: TimeInterval) {
        if self.isNextActionReady {
            self.fightcirclerun()   //上一回合执行完毕，再次调用fightcirclerun函数
            
        }
    }
}
