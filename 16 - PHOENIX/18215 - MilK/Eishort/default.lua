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
			OnCommand=cmd(decelerate,.15;addy,-750*scale;accelerate,0;addy,750*scale);
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
		82.5,
		83,
		83.5,
		94,
		94.75,
		114.5,
		115,
		115.5,
		126,
		126.75,
		242.5,
		243,
		243.5,
		254,
		254.75,
		274.5,
		275,
		275.5,
		286,
		286.75,
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
			PlayCommand=cmd(y,SCREEN_BOTTOM;decelerate,.15;addy,-750*scale;accelerate,0;addy,750*scale);
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