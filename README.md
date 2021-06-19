# Nexus Battles
[Nexus Battles](https://www.roblox.com/games/6933375869/Nexus-Battles)
is a remaster of [Roblox Battle](https://www.roblox.com/games/96623001/ROBLOX-Battle-OPEN),
[Roblox Battle Remastered](https://www.roblox.com/games/264182869/Roblox-Battle-Remastered),
and [Roblox Battle (2018 Edition)](https://www.roblox.com/games/2061194359/Roblox-Battle-2018-Edition).
The goal of the game is to re-implement Roblox Battle
using current systems (like Roblox Battle (2018 Edition)
did), but also use the round system used in
[Ultimate Boxing](https://www.roblox.com/games/527513446/Ultimate-Boxing)
to:
- Increase playtime by reducing idle-time
  between rounds.
- Improve round options by allowing any game
  mode to be started with enough players.
- Add elimination and other custom game
  modes that Roblox Battle couldn't accommodate.
- Make the game more fun!

# Building
This project uses [Rojo](https://github.com/rojo-rbx/rojo)
for managing files. After downloading the repository
**and submodules**, a place file can be generated using:
```
rojo build --output nexus-battles.rbxlx
```

Rojo live syncing can also be used, but is only
recommended for development because of the use
of `Unions`s. If Roblox allows Rojo to have
feature parity with live syncing as building, this
can be ignored.

# Republishing
This game can be republished on Roblox as-is without
permission under the condition that the project is not
claimed as your own.