Config = {}

-- car thief
Config.EnterMessage = 'Press [E] To enter the target garage'
Config.StartMission = 'Press [E] To speak with car guy'
-- npc config

Config.Invincible = true
Config.Frozen = true 
Config.Stoic = true 
Config.Fade = true
Config.Distance = 15.0

Config.MinusOne = true

Config.PedList = {
	{
		model = "csb_car3guy1", -- Sell vehicle
		coords = vector3(-3083.549, 220.4428, 13.99717),
		heading = 320.0, 
		gender = "male", 
	    isRendered = false,
        ped = nil,
    },
    {
		model = "csb_car3guy1", -- Start car thief
		coords = vector3(1275.563, -1710.549, 54.77142),
		heading = 100.0, 
		gender = "male", 
	    isRendered = false,
        ped = nil,
    },
}