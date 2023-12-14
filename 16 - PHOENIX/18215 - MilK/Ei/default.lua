local function retFrame_simple()
	--[[
		Different themes use different resolutions, so make sure this PNG
		is always scaled properly.
	]]
	local scale = SCREEN_HEIGHT/1080

	return Def.ActorFrame{
		Def.Sprite{
			Name="EiBounce";
			Texture="Ei";
			InitCommand=cmd(zoom,scale;xy,SCREEN_CENTER_X,SCREEN_BOTTOM;vertalign,top);
			OnCommand=cmd(decelerate,.1;addy,-750*scale;accelerate,.6;addy,750*scale);
		};
	}
end;


local function retFrame()
	--[[
		Different themes use different resolutions, so make sure this PNG
		is always scaled properly.
	]]
	local scale = SCREEN_HEIGHT/1080
	
	local beats = {
		--1,
		--1.25,
		--1.5,
		--1.75,
		70,
		74,
		78,
		86,
		90,
		95.50,
		102,
		106,
		110,
		118,
		122,
		127.50,
		230,
		234,
		238,
		246,
		250,
		255.50,
		262,
		266,
		270,
		278,
		282,
		287.50,
		999 --lol
	}
	
	--lua is 1 indexed...
	local currentIndex = 1;
	local spr;

	return Def.ActorFrame{
		
		
		OnCommand=function(self)
			self:SetUpdateFunction(function(actorFrame,delta)
				local b = GAMESTATE:GetSongBeat();
				if currentIndex < #beats and b+.2 >= beats[currentIndex] then
					currentIndex=currentIndex+1;
					
					--StepP1 is bugged and I can't do this commmand in one line
					spr:stoptweening()
					spr:queuecommand("Play");
					
					
				end;
			end)
			--Need this because fgchanges won't display without a tween
			self:sleep(120);
		end;
		
		Def.Sprite{
			Name="EiBounce";
			Texture="Ei";
			InitCommand=cmd(zoom,scale;xy,SCREEN_CENTER_X,SCREEN_BOTTOM;vertalign,top);
			OnCommand=function(self)
				spr = self;
			end;
			PlayCommand=cmd(y,SCREEN_BOTTOM;decelerate,.1;addy,-750*scale;accelerate,.6;addy,750*scale);
		};
		--[[Def.Sprite{
			Name="EiFlash";
			Texture="Ei";
			InitCommand=cmd(zoom,scale;xy,SCREEN_CENTER_X,SCREEN_BOTTOM;vertalign,top;addy,-750*scale);
			OnCommand=cmd(visible,false);
		}]]
	}
end;

--do return retFrame() end;

for pn in ivalues(GAMESTATE:GetEnabledPlayers()) do
	if GAMESTATE:GetCurrentSteps(pn):GetChartName() == "Dango MilK" then
		--If at least one player is playing this chart, display the image
		return retFrame();
	end;
end;


--Return empty frame if we don't want to display.
--If we got this far, neither player is playing that chart.
return Def.ActorFrame{};

--S. Ferri was here