local ratio = PREFSMAN:GetPreference("DisplayAspectRatio")




if (ratio > 1.5) then
	return LoadActor("12-Xuxa-bg2-bg.png")..{
	OnCommand=cmd(Center;FullScreen;sleep,1.45);
	}
else
	return LoadActor("12-Xuxa-bg2-bg.png")..{
	OnCommand=cmd(Center;FullScreen;sleep,1.45);
}
end;
