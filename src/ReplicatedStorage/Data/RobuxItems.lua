--[[
TheNexusAvenger

Items that can be purchased with Robux.
--]]

if game.GameId == 2346548105 then
    --Nexus Development Quality Assurance
    return {
        {
            Name = "50Coins",
            ProductId = 1179032746,
            Coins = 50,
            DisplayInCoinPurchase = true,
        },
        {
            Name = "250Coins",
            ProductId = 1179032871,
            Coins = 250,
            DisplayInCoinPurchase = true,
        },
        {
            Name = "1050Coins",
            ProductId = 1179032932,
            Coins = 1050,
            Text = "5% MORE",
            DisplayInCoinPurchase = true,
        },
        {
            Name = "2750Coins",
            ProductId = 1179032993,
            Coins = 2750,
            Text = "10% MORE",
            DisplayInCoinPurchase = true,
        },
        {
            Name = "FirstArmorBundle",
            ProductId = 1179475378,
            Armor = {
                102,
                201,
            },
            RankScore = 100,
        },
    }
else
    --Release Game
    return {
        --TODO: Update with release version
    }
end