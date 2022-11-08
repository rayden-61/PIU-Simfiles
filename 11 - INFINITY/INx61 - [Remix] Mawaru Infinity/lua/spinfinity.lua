local sw = SCREEN_WIDTH
local sh = SCREEN_HEIGHT
local t = Def.ActorFrame {}
t[#t+1] = Def.ActorFrame {
	OnCommand=cmd(x,9999;sleep,999)	
};

t[#t+1] = Def.ActorFrame {
	OnCommand=function(self)
		local screen = SCREENMAN:GetTopScreen();
		local P1 = SCREENMAN:GetTopScreen():GetChild('PlayerP1');
		local P2 = SCREENMAN:GetTopScreen():GetChild('PlayerP2');
		if P1 then P1:decelerate(1.20);P1:y(math.floor(sh*.50));P1:decelerate(2.00); P2:rotationz(360); P1:y(math.floor(sh*.00));P1:decelerate(2.40); end
		if P2 then P2:decelerate(1.20);P2:y(math.floor(sh*.50));P2:decelerate(2.00); P2:rotationz(360); P2:y(math.floor(sh*.00));P2:decelerate(2.40); end
	end;
};

return t;