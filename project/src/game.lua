
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------


-- Configure image sheet


-- Initialize variables


local character={}
function character:new(name)
    character.name =name
    character.health = 40
    character.MP = 15
    character.money = 15
    
    function character:takeDamage(damage)
        self.health = self.health - damage
        print("Character took " .. damage .. " damage. Health: " .. self.health)
    end

    return character
end


local player ={}
function player:new(name)
    player.name = name
    return player
end


local npc ={}
function npc:new(name)
    npc.name = name
    return npc
end

local myPlayer
local myNPC

local turn=0

local backGroup
local mainGroup
local uiGroup

local exitButton
local playerUseItemButton
local turnText

local playerNameBar
local playerNameText


local function endGame()
  composer.gotoScene( "menu", { time=800, effect="crossFade" } )
end


local function initCharacter()
  myPlayer= player:new(_G.username)
  myNPC= npc:new("TEST")

end

local function initGameUI(sceneGroup)
  uiGroup = display.newGroup()
  sceneGroup:insert( uiGroup )
  
  turnText = display.newText( uiGroup, "TURN: " .. turn, display.contentCenterX, -20, native.systemFont, 20 )
  
  playerUseItemButton = display.newImageRect( uiGroup, "resource/game_playerArea.png", 150, 225 )
  playerUseItemButton.x = display.contentCenterX-75
  playerUseItemButton.y = 125
  
  playerNameBar = display.newImageRect( uiGroup, "resource/game_namebar.png", 150, 20 )
  playerNameBar.x = display.contentCenterX-75
  playerNameBar.y = 5
  playerNameText = display.newText( uiGroup, myPlayer.name,display.contentCenterX-75, 5, native.systemFont, 12 )
  
  exitButton = display.newImageRect( uiGroup, "resource/game_exitButton.png", 20, 20 )
  exitButton.x = display.contentCenterX-125
  exitButton.y = -20
  exitButton:addEventListener( "tap", endGame )
end

local function gameLoop()

 
end





-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
  local sceneGroup = self.view
  
  initCharacter()
  initGameUI(sceneGroup)
  
  
  
  
end


-- show()
function scene:show( event )


end


-- hide()
function scene:hide( event )

end


-- destroy()
function scene:destroy( event )

  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
  myPlayer:removeSelf()
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
