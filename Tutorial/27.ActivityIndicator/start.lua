function setup()
	GL_ClearColor(0.5,0.5,0.0,1)
	pActI = UI_ActivityIndicator(nil,ACTI_TYPE_GRAY,50,50,50,50)
	sysCommand(pActI,UI_ACTI_ANIM_START)
	lasttime = os.time()

	pdb = DB_open("asset://userinfo.sqlite",true,true)
	-- DB_query(pdb,"CREATE TABLE user ('name' TEXT, 'value' TEXT)")
	DB_close(pdb)
end

function execute(deltaT)
	if os.time() - lasttime > 5 then
		sysCommand(pActI,UI_ACTI_ANIM_STOP)
	end
end

function leave()

end
