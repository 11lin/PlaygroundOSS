local pForm = nil

bgm = SND_Open("asset://assets/Sounds/bgm", true)
seON = SND_Open("asset://assets/Sounds/se_on")
seOFF = SND_Open("asset://assets/Sounds/se_off")
seDRAG = SND_Open("asset://assets/Sounds/se_drag")
function setup()
	local x = 0
	local y = 0
	pForm = UI_Form(nil,	-- arg[1]:	親となるUIタスクのポインタ
		1000,		-- arg[2]:	基準表示プライオリティ
		x, y,		-- arg[3,4]:	表示位置
		"asset://app/views/Entry.json",	-- arg[5]:	composit jsonのパス
		false		-- arg[6]:	排他フラグ
	)
	--[[
		arg[6]:排他フラグ は、省略可能です。
		省略した場合は false と同じ挙動になります。
	]]
	
	TASK_StageOnly(pForm)
end

function execute(deltaT)
end

function leave()
	TASK_StageClear()
	TASK_kill(pForm)
end


function onClickGO(name,type,id)
	if type == ACTION_CLICK  then
		sysLoad("asset://app/views/Battle.lua")
		SND_Play(seON)
	end
	syslog('----- Entry.onClickGO() -----'..string.format("name:%s,type:%s,id:%s",name,type,id))
	-- sysLoad("asset://form1.lua")
end
function onClickCheck( name,type,id )
	if type == ACTION_CLICK  then
		Config.isDebug = not Config.isDebug
		if Config.isDebug then
			SND_Play(seON)
		else
			SND_Play(seOFF)
		end
	end	
	print('----- Entry.onClickCheck() -----'..string.format("name:%s,type:%s,id:%s",name,type,id),Config.isDebug)
end
