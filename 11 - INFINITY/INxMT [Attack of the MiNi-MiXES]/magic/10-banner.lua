local ratio = PREFSMAN:GetPreference("DisplayAspectRatio")




if (ratio > 1.5) then
	return LoadActor("10-Dawn of the Apocalypse-bg.png")..{
	OnCommand=cmd(Center;FullScreen;sleep,3.00);
	}
else
	return LoadActor("10-Dawn of the Apocalypse-bg.png")..{
	OnCommand=cmd(Center;FullScreen;sleep,3.00);
}
end;
