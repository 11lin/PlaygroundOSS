local MainGame = class("MainGame")
local Bullet = class("Bullet")
local BulletManger = class("BulletManger")
local BulletGnerator  = class("BulletGnerator")
local ItemManger  = class("ItemManger")
local Item  = class("Item")
-- 主要结构 MainGame -> BulletManger -> BulletGenerator -> Bullet
				            -- -> Bullet
--设置单例模式
SetSingletonClass(MainGame)
SetSingletonClass(BulletManger)
SetSingletonClass(ItemManger)

Octopus_Punch = SND_Open("asset://assets/Sounds/Octopus_Punch")
Dream_Fail = SND_Open("asset://assets/Sounds/Dream_Fail")
----------------------------------------------MainGame---start---------------------------------------
function MainGame:setup(  )
	self.heroPos= vec2(320,900)
	self.heroMoveLastPos = vec2(0,0)
	self.pbg = UI_SimpleItem(nil,0,0,0,"asset://assets/Battle/BattleBg.png.imag")
	self.pHero = UI_SimpleItem(nil,500,self.heroPos.x,self.heroPos.y,"asset://assets/Battle/RabbitHat.png.imag")
	self.pForm = UI_Form(nil,1000,0, 0,"asset://app/views/Battle.json",false)

	sysCommand(self.pForm, UI_FORM_UPDATE_NODE, "loseNode", FORM_NODE_VISIBLE, false )
	TASK_StageOnly(pForm)

	-- self.pCtl = UI_Control("onClick","onDrag")
	self.pTPad = UI_TouchPad("callbackTP")

	self.heroTapPos = vec2(0,0)
	self.heroTapHeroPos = vec2(0,0)
	self.gameTime = 0 --毫秒

	BulletManger.getInstance():setup()
	ItemManger.getInstance():setup()
	self.score = 0
	self.isPause = false

	SND_Play(bgm)
end
function MainGame:execute( deltaT )
	if self.isPause then
		return
	end
	self.gameTime = self.gameTime + deltaT
	BulletManger.getInstance():update(deltaT)
	ItemManger.getInstance():update(deltaT)
	sysCommand(self.pForm, UI_FORM_UPDATE_NODE, "lblTime", FORM_LBL_SET_TEXT, self.gameTime )
	sysCommand(self.pForm, UI_FORM_UPDATE_NODE, "lblScore", FORM_LBL_SET_TEXT, self.score)
	self:debugLine()
end
function MainGame:checkHeroAndBullet(blt)
	if blt:isCollisionHero() then
		self:gameOver()
		-- local prop = TASK_getProperty(self.pHero)
		-- local pos = blt:getPosition()
		-- print("1111111111111111111",pos.x,pos.y,self.heroPos.x,self.heroPos.y,prop.x,prop.y)
	end
end
-- 碰撞到道具
function MainGame:collisionItem( it )
	self.score = self.score + 1
	SND_Play(Octopus_Punch)
end
function MainGame:leave( )
	self.pbg = TASK_kill(self.pbg)
	self.pHero = TASK_kill(self.pHero)
	self.pForm = TASK_kill(self.pForm)
	self.pTPad = TASK_kill(self.pTPad)
	BulletManger.getInstance():destroy()
	ItemManger.getInstance():destroy()
	if self.pHeroPolyLine then
		self.pHeroPolyLine = TASK_kill(self.pHeroPolyLine)
	end
	bgm = SND_Close(bgm)
	Octopus_Punch = SND_Close(Octopus_Punch)
	Dream_Fail = SND_Close(Dream_Fail)
end
function MainGame:pause(  )
	self.isPause = true
end
function MainGame:gameOver(  )
	SND_Play(Dream_Fail)
	sysCommand(self.pForm, UI_FORM_UPDATE_NODE, "loseNode", FORM_NODE_VISIBLE, true )
	sysCommand(self.pForm, UI_FORM_UPDATE_NODE, "lblDlgCurrent", FORM_LBL_SET_TEXT, self.score)
	self:pause()
end
function MainGame:replay(  )
	sysCommand(self.pForm, UI_FORM_UPDATE_NODE, "loseNode", FORM_NODE_VISIBLE, false )
	BulletManger.getInstance():replay()
	BulletManger.getInstance():replay()
	self.isPause = false
	self:setHeroPosition(vec2(320,900))
	self.gameTime = 0 --毫秒
	self.score = 0
end
function MainGame:onClickReplay()
	self:replay()
end
function MainGame:callbackTP( tbl )
	if self.isPause then
		return
	end
	syslog("callbackTP. . . .")
	local item = nil
	if tbl and #tbl >0 then
		item = tbl[1] --处理多点触控
	end
	if item == nil then
		return
	end
	-- syslog(string.format("type:%s,x:%s,y:%s",item.type,item.x,item.y))
	if item.type == PAD_ITEM_TAP then
		-- local prop = TASK_getProperty(self.pHero)
		self.heroTapHeroPos = self.heroPos
		-- self.heroTapHeroPos.y = prop.y
		self.heroTapPos = item
	elseif item.type == PAD_ITEM_DRAG then
		local  mv = vec2sub(item,self.heroTapPos)
		self.heroPos = vec2add(self.heroTapHeroPos,mv)
		if rectContainsVec2(Const.HERO_ACTIVE_RECT,self.heroPos) then
			self.heroMoveLastPos = self.heroPos
		else
			self.heroPos = self.heroMoveLastPos
		end
		local prop = TASK_getProperty(self.pHero)
		prop.x = self.heroPos.x
		prop.y = self.heroPos.y
		TASK_setProperty(self.pHero, prop)

		-- syslog(string.format("move:x=%s,y=%s,posx=%s,posy:%s",mvx,mvy,this.heroPos.x,this.heroPos.y)..",tapx:"..this.heroTapPosX..",tapy:"..this.heroTapPosY)
	elseif item.type == PAD_ITEM_RELEASE then

	end	
end
function MainGame:getHeroPosition( )
	return self.heroPos
end
function MainGame:setHeroPosition( pos )
	self.heroPos = pos
	local prop = TASK_getProperty(self.pHero)
	prop.x = self.heroPos.x
	prop.y = self.heroPos.y
	TASK_setProperty(self.pHero, prop)
end
function MainGame:debugLine(  )
	if not Config.isDebug then
		return
	end
	if not self.pHeroPolyLine then
		self.pHeroPolyLine = UI_Polyline(nil, 501, 6)
		sysCommand(self.pHeroPolyLine, UI_POLYLINE_SET_POINTCOUNT, 5)
		sysCommand(self.pHeroPolyLine , UI_POLYLINE_SET_COLOR, 0xff, 0xFF0000)
	end
	sysCommand(self.pHeroPolyLine , UI_POLYLINE_SET_POINT, 0, self.heroPos.x-Const.HERO_REDIUS, self.heroPos.y-Const.HERO_REDIUS)
	sysCommand(self.pHeroPolyLine , UI_POLYLINE_SET_POINT, 1, self.heroPos.x+Const.HERO_REDIUS, self.heroPos.y-Const.HERO_REDIUS)	
	sysCommand(self.pHeroPolyLine , UI_POLYLINE_SET_POINT, 2, self.heroPos.x+Const.HERO_REDIUS, self.heroPos.y+Const.HERO_REDIUS)	
	sysCommand(self.pHeroPolyLine , UI_POLYLINE_SET_POINT, 3, self.heroPos.x-Const.HERO_REDIUS, self.heroPos.y+Const.HERO_REDIUS)	
	sysCommand(self.pHeroPolyLine , UI_POLYLINE_SET_POINT, 4, self.heroPos.x-Const.HERO_REDIUS, self.heroPos.y-Const.HERO_REDIUS)	
end
----------------------------------------------MainGame---end---------------------------------------

----------------------------------------------ItemManger---start---------------------------------------
function ItemManger:setup(  )
	self.itemPool = {}
	self.itemCreatePool={}
	self:replay()

	self.nextTime = 5000
end
function ItemManger:replay(  )
	self:destroy()
end
function ItemManger:update( deltaT )
	for i,v in ipairs(self.itemPool) do
		v:update(deltaT)
		if not v._isJoinCreatePool and v:isCollisionHero() then
			MainGame.getInstance():collisionItem(v)
			v._isJoinCreatePool = true
			table.insert(self.itemCreatePool,v)
			v:setPosition(vec2(-1000,-1000))

			self.nextTime = MainGame.getInstance().gameTime + Const.ITEM_SECOND
		end
	end
	if MainGame.getInstance().gameTime > self.nextTime then
		self:createItem()
		if #self.itemPool < Const.ITEM_COUNT  then
			self.nextTime = MainGame.getInstance().gameTime + Const.ITEM_SECOND
		end
	end
end
function ItemManger:destroy(  )
	for i,v in ipairs(self.itemPool) do
		v:destroy()
	end
	self.itemPool = {}
end
function ItemManger:getRandomPosition(  )
	-- math.randomseed(os.time())
	local pos = vec2(0,0)
	pos.x = math.random(Const.GAME_ITEM_RANDOM_RECT.x,Const.GAME_ITEM_RANDOM_RECT.x+Const.GAME_ITEM_RANDOM_RECT.width)
	pos.y = math.random(Const.GAME_ITEM_RANDOM_RECT.y,Const.GAME_ITEM_RANDOM_RECT.y+Const.GAME_ITEM_RANDOM_RECT.height)
	return pos
end
function ItemManger:createItem( )
	local initPos = self:getRandomPosition()
	local it = table.remove(self.itemCreatePool,1)
	if it then
		it:reInitialize(initPos)
		it._isJoinCreatePool = false
	else
		it = Item:new(initPos)
		table.insert(self.itemPool,it)
	end
	return it
end
----------------------------------------------ItemManger---end---------------------------------------

----------------------------------------------Item---start---------------------------------------
function Item:initialize( initPos )
	self.pItem = UI_SimpleItem(nil,600,initPos.x,initPos.y,"asset://assets/Battle/Star.png.imag")
	self.vPos = initPos

	self.minScale = 0.8
	self.maxScale = 1.5
	self.redius = 38

	self:reInitialize(initPos)
end
function Item:reInitialize(initPos)
	self:setPosition(initPos)
	local prop = TASK_getProperty(self.pItem)
	prop.scaleX = 1
	prop.scaleY = 1
	TASK_setProperty(self.pItem,prop)
	self.isAdd = true
end
function Item:update( deltaT )
	local prop = TASK_getProperty(self.pItem)
	if self.isAdd then
		prop.scaleX = prop.scaleX + deltaT*0.001
		prop.scaleY = prop.scaleY + deltaT*0.001
	else
		prop.scaleX = prop.scaleX - deltaT*0.001
		prop.scaleY = prop.scaleY - deltaT*0.001		
	end
	TASK_setProperty(self.pItem,prop)

	if prop.scaleX > self.maxScale then
		self.isAdd = false
	elseif prop.scaleX < self.minScale then
		self.isAdd = true
	end
end
function Item:setPosition( pos )
	self.vPos = pos
	local prop = TASK_getProperty(self.pItem)
	prop.x = pos.x
	prop.y = pos.y
	TASK_setProperty(self.pItem,prop)	
end
function Item:getPosition(  )
	return self.vPos
end
function Item:destroy(  )
	self.pItem = TASK_kill(self.pItem)
end
function Item:isCollisionHero()
	local hPos = MainGame.getInstance():getHeroPosition()
	local vec = vec2sub(hPos,self.vPos)
	local distance = math.sqrt(vec.x * vec.x + vec.y * vec.y)
	local len = Const.HERO_REDIUS + self.redius
	if distance <  len then
		return true
	end
	return false
end
----------------------------------------------Item---end---------------------------------------

----------------------------------------------BulletManger---start---------------------------------------
function BulletManger:setup()
	self.bulletGens = {}
	self.bulletPool = {}
	self.bulletCreatePool = {}


	self:replay()

	-- for i=1,10 do
	-- 	local gen = BulletGnerator:new(vec2(i*64,-100),i*100,500,vec2(0,math.random(10,20)))
	-- 	table.insert(self.bulletGens,gen)
	-- end
	-- for i=1,10 do
	-- 	self.bulletItems[i] = Bullet:new("BulletGreen",i*60,-150,math.random(1,10))
	-- end	
end
function BulletManger:loadGeneratorData()
	self.bulletGens = {}

	local angle = 360/10
	for i=1,10 do
		local radian = (2*math.pi/ 360) * angle * i
		local x = 320 + math.sin(radian) * 200
		local y = -200 - math.cos(radian) * 200
		local gen = BulletGnerator:new(vec2(x,y),9000,10000,vec2(0,3))
		table.insert(self.bulletGens,gen)
	end

	angle = 9
	for i=1,10 do
		local radian = (2*math.pi/ 360) * ( 90 + angle * i)
		local x = 100 +  math.sin(radian) 
		local y = 150 - math.cos(radian)
		local gen = BulletGnerator:new(vec2(x,y),1000,30000,vec2(math.sin(radian)*3,-math.cos(radian)*3))
		table.insert(self.bulletGens,gen)
	end

	for i=1,10 do
		local radian = (2*math.pi/ 360) * ( 90 + angle * i)
		local x = 100 +  math.sin(radian) 
		local y = 150 - math.cos(radian)
		local gen = BulletGnerator:new(vec2(x,y),1500,30000,vec2(math.sin(radian)*3,-math.cos(radian)*3))
		table.insert(self.bulletGens,gen)
	end

	for i=1,10 do
		local radian = (2*math.pi/ 360) * (180 + angle * i)
		local x = 600 + math.sin(radian) 
		local y = 150 - math.cos(radian)
		local gen = BulletGnerator:new(vec2(x,y),2000,30000,vec2(math.sin(radian)*3,-math.cos(radian)*3))
		table.insert(self.bulletGens,gen)
	end

	for i=1,10 do
		local radian = (2*math.pi/ 360) * (180 + angle * i)
		local x = 600 + math.sin(radian) 
		local y = 150 - math.cos(radian)
		local gen = BulletGnerator:new(vec2(x,y),2500,30000,vec2(math.sin(radian)*3,-math.cos(radian)*3))
		table.insert(self.bulletGens,gen)
	end
	angle = 180/20
	for i=1,20 do
		local radian = (2*math.pi/ 360) * (90 + angle * i)
		local x = 320 + math.sin(radian) 
		local y = 150 - math.cos(radian)
		local gen = BulletGnerator:new(vec2(x,y),3000,30000,vec2(math.sin(radian)*2,-math.cos(radian)*2))
		table.insert(self.bulletGens,gen)
	end

	for i=1,20 do
		local radian = (2*math.pi/ 360) * (90 + angle * i)
		local x = 320 + math.sin(radian) 
		local y = 150 - math.cos(radian)
		local gen = BulletGnerator:new(vec2(x,y),3500,30000,vec2(math.sin(radian)*2,-math.cos(radian)*2))
		table.insert(self.bulletGens,gen)
	end


	local gen = BulletGnerator:new(vec2(670,500),15000,4000,4,true,"BulletYellow")
	table.insert(self.bulletGens,gen)

	gen = BulletGnerator:new(vec2(-100,500),20000,5000,3,true,"BulletYellow")
	table.insert(self.bulletGens,gen)

	-- gen = BulletGnerator:new(vec2(50,-200),1000,2000,vec2(3,3))
	-- table.insert(self.bulletGens,gen)

	-- gen = BulletGnerator:new(vec2(590,-200),2000,2000,vec2(-3,3))
	-- table.insert(self.bulletGens,gen)

	-- local sPos = vec2(160,-100)
	-- local toPos = vec2(640,1136)
	-- local speed = vec2mul(vec2normalize(vec2sub(toPos,sPos)),math.random(5,10))
	-- local gen = BulletGnerator:new(sPos,100,math.random(200,300),speed)
	-- table.insert(self.bulletGens,gen)

	-- sPos = vec2(160*2,-100)
	-- toPos = vec2(640,1136)
	-- speed = vec2mul(vec2normalize(vec2sub(toPos,sPos)),math.random(5,10))
	-- gen = BulletGnerator:new(sPos,200,math.random(200,300),speed)
	-- table.insert(self.bulletGens,gen)

	-- sPos = vec2(160*2,-100)
	-- toPos = vec2(0,1136)
	-- speed = vec2mul(vec2normalize(vec2sub(toPos,sPos)),math.random(5,10))
	-- gen = BulletGnerator:new(sPos,200,math.random(200,300),speed)
	-- table.insert(self.bulletGens,gen)

	-- sPos = vec2(160*3,-100)
	-- toPos = vec2(0,1136)
	-- speed = vec2mul(vec2normalize(vec2sub(toPos,sPos)),math.random(5,10))
	-- gen = BulletGnerator:new(sPos,300,math.random(200,300),speed)
	-- table.insert(self.bulletGens,gen)	
end
function BulletManger:replay( )
	self:loadGeneratorData()
	for i,v in ipairs(self.bulletPool) do
		v:setPosition(vec2(-200,-200))
	end
end
function BulletManger:update( deltaT )
	for i,v in ipairs(self.bulletGens) do
		v:update(deltaT)			
	end		
	for i,v in ipairs(self.bulletPool) do
		if not v._isJoinCreatePool and v:isShowContains() == false then
			v:setActive(false)
			self:addCreatePool(v)
		end
		v:update(deltaT)
		MainGame.getInstance():checkHeroAndBullet(v)
	end
end
function BulletManger:addCreatePool(blt)
	local resName = blt:getResName()
	if self.bulletCreatePool[resName] == nil then
		self.bulletCreatePool[resName] = {}
	end
	blt._isJoinCreatePool = true
	table.insert(self.bulletCreatePool[resName],blt)	
end
function BulletManger:addBullet( blt )
	table.insert(self.bulletPool,blt)
end
function BulletManger:createBullet( resName,initPos,speed,isTrace)
	if not self.bulletCreatePool[resName] then
		self.bulletCreatePool[resName] = {}
	end
	local blt = table.remove(self.bulletCreatePool[resName],1)
	if blt then
		blt:reInitialize(resName,initPos,speed,isTrace)
	else
		blt = Bullet:new(resName,initPos,speed,isTrace)
		self:addBullet(blt)
	end
	blt._isJoinCreatePool = false
	return blt
end
function BulletManger:destroy()
	self.bulletGens = {}
	for i,v in ipairs(self.bulletPool) do
		v:destroy()
	end
	self.bulletPool={}
end
----------------------------------------------BulletManger---end---------------------------------------

----------------------------------------------BulletGnerator---start---------------------------------------
function BulletGnerator:initialize( startPos, startTime, interval, speed, isTrace, resName)
	self.startPos = startPos
	self.startTime = startTime
	self.interval = interval
	self.speed = speed
	self.nextTime = startTime
	self.resName = resName or "BulletGreen"
	self.isTrace = isTrace
end
-- function BulletGenerator:setup(  )
	
-- end
function BulletGnerator:update( deltaT )
	if MainGame.getInstance().gameTime >  self.nextTime then
		Bullet.create(self.resName,self.startPos,self.speed,self.isTrace)
		 self.nextTime = MainGame.getInstance().gameTime + self.interval
	end
end
----------------------------------------------BulletGnerator---end---------------------------------------

----------------------------------------------Bullet---start---------------------------------------
function Bullet.static.create(resName,initPos,speed,isTrace)
	return BulletManger.getInstance():createBullet(resName,initPos,speed,isTrace)
end
--@param speed 包含{x,y}
function Bullet:initialize(resName,initPos,speed,isTrace)
	self.pItem = UI_SimpleItem(nil,700,initPos.x,initPos.y,"asset://assets/Battle/"..resName..".png.imag")
	self:reInitialize(resName,initPos,speed,isTrace)

	self.redius = 35
end
function Bullet:reInitialize(resName,initPos,speed,isTrace )
	self.vPos = initPos
	self.currentIsDestroy = false
	self.currentIsActive = true
	self.resName = resName
	self:setPosition(initPos)
	self.rotate=0
	self.isTrace = isTrace

	if self.isTrace then
		 local dir = vec2normalize(vec2sub(MainGame.getInstance():getHeroPosition(),self.vPos))
		 self.speed = vec2mul(dir,speed)
	else
		self.speed = speed
	end

	self.rotateSpeed = math.sqrt(self.speed.x*self.speed.x+self.speed.y*self.speed.y)
end
function Bullet:debugLine(  )
	if not Config.isDebug then
		return
	end
	if not self.pPolyLine then
		self.pPolyLine = UI_Polyline(nil, 800, 6)
		sysCommand(self.pPolyLine, UI_POLYLINE_SET_POINTCOUNT, 5)
		sysCommand(self.pPolyLine , UI_POLYLINE_SET_COLOR, 0xff, 0x0000FF)
	end
	sysCommand(self.pPolyLine , UI_POLYLINE_SET_POINT, 0, self.vPos.x-self.redius, self.vPos.y-self.redius)
	sysCommand(self.pPolyLine , UI_POLYLINE_SET_POINT, 1, self.vPos.x+self.redius, self.vPos.y-self.redius)	
	sysCommand(self.pPolyLine , UI_POLYLINE_SET_POINT, 2, self.vPos.x+self.redius, self.vPos.y+self.redius)	
	sysCommand(self.pPolyLine , UI_POLYLINE_SET_POINT, 3, self.vPos.x-self.redius, self.vPos.y+self.redius)	
	sysCommand(self.pPolyLine , UI_POLYLINE_SET_POINT, 4, self.vPos.x-self.redius, self.vPos.y-self.redius)	
end
function Bullet:update(deltaT)
	if self:isActive() == false then
		return
	end
	local prop = TASK_getProperty(self.pItem)
	self.vPos = vec2add(self.vPos,self.speed)
	prop.x = self.vPos.x
	prop.y = self.vPos.y
	prop.scaleX = 0.5
	prop.scaleY = 0.5
	self.rotate = self.rotate + self.rotateSpeed
	prop.rot = self.rotate
	TASK_setProperty(self.pItem,prop)
	self:debugLine()
end
function Bullet:getResName(  )
	return self.resName
end
function Bullet:destroy()
	self.currentIsDestroy = true
	self.pItem = TASK_kill(self.pItem)
	if self.pPolyLine then
		self.pPolyLine = TASK_kill(self.pPolyLine)
	end
end
function Bullet:isDestroy()
	return self.currentIsDestroy
end
function Bullet:setActive( act)
	self.currentIsActive = act;
end
function Bullet:isActive(  )
	return self.currentIsActive
end
function Bullet:setPosition(pos)
	local prop = TASK_getProperty(self.pItem)
	self.vPos = pos
	prop.x = self.vPos.x
	prop.y = self.vPos.y
	TASK_setProperty(self.pItem,prop)	
end
function Bullet:getPosition(  )
	return self.vPos
end
function Bullet:isShowContains()
	-- return self.vPos.y < Const.OUTSIDE_Y
	return rectContainsVec2(Const.GAME_SHOW_RECT,self.vPos)
end
function Bullet:isCollisionHero()
	local hPos = MainGame.getInstance():getHeroPosition()
	local vec = vec2sub(hPos,self.vPos)
	local distance = math.sqrt(vec.x * vec.x + vec.y * vec.y)
	local len = Const.HERO_REDIUS + self.redius
	if distance <  len then
		return true
	end
	return false
end
----------------------------------------------Bullet---end---------------------------------------

function setup()
	MainGame.getInstance():setup()
	print(os.time(),"Battle.setup")
end

function execute(deltaT)
	MainGame.getInstance():execute(deltaT)
end

function leave()
	TASK_StageClear()	
	MainGame.getInstance():leave()
	print(os.time(),"Battle.leave")
end
function onClickReplay(name,type,id)
	if type == ACTION_CLICK then
		MainGame.getInstance():onClickReplay()
	end
end
function onClickReturn(name,type,id)
	if type == ACTION_CLICK then
		sysLoad("asset://app/views/Entry.lua")
	end
end
function callbackTP(tbl)
	MainGame.getInstance():callbackTP(tbl)
end