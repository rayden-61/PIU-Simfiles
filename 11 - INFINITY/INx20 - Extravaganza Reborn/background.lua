local ratio = PREFSMAN:GetPreference("DisplayAspectRatio")




if (ratio > 1.5) then
	return LoadActor("IN18-wide.png")..{
		OnCommand=cmd(Center);
	}
else
	return LoadActor("IN18.png")..{
	OnCommand=cmd(Center);
}
end;


	