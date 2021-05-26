--[[
TheNexusAvenger

Data for the rank icons.
--]]

local RANK_ICONS_IMAGE = "http://www.roblox.com/asset/?id=6864239195"
local RANK_ICON_SIZE = Vector2.new(512,512)
local RANK_ICON_POSITIONS = {
    Vector2.new(0,0),
    Vector2.new(512,0),
    Vector2.new(0,512),
    Vector2.new(512,512),
}
local RANK_ICON_COLORS = {
    Bronze = Color3.new(180/255,110/255,0),
    Silver = Color3.new(230/255,230/255,230/255),
    Gold = Color3.new(235/255,200/255,0),
    Blue = Color3.new(0,170/255,255/255),
    Purple = Color3.new(100/255,0,255/255),
    Red = Color3.new(255/255,0,0),
}



return {
    Normal = {
        --Bronze
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[1],
            Color = RANK_ICON_COLORS.Bronze,
            RankScore = 0,
        },
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[2],
            Color = RANK_ICON_COLORS.Bronze,
            RankScore = 10, -- +10
        },
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[3],
            Color = RANK_ICON_COLORS.Bronze,
            RankScore = 25, -- +15
        },
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[4],
            Color = RANK_ICON_COLORS.Bronze,
            RankScore = 50, -- +25
        },

        --Silver
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[1],
            Color = RANK_ICON_COLORS.Silver,
            RankScore = 100, -- +50
        },
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[2],
            Color = RANK_ICON_COLORS.Silver,
            RankScore = 200, -- +100
        },
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[3],
            Color = RANK_ICON_COLORS.Silver,
            RankScore = 350, -- + 150
        },
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[4],
            Color = RANK_ICON_COLORS.Silver,
            RankScore = 550, -- +200
        },

        --Gold
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[1],
            Color = RANK_ICON_COLORS.Gold,
            RankScore = 800, -- +250
        },
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[2],
            Color = RANK_ICON_COLORS.Gold,
            RankScore = 1100, -- +300
        },
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[3],
            Color = RANK_ICON_COLORS.Gold,
            RankScore = 1500, -- + 400
        },
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[4],
            Color = RANK_ICON_COLORS.Gold,
            RankScore = 2000, -- + 500
        },

        --Blue
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[1],
            Color = RANK_ICON_COLORS.Blue,
            RankScore = 2750, -- +750
        },
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[2],
            Color = RANK_ICON_COLORS.Blue,
            RankScore = 3750, -- +1000
        },
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[3],
            Color = RANK_ICON_COLORS.Blue,
            RankScore = 5000, -- + 1250
        },
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[4],
            Color = RANK_ICON_COLORS.Blue,
            RankScore = 6500, -- +1500
        },

        --Purple
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[1],
            Color = RANK_ICON_COLORS.Purple,
            RankScore = 8000, -- +1500
        },
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[2],
            Color = RANK_ICON_COLORS.Purple,
            RankScore = 9500, -- +1500
        },
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[3],
            Color = RANK_ICON_COLORS.Purple,
            RankScore = 11000, -- + 1500
        },
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[4],
            Color = RANK_ICON_COLORS.Purple,
            RankScore = 12500, -- +1500
        },
    },
    Admin = {
        --Red
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[1],
            Color = RANK_ICON_COLORS.Red,
            NexusAdminLevel = 1,
        },
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[2],
            Color = RANK_ICON_COLORS.Red,
            NexusAdminLevel = 3,
        },
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[3],
            Color = RANK_ICON_COLORS.Red,
            NexusAdminLevel = 4,
        },
        {
            Image = RANK_ICONS_IMAGE,
            Size = RANK_ICON_SIZE,
            Position = RANK_ICON_POSITIONS[4],
            Color = RANK_ICON_COLORS.Red,
            NexusAdminLevel = 5,
        },
    },
}