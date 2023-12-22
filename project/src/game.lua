
local composer = require( "composer" )
local socket = require("socket")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- 自訂函式寫在這邊
-- -----------------------------------------------------------------------------------


-- Configure image sheet


-- Initialize variables

local Item = {}

function Item:new(name, value, imagePath)
    local newItem = {
        name = name,
        value = value,
        imagePath = imagePath,
    }
    setmetatable(newItem, { __index = Item })
    return newItem
end


local Weapon = {}

function Weapon:new(name, damage, imagePath)
    local newWeapon = Item:new(name, damage, imagePath)
    newWeapon.damage = damage
    setmetatable(newWeapon, { __index = Weapon })
    return newWeapon
end


local Armor = {}

function Armor:new(name, defense, imagePath)
    local newArmor = Item:new(name, defense, imagePath)  
    newArmor.defense = defense
    setmetatable(newArmor, { __index = Armor })
    return newArmor
end


local Potion = {}

function Potion:new(name, healing, imagePath)
    local newPotion = Item:new(name, 2, imagePath)  
    newPotion.healing = healing
    setmetatable(newPotion, { __index = Potion })
    return newPotion
end

-- 編輯道具模板以新增道具

local itemTemplates = {
   --{id = , type = "", name = "", value = , imagePath = "resource/icon/release_v1.2-single_A.png"}
   {id = 1, type = "Weapon" , name = "weapon", value = 5, imagePath = "resource/icon/release_v1.2-single_1.png"},
   {id = 2, type = "Potion" , name = "healthPotion", value = 5, imagePath = "resource/icon/release_v1.2-single_2.png"},
   {id = 3, type = "Weapon" , name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_3.png"},
   {id = 4, type = "Armor", name = "armor", value = 4, imagePath = "resource/icon/release_v1.2-single_4.png"},
   {id = 5, type = "Weapon", name = "weapon", value = 2, imagePath = "resource/icon/release_v1.2-single_5.png"},
   {id = 6, type = "Weapon" , name = "weapon", value = 5, imagePath = "resource/icon/release_v1.2-single_6.png"},
   {id = 7, type = "Armor", name = "armor", value = 4, imagePath = "resource/icon/release_v1.2-single_7.png"},
   {id = 8, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_8.png"},
   {id = 9, type = "Potion", name = "healthPotion", value = 5, imagePath = "resource/icon/release_v1.2-single_9.png"},
   {id = 10, type = "Armor", name = "armor", value = 4, imagePath = "resource/icon/release_v1.2-single_10.png"},
   {id = 11, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_11.png"},
   {id = 12, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_12.png"},
   {id = 13, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_13.png"},
   {id = 14, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_14.png"},
   {id = 15, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_15.png"},
   {id = 16, type = "Armor", name = "armor", value = 4, imagePath = "resource/icon/release_v1.2-single_16.png"},
   {id = 17, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_17.png"},
   {id = 18, type = "Armor", name = "armor", value = 4, imagePath = "resource/icon/release_v1.2-single_18.png"},
   {id = 19, type = "Potion", name = "healthPotion", value = 5, imagePath = "resource/icon/release_v1.2-single_19.png"},
   {id = 20, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_20.png"},
   {id = 21, type = "Weapon", name = "weapon", value = 5, imagePath = "resource/icon/release_v1.2-single_21.png"},
   {id = 22, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_22.png"},
   {id = 23, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_23.png"},
   {id = 24, type = "Potion", name = "healthPotion", value = 5, imagePath = "resource/icon/release_v1.2-single_24.png"},
   {id = 25, type = "Armor", name = "armor", value = 4, imagePath = "resource/icon/release_v1.2-single_25.png"},
   {id = 26, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_26.png"},
   {id = 27, type = "Weapon", name = "weapon", value = 5, imagePath = "resource/icon/release_v1.2-single_27.png"},
   {id = 28, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_28.png"},
   {id = 29, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_29.png"},
   {id = 30, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_30.png"},
   {id = 31, type = "Weapon", name = "weapon", value = 5, imagePath = "resource/icon/release_v1.2-single_31.png"},
   {id = 32, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_32.png"},
   {id = 33, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_33.png"},
   {id = 34, type = "Potion", name = "healthPotion", value = 5, imagePath = "resource/icon/release_v1.2-single_34.png"},
   {id = 35, type = "Armor", name = "armor", value = 4, imagePath = "resource/icon/release_v1.2-single_35.png"},
   {id = 36, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_36.png"},
   {id = 37, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_37.png"},
   {id = 38, type = "Potion", name = "healthPotion", value = 5, imagePath = "resource/icon/release_v1.2-single_38.png"},
   {id = 39, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_39.png"},
   {id = 40, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_40.png"},
   {id = 41, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_41.png"},
   {id = 42, type = "Weapon", name = "weapon", value = 5, imagePath = "resource/icon/release_v1.2-single_42.png"},
   {id = 43, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_43.png"},
   {id = 44, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_44.png"},
   {id = 45, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_45.png"},
   {id = 46, type = "Weapon", name = "weapon", value = 5, imagePath = "resource/icon/release_v1.2-single_46.png"},
   {id = 47, type = "Potion", name = "healthPotion", value = 5, imagePath = "resource/icon/release_v1.2-single_47.png"},
   {id = 48, type = "Weapon", name = "weapon", value = 5, imagePath = "resource/icon/release_v1.2-single_48.png"},
   {id = 49, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_49.png"},
   {id = 50, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_50.png"},
   {id = 51, type = "Armor", name = "armor", value = 4, imagePath = "resource/icon/release_v1.2-single_51.png"},
   {id = 52, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_52.png"},
   {id = 53, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_53.png"},
   {id = 54, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_54.png"},
   {id = 55, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_55.png"},
   {id = 56, type = "Weapon", name = "weapon", value = 5, imagePath = "resource/icon/release_v1.2-single_56.png"},
   {id = 57, type = "Armor", name = "armor", value = 4, imagePath = "resource/icon/release_v1.2-single_57.png"},
   {id = 58, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_58.png"},
   {id = 59, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_59.png"},
   {id = 60, type = "Armor", name = "armor", value = 4, imagePath = "resource/icon/release_v1.2-single_60.png"},
   {id = 61, type = "Potion", name = "healthPotion", value = 5, imagePath = "resource/icon/release_v1.2-single_61.png"},
   {id = 62, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_62.png"},
   {id = 63, type = "Potion", name = "healthPotion", value = 5, imagePath = "resource/icon/release_v1.2-single_63.png"},
   {id = 64, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_64.png"},
   {id = 65, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_65.png"},
   {id = 66, type = "Armor", name = "armor", value = 4, imagePath = "resource/icon/release_v1.2-single_66.png"},
   {id = 67, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_67.png"},
   {id = 68, type = "Potion", name = "healthPotion", value = 5, imagePath = "resource/icon/release_v1.2-single_68.png"},
   {id = 69, type = "Armor", name = "armor", value = 4, imagePath = "resource/icon/release_v1.2-single_69.png"},
   {id = 70, type = "Armor", name = "armor", value = 4, imagePath = "resource/icon/release_v1.2-single_70.png"},
   {id = 71, type = "Potion", name = "healthPotion", value = 5, imagePath = "resource/icon/release_v1.2-single_71.png"},
   {id = 72, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_72.png"},
   {id = 73, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_73.png"},
   {id = 74, type = "Armor", name = "armor", value = 4, imagePath = "resource/icon/release_v1.2-single_74.png"},
   {id = 75, type = "Potion", name = "healthPotion", value = 5, imagePath = "resource/icon/release_v1.2-single_75.png"},
   {id = 76, type = "Weapon", name = "weapon", value = 5, imagePath = "resource/icon/release_v1.2-single_76.png"},
   {id = 77, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_77.png"},
   {id = 78, type = "Potion", name = "healthPotion", value = 5, imagePath = "resource/icon/release_v1.2-single_78.png"},
   {id = 79, type = "Potion", name = "healthPotion", value = 5, imagePath = "resource/icon/release_v1.2-single_79.png"},
   {id = 80, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_80.png"},
   {id = 81, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_81.png"},
   {id = 82, type = "Armor", name = "armor", value = 4, imagePath = "resource/icon/release_v1.2-single_82.png"},
   {id = 83, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_83.png"},
   {id = 84, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_84.png"},
   {id = 85, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_85.png"},
   {id = 86, type = "Potion", name = "healthPotion", value = 5, imagePath = "resource/icon/release_v1.2-single_86.png"},
   {id = 87, type = "Armor", name = "armor", value = 4, imagePath = "resource/icon/release_v1.2-single_87.png"},
   {id = 88, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_88.png"},
   {id = 89, type = "Armor", name = "armor", value = 4, imagePath = "resource/icon/release_v1.2-single_89.png"},
   {id = 90, type = "Potion", name = "healthPotion", value = 5, imagePath = "resource/icon/release_v1.2-single_90.png"},
   {id = 91, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_91.png"},
   {id = 92, type = "Potion", name = "healthPotion", value = 5, imagePath = "resource/icon/release_v1.2-single_92.png"},
   {id = 93, type = "Armor", name = "armor", value = 4, imagePath = "resource/icon/release_v1.2-single_93.png"},
   {id = 94, type = "Armor", name = "armor", value = 4, imagePath = "resource/icon/release_v1.2-single_94.png"},
   {id = 95, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_95.png"},
   {id = 96, type = "Weapon", name = "weapon", value = 5, imagePath = "resource/icon/release_v1.2-single_96.png"},
   {id = 97, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_97.png"},
   {id = 98, type = "Armor", name = "armor", value = 4, imagePath = "resource/icon/release_v1.2-single_98.png"},
   {id = 99, type = "Armor", name = "armor", value = 4, imagePath = "resource/icon/release_v1.2-single_99.png"},
   {id = 100, type = "Weapon", name = "attackPotion", value = 3, imagePath = "resource/icon/release_v1.2-single_100.png"}
}

-- 工廠函數，根據類型創建對應的物品

function createItemFromTemplate(id)
    local template = itemTemplates[id]
    if template then
        local newItem
        if template.type == "Weapon" then
          newItem = Weapon:new(template.name, template.value, template.imagePath)
        elseif template.type == "Armor" then
          newItem = Armor:new(template.name, template.value, template.imagePath)
        elseif template.type == "Potion" then
          newItem = Potion:new(template.name, template.value, template.imagePath)
        end
        return newItem
    else
        error("Invalid item type")
    end
end

--隨機生成道具
function randomCreateItem()
  local newItem = createItemFromTemplate(math.random(1, #itemTemplates))
  return newItem
end

--character類別
local character={}
function character:new(name)
    local Character={}
    setmetatable(character, self)
    self.__index = self
    Character.name =name
    Character.health = 40
    Character.MP = 15
    Character.money = 15
    Character.item={}
    Character.itemCount=0
    
    function Character:adjustHealth(add_or_subtract,delta)
        if add_or_subtract == 1 then
          self.health = self.health + delta
        elseif add_or_subtract == 0 then
          self.health = self.health - delta
          print("Character took " .. delta .. " damage. Health: " .. self.health)
        end
    end

    function Character:addItem()
      if self.itemCount <=8 then
        table.insert(self.item, randomCreateItem())
        self.itemCount = self.itemCount+1
      end
    end
    return Character
end

--player類別繼承character
local player ={}
function player:new(name)
    local Player = character:new(name)
    return Player
end

--npc類別繼承character
local npc ={}
function npc:new(name)
    local NPC = character:new(name)
    return NPC
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
local itemButtonRects = {} 
local itemIconRects ={}

local playerNameBar
local playerNameBar2
local playerNameText
local playerNameText2
local npcNameBar
local npcNameText2
local showAttackIcon
local waitMessage

local function endGame()
  composer.gotoScene( "menu", { time=800, effect="crossFade" } )
end

function generateRandomChineseName(length)
    local name = ""
    for i = 1, length do
        local randomChar = string.char(math.random(0, 191))
        name = name .. randomChar
    end
    return name
end

local function initCharacter()
  myPlayer= player:new(_G.username)
  myNPC= npc:new(generateRandomChineseName(math.random(1, 3)))
  
  for i=1,8 do
    myPlayer:addItem()
    myNPC:addItem()
  end
 
end




local function initGameUI(sceneGroup)
  uiGroup = display.newGroup()
  waitMessage = display.newGroup()
  sceneGroup:insert( uiGroup )
  sceneGroup:insert(waitMessage)
  
  turnText = display.newText( uiGroup, "TURN: " .. turn, display.contentCenterX, -20, native.systemFont, 20 )
  
  playerUseItemButton = display.newImageRect( uiGroup, "resource/game_playerArea.png", 125, 225 )
  playerUseItemButton.x = display.contentCenterX-80
  playerUseItemButton.y = 130
  
  playerNameBar = display.newImageRect( uiGroup, "resource/game_namebar.png", 125, 20 )
  playerNameBar.x = display.contentCenterX-80
  playerNameBar.y = 5
  if(myPlayer) then
    playerNameText = display.newText( uiGroup, myPlayer.name,display.contentCenterX-80, 5, native.systemFont, 12 )
  else
    playerNameText = display.newText( uiGroup, "player",display.contentCenterX-75, 5, native.systemFont, 12 )
  end
  
  playerNameBar2 = display.newImageRect( uiGroup, "resource/game_namebar.png", 180, 30 )
  playerNameBar2.x = display.contentCenterX
  playerNameBar2.y = display.contentCenterY+160
  
  playerNameText2 = display.newText( uiGroup, "player",display.contentCenterX, display.contentCenterY+160, native.systemFont, 12 )
  
  npcNameBar = display.newImageRect( uiGroup, "resource/game_namebar.png", 180, 30 )
  npcNameBar.x = display.contentCenterX
  npcNameBar.y = display.contentCenterY+200
  
  npcNameText2 = display.newText( uiGroup, "TEST",display.contentCenterX, display.contentCenterY+200, native.systemFont, 12 )
  
  exitButton = display.newImageRect( uiGroup, "resource/game_exitButton.png", 20, 20 )
  exitButton.x = display.contentCenterX-125
  exitButton.y = -20
  exitButton:addEventListener( "tap", endGame )
  
  showAttackIcon = display.newImageRect( uiGroup, "resource/game_showAttack.png", 25, 25 )
  showAttackIcon.x = display.contentCenterX
  showAttackIcon.y = 5
  showAttackIcon.isVisible = false
  

  for i = 1, 4 do
    itemButtonRects[i] = display.newImageRect("resource/game_itemButton.png", 50, 50)
    itemButtonRects[i].x = (display.contentCenterX+35) + (i - 3) * 70  -- 設置 x 座標
    itemButtonRects[i].y = (display.contentCenterY+30)  -- 設置 y 座標
    itemButtonRects[i]:toBack()
    
    itemIconRects[i] = display.newImageRect("resource/game_itemButton.png", 40, 40)
    itemIconRects[i].x = (display.contentCenterX+35) + (i - 3) * 70  -- 設置 x 座標
    itemIconRects[i].y = (display.contentCenterY+30)  -- 設置 y 座標
    itemIconRects[i].isHitTestable = false
    itemIconRects[i].alpha = 1
  end
  
  for i =5,8 do
    itemButtonRects[i] = display.newImageRect("resource/game_itemButton.png", 50, 50)
    itemButtonRects[i].x = (display.contentCenterX+35) + (i - 7) * 70  -- 設置 x 座標
    itemButtonRects[i].y = (display.contentCenterY+30)+70  -- 設置 y 座標
    itemButtonRects[i]:toBack()
    
    itemIconRects[i] = display.newImageRect("resource/game_itemButton.png", 40, 40)
    itemIconRects[i].x = (display.contentCenterX+35) + (i - 7) * 70  -- 設置 x 座標
    itemIconRects[i].y = (display.contentCenterY+30)+70  -- 設置 y 座標
    itemIconRects[i].isHitTestable = false
    itemIconRects[i].alpha = 1
  end
  

 
 local waitMessageFrame = display.newImageRect(waitMessage,"resource/game_playerArea.png", 300, 250)
 waitMessageFrame.x = display.contentCenterX
 waitMessageFrame.y = display.contentCenterY-50
 local waitMessageText = display.newText( waitMessage, "決鬥準備開始",display.contentCenterX,display.contentCenterY-50 , native.systemFont, 40 )
 waitMessage:toFront()
 
end

local function setPlayerNameText()
    playerNameText.text = myPlayer.name
    playerNameText2.text = myPlayer.name
    npcNameText2.text = myNPC.name
end

local function setItemImage()
  for i =1 , #myPlayer.item  do
    print(myPlayer.item[i])
    itemIconRects[i].fill={type = "image", filename = myPlayer.item[i].imagePath}
    itemIconRects[i].alpha = 1
  end
end

local function hideMessage()
  waitMessage.isVisible = false
end


local function gameLoop()

 
end





-- -----------------------------------------------------------------------------------
-- 跟場景有關的寫在這邊
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
  local sceneGroup = self.view
  initGameUI(sceneGroup)

  
  
end


-- show()
function scene:show( event )
  initCharacter()
  setPlayerNameText()
  setItemImage()
  hideMessage()
  
  
  
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
