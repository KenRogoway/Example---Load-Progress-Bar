application =
{
	content =
	{
		width = 320,
		height = 480,
		scale = "letterbox",
		fps = 30,
		antialias = true,
		
		imageSuffix =
		{
			["@2x"] = 2,
		}
	}
}

local sysModel = system.getInfo("model")

if sysModel == "iPad" then

	application = 
	{
		content = 
		{ 
			width = 768,
			height = 1024,
			scale = "letterbox",
			fps = 30,
			
			imageSuffix = {
				["@2x"] = 2,
			}
		}
	}
end