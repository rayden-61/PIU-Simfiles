local ratio = PREFSMAN:GetPreference("DisplayAspectRatio")




if (ratio > 1.5) then
	return LoadActor("13-Toccata-bg.png")..{
	OnCommand=cmd(Center;FullScreen;sleep,3.00);
	}
else
	return LoadActor("13-Toccata-bg.png")..{
	OnCommand=cmd(Center;FullScreen;sleep,3.00);
}
end;
