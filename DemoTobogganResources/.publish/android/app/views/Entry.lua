bgm = SND_Open("asset://assets/Sounds/bgm", true)
seON = SND_Open("asset://assets/Sounds/se_on")
seOFF = SND_Open("asset://assets/Sounds/se_off")
seDRAG = SND_Open("asset://assets/Sounds/se_drag")
local Entry = class("Entry")
local entry = Entry:new()

function Entry:setup(  )
	self.pForm = UI_Form(nil,	-- arg[1]:	親となるUIタスクのポインタ
		1000,		-- arg[2]:	基準表示プライオリティ
		0, 0,		-- arg[3,4]:	表示位置
		"asset://app/views/Entry.json",	-- arg[5]:	composit jsonのパス
		false		-- arg[6]:	排他フラグ
	)
	--[[
		arg[6]:排他フラグ は、省略可能です。
		省略した場合は false と同じ挙動になります。
	]]
	
	TASK_StageOnly(self.pForm)
	self.minScale = 0.9
	self.maxScale = 1.1
	self.goScale = 1
	self.isAdd = true	
end
function Entry:update( deltaT )
	if self.isAdd then
		self.goScale = self.goScale+ deltaT*0.0005
	else
		self.goScale = self.goScale - deltaT*0.0005
	end
	sysCommand(self.pForm, UI_FORM_UPDATE_NODE,"Go", FORM_NODE_SCALE, self.goScale,self.goScale)
	if self.goScale > self.maxScale then
		self.isAdd = false
	elseif self.goScale < self.minScale then
		self.isAdd = true
	end	
end
function Entry:leave(  )
	TASK_StageClear()
	TASK_kill(self.pForm)
end
function Entry:onClickGO( name,type,id )
	if type == ACTION_CLICK  then
		sysLoad("asset://app/views/Battle.lua")
		SND_Play(seON)
	end
	syslog('----- Entry.onClickGO() -----'..string.format("name:%s,type:%s,id:%s",name,type,id))
end
function Entry:onClickCheck(name,type,id )
	if type == ACTION_CLICK  then
		Config.isDebug = not Config.isDebug

		if Config.isDebug then
			sysCommand(self.pForm, UI_FORM_UPDATE_NODE, "lblBox", FORM_LBL_SET_TEXT, "Show border" )
			SND_Play(seON)
		else
			SND_Play(seOFF)
			sysCommand(self.pForm, UI_FORM_UPDATE_NODE, "lblBox", FORM_LBL_SET_TEXT, "Close border" )
		end
	end	
	print('----- Entry.onClickCheck() -----'..string.format("name:%s,type:%s,id:%s",name,type,id),Config.isDebug)
end

function setup()
	entry:setup()
end

function execute(deltaT)
	entry:update(deltaT)
end

function leave()
	entry:leave()
end


function onClickGO(name,type,id)
	entry:onClickGO(name,type,id)
end
function onClickCheck( name,type,id )
	entry:onClickCheck(name,type,id)
end
