CUR = "$"
-------------
-- LightRP
-- Rick Darkaliono aka DarkCybo1
-- Jan 22, 2007
-- Done Jan 26, 2007
-- This script isn't a representation of my skillz
-------------
-- DarkRP v1.07
-- By: Rickster
-- Done June 15, 2007
-------------
-- v2.0 and up
-- By: Pcwizdan / Silent Inferno
-- All credit goes to Rickster, v2.0 just a Fix/Cleanup Mod
-------------
-- DarkRP 2008 v2.21 E
-- by philxyz
-- code cleanup
-- earthquake
-------------
-- DarkRP 2008 v2.22 E
-- by philxyz
-------------
-- DarkRP 2.2.3
-- by philxyz
-- fix the name, it was getting stupid.
-- add a /queryvar command so clients can see what a given server var is are set to
-- chat.lua now checks whole command, not just first letters
-- fix simple prop protection compatibility
-- fix scroll direction in F1 menu
-- fix prices being 0 on initial load
-- chief can now set the jailpos as well as admin
-- anti-deathmatch feature rp_dm_autokick, rp_dm_maxkills and rp_dm_gracetime
-- move sv_earthquakes and sv_earthquake_chance_is_1_in to the rp_ namespace
-- allow searching by player name and steam ID for /playerwarrant etc
-- more code clean up (spaces for tabs, remove semicolons)
-- only gangs can spawn druglabs. Like in DarkRP 2.1
-------------
-- DarkRP 2.2.4
-- by philxyz and [GNC] Matt
-- philxyz: Arrested players are now on suicide watch! (no kill in console)
-- philxyz: Arrested players when killed, will not respawn until their time in jail is served
-- philxyz: CPs can only smash in doors with a warrant set on one of the door's owners (rp_doorwarrants 1 default)
-- philxyz: If a gangster or the mobboss steals a battering ram, they can use it as they wish
-- philxyz: If there is a Mayor, he must approve /playerwarrant requests by CPs
-- philxyz: When someone gets demoted, they can not rejoin that job until the timer is up (rp_demotetime 120) 2 mins by default
-- philxyz: Fix a bunch of Lua errors
-- philxyz: Fix the baton view model errors
-- philxyz: Fixed the last wrongly labelled "Max Gundealers Reached" Notify()
-- philxyz & [GNC] Matt: FindPlayer() is now case insensitive
-- philxyz: Backport /give and /moneydrop from my new unreleased gamemode. Fractional amounts are now not allowed and minimum give amount is 2 dollars
-- philxyz: Lockpick has random chance of success and can open vehicles
-- philxyz: Shipments now come in crates
-- philxyz: Disable mayor help on mayor death
-- [GNC] Matt: Police Chief spawn position fix
-- [GNC] Matt: Hit and run now registers as a kill by the driver
-- [GNC] Matt: Battering ram can force people out of vehicles
-- [GNC] Matt: Keys work on vehicles at a greater distance
-------------
-- DarkRP 2.2.5
-- by philxyz and [GNC] Matt
-- [GNC] Matt: Simplify chat.lua
-- [GNC] Matt: Fix a money related typo
-- philxyz: Player has died in jail is now printed in the middle of the screen
-- philxyz: Replace IsValid() with calls to G.ValidEntity()
-- philxyz: Use the Unix find and sed commands to clean out the syntax even more (spacing, semicolons, if spacing etc)
-- philxyz: Remove all traces of old bug reporting tools
-- philxyz: Actually fix the druglab removal on player disconnect process
-- philxyz: Remove spawned microwaves and gun labs on player disconnect
-- philxyz: Fix the rest of the help screens not disappearing on job change
-------------
-- DarkRP 2.2.6
-- by philxyz
-- philxyz: Remove the ability to screw up your money
-- philxyz: CPs can smash open their own or unowned doors (important for rp_tb_city45 nexus)
-- philxyz: allow help menu closing using /x in chat - it's much quicker
-- philxyz: Added /dropweapon, /weapondrop as aliases for /drop
-- philxyz: /moneydrop is now /dropmoney (with an alias /moneydrop so as not to confuse people)
-- philxyz: Money should be owned by "World" according to Simple Prop Protection
-------------
-- DarkRP 2.2.7
-- philxyz: Implement rp_maxdrugs and rp_maxfoods
-- philxyz: A more successful attempt at fixing Simple Prop Protection compatibility - thanks to Spacetech for both his original work and his co-operation
-- philxyz: When unowning doors, don't show cents in the sale value
-- philxyz: Implement rp_maxdrugs and rp_maxfoods
-- philxyz: Show the price when buying a melon
-- philxyz: Remove letters on player disconnect
-- philxyz: When unowning doors, don't show cents in the sale value
-- philxyz: Fix an old typo that meant rp_gunlabcost was not working
-- philxyz: Fix rp_microwavefoodcost
------------
-- DarkRP 2.2.8
-- philxyz: Fix "Players could never re-take a job after demotion"
-- philxyz: Remove duplicate function definitions from util.lua
-- philxyz: Log Notify() output to server and client consoles (useful for /give proof of purchase)
------------
-- DarkRP 2.2.9
-- philxyz: Remove /playerwarrant - it became a bizarre cross between arrest warrant (unnecessary) and search warrant
-- philxyz: Add /warrant command for search warrants
-- philxyz: Add rp_searchtime (default 30) for search warrant expiry
-- philxyz: Add /wanted and /unwanted commands for CPs or the Mayor to highlight a wanted criminal (replaces playerwarrant)
-- philxyz: Add /ao and /ro as aliases for /addowner and /removeowner respectively.
-- philxyz: Add more commands to the F2 menu
------------
-- DarkRP 2.2.10
-- philxyz: For these and future changes, please refer to changelog.txt

-- RP Name Overrides

DARKRPVERSION = "2.3.5"

local meta = FindMetaTable("Player")
meta.SteamName = meta.Name
meta.Name = function(self)
	return self:GetNWString("rpname")
end
meta.Nick = meta.Name
meta.GetName = meta.Name
-- End
RPArrestedPlayers = {}

DeriveGamemode("sandbox")
AddCSLuaFile("addshipments.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_vgui.lua")
AddCSLuaFile("entity.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_deathnotice.lua")
AddCSLuaFile("scoreboard/admin_buttons.lua")
AddCSLuaFile("scoreboard/player_frame.lua")
AddCSLuaFile("scoreboard/player_infocard.lua")
AddCSLuaFile("scoreboard/player_row.lua")
AddCSLuaFile("scoreboard/scoreboard.lua")
AddCSLuaFile("scoreboard/vote_button.lua")
AddCSLuaFile("cl_helpvgui.lua")
AddCSLuaFile("showteamtabs.lua")

-- Earthquake Mod addon
resource.AddFile("sound/earthquake.mp3")
util.PrecacheSound("earthquake.mp3")
//quakenotify = nil -- When the next quake report comes up
lastmagnitudes = {} -- The magnitudes of the last tremors

DB = {}
LRP = {}
CSFiles = {}
CfgVars = {}

include("help.lua")
include("shared.lua")
include("data.lua")
include("admincc.lua")
include("player.lua")
include("chat.lua")
include("main.lua")
include("util.lua")
include("votes.lua")
include("questions.lua")
include("admins.lua")
include("entity.lua")
include("bannedprops.lua")
include("hints.lua")
include("servercontrol.lua")
include("addshipments.lua")
include("rating.lua")
//AddCSLuaFile("autorun/sh_SPropProtection.lua")
AddCSLuaFile("SPropProtection/cl_Init.lua")
AddCSLuaFile("SPropProtection/sh_CPPI.lua")
include("SPropProtection/sv_Init.lua")
include("SPropProtection/sh_CPPI.lua")

AddHelpCategory(HELP_CATEGORY_CHATCMD, "Chat Commands")
AddHelpCategory(HELP_CATEGORY_CONCMD, "Console Commands")
AddHelpCategory(HELP_CATEGORY_ADMINTOGGLE, "Admin Toggle Commands (1 or 0!)")
AddHelpCategory(HELP_CATEGORY_ADMINCMD, "Admin Console Commands")

function includeCS(dir)
	AddCSLuaFile(dir)
	table.insert(CSFiles, dir)
end

local files = file.Find("../gamemodes/DarkRP/gamemode/modules/*.lua")
for k, v in pairs(files) do
	include("modules/" .. v)
end

local function RefreshSettings()
-- DO NOT TOUCH THIS! JUST SET THE RP SETTING IN GAME AND IT WILL SAVE AUTOMATICALLY! IF IT DOESNT SAVE AUTOMATICALLY DO rp_savechanges IN CONSOLE!
CfgVars["ooc"] = 1 --OOC allowed
--CfgVars["alltalk"] = 1 --All talk allowed
CfgVars["allowrpnames"] = 1 --RP Name changing allowed?
CfgVars["crosshair"] = 1 --Crosshairs enabled?
CfgVars["strictsuicide"] = 0 --Should players respawn where they suicided (regardless of they're arrested or not)
CfgVars["propertytax"] = 0 --Property taxes
CfgVars["cit_propertytax"] = 0 --Just citizens have to pay property tax?
CfgVars["banprops"] = 1 --Prop banning
CfgVars["toolgun"] = 0 --Tool gun enabled?
CfgVars["allowedprops"] = 0 --Should players be only able to spawn "allowed" props?
CfgVars["propspawning"] = 1 --Prop spawning enabled?
CfgVars["adminsents"] = 1 --Should all SENTs be admin only?
CfgVars["adminsweps"] = 1 --Should all sweps be admin only?
CfgVars["cpvote"] = 1 --Should people be able to use /votecop?
CfgVars["mayorvote"] = 1 --Should people be able to use /votemayor?
CfgVars["enforceplayermodel"] = 1 --Should player models be enforced? (Bans using player models like zombie/combine/etc)
CfgVars["proppaying"] = 0 --Should players pay for props
CfgVars["letters"] = 1 --Allow letter writing
CfgVars["cpvoting"] = 1 --Allow CP voting
CfgVars["mayorvoting"] = 1 --Allow Mayor voting
CfgVars["mayorsetsalary"] = 1 --Allow the Mayor to decide salaries of other players
CfgVars["cptomayoronly"] = 0 --Only CPs can do /votemayor
CfgVars["chiefjailpos"] = 1 -- Can the Chief set the jail positions?
CfgVars["physgun"] = 1 --Physguns for everybody? 0 = Admins only
CfgVars["teletojail"] = 1 --Should Criminals Be AUTOMATICALLY Teleported TO jail?
CfgVars["telefromjail"] = 1 --Should Jailed People be automatically Teleported FROM jail?
CfgVars["allowgang"] = 1 -- Should Gangs be allowed?
CfgVars["allowmedics"] = 1 -- Should Medics be allowed?
CfgVars["allowdealers"] = 1 -- Should Gun Dealers be allowed?
CfgVars["allowcooks"] = 1 -- Should Cooks be allowed?
CfgVars["allowhobos"] = 1 -- Disable hobos? :(
CfgVars["customspawns"] = 1 -- Custom spawn points enabled?
CfgVars["earthquakes"] = 1 -- Should earthquakes be enabled?
CfgVars["dmautokick"] = 1 -- Enable deathmatch auto-kick
CfgVars["doorwarrants"] = 1 -- Whether or not CPs require a warrant to smash in a door
CfgVars["allowvnocollide"] = 0 -- Whether or not to allow players to no-collide their vehicles (security)
CfgVars["restrictbuypistol"] = 0 -- Whether /buypistol is available only to Gun Dealers (if one or more)
CfgVars["noguns"] = 0 -- Whether or not guns are banned on this server
CfgVars["customjobs"] = 1 -- Whether or not players can use the /job command
CfgVars["deathblack"] = 1 -- Whether or not players see black when dead
CfgVars["norespawn"] = 1 -- Whether people have to respawn when they change job or not
CfgVars["advertisements"] = 1--chatprint advertisements
CfgVars["copscanunfreeze"] = 1  -- Cops can unfreeze props with the battering ram
CfgVars["removeclassitems"] = 1 -- Remove(example) every gun shipment when the gundealer changes to a medic or something
CfgVars["enablebuypistol"] = 1 -- People can do /buypistol
CfgVars["allowpdchief"] = 1 --Allow the chief
CfgVars["enableshipments"] = 1 --Enable gun shipments
CfgVars["lottery"] = 1 -- Enable the lottery
CfgVars["restrictallteams"] = 0
CfgVars["AdminsSpawnWithCopWeapons"] = 1
CfgVars["babygod"] = 0


-- You can set the exact value of the below items:

CfgVars["aspd"] = 120 -- Arrested speed
//CfgVars["cspd"] = 180 -- Crouch Speed
CfgVars["rspd"] = 230 -- Run Speed
CfgVars["wspd"] = 155 -- Walk Speed
CfgVars["doorcost"] = 30 -- Cost to buy a door.
CfgVars["vehiclecost"] = 40 -- Car/Airboat Cost
CfgVars["npckillpay"] = 10 -- Amount paid for killing a non-player character
CfgVars["normalsalary"] = 45 -- Normal Salary
CfgVars["maxnormalsalary"] = 150 -- Maximum Normal Salary
CfgVars["maxmayorsetsalary"] = 120 -- Max salary that a mayor can set for another player
CfgVars["paydelay"] = 160 -- Pay day delay (in seconds)
CfgVars["maxcps"] = 4 -- Max number of CPs you can have
CfgVars["propcost"] = 10 -- Prop cost
CfgVars["maxdruglabs"] = 1 -- Maximum drug labs per player
CfgVars["maxdrugs"] = 2 -- Maximum drug bottles per druglab owner
CfgVars["maxmicrowaves"] = 1 -- Maximum microwave ovens per player
CfgVars["maxfoods"] = 2 -- Maximum food cartons per microwave owner
CfgVars["maxgunlabs"] = 1 -- Maximum gun labs per player
CfgVars["maxmprinters"] = 2 -- Maximum money printers per player
CfgVars["maxletters"] = 4 -- Maximum number of letters per player
CfgVars["maxgangsters"] = 3 -- Maximum number of Gangsters
CfgVars["maxmedics"] = 3 -- Maximum number of Medics
CfgVars["maxgundealers"] = 2 -- Maximum number of Gun Dealers
CfgVars["maxcooks"] = 2 -- Maximum number of Cooks
CfgVars["quakechance"] = 4000 -- Earthquake probability (1 in 4000)
CfgVars["dmgracetime"] = 30 -- Players have a 30 second grace time by default
CfgVars["dmmaxkills"] = 3 -- ...in which they can make a maximum of 3 kills
CfgVars["demotetime"] = 120 -- Amount of time a player is banned from rejoining a team after being demoted
CfgVars["searchtime"] = 30 -- Amount of time a search warrant is valid for
CfgVars["respawntime"] = 4 -- Amount of time a player has to wait before respawning
CfgVars["wantedtime"] = 120 -- Amount of time a player is wanted for
CfgVars["lotterycommitcost"] = 50
CfgVars["babygodtime"] = 5


CfgVars["refreshglobals"] = 0

SetGlobalString("cmdprefix", "/") --Prefix before any chat commands
end
RefreshSettings()

-- Strings
CfgVars["mobagenda"] = ""

if not file.IsDir("DarkRP/") then
	file.CreateDir("DarkRP")
end

function SaveRPChanges()
	// OK first check if not everything is 0, because then you should load instead of save
	local settingsbroken = true
	for k,v in pairs(CfgVars) do
		if v ~= 0 then settingsbroken = false break end
	end
	if settingsbroken then print("DARKRP SETTINGS BROKEN!, LOADING OLD SETTINGS TO FIX!")  ReloadRPSettings() return end
	local globalsbroken = true
	for k,v in pairs(ValueCmds) do
		if v.global and GetGlobalInt(v.var) ~= 0 then
			globalsbroken = false
		end
	end
	for k,v in pairs(ToggleCmds) do
		if v.global and GetGlobalInt(v.var) ~= 0 then globalsbroken = false break end
	end
	if globalsbroken then print("DARKRP GLOBALS BROKEN!, LOADING OLD GLOBALS TO FIX!") ReloadRPGlobals() return end
	// End of checking if they're broken :)
	
	local Save1 = false
	local Save2 = false
	local settingsfile = file.Read("DarkRP/settings.txt")
	local Globalsfile = file.Read("DarkRP/globals.txt")
	if file.Exists("DarkRP/settings.txt") and settingsfile ~= "" then // If the file exists then 
		local compare = util.KeyValuesToTable(settingsfile)
		for k,v in pairs(compare) do
			if CfgVars[k] ~= compare[k] then // Check if the contents match and if they don't then
				print(k .. " changed from: ",  compare[k], "to", CfgVars[k])
				Save1 = true
			end
		end
	else//if the file does not exist then you should make it.
		print("Settings file does not exist, creating now...")
		Save1 = true
	end	
	
	local newsettings = {}
	for k,v in pairs(ValueCmds) do
		if v.global then
			newsettings[v.var] = GetGlobalInt(v.var)
		end
	end
	for k,v in pairs(ToggleCmds) do
		if v.global then
			newsettings[v.var] = GetGlobalInt(v.var)
		end
	end
	if file.Exists("DarkRP/globals.txt") and Globalsfile ~= "" then // If the file exists then 
		local compare = util.KeyValuesToTable(Globalsfile)
		for k,v in pairs(compare) do
			if v ~= newsettings[k] then // Check if the contents match and if they don't then
				print(k .. " changed from:",  v, "to", newsettings[k])
				Save2 = true
			end
		end 
	else//if the file does not exist then you should make it.
		print("Globals file does not exist, creating now...")
		Save2 = true
	end
	
	if Save1 then
		local settings = util.TableToKeyValues(CfgVars)
		local File = "DarkRP/settings.txt"
		file.Write(File, settings) // Save all the settings!
		print("DarkRP settings saved!")
	end
	if Save2 then
		local File = "DarkRP/globals.txt"
		local settings = util.TableToKeyValues(newsettings)
		file.Write(File, settings) // Save all the settings!
		print("DarkRP globals saved!")
	end
end
concommand.Add("rp_savechanges", SaveRPChanges)


//At the beginning of the game, load the last saved settings :D
function ReloadRPSettings()
	if file.Exists("DarkRP/settings.txt") and file.Read("DarkRP/settings.txt") ~= "" then
		local temp = util.KeyValuesToTable(file.Read("DarkRP/settings.txt"))
		for k,v in pairs(temp) do
			CfgVars[k] = tonumber(v)
		end
	end
end
ReloadRPSettings()

function ReloadRPGlobals()
	if file.Exists("DarkRP/globals.txt") and file.Read("DarkRP/globals.txt") ~= "" then
		local temp = util.KeyValuesToTable(file.Read("DarkRP/globals.txt"))
		for k,v in pairs(temp) do
			SetGlobalInt(k, tonumber(v))
		end
	else
		RefreshGlobals()
		timer.Simple(1, SaveRPChanges)
	end
end
ReloadRPGlobals()
timer.Simple(10.5, ReloadRPGlobals) // for some reason I don't know about the vars reset after 10 seconds...

function ResetAllRPSettings(ply,cmd,args)
	if not ply:IsSuperAdmin() then
		Notify(ply, 1, 4, "You must be a superadmin")
		return
	end
	Notify(ply, 1, 4, "All settings resetted!")
	file.Delete("DarkRP/globals.txt")
	file.Delete("DarkRP/settings.txt")
	RefreshSettings()
	ReloadRPGlobals()
end
concommand.Add("rp_ResetAllSettings", ResetAllRPSettings)

timer.Simple(5, function()
	-- Player Priviliges
	ADMIN = 0			-- DarkRP Admin
	MAYOR = 1			-- Can become Mayor without a vote (Uses /mayor)
	CP = 2					-- Can become CP without a vote (Uses /cp)
	TOOL = 3				-- Always spawns with the toolgun
	PHYS = 4				-- Always spawns with the physgun
	PROP = 5			-- Can always spawn props (unless jailed)
end)

GenerateChatCommandHelp()

function GM:Initialize()
	self.BaseClass:Initialize()
	DB.Init()
end

function ShowSpare1(ply)
	ply:ConCommand("gm_showspare1\n")
end
concommand.Add("gm_spare1", ShowSpare1)

function ShowSpare2(ply)
	ply:ConCommand("gm_showspare2\n")
end
concommand.Add("gm_spare2", ShowSpare2)

function GM:ShowTeam(ply)
	ply:SendLua("KeysMenu(" ..tostring(ply:GetEyeTrace().Entity:IsVehicle()) .. ")")
end

function GM:ShowHelp(ply)
	umsg.Start("ToggleHelp", ply)
	umsg.End()
end

-- Earthquake Mod part
local next_update_time
local tremor = ents.Create("env_physexplosion")
tremor:SetPos(Vector(0,0,0))
tremor:SetKeyValue("radius",9999999999)
tremor:SetKeyValue("spawnflags", 7)
tremor.nodupe = true
tremor:Spawn()

function TremorReport(alert)
	local mag = table.remove(lastmagnitudes, 1)
	if mag then
		local alert = "Earthquake"
		if mag < 6.5 then
			alert = "Earth Tremor"
		end
		NotifyAll(1, 3, alert .. " reported of magnitude " .. tostring(mag) .. "Mw")
	end
end

FlammableProps = {"drug", "drug_lab", "food", "gunlab", "letter", "melon", "microwave", "money_printer", "spawned_shipment", "spawned_weapon", "cash_bundle", "prop_physics"}

function IsFlammable(ent)
        local class = ent:GetClass()
        for k, v in pairs(FlammableProps) do
            if class == v then return true end
        end
        return false
end

-- FireSpread from SeriousRP
function FireSpread(e)
	if e:IsOnFire() then
		if e:GetTable().MoneyBag then
			e:Remove()
		end
		local en = ents.FindInSphere(e:GetPos(), math.random(20, 90))
		local maxcount = 3
		local count = 1
		local rand = 0
		for k, v in pairs(en) do
			if IsFlammable(v) then
			if count >= maxcount then break end
				if math.random(0.0, 60000.0) < 1.0 then
					if not v.burned then
						v:Ignite(math.random(5,180), 0)
						v.burned = true
					else
						local r, g, b, a = v:GetColor()
						if (r - 51)>=0 then r = r - 51 end
						if (g - 51)>=0 then g = g - 51 end
						if (b - 51)>=0 then b = b - 51 end
						v:SetColor(r, g, b, a)
						math.randomseed((r / (g+1)) + b)
						if (r + g + b) < 103 and math.random(1, 100) < 35 then
							v:Fire("enablemotion","",0)
							constraint.RemoveAll(v)
						end
					end
					count = count + 1
				end
			end
		end
	end
end


function GM:Think()
	for k, v in ipairs(FlammableProps) do
		local ens = ents.FindByClass(v)

		for a, b in pairs(ens) do
			FireSpread(b)
		end
	end
	-- End Spreadable fire Mod
end

AddHelpLabel(-1, HELP_CATEGORY_CONCMD, "gm_showhelp - Toggle help menu (bind this to F1 if you haven't already)")
AddHelpLabel(-1, HELP_CATEGORY_CONCMD, "serverHelp - Show's server help.")
AddHelpLabel(-1, HELP_CATEGORY_CONCMD, "gm_showspare1 - Toggle vote clicker (bind this to F3 if you haven't already)")
AddHelpLabel(-1, HELP_CATEGORY_CONCMD, "gm_showspare2 - Job menu(bind this to F4 if you haven't already)")

GM.Name = "DarkRP "..DARKRPVERSION
GM.Author = "By Rickster, Updated: Pcwizdan, Sibre, philxyz, [GNC] Matt, Chrome Bolt, FPtje Falco"