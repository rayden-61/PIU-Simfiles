local ratio = PREFSMAN:GetPreference("DisplayAspectRatio")




if (ratio > 1.5) then
	return LoadActor("01-Canon D-bg.png")..{
	OnCommand=cmd(Center;FullScreen);
	}
else
	return LoadActor("01-Canon D-bg.png")..{
	OnCommand=cmd(Center;FullScreen);
}
end;
