local ratio = PREFSMAN:GetPreference("DisplayAspectRatio")




if (ratio > 1.5) then
	return LoadActor("IN46-wide.png")..{
		OnCommand=cmd(Center);
	}
else
	return LoadActor("IN46.png")..{
	OnCommand=cmd(Center);
}
end;


	