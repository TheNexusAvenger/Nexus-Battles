--[[
TheNexusAvenger

Game types that are usable.
--]]

local DEFAULT_REQUIRED_PLAYERS = 1 --TODO: Revert after Nexus Admin integrated
local DEFAULT_REQUIRED_PLAYERS_TEAMS = 4
local DEFAULT_MAX_PLAYERS = 12



return {
    LobbySelection = {
        DisplayName = "Lobby Selection",
        Description = "Internal round type for selecting rounds.",
        RoundClass = "Round.LobbySelectionRound",
    },
    FreeForAll = {
        DisplayName = "Free For All",
        Description = "Everyone for themselves!",
        RequiredPlayers = DEFAULT_REQUIRED_PLAYERS,
        MaxPlayers = DEFAULT_MAX_PLAYERS,
        RoundClass = "Round.FreeForAll",
    },
    OneWeaponSword = {
        DisplayName = "Sword Showdown",
        Description = "Swords only!",
        RequiredPlayers = DEFAULT_REQUIRED_PLAYERS,
        MaxPlayers = DEFAULT_MAX_PLAYERS,
        RoundClass = "Round.OneWeaponSword",
	},
	OneWeaponSuperball = {
        DisplayName = "Superball Smackdown",
        Description = "Superballs only!",
        RequiredPlayers = DEFAULT_REQUIRED_PLAYERS,
        MaxPlayers = DEFAULT_MAX_PLAYERS,
        RoundClass = "Round.OneWeaponSuperball",
    },
	OneWeaponBomb = {
        DisplayName = "Bomb Blitz",
        Description = "Bombs only!",
        RequiredPlayers = DEFAULT_REQUIRED_PLAYERS,
        MaxPlayers = DEFAULT_MAX_PLAYERS,
        RoundClass = "Round.OneWeaponBomb",
    },
	OneWeaponRocketLauncher = {
        DisplayName = "Rocket Rampage",
        Description = "Rocket Launchers only!",
        RequiredPlayers = DEFAULT_REQUIRED_PLAYERS,
        MaxPlayers = DEFAULT_MAX_PLAYERS,
        RoundClass = "Round.OneWeaponRocketLauncher",
    },
	Party = {
        DisplayName = "Party",
        Description = "Three random weapons!",
        RequiredPlayers = DEFAULT_REQUIRED_PLAYERS,
        MaxPlayers = DEFAULT_MAX_PLAYERS,
        RoundClass = "Round.Party",
    },
	BurnDown = {
        DisplayName = "Burn Down",
        Description = "Get a KO with each weapon!",
        RequiredPlayers = DEFAULT_REQUIRED_PLAYERS,
        MaxPlayers = DEFAULT_MAX_PLAYERS,
        RoundClass = "Round.BurnDown",
    },
	TeamDeathmatch = {
        DisplayName = "Team Deathmatch",
        Description = "Team vs team!",
        RequiredPlayers = DEFAULT_REQUIRED_PLAYERS_TEAMS,
        MaxPlayers = DEFAULT_MAX_PLAYERS,
        RoundClass = "Round.TeamDeathmatch",
    },
	RocketRace = {
        DisplayName = "Rocket Race",
        Description = "Get to the top! Hold the point!",
        RequiredPlayers = DEFAULT_REQUIRED_PLAYERS,
        MaxPlayers = DEFAULT_MAX_PLAYERS,
        RoundClass = "Round.NullRound",
		Weight = 2,
    },
    Juggernaut = {
        DisplayName = "Juggernaut",
        Description = "Fight to be the Juggernaut!",
        RequiredPlayers = DEFAULT_REQUIRED_PLAYERS,
        MaxPlayers = DEFAULT_MAX_PLAYERS,
        RoundClass = "Round.NullRound",
    },
    SwordSwept = {
        DisplayName = "Sword Swept",
        Description = "Swords Vs. Brooms!",
        RequiredPlayers = DEFAULT_REQUIRED_PLAYERS,
        MaxPlayers = DEFAULT_MAX_PLAYERS,
        RoundClass = "Round.SwordSwept",
		Weight = 2,
    },
    Dodgeball = {
        DisplayName = "Dodgeball",
        Description = "Eliminate the other team!",
        RequiredPlayers = DEFAULT_REQUIRED_PLAYERS_TEAMS,
        MaxPlayers = DEFAULT_MAX_PLAYERS,
        RoundClass = "Round.NullRound",
		Weight = 2,
    },
    CaptureTheFlag = {
        DisplayName = "Capture The Flag",
        Description = "Capture the other team's flag and bring it back!",
        RequiredPlayers = DEFAULT_REQUIRED_PLAYERS_TEAMS,
        MaxPlayers = DEFAULT_MAX_PLAYERS,
        RoundClass = "Round.NullRound",
		Weight = 2,
    },
    KingOfTheHill = {
        DisplayName = "King Of The Hill",
        Description = "Stay at the top of the hill for as long as you can!",
        RequiredPlayers = DEFAULT_REQUIRED_PLAYERS,
        MaxPlayers = DEFAULT_MAX_PLAYERS,
        RoundClass = "Round.NullRound",
		Weight = 2,
    },
    TeamSwap = {
        DisplayName = "Team Swap",
        Description = "Kill the other team's players to get them on your team!",
        RequiredPlayers = DEFAULT_REQUIRED_PLAYERS_TEAMS,
        MaxPlayers = DEFAULT_MAX_PLAYERS,
        RoundClass = "Round.TeamSwap",
    },
    OneWeaponMadness = {
        DisplayName = "One Weapon Madness",
        Description = "Get one random weapon every knockout!",
        RequiredPlayers = DEFAULT_REQUIRED_PLAYERS,
        MaxPlayers = DEFAULT_MAX_PLAYERS,
        RoundClass = "Round.OneWeaponMadness",
    },
}