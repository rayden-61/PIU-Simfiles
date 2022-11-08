if GAMESTATE:GetCurrentSteps(GAMESTATE:GetMasterPlayerNumber()):GetDescription() ~= 'SLUMPAGE Infinity' then
	return Def.ActorFrame{}
end

local song_path= GAMESTATE:GetCurrentSong():GetSongDir()

-- Gets the Current Rate Mod
function vv_GetRateMod()
	
	--if true then return 0.5 end;
	
	--GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate()
	local so = GAMESTATE:GetSongOptions('ModsLevel_Song');
	Trace(so);
	local s = '';
	if not so then return 1.0 else s = so end
	if not s then return 1.0 end;
	
	local fbegin = string.find(s,'.',1,true);
	local fend = string.find(s,'xMusic');
	if fbegin and fend then
		return tonumber(string.sub(s,fbegin-1,fend-1));
	else
		return 1.0;
	end
	
	--TODO check if this works
	--return 1.0
	
end

RATEMOD = vv_GetRateMod()

local function vv_mod(str,pn)
	if pn then
		pn= 'PlayerNumber_P' .. pn
		local ps= GAMESTATE:GetPlayerState(pn)
		local pmods= ps:GetPlayerOptionsString('ModsLevel_Song')
		ps:SetPlayerOptions('ModsLevel_Song', pmods .. ', ' .. str)
	else
		for i=1,2 do
			pn= 'PlayerNumber_P' .. i
			local ps= GAMESTATE:GetPlayerState(pn)
			local pmods= ps:GetPlayerOptionsString('ModsLevel_Song')
			ps:SetPlayerOptions('ModsLevel_Song', pmods .. ', ' .. str)
		end
	end
end

local function get_speed_from_poptions(player_number)
	if GAMESTATE:IsPlayerEnabled(player_number) then
		local poptionsray= GAMESTATE:GetPlayerState(player_number):GetPlayerOptionsArray("ModsLevel_Song")
		local speed= nil
		local mode= nil
		for i, el in ipairs(poptionsray) do
			local fel= el:sub(1, 1)
			local lel= el:sub(-1)
			if fel == "m" or fel == "C" then
				speed= tonumber(el:sub(2))
				mode= fel
			elseif lel == "x" then
				speed= tonumber(el:sub(1, -2))
				mode= lel
			end
			if speed and mode then
				break
			end
		end
	end
	if not speed or not mode then
		speed= 2
		mode= "x"
	end
	return { speed= speed, mode= mode }
end

local function set_player_speed(player_number, speed_info)
	if not GAMESTATE:IsPlayerEnabled(player_number) then return end
	local mode_functions= {
		x= function(speed)
				 vv_mod(("*1000 %.2f"):format(speed).."x", pn)
			 end,
		C= function(speed)
				 vv_mod("*1000 C"..("%.0f"):format(speed), pn)
			 end,
		m= function(speed)
				 local max_bpm= GAMESTATE:GetCurrentSteps(pn):GetDisplayBpms()[2]
				 local real_speed= (speed / max_bpm)
				 -- Setting an mmod while on ScreenGameplay doesn't actually work, due to the way mmods are implemented in the engine.  So set the equivalent xmod
				 vv_mod(("*1000 %.2f"):format(real_speed).."x", pn)
			 end
	}
	mode_functions[speed_info.mode](speed_info.speed)
end

--alternates a mod back and forth before resetting to 0
--beat,num,div,amt,spdmult,mod,pn
function mod_wiggle(beat,num,div,amt,spdmult,mod,pn,first)
	local fluct = 1
	for i=0,(num-1) do
		b = beat+(i/div)
		local m = 1
		if i==0 and not first then m = 0.5 end
		table.insert(mods,{b,'*'..math.abs(spdmult*m*amt/10)..' '..(amt*fluct)..' '..mod..'',pn});
		fluct = fluct*-1;
	end
	table.insert(mods,{beat+(num/div),'*'..math.abs(spdmult*amt/20)..' no '..mod..'',pn});
end

function simple_m0d2(beat,strength,mult,mod,pn)
	if not strength then strength = 400 end
	if not mult then mult = 1 end
	if not mod then mod = 'drunk' end
	
	table.insert(mods,{beat,'*'..math.abs(strength/10)..' '..strength..' '..mod,pn});
	table.insert(mods,{beat+.3,'*'..((1/mult)*math.abs(strength)/100)..' no '..mod,pn});
end

local function vv_init()
	fgcurcommand = 0;
	checked = false;
	--self:queuecommand('Update');
	
	vv_speedmod = get_speed_from_poptions(PLAYER_1)
	
	local mult = 1.6;
	
	local swamt = 50;
	
	for pn=1,2 do
		if GAMESTATE:PlayerIsUsingModifier('PlayerNumber_P'..pn,'infinity') or GAMESTATE:PlayerIsUsingModifier('PlayerNumber_P'..pn,'rhythm') then
			swamt = 51.2
		end
	end
	
	--lua course :D	/ timed mod management	
	curmod = 1;
	--{time(seconds),mod,player}
	mods = {
		
		{0,'*10 '..swamt..' swapsides, *2 3x'},
		{12,'*'..(2.5*mult)..' -250 move0, *'..(1.5*mult)..' -150 move5, *'..(1.5*mult)..' -150 move1, *'..(0.5*mult)..' -50 move6, *'..(0.5*mult)..' -50 move2, *'..(0.5*mult)..' 50 move7, *'..(0.5*mult)..' 50 move3, *'..(1.5*mult)..' 150 move8, *'..(1.5*mult)..' 150 move4, *'..(2.5*mult)..' 250 move9'},
		{13.5,'*2.5 no move0, *1.5 no move5, *1.5 no move1, *0.5 no move6, *0.5 no move2, *0.5 no move7, *0.5 no move3, *1.5 no move8, *1.5 no move4, *2.5 no move9, *0.5 no swapsides'},
		
		--[[
		{18-.05,'*10 invert'},
		{19-.05,'*10 no invert'},
		]]
		
		{44,'*1000 90 dizzy'},
		{46,'*1000 -90 dizzy'},
		{48,'*1000 90 dizzy'},
		{50,'*1000 no dizzy'},
		
		{51-.05,'*10 30 tipsy'},
		{51.25-.05,'*20 -30 tipsy'},
		{51.5-.05,'*20 30 tipsy, *1000 500 beat'},
		{51.75-.05,'*20 -30 tipsy'},
		{52.25,'*1000 no beat'},
	
		{78,'*10000 no wave, *10000 no tornado, *10000 '..(2/RATEMOD)..'x'},
		
		{94.5-.05,'*10 100 drunk, *100 200 dizzy'},
		{94.75-.05,'*20 -100 drunk'},
		{95-.05,'*10 no drunk, *100 no dizzy'},
		{95.5-.05,'*10 100 drunk, *100 300 beat, *100 600 dizzy'},
		{95.75-.05,'*20 -100 drunk'},
		{96-.05,'*10 no drunk, *100 no dizzy'},
		
		{112.5,'*100 no beat'},
		
		{116,'3.2x'},
		
		{118,'*10 50 stealth, *10 50 drunk'},
		{118.4,'*1 no stealth, *1 no drunk'},
		{122,'*10 50 stealth, *10 -50 drunk'},
		{122.4,'*1 no stealth, *1 no drunk'},
		{126,'*10 50 stealth, *10 50 drunk'},
		{126.4,'*1 no stealth, *1 no drunk'},
		{130,'*10 50 stealth, *10 -50 drunk'},
		{130.4,'*1 no stealth, *1 no drunk'},
		{132,'*10 50 stealth, *10 50 drunk'},
		{132.4,'*1 no stealth, *1 no drunk'},
		{134,'*10 50 stealth, *10 -50 drunk'},
		{134.4,'*1 no stealth, *1 no drunk'},
		{138,'*10 50 stealth, *10 50 drunk'},
		{138.4,'*1 no stealth, *1 no drunk'},
		{142,'*10 50 stealth, *10 -50 drunk'},
		{142.4,'*1 no stealth, *1 no drunk'},
		{146,'*10 50 stealth, *10 50 drunk'},
		{146.4,'*1 no stealth, *1 no drunk'},
		{148,'*10 50 stealth, *10 -50 drunk'},
		{148.4,'*1 no stealth, *1 no drunk'},
		{149,'*10 50 stealth, *10 -50 drunk'},
		{149.4,'*1 no stealth, *1 no drunk'},
		
		{150,'*10 50 stealth, *10 50 drunk, 150 bumpy'},
		{150.4,'*1 no stealth, *1 no drunk, 150 bumpy'},
		{154,'*10 50 stealth, *10 -50 drunk, 150 bumpy'},
		{154.4,'*1 no stealth, *1 no drunk, 150 bumpy'},
		{158,'*10 50 stealth, *10 50 drunk, 150 bumpy'},
		{158.4,'*1 no stealth, *1 no drunk, 150 bumpy'},
		{162,'*10 50 stealth, *10 -50 drunk, 150 bumpy'},
		{162.4,'*1 no stealth, *1 no drunk, 150 bumpy'},
		{164,'*10 50 stealth, *10 50 drunk, 150 bumpy'},
		{164.4,'*1 no stealth, *1 no drunk, 150 bumpy'},
		{166,'*10 50 stealth, *10 -50 drunk, 150 bumpy'},
		{166.4,'*1 no stealth, *1 no drunk, 150 bumpy'},
		{168,'*10 50 stealth, *10 -50 drunk, 150 bumpy'},
		{168.4,'*1 no stealth, *1 no drunk, 150 bumpy'},
		{170,'*10 50 stealth, *10 50 drunk, 150 bumpy'},
		{170.4,'*1 no stealth, *1 no drunk, 150 bumpy'},
		{172,'*10 50 stealth, *10 50 drunk, 150 bumpy'},
		{172.4,'*1 no stealth, *1 no drunk, 150 bumpy'},
		{174,'*10 50 stealth, *10 -50 drunk, 150 bumpy'},
		{174.4,'*1 no stealth, *1 no drunk, 150 bumpy'},
		{176,'*10 50 stealth, *10 -50 drunk, 150 bumpy'},
		{176.4,'*1 no stealth, *1 no drunk, 150 bumpy'},
		{178,'*2 50 stealth, *2 50 drunk, 150 bumpy'},
		{179,'*2 no stealth, *2 no drunk, 150 bumpy'},
		{180,'*2 50 stealth, *2 50 drunk, 150 bumpy'},
		{181,'*2 no stealth, *2 no drunk, 150 bumpy'},
		
		{182,'*1000 no bumpy, *100000 314.15 dizzy, *10000 30 swapsides, *10000 200 move0, *10000 100 move1, *10000 0 move2, *10000 -100 move3, *10000 -200 move4, *10000 200 move5, *10000 100 move6, *10000 0 move7, *10000 -100 move8, *10000 -200 move9, *10000 centered, *10000 -200 tornado, *10000 2x, *10000 brake'},
		{186,'*100000 628 dizzy'},
		{194,'*2 no tornado, *6.28 no dizzy, *0.4 no swapsides, no brake, no centered, *2 no move0, no move1, no move3, *2 no move4, *2 no move5, no move6, no move8, *2 no move9,'},
		{196,'3x'},
		
		{206,'*22 220 hallway'},
		{206.3,'*2 no hallway'},
		
		{210,'*10 50 stealth, *10 50 drunk'},
		{210.4,'*1 no stealth, *1 no drunk'},
		{214,'*10 50 stealth, *10 -50 drunk'},
		{214.4,'*1 no stealth, *1 no drunk'},
		{218,'*10 50 stealth, *10 50 drunk'},
		{218.4,'*1 no stealth, *1 no drunk'},
		{222,'*10 50 stealth, *10 -50 drunk'},
		{222.4,'*1 no stealth, *1 no drunk'},
		{224,'*10 50 stealth, *10 50 drunk'},
		{224.4,'*1 no stealth, *1 no drunk'},
		{226,'*10 50 stealth, *10 -50 drunk'},
		{226.4,'*1 no stealth, *1 no drunk'},
		{230,'*10 50 stealth, *10 50 drunk'},
		{230.4,'*1 no stealth, *1 no drunk'},
		{234,'*10 50 stealth, *10 -50 drunk'},
		{234.4,'*1 no stealth, *1 no drunk'},
		{238,'*10 50 stealth, *10 -50 drunk'},
		{238.4,'*1 no stealth, *1 no drunk'},
		
		{240,'*20 25 distant'},
		{240.5,'*20 50 distant'},
		{241,'*20 75 distant'},
		{241.5,'*20 100 distant'},
		
		{242,'*10 50 stealth, *10 50 drunk'},
		{242.4,'*1 no stealth, *1 no drunk'},
		{246,'*10 50 stealth, *10 -50 drunk'},
		{246.4,'*1 no stealth, *1 no drunk'},
		{250,'*10 50 stealth, *10 50 drunk'},
		{250.4,'*1 no stealth, *1 no drunk'},
		
		{254,'*10 no distant'},
		{255,'*10 invert'},
		{256,'*10 distant'},
		{257,'*10 no invert'},
		
		{258,'*0.08 40 drunk, *0.2 150 distant, *0.1 40 bumpy, *100 50 beat, *10 -10000 move0'},
		{260,'*10 10000 move9, *10 -10000 move0'},
		{262,'*10 -10000 move1, *10 10000 move9, *10 -10000 move0'},
		{264,'*10 10000 move8, *10 -10000 move1, *10 10000 move9, *10 -10000 move0'},
		{266,'*50 50 stealth, *10 10000 move8, *10 -10000 move1, *10 10000 move9, *10 -10000 move0'},
		{266.2,'*5 no stealth, *10 10000 move8, *10 -10000 move1, *10 10000 move9, *10 -10000 move0'},
		{268,'*50 50 stealth, *10 10000 move8, *10 -10000 move1, *10 10000 move9, *10 -10000 move0'},
		{268.2,'*5 no stealth, *10 10000 move8, *10 -10000 move1, *10 10000 move9, *10 -10000 move0'},
		{270,'*50 50 stealth'},
		{270.2,'*5 no stealth'},
		{271,'*50 50 stealth'},
		{271.2,'*5 no stealth'},
		{272,'*50 50 stealth'},
		{272.2,'*5 no stealth'},
		{273,'*50 50 stealth'},
		{273.2,'*5 no stealth, *100 no beat'},
		{274,'*4 no drunk, *10 no bumpy'},

	}
	
	for i=16,43.6,1 do
		if i==16 or i==32 then
			local str = '*10 30 drunk, *7 20 brake'
			table.insert(mods,{i-.05,str})
		else
			local str = '*20 30 drunk, *7 20 brake'
			if i==18 then str = str..', *10 80 stealth' end
			if i==19 then str = str..', *10 no stealth' end
			if i==21 then str = str..', *10 80 stealth' end
			if i==24 then str = str..', *10 no stealth' end
			if i==26 then str = str..', *10 80 stealth' end
			if i==27 then str = str..', *10 no stealth' end
			if i==29 then str = str..', *10 80 stealth' end
			if i==30 then str = str..', *10 no stealth' end
			if i==34 then str = str..', *10 80 stealth' end
			if i==35 then str = str..', *10 no stealth' end
			if i==37 then str = str..', *10 80 stealth' end
			if i==41 then str = str..', *10 no stealth' end
			table.insert(mods,{i-.05,str})
		end
		local str = '*6 no drunk, *4 no brake'
		if i==18 then str = str..', *10 80 stealth' end
		if i==19 then str = str..', *10 no stealth' end
		if i==21 then str = str..', *10 80 stealth' end
		if i==24 then str = str..', *10 no stealth' end
		if i==26 then str = str..', *10 80 stealth' end
		if i==27 then str = str..', *10 no stealth' end
		if i==29 then str = str..', *10 80 stealth' end
		if i==30 then str = str..', *10 no stealth' end
		if i==34 then str = str..', *10 80 stealth' end
		if i==35 then str = str..', *10 no stealth' end
		if i==37 then str = str..', *10 80 stealth' end
		if i==41 then str = str..', *10 no stealth' end
		table.insert(mods,{i+.2,str})
		if i~= 31 then
			table.insert(mods,{i+.5-.05,'*20 -30 drunk, *7 20 brake'})
			table.insert(mods,{i+.5+.1,'*3 no drunk, *2 no brake'})
		end
	end
	
	local beats = {52,52.5,53,53.5,
					54.25,54.75,55.25,55.5,
					56,56.5,56.75,57.25,57.75,
					58,58.5,59,59.75,
					60.25,60.75,61.25,
					62,62.5,63,63.25,63.75,
					64.25,64.5,65,65.5,65.75,
					66.25,66.75,67.5,
					68,68.5,69,69.75,
					70.25,70.75,71,71.5,
					72,72.25,72.75,73.25,73.5,
					74,74.5,75.25,75.75}
	
	local fluct = 1
	for i=1,#beats do
		
		local str = '*30 '..(50*fluct)..' drunk, *15 50 brake'
		if beats[i] == 52 then str = str..',*10 no tipsy' end
		if beats[i] == 58 or beats[i] == 59 then str = str..',*10 invert' end
		if beats[i] == 58.5 or beats[i] == 59.75 then str = str..',*10 no invert' end
		if beats[i] >= 72 then str = str..', *0.6 wave, *0.2 tornado' end
		table.insert(mods,{beats[i]-.05,str})
		
		local str = '*4 no drunk, *4 no brake'
		if beats[i] == 52 then str = str..',*10 no tipsy' end
		if beats[i] == 58 or beats[i] == 59 then str = str..',*10 invert' end
		if beats[i] == 58.5 or beats[i] == 59.75 then str = str..',*10 no invert' end
		if beats[i] >= 72 then str = str..', *0.6 wave, *0.2 tornado' end
		table.insert(mods,{beats[i]+.1,str})
		
		fluct = fluct*-1;
	end
	
	--beat,num,div,amt,spdmult,mod,pn
	mod_wiggle(98.-.05,8,4,50,5,'drunk');
	mod_wiggle(102.-.05,8,4,20,5,'tipsy');
	mod_wiggle(106.-.05,8,4,50,5,'drunk');
	mod_wiggle(110.-.05,8,4,20,5,'tipsy');
	
	simple_m0d2(112,200,2,'Tornado');
	
	simple_m0d2(196,800,1,'Bumpy');
	
	curaction = 1;
	--{beat,message,persists}
	actions = {
		{44,function()
			for pn=1,2 do
				local a = _G['P'..pn]
				if a then
					a:decelerate(2*(60/140)/RATEMOD)
					a:rotationy(30);
					a:decelerate(2*(60/140)/RATEMOD)
					a:rotationy(-30);
					a:decelerate(2*(60/140)/RATEMOD)
					a:rotationy(30);
					a:decelerate(2*(60/140)/RATEMOD)
					a:rotationy(0);
				end
			end
		end},
		{16,'WhiteFlashM'},
		{44,'WhiteFlashM'},
		{46,'WhiteFlashM'},
		{48,'WhiteFlashM'},
		{50,'WhiteFlashM'},
		{52,'WhiteFlashM'},
		{78,'Yes'},
		{112,function()
			for pn=1,2 do
				local a = _G['P'..pn]
				if a then
					a:decelerate(6*(60/140)/RATEMOD)
					--a:tween(6*(60/140),{1,0,0,1})
					a:y(0)
					a:rotationz(360)
					a:sleep(0)
					a:rotationz(0)
				end
			end
		end},
		{178,function()
			for pn=1,2 do
				local a = _G['P'..pn]
				if a then
					a:zoom(1);
					a:rotationz(0);
					a:linear(60/175.625/RATEMOD)
					a:zoom(0.7)
					--a:rotationz(20);
					a:linear(60/175.625/RATEMOD)
					a:zoom(1)
					a:rotationz(0);
					a:linear(60/175.625/RATEMOD)
					a:zoom(0.7)
					--a:rotationz(-20);
					a:linear(60/175.625/RATEMOD)
					a:zoom(1)
					a:rotationz(0);
				end
			end
		end},
		{182,'WhiteFlashLong'},
		{182,function()
			for pn=1,2 do
				local a = _G['P'..pn]
				if a then
					a:finishtweening();
					a:y(SCREEN_CENTER_Y)
					a:linear(4*60/152.478/RATEMOD)
					a:rotationz(360*2)
					a:linear(4*60/82.873/RATEMOD)
					a:rotationz(360*6)
					a:linear(4*60/78.201/RATEMOD)
					a:rotationz(360*10)
					a:decelerate(2*60/88.790/RATEMOD)
					a:rotationz(360*11)
					a:sleep(0);
					a:rotationz(0);
				end
			end
		end},
		-- Yet another StepF2 fix -Nirvash-
			{186,function()
			for pn=1,2 do
				local a = _G['P'..pn]
				if a then
					a:y(0)
				end
			end
		end},
		
		{198,function()
			for pn=1,2 do
				local a = _G['P'..pn]
				if a then
					a:vibrate()
					a:effectmagnitude(0,10,0);
				end
			end
		end},
		{206,function()
			for pn=1,2 do
				local a = _G['P'..pn]
				if a then
					a:stopeffect()
				end
			end
		end},
		{240-.05,function()
			for pn=1,2 do
				local a = _G['P'..pn]
				if a then
					a:linear(5/186/RATEMOD)
					a:zoomz(1.2)
					a:sleep(25/186/RATEMOD)
					a:linear(5/186/RATEMOD)
					a:zoomz(1.4)
					a:sleep(25/186/RATEMOD)
					a:linear(5/186/RATEMOD)
					a:zoomz(1.6)
					a:sleep(25/186/RATEMOD)
					a:linear(5/186/RATEMOD)
					a:zoomz(1.8)
					a:sleep(25/186/RATEMOD)
				end
			end
		end},
		{242,function()
			for pn=1,2 do
				local a = _G['P'..pn]
				if a then
					a:linear(12*60/185/RATEMOD)
					a:zoomz(2.5);
					a:linear(60/185/RATEMOD)
					a:zoomz(1);
					a:sleep(60/185/RATEMOD)
					a:linear(60/185/RATEMOD)
					a:zoomz(2.5);
				end
			end
		end},
		{258,function()
			for pn=1,2 do
				local a = _G['P'..pn]
				if a then
					a:linear(16*60/185/RATEMOD)
					a:zoomz(4);
					a:linear(8*60/185/RATEMOD)
					a:zoomz(500);
				end
			end
		end},
				{274,function()
			for pn=1,2 do
				local a = _G['P'..pn]
				if a then
					a:y(-20)
				
				end
			end
		end},
			{274,function()
			for pn=1,2 do
				local a = _G['P'..pn]
				if a then
					a:z(560)
				
				end
			end
		end},
	}
	
	function vv_scalething(beat,bpm,ang,s)
		table.insert(actions,{beat,function()
			for pn=1,2 do
				local a = _G['P'..pn]
				if a then
					a:finishtweening()
					a:zoom(1);
					a:rotationz(0);
					a:decelerate(90/bpm)
					a:rotationz(ang);
					a:zoom(s)
				end
			end
		end})
	end
	
	vv_scalething(118,147.5,6,0.9)
	vv_scalething(122,148,-7,0.9)
	vv_scalething(126,148,8,0.85)
	vv_scalething(130,148,-9,0.85)
	vv_scalething(132,148,10,0.85)
	
	vv_scalething(134,157.8,-10,0.8)
	vv_scalething(138,158.5,10,0.8)
	vv_scalething(142,158.5,-10,0.8)
	vv_scalething(146,158.5,10,0.8)
	vv_scalething(148,158.5,-10,0.8)
	vv_scalething(149,158.5,-10,0.8)
	
	vv_scalething(150,167.75,12,0.8)
	vv_scalething(154,167.75,-12,0.8)
	vv_scalething(158,167.75,12,0.8)
	vv_scalething(162,167.75,-12,0.8)
	vv_scalething(164,167.75,14,0.8)
	
	vv_scalething(166,175.040,-14,0.75)
	vv_scalething(168,175.040,14,0.75)
	vv_scalething(170,175.040,-14,0.75)
	vv_scalething(172,175.625,14,0.75)
	vv_scalething(174,175.625,-14,0.75)
	vv_scalething(176,175.625,14,0.75)
	
	function time_compare(a,b)
		return a[1] < b[1]
	end
	
	if table.getn(mods) > 1 then
		table.sort(mods, time_compare)
	end
	
	if table.getn(actions) > 1 then
		table.sort(actions, time_compare)
	end
	
end

vv_cenpos = 0;
vv_cenpos_last = 0;
vv_cenreset = 81-0.05;

mod_firstSeenBeat = GAMESTATE:GetSongBeat()

local function vv_update(self, delta)
	if GAMESTATE:GetSongBeat()>0 and not checked then
		
		P1 = SCREENMAN:GetTopScreen():GetChild('PlayerP1');
		P2 = SCREENMAN:GetTopScreen():GetChild('PlayerP2');
		
		for pn=1,2 do
			local a = _G['P'..pn]
			if a then
				a:zoom(1);
				a:y(0);
				a:rotationz(0);
				a:zoomz(1)
			end
		end
		
		screen = SCREENMAN:GetTopScreen();
		checked = true;
		
	end
	
	local beat = GAMESTATE:GetSongBeat()
	
	if beat>80 and beat > mod_firstSeenBeat+1 and beat<111.99 then
		if beat<vv_cenreset then
			vv_cenpos = vv_cenpos+(5.7)
		else
			vv_cenpos = 0
			vv_cenreset = vv_cenreset+1
		end
	end
	
	if beat>80 and beat<111.99 then
		for pn=1,2 do
			local a = _G['P'..pn]
			if a then
				if vv_cenpos > vv_cenpos_last then
					a:linear(0.02)
				end
				a:y(0+vv_cenpos)
			end
		end
	end
	
	vv_cenpos_last = vv_cenpos
	
---------------------------------------------------------------------------------------
----------------------DON'T TOUCH IT KIDDO---------------------------------------------
---------------------------------------------------------------------------------------
	
	--custom mod reader (c) 2014 #taronuke #yolo #swag #swag #amazon.co.jp #teamproofofconcept #swag
	while curmod<= #mods and GAMESTATE:GetSongBeat()>=mods[curmod][1] do
		for i=1,2 do
			local pn= 'PlayerNumber_P' .. i
			local ps= GAMESTATE:GetPlayerState(pn)
			local pmods= ps:GetPlayerOptionsString('ModsLevel_Song')
			ps:SetPlayerOptions('ModsLevel_Song', pmods .. ', ' .. mods[curmod][2])
		end
		curmod = curmod+1;
	end
	
	while curaction<=table.getn(actions) and GAMESTATE:GetSongBeat()>=actions[curaction][1] do
		if actions[curaction][3] or GAMESTATE:GetSongBeat() < actions[curaction][1]+2 then
			if type(actions[curaction][2]) == 'function' then
				actions[curaction][2]()
			elseif type(actions[curaction][2]) == 'string' then
				Trace('Message: '..actions[curaction][2]);
				MESSAGEMAN:Broadcast(actions[curaction][2]);
			end
		end
		curaction = curaction+1;
	end

---------------------------------------------------------------------------------------
----------------------END DON'T TOUCH IT KIDDO-----------------------------------------
---------------------------------------------------------------------------------------
end

local t = Def.ActorFrame{
	OnCommand= function(self)
							 songName = GAMESTATE:GetCurrentSong():GetSongDir();
							 vv_init()
							 --self:SetUpdateFunction(vv_update)
						 end,
	Def.Quad{
		OnCommand=cmd(visible,false;sleep,1000);
	},
		Def.BitmapText{
			Font="Common Normal";
			OnCommand=cmd(Center;queuecommand,"Update");
			UpdateCommand=function(self)
				--self:settext((curaction or "nil!").."/"..table.getn(actions).."\n"..GAMESTATE:GetSongBeat());
				self:sleep(0.02);
				vv_update();
				self:queuecommand("Update");
			end;
		};
	LoadActor('yes')..{
		OnCommand=cmd(zoomto,SCREEN_WIDTH,SCREEN_HEIGHT;x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;diffusealpha,0);
		YesMessageCommand=cmd(diffusealpha,1;accelerate,120/140/RATEMOD;diffusealpha,0);
	},
	Def.Quad{
		OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;zoomto,SCREEN_WIDTH,SCREEN_HEIGHT;diffuse,0,0,0,0),
		WhiteFlashLongMessageCommand=cmd(diffuse,1,1,1,1.04;linear,2/RATEMOD;diffusealpha,0),
		WhiteFlashMessageCommand=cmd(diffuse,1,1,1,1;linear,1/RATEMOD;diffusealpha,0),
		WhiteFlashQMessageCommand=cmd(diffuse,1,1,1,0.4;linear,0.6/RATEMOD;diffusealpha,0),
		WhiteFlashMMessageCommand=cmd(finishtweening;diffuse,1,1,1,0.8;linear,0.8/RATEMOD;diffusealpha,0),
	},
}

return t
