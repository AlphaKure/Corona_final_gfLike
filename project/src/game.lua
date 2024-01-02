
local composer = require( "composer" )
local socket = require("socket")
local transition = require("transition")
local timer = require("timer")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- 自訂函式寫在這邊
-- -----------------------------------------------------------------------------------



-- -----------------------------------------------------------------------------------
-- Initialize variables-----------------------------------------------------------------------------------
local myPlayer
local myNPC

local turn=0
local whosTurn
local npcTurn
local playerTurn

local backGroup
local mainGroup
local uiGroup
local allItemInfoGroup
local allINPCtemInfoGroup
local valueBarGroup

local exitButton
local attackerButton
local turnText
local itemButtonRects = {} 
local itemIconRects ={}
local itemButtonIsClick={false,false,false,false,false,false,false,false}
local itemButtonTouchable={true,true,true,true,true,true,true,true}
local background
local overlay
local valueBar
local valueBarText

local playerNameBar
local playerNameBar2
local playerNameText
local playerNameText2
local playerHealthText
local playerPPText
local playerMoneyText
local npcNameBar
local npcNameBarUp
local npcNameTextUp
local npcNameText2
local npcHealthText
local npcPPText
local npcMoneyText
local showAttackIcon
local waitMessage
local finalMessageGroup
local finalMessageText
local finalMessageBar

local playerItemQueue={}
local npcItemQueue={}
local curAction
local preSelectedItemIndex ={}
-- -----------------------------------------------------------------------------------
local Item = {}
--道具初始屬性:名稱、價格、稀有度(1最低~5最高)、圖片、效果函式
function Item:new(name, value,rare, imagePath , effect,describe)
    local newItem = {
        name = name,
        value = value,
        rare = rare,
        imagePath = imagePath,
        effect = effect,
        describe =describe,
    }
    setmetatable(newItem, { __index = Item })
    return newItem
end


local Weapon = {}
--武器傷害值可以是變動的ex:2d6 = 投擲2顆六面骰子，屬性種類有:
function Weapon:new(name,dice_amount,dice_face,element,value,rare, imagePath,effect,describe)
    local newWeapon = Item:new(name,value,rare,imagePath,effect,describe)
    newWeapon.damage = 0--此參數只用做儲存投擲完骰子的結果
    newWeapon.amount = dice_amount
    newWeapon.face = dice_face
    newWeapon.element = element
    setmetatable(newWeapon, { __index = Weapon })
    return newWeapon
end

local WeaponAdd = {}
--可以疊加傷害的武器，疊加值是固定的
function WeaponAdd:new(name,damage,element,value,rare, imagePath,effect,describe)
    local newWeaponAdd = Item:new(name,value,rare,imagePath,effect,describe)
    newWeaponAdd.damage = damage
    newWeaponAdd.element = element
    setmetatable(newWeaponAdd, { __index = WeaponAdd })
    return newWeaponAdd
end

local Armor = {}
--防具的防禦值是固定的
function Armor:new(name,defence,element,value,rare,imagePath,effect,describe)
    local newArmor = Item:new(name,value,rare,imagePath,effect,describe)
    newArmor.defence = defence
    setmetatable(newArmor, { __index = Armor })
    return newArmor
end


local Potion = {}
--藥水回復值可能變動
function Potion:new(name,dice_amount,dice_face,recover_type,value,rare,imagePath,effect,describe)
    local newPotion = Item:new(name,value,rare,imagePath,effect,describe)
    newPotion.amount = dice_amount
    newPotion.face = dice_face
    newPotion.recover_type = recover_type
    newPotion.recover =0
    newPotion.damage =0
    setmetatable(newPotion, { __index = Potion })
    return newPotion
end

-- 編輯道具模板以新增道具

local function effectFunctionTest()
  print("effect test")
end

local function bloodSword()
  -- 武器效果 每3回合提升該武器1點攻擊力
  print('bloodSword effect 啟動')
end

local itemTemplates = {
   --{id = , type = "Weapon", name = "",dice_amount =,dice_face =,element =, value =,rare =, imagePath = "resource/icon/release_v1.2-single_A.png",effect =,describe=}
   --{id = , type = "WeaponAdd", name = "",damage =,element =, value =,rare =, imagePath = "resource/icon/release_v1.2-single_A.png",effect =,describe=}
   --{id = , type = "Armor", name = "",defence =,element =, value =,rare =, imagePath = "resource/icon/release_v1.2-single_A.png",effect =,describe=}
   --{id = , type = "Potion", name = "",dice_amount =,dice_face =,type =, value =,rare =, imagePath = "resource/icon/release_v1.2-single_A.png",effect =,describe=}
   {id = 0, type = "Weapon", name = "新手之劍", dice_amount = 1,dice_face = 4,element = nil, value = 1,rare = 1, imagePath = "resource/icon/Barbarian_17.png",effect = nil,describe= "一把普通的劍，不附帶任何屬性"},
   {id = 1, type = "Weapon", name = "強化之劍", dice_amount = 1,dice_face = 6,element = nil, value = 2,rare = 2, imagePath = "resource/icon/Barbarian_18.png",effect = nil,describe= "一把經過強化的劍，傷害有機會變得更高"},
   {id = 2, type = "Weapon", name = "詛咒之刃", dice_amount = 2,dice_face = 6,element = nil, value = 4,rare = 4, imagePath = "resource/icon/Barbarian_19.png",effect = nil,describe= "一把受詛咒的刀刃，傷害上限不容小覷"},
   {id = 3, type = "Weapon", name = "新手之仗", dice_amount = 1,dice_face = 4,element = nil, value = 1,rare = 1, imagePath = "resource/icon/Barbarian_36.png",effect = nil,describe= "一把普通的魔仗，拿來錘人好像有點癢"},
   {id = 4, type = "Weapon", name = "強化之仗", dice_amount = 2,dice_face = 4,element = nil, value = 3,rare = 3, imagePath = "resource/icon/Barbarian_20.png",effect = nil,describe= "一把經過強化的魔仗，錘起人來有點痛"},
   {id = 5, type = "Weapon", name = "伐木斧頭", dice_amount = 1,dice_face = 3,element = nil, value = 1,rare = 1, imagePath = "resource/icon/Barbarian_27.png",effect = nil,describe= "一把伐木用的斧頭，由於經常使用已經有點磨損了"},
   {id = 6, type = "Weapon", name = "大型斧頭", dice_amount = 1,dice_face = 6,element = nil, value = 2,rare = 2, imagePath = "resource/icon/Barbarian_21.png",effect = nil,describe= "全新的伐木斧頭，砍中敵人要害也是很痛的"},
   {id = 7, type = "Weapon", name = "皇家斧頭", dice_amount = 2,dice_face = 5,element = nil, value = 3,rare = 3, imagePath = "resource/icon/Barbarian_22.png",effect = nil,describe= "一把皇家用的斧頭，威力不容小覷"},
   {id = 8, type = "Weapon", name = "皇家之劍", dice_amount = 2,dice_face = 5,element = nil, value = 3,rare = 3, imagePath = "resource/icon/Barbarian_26.png",effect = nil,describe= "一把皇家用的劍，威力不容小覷"},
   {id = 9, type = "Weapon", name = "皇家之矛", dice_amount = 2,dice_face = 5,element = nil, value = 3,rare = 3, imagePath = "resource/icon/Barbarian_23.png",effect = nil,describe= "一把皇家用的矛，威力不容小覷"},
   {id = 10, type = "Weapon", name = "嗜血之劍", dice_amount = 1,dice_face = 4,element = nil, value = 5,rare = 5, imagePath = "resource/icon/Barbarian_28.png",effect = nil ,describe= "這是一把嗜血的劍，雖然基礎數值不高但會隨著回合數慢慢提升攻擊力。"},
   {id = 11, type = "Weapon", name = "長劍", dice_amount = 1,dice_face = 5,element = nil, value = 2,rare = 2, imagePath = "resource/icon/Barbarian_29.png",effect = nil ,describe= "這是一把長劍，不附帶任何屬性"},
   {id = 12, type = "Weapon", name = "王者之劍", dice_amount = 3,dice_face = 6,element = nil, value = 5,rare = 5, imagePath = "resource/icon/Barbarian_31.png",effect = nil ,describe= "這是一把王者之劍，擁有極高的攻擊力"},
   {id = 13, type = "Weapon", name = "骨劍", dice_amount = 1,dice_face = 3,element = nil, value = 1,rare = 1, imagePath = "resource/icon/Barbarian_38.png",effect = nil ,describe= "一把骨頭製成的劍，傷害並不高"},
   {id = 14, type = "Weapon", name = "餐刀", dice_amount = 1,dice_face = 2,element = nil, value = 1,rare = 1, imagePath = "resource/icon/BloodMage_7.png",effect = nil ,describe= "一把餐刀，老實說誰會拿它來戰鬥"},
   {id = 15, type = "WeaponAdd" , name = "草屬性附魔", damage =1,element =nil, value =1,rare =1, imagePath = "resource/icon/release_v1.2-single_1.png",effect =nil,describe="賦予武器1點草屬性傷害"},
   {id = 16, type = "Potion" , name = "中型回復生命", dice_amount =1, dice_face =5,recover_type ="health", value =3,rare =1, imagePath = "resource/icon/release_v1.2-single_2.png",effect =nil,describe="回復1d5的生命值"},
   {id = 17, type = "Potion" , name = "小型回復生命", dice_amount =1, dice_face =3,recover_type ="health", value =1,rare =1,imagePath = "resource/icon/release_v1.2-single_3.png",effect =nil,describe="回復1d3的生命值"},
   {id = 18, type = "WeaponAdd" , name = "光屬性附魔", damage =1,element =nil, value =1,rare =1, imagePath = "resource/icon/release_v1.2-single_6.png",effect =nil,describe="賦予武器1點光屬性傷害"},
   {id = 19, type = "Armor", name = "光之護甲", defence =2,element =nil, value =3,rare =1, imagePath = "resource/icon/release_v1.2-single_7.png",effect =nil,describe="提供玩家2點光屬性護甲"},
   {id = 20, type = "Potion", name = "光之射擊", dice_amount =1,dice_face =5,recover_type ="attack",value =3,rare =1,effect =nil,describe="對敵人造成1d5光屬性傷害", imagePath = "resource/icon/release_v1.2-single_8.png"},
   {id = 21, type = "Potion", name = "光之回復", dice_amount =1,dice_face =4,recover_type ="health",value =5,rare =1,effect =nil,describe="回復玩家1d5生命值",imagePath = "resource/icon/release_v1.2-single_9.png"},
   {id = 22, type = "WeaponAdd", name = "磨刀", damage =2,element =nil, value =5,rare =2,effect =nil,describe="提升武器攻擊力2點", imagePath = "resource/icon/release_v1.2-single_11.png"},
   {id = 23, type = "Potion", name = "無屬性直斬", dice_amount =1,dice_face =3,recover_type ="attack",value =3,rare =1,effect =nil,describe="對敵人造成1d3傷害", imagePath = "resource/icon/release_v1.2-single_12.png"},
   {id = 24, type = "Potion", name = "無屬性亂斬", dice_amount =2,dice_face =2,recover_type ="attack",value =3,rare =1,effect =nil,describe="對敵人造成2d2傷害", imagePath = "resource/icon/release_v1.2-single_13.png"},
   {id = 25, type = "Potion", name = "無屬性重擊", dice_amount =1,dice_face =4,recover_type ="attack",value =3,rare =1,effect =nil,describe="對敵人造成1d4傷害", imagePath = "resource/icon/release_v1.2-single_14.png"},
   {id = 26, type = "Potion", name = "無屬性弱點突破", dice_amount =2,dice_face =4,recover_type ="attack",value =3,rare =1,effect =nil,describe="對敵人造成2d4傷害", imagePath = "resource/icon/release_v1.2-single_15.png"},
   {id = 27, type = "Armor", name = "無屬性護甲", defence =3,element =nil, value =3,rare =1,effect =nil,describe="提供玩家3點無屬性護甲", imagePath = "resource/icon/release_v1.2-single_16.png"},
   {id = 28, type = "Potion", name = "雷擊", dice_amount =1,dice_face =10,recover_type ="attack",value =3,rare =1,effect =nil,describe="對敵人造成1d10傷害", imagePath = "resource/icon/release_v1.2-single_17.png"},
   {id = 29, type = "Armor", name = "小型吸收護甲", defence =2,element =nil, value =3,rare =1,effect =nil,describe="提供玩家2點護甲" ,imagePath = "resource/icon/release_v1.2-single_18.png"},
   {id = 30, type = "Potion", name = "小型回復生命", dice_amount =1, dice_face =3,recover_type ="health", value =1,rare =1, effect =nil,describe="回復1d3的生命值", imagePath = "resource/icon/release_v1.2-single_19.png"},
   {id = 31, type = "WeaponAdd", name = "封鎖",damage =2,element =nil, value =1,rare =1,effect =nil,describe="提升武器2點無屬性傷害", imagePath = "resource/icon/release_v1.2-single_20.png"},
   {id = 32, type = "Potion", name = "射擊", dice_amount =1,dice_face =3,recover_type ="attack",value =3,rare =1,effect =nil,describe="對敵人造成1d3傷害",imagePath = "resource/icon/release_v1.2-single_21.png"},
   {id = 33, type = "Potion", name = "萬箭齊發",dice_amount =2,dice_face =2,recover_type ="attack",value =3,rare =1,effect =nil,describe="對敵人造成2d2傷害",imagePath = "resource/icon/release_v1.2-single_22.png"},
   {id = 34, type = "WeaponAdd", name = "風之附魔", damage =1,element =nil, value =1,rare =1,effect =nil,describe="提升武器1點風屬性傷害", imagePath = "resource/icon/release_v1.2-single_23.png"},
   {id = 35, type = "Potion", name = "升級!", dice_amount =2, dice_face =4,recover_type ="health", value =5,rare =3, effect =nil,describe="回復2d4的生命值",imagePath = "resource/icon/release_v1.2-single_24.png"},
   {id = 36, type = "WeaponAdd", name = "光之照耀", damage =2,element =nil, value =1,rare =1,effect =nil,describe="提升武器2點光屬性傷害", imagePath = "resource/icon/release_v1.2-single_26.png"},
   {id = 37, type = "WeaponAdd", name = "石中劍?", damage =3,element =nil, value =1,rare =1,effect =nil,describe="提升武器3點無屬性傷害", imagePath = "resource/icon/release_v1.2-single_27.png"},
   {id = 38, type = "Potion", name = "雷射", dice_amount =1,dice_face =3,recover_type ="attack",value =1,rare =1,effect =nil,describe="對敵人造成1d3傷害", imagePath = "resource/icon/release_v1.2-single_28.png"},
   {id = 39, type = "Potion", name = "雷射機關槍", dice_amount =2,dice_face =3,recover_type ="attack",value =3,rare =1,effect =nil,describe="對敵人造成2d3傷害", imagePath = "resource/icon/release_v1.2-single_30.png"},
   {id = 40, type = "WeaponAdd", name = "暗之附魔", damage =1,element =nil, value =1,rare =1,effect =nil,describe="提升武器1點暗屬性傷害", imagePath = "resource/icon/release_v1.2-single_31.png"},
   {id = 41, type = "Potion", name = "魔王降臨", dice_amount =1,dice_face =10,recover_type ="attack",value =5,rare =5,effect =nil,describe="對敵人造成1d10傷害", imagePath = "resource/icon/release_v1.2-single_32.png"},
   {id = 42, type = "Potion", name = "san值毀滅", dice_amount =1,dice_face =8,recover_type ="attack",value =5,rare =5,effect =nil,describe="對敵人造成1d8傷害", imagePath = "resource/icon/release_v1.2-single_33.png"},
   {id = 43, type = "Potion", name = "中女亞沙漏?",dice_amount =1,dice_face =5,recover_type ="health",value =5,rare =1,effect =nil,describe="回復1d5的生命值", imagePath = "resource/icon/release_v1.2-single_34.png"},
   {id = 44, type = "Armor", name = "暗黑護甲", defence =4,element =nil, value =4,rare =1,effect =nil,describe="提供玩家4點護甲，雖然很黑" , imagePath = "resource/icon/release_v1.2-single_35.png"},
   {id = 45, type = "WeaponAdd", name = "冰之附魔", damage =1,element =nil, value =1,rare =1,effect =nil,describe="提升武器1點冰屬性傷害", imagePath = "resource/icon/release_v1.2-single_36.png"},
   {id = 46, type = "Potion", name = "冰之回復", dice_amount =1, dice_face =3,recover_type ="health", value =1,rare =1,effect =nil,describe="回復1d3的生命值", imagePath = "resource/icon/release_v1.2-single_38.png"},
   {id = 47, type = "Potion", name = "永恆暴風雪", dice_amount =1,dice_face =6,recover_type ="attack",value =4,rare =4,effect =nil,describe="對敵人造成1d6傷害", imagePath = "resource/icon/release_v1.2-single_39.png"},
}

-- 工廠函數，根據類型創建對應的物品
function createItemFromTemplate(id)
    local template = itemTemplates[id]
    if template then
        local newItem
        if template.type == "Weapon" then
          newItem = Weapon:new(template.name, template.dice_amount,template.dice_face,template.element,template.value,template.rare, template.imagePath,template.effect,template.describe)
        elseif template.type == "WeaponAdd" then
          newItem = WeaponAdd:new(template.name, template.damage,template.element,template.value,template.rare, template.imagePath,template.effect,template.describe)
        elseif template.type == "Armor" then
          newItem = Armor:new(template.name, template.defence,template.element,template.value,template.rare, template.imagePath,template.effect,template.describe)
        elseif template.type == "Potion" then
          newItem = Potion:new(template.name, template.dice_amount,template.dice_face,template.recover_type,template.value,template.rare, template.imagePath,template.effect,template.describe)
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
    
    function Character:adjustHealth(delta)
      self.health = self.health + delta
      print("Character took " .. delta .. " damage. Health: " .. self.health) 
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



-- -----------------------------------------------------------------------------------
--UI相關
-- -----------------------------------------------------------------------------------
local function hideMessage(event)
  waitMessage.isVisible = false
end

local function showMessage()
  waitMessage.isVisible = true
end

local function showValueBar(text)
  valueBarGroup.isVisible = true
  valueBarText.text = text
end

local function hideValueBar()
  valueBarGroup.isVisible = false
end

local function setItemImage(callback)
  local alltime = 0
    for i=1,#myPlayer.item do
      itemIconRects[i].fill={type = "image", filename = myPlayer.item[i].imagePath}
      transition.fadeIn( itemIconRects[i], { delay = i*250, time = 250,})
      alltime = alltime +500
    end
    timer.performWithDelay(alltime,function()
     callback()
     hideMessage()
     end)
end

local function updateItemSelectImage()
 for i=1,#myPlayer.item do
      itemIconRects[i].fill={type = "image", filename = myPlayer.item[i].imagePath}
      transition.fadeIn( itemIconRects[i], { delay = i*100, time = 100,})
    end 
end

local function setAttackIconVisible()
  showAttackIcon.isVisible = true
  if curAction.target == myPlayer then
    showAttackIcon.rotation = 180
    npcNameBarUp.isVisible = false
    npcNameTextUp.isVisible = false
  else
    showAttackIcon.rotation = 0
    npcNameBarUp.isVisible = true
    npcNameTextUp.isVisible = true
  end
end

local function hideAttackIcon()
  showAttackIcon.isVisible = false
end

local function updateTurn()
  turn=turn+1
  turnText.text = "TURN: "..turn
end

--更新UI上的道具欄位顯示
local function updateItemInfoUI()
  local maxY =display.contentCenterY-320
  local minY =display.contentCenterY-520
  local totalHeight = #playerItemQueue * (40 + 5) - 5
  local curYDelta = (maxY- minY)/(#playerItemQueue)

  if totalHeight > (maxY - minY) then
    local currentY = minY
      for i=1, #playerItemQueue do
        transition.to( allItemInfoGroup[i], { time=200, y=currentY} )
        currentY = currentY + curYDelta
      end
    else
      for i=1, #playerItemQueue do
        transition.to( allItemInfoGroup[i], { time=200, y=minY + (i - 1) * (40 + 5)} )
      end
    end
end

local function updateNPCItemInfoUI(callback)
  

  local maxY =display.contentCenterY-320
  local minY =display.contentCenterY-520
  local totalHeight = #npcItemQueue * (40 + 5) - 5
  local curYDelta = (maxY- minY)/(#npcItemQueue)
  local alltime =0

  if totalHeight > (maxY - minY) then
    local currentY = minY
      for i=1, #npcItemQueue do
        transition.to( allINPCtemInfoGroup[i], { time=200, y=currentY} )
        currentY = currentY + curYDelta
        alltime = alltime+200
      end
    else
      for i=1, #npcItemQueue do
        transition.to( allINPCtemInfoGroup[i], { time=200, y=minY + (i - 1) * (40 + 5)} )
        alltime = alltime +200
      end
    end
     timer.performWithDelay(alltime+1000,function()
     callback()
     hideMessage()
     end)
    
end


--當點選新道具時，增加玩家的UI元素
local function setplayerItemInfo(item)
  local itemInfoGroup = display.newGroup()
  allItemInfoGroup:insert(itemInfoGroup)
  local itemInfoBgRect = display.newImageRect(itemInfoGroup,"resource/game_itemButton.png", 100, 40)
  itemInfoBgRect.x = display.contentCenterX
  itemInfoBgRect.y = display.contentCenterY
  local itemInfoIcon = display.newImageRect(itemInfoGroup,item.imagePath, 40, 40)
  itemInfoIcon.x = display.contentCenterX-65
  itemInfoIcon.y = display.contentCenterY
  local itemInfoNameText = display.newText(itemInfoGroup,item.name,display.contentCenterX-15, display.contentCenterY-9, native.systemFont, 14 )
  local itemInfoDescriptText = display.newText(itemInfoGroup,item.describe,display.contentCenterX-12, display.contentCenterY+5, native.systemFont, 10 )
  itemInfoGroup.x = display.contentCenterX-220
  updateItemInfoUI()
end

--非玩家
local function setNPCItemInfo(item,callback)
  if item == nil then
    callback()
    return
  end
  local itemInfoGroup = display.newGroup()
  allINPCtemInfoGroup:insert(itemInfoGroup)
  local itemInfoBgRect = display.newImageRect(itemInfoGroup,"resource/game_itemButton.png", 100, 40)
  itemInfoBgRect.x = display.contentCenterX
  itemInfoBgRect.y = display.contentCenterY
  local itemInfoIcon = display.newImageRect(itemInfoGroup,item.imagePath, 40, 40)
  itemInfoIcon.x = display.contentCenterX-65
  itemInfoIcon.y = display.contentCenterY
  local itemInfoNameText = display.newText(itemInfoGroup,item.name,display.contentCenterX-15, display.contentCenterY-9, native.systemFont, 14 )
  local itemInfoDescriptText = display.newText(itemInfoGroup,item.describe,display.contentCenterX-12, display.contentCenterY+5, native.systemFont, 10 )
  itemInfoGroup.x = display.contentCenterX-30
  updateNPCItemInfoUI(callback)
end

local function showFinalMessage()
  finalMessageGroup.isVisible = true
    if(myPlayer.health<=0)then
      finalMessageText.text = "勝利者"..myNPC.name
    end
    if(myNPC.health<=0)then
      finalMessageText.text = "勝利者"..myPlayer.name
    end
    if(myNPC.health<=0 and myPlayer.health<=0 )then
      finalMessageText.text = "大家都掛了"
    end  
end


local function resetPrevSelectedButton()
  for i=1,#preSelectedItemIndex do
    itemIconRects[preSelectedItemIndex[i]]:setFillColor(1, 1, 1)
    itemButtonIsClick[preSelectedItemIndex[i]] = false    
  end
  preSelectedItemIndex={}
end

local battleLog = {}
--紀錄並執行數值變化
function battleLog:new(attacker,target,action,valueChange)
  local newLog = {
    attacker = attacker,
    target = target,
    action = action,
    valueChange = valueChange, 
  }
  setmetatable(newLog, { __index = battleLog }) 
  function newLog:update()
    local attackSum
    if self.action == "attack" then
      attackSum = 0
      for i=1,#playerItemQueue do
        attackSum = attackSum - playerItemQueue[i].damage
      end  
      self.valueChange = attackSum   
    end
    if self.action == "usePotion" then
    self.valueChange =self.valueChange + playerItemQueue[1].recover
    end    
  end
  function newLog:addDefend(change)
    self.valueChange = self.valueChange + change 
  end
  function newLog:execute()
    self.action()
  end
  return newLog
end


--擲骰子
local function rollDice(item)
  if(item.amount == nil or item.face == nil)then
    error("not rollable")
  end
  local damageSum=0
  for i=1,item.amount do
    damageSum = damageSum +math.random(1, item.face)
  end
  if(curAction.action == "usePotion")then
    item.recover = damageSum
    print("usePotion..."..damageSum)
  else
    item.damage = damageSum    
  end

end

local function getNewItem(character)
  if character == myPlayer then
    
    for i=1,#preSelectedItemIndex do

      myPlayer.item[preSelectedItemIndex[i]] = randomCreateItem()

    end
    updateItemSelectImage()
  end
end

local function resetQueue()
  npcItemQueue={}
  playerItemQueue={}
  allItemInfoGroup:removeSelf()
  allItemInfoGroup = display.newGroup()
  allINPCtemInfoGroup:removeSelf()
  allINPCtemInfoGroup = display.newGroup()
end
--Strategy Pattern處理道具邏輯

local strategy = {}

function strategy:new()
    local newStrategy = {}
    setmetatable(newStrategy, { __index = strategy }) 
    function newStrategy:itemStrategy()
    
    end
    function newStrategy:restoreStrategy()
      
    end    
    return newStrategy
end

local selectWeaponStrategy={}
function selectWeaponStrategy:new(buttonIndex)
    local WeaponStrategy = strategy:new()
    function WeaponStrategy:itemStrategy()
      if(whosTurn== myPlayer)then
      
        if(#playerItemQueue == 0)then
          table.insert(playerItemQueue, myPlayer.item[buttonIndex])
        elseif playerItemQueue[1] then
          resetQueue()
          table.insert(playerItemQueue, myPlayer.item[buttonIndex])
          resetPrevSelectedButton()
        else
          table.insert(playerItemQueue, myPlayer.item[buttonIndex])
        end
        showValueBar(myPlayer.item[buttonIndex].amount.."D"..myPlayer.item[buttonIndex].face)
        curAction.action = "attack"
        curAction.target = myNPC
        rollDice(myPlayer.item[buttonIndex])
        curAction:update()
        
        table.insert(preSelectedItemIndex,buttonIndex)
      end
      if(whosTurn== myNPC)then
      
      end
    end      

    return WeaponStrategy
end

local selectWeaponAddStrategy={}
function selectWeaponAddStrategy:new(buttonIndex)
    local WeaponAddStrategy = strategy:new()
    function WeaponAddStrategy:itemStrategy()
      if(whosTurn== myPlayer)then
      
        table.insert(playerItemQueue, myPlayer.item[buttonIndex])
        
        local addSum=0      
        if getmetatable(playerItemQueue[1]).__index == WeaponAdd then
          for i=1,#playerItemQueue do 
            addSum = addSum +playerItemQueue[i].damage         
          end
          showValueBar("+"..addSum) 
        elseif getmetatable(playerItemQueue[1]).__index == Weapon and getmetatable(playerItemQueue[#playerItemQueue]).__index == WeaponAdd then
          for i=2,#playerItemQueue do 
            addSum = addSum +playerItemQueue[i].damage         
          end
          showValueBar(playerItemQueue[1].amount.."D"..playerItemQueue[1].face.."+"..addSum)               
        else
          resetQueue()
          table.insert(playerItemQueue, myPlayer.item[buttonIndex])
          resetPrevSelectedButton()
          showValueBar("+"..myPlayer.item[buttonIndex].damage) 
        end
        curAction.action = "attack"
        curAction.target = myNPC
        curAction:update() 
        table.insert(preSelectedItemIndex,buttonIndex)
      end
      if(whosTurn== myNPC)then
        
      end
    end      
  
    return WeaponAddStrategy
end

local selectArmorStrategy={}
function selectArmorStrategy:new(buttonIndex)
    local WeaponStrategy = strategy:new()
    function WeaponStrategy:itemStrategy()
      if(whosTurn== myPlayer)then
       
      end
      if(whosTurn== myNPC)then
        table.insert(playerItemQueue, myPlayer.item[buttonIndex])
      end
    end      
    return WeaponStrategy
end

local selectPotionStrategy={}
function selectPotionStrategy:new(buttonIndex)
    local PotionStrategy = strategy:new()
    function PotionStrategy:itemStrategy()
      if(whosTurn== myPlayer)then
        if playerItemQueue[1] then
          resetQueue()
          table.insert(playerItemQueue, myPlayer.item[buttonIndex])
          resetPrevSelectedButton()
        else   
          table.insert(playerItemQueue, myPlayer.item[buttonIndex])
          
        end
      if(myPlayer.item[buttonIndex].recover_type == "health")then
        curAction.action = "usePotion"
        curAction.target = myPlayer
        rollDice(myPlayer.item[buttonIndex])
      end
      if(myPlayer.item[buttonIndex].recover_type == "attack")then
        curAction.action = "attack"
        curAction.target = myNPC
        rollDice(myPlayer.item[buttonIndex])
      end        
        
      curAction:update()
      table.insert(preSelectedItemIndex,buttonIndex)
      end
      if(whosTurn== myNPC)then
      
      end
    end      

    return PotionStrategy
end

local curStrategy

local function itemLogicHandler(buttonIndex)
  local type = getmetatable(myPlayer.item[buttonIndex]).__index
  if type == Weapon then
    curStrategy = selectWeaponStrategy:new(buttonIndex)
  end
  if type == Armor then
    curStrategy = selectArmorStrategy:new(buttonIndex)
  end
  if type == Potion then
    curStrategy = selectPotionStrategy:new(buttonIndex)
  end
  if type == WeaponAdd then
    curStrategy = selectWeaponAddStrategy:new(buttonIndex)
  end
  curStrategy:itemStrategy()
end

--
local function npcDefenceLogic()
  if playerItemQueue[1] == nil then
    setNPCItemInfo(nil,resetQueue)
    return
  end
  if getmetatable(playerItemQueue[1]).__index == Weapon then
    local curDamage = curAction.valueChange
    local curDefence = 0
    for i=1,# myNPC.item do
      if(getmetatable(myNPC.item[i]).__index == Armor)then
        print("DC"..myNPC.item[i].name)
        if(curDefence + myNPC.item[i].defence>=curDamage)then
          table.insert(npcItemQueue,myNPC.item[i])
          curDefence = curDefence + myNPC.item[i].defence
          setNPCItemInfo(myNPC.item[i],resetQueue)
        end
      end  
    end
    for i=1,#npcItemQueue do
      print(i..":"..npcItemQueue[i].name) 
    end
    if curDefence < -curDamage then
      curAction:addDefend(curDefence)  
    end
  end
end

local function onItemButtonTap(buttonIndex)
    return function(event)
    if itemButtonTouchable[buttonIndex] == true then
      if itemButtonIsClick[buttonIndex] == false then
        itemLogicHandler(buttonIndex)
        local setIndex = table.indexOf(playerItemQueue, myPlayer.item[buttonIndex])
        setplayerItemInfo(playerItemQueue[#playerItemQueue])
        itemButtonIsClick[buttonIndex] = true
        itemIconRects[buttonIndex]:setFillColor(0.5, 0.5, 0.5)
      else        
        if #playerItemQueue>1 and (getmetatable(playerItemQueue[#playerItemQueue]).__index ~= getmetatable(playerItemQueue[1]).__index) then
          resetQueue()
        else
          local delItemIndex = table.indexOf(playerItemQueue, myPlayer.item[buttonIndex])
          table.remove(playerItemQueue,delItemIndex)   
          allItemInfoGroup[delItemIndex]:removeSelf() 
        end
        resetPrevSelectedButton()
        updateItemInfoUI()
        hideValueBar()
      end
      
      for i=1,#playerItemQueue do
        print(i..":"..playerItemQueue[i].name)
      end
    end
    setAttackIconVisible()
    end
end


local function onAttackerAreaTap(event)
  if event.phase == "began" then
    overlay.alpha = 0.3  
  end
  if event.phase == "ended" then
   overlay.alpha = 0
   showAttackIcon.isVisible = true
   npcDefenceLogic()
   
   curAction.target:adjustHealth(curAction.valueChange)
   npcHealthText.text = "HP:"..myNPC.health
   playerHealthText.text = "HP:"..myPlayer.health
   getNewItem(myPlayer)
   
   resetPrevSelectedButton()
   allItemInfoGroup:removeSelf()
   allItemInfoGroup = display.newGroup()
   npcTurn()
  end
end





playerTurn = function()
--決定目前可以使用甚麼道具
  whosTurn = myPlayer
  updateTurn()
  curAction=battleLog:new(myPlayer,myNPC,nil,0)
  for i=1,# myPlayer.item do
    if getmetatable(myPlayer.item[i]).__index == Armor then
       itemButtonTouchable[i] = false
       itemIconRects[i]:setFillColor(0.5, 0.5, 0.5)
    end
    if getmetatable(myPlayer.item[i]).__index == Weapon then
       itemButtonTouchable[i] = true
       itemIconRects[i]:setFillColor(1, 1, 1)
    end
    if getmetatable(myPlayer.item[i]).__index == Potion then
       itemButtonTouchable[i] = true
       itemIconRects[i]:setFillColor(1, 1, 1)
    end
  end
  
  if myPlayer.health<=0 or myNPC.health<=0 then
    showFinalMessage()
  end
end

npcTurn = function()
  whosTurn = myNPC
  updateTurn()
  curAction=battleLog:new(myNPC,myPlayer,nil,0)
  for i=1,# myPlayer.item do
    if getmetatable(myPlayer.item[i]).__index == Weapon then
       itemButtonTouchable[i] = false
       itemIconRects[i]:setFillColor(0.5, 0.5, 0.5)
    end
    if getmetatable(myPlayer.item[i]).__index == Potion then
       itemButtonTouchable[i] = false
       itemIconRects[i]:setFillColor(0.5, 0.5, 0.5)
    end
    if getmetatable(myPlayer.item[i]).__index == Armor then
       itemButtonTouchable[i] = true
       itemIconRects[i]:setFillColor(1, 1, 1)
    end  
  end
  if myPlayer.health<=0 or myNPC.health<=0 then
    showFinalMessage()
  end
 playerTurn()
end

local function initGameUI(sceneGroup)
  uiGroup = display.newGroup()
  waitMessage = display.newGroup()
  allItemInfoGroup = display.newGroup()
  valueBarGroup = display.newGroup()
  finalMessageGroup = display.newGroup()
  allINPCtemInfoGroup = display.newGroup()
  
  sceneGroup:insert( uiGroup )
  sceneGroup:insert(waitMessage)
  sceneGroup:insert(allItemInfoGroup)
  sceneGroup:insert(valueBarGroup)
  sceneGroup:insert(finalMessageGroup)
  sceneGroup:insert(allINPCtemInfoGroup)
  
  background = display.newImageRect( uiGroup, "resource/game_background.jpeg", 500, 1000 )
  background.x = display.contentCenterX
  background.y = display.contentCenterY
  turnText = display.newText( uiGroup, "TURN: " .. turn, display.contentCenterX, -20, native.systemFont, 20 )
  
  attackerButton = display.newImageRect( uiGroup, "resource/game_playerArea.png", 125, 225 )
  attackerButton.x = display.contentCenterX-80
  attackerButton.y = 130
  attackerButton:addEventListener( "touch", onAttackerAreaTap)
  
  overlay = display.newRect(display.contentCenterX-80, 130, 130, 230)
  overlay:setFillColor(1, 1, 1)
  overlay.isHitTestable = false
  overlay.alpha = 0
  
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
  
  playerNameText2 = display.newText( uiGroup, "player",display.contentCenterX-70, display.contentCenterY+160, native.systemFont, 12 )
  playerHealthText = display.newText( uiGroup, "HP:",display.contentCenterX-35, display.contentCenterY+160, native.systemFont, 12 )
  playerPPText = display.newText( uiGroup, "PP:",display.contentCenterX, display.contentCenterY+160, native.systemFont, 12 )
  playerMoneyText = display.newText( uiGroup, "MONEY:",display.contentCenterX+50, display.contentCenterY+160, native.systemFont, 12 )
  
  npcNameBar = display.newImageRect( uiGroup, "resource/game_namebar.png", 180, 30 )
  npcNameBar.x = display.contentCenterX
  npcNameBar.y = display.contentCenterY+200
  
  npcNameText2 = display.newText( uiGroup, "player",display.contentCenterX-70, display.contentCenterY+200, native.systemFont, 12 )
  npcHealthText = display.newText( uiGroup, "HP:0",display.contentCenterX-35, display.contentCenterY+200, native.systemFont, 12 )
  npcPPText = display.newText( uiGroup, "PP:0",display.contentCenterX, display.contentCenterY+200, native.systemFont, 12 )
  npcMoneyText = display.newText( uiGroup, "MONEY:0",display.contentCenterX+50, display.contentCenterY+200, native.systemFont, 12 )
  
  npcNameBarUp = display.newImageRect( uiGroup, "resource/game_namebar.png", 125, 20 )
  npcNameBarUp.x = display.contentCenterX+80
  npcNameBarUp.y = 5
  npcNameTextUp = display.newText( uiGroup, "NPC",display.contentCenterX+75, 5, native.systemFont, 12 )
    
  exitButton = display.newImageRect( uiGroup, "resource/game_exitButton.png", 20, 20 )
  exitButton.x = display.contentCenterX-125
  exitButton.y = -20
  exitButton:addEventListener( "tap", endGame )
  
  showAttackIcon = display.newImageRect( uiGroup, "resource/game_showAttack.png", 25, 25 )
  showAttackIcon.x = display.contentCenterX
  showAttackIcon.y = 5
  showAttackIcon.isVisible = false
  
  valueBar = display.newImageRect( valueBarGroup, "resource/game_valueBar.png", 125, 30 )
  valueBar.x = display.contentCenterX-80
  valueBar.y = display.contentCenterY-25
  
  valueBarText =display.newText(valueBarGroup, "NONE",display.contentCenterX-80,display.contentCenterY-25, native.systemFont, 14 )
  valueBarGroup.isVisible = false
  for i = 1, 4 do
    itemButtonRects[i] = display.newImageRect(uiGroup,"resource/game_itemButton.png", 50, 50)
    itemButtonRects[i].x = (display.contentCenterX+35) + (i - 3) * 70  -- 設置 x 座標
    itemButtonRects[i].y = (display.contentCenterY+30)  -- 設置 y 座標
    itemButtonRects[i]:toBack()
    itemButtonRects[i]:addEventListener( "tap", onItemButtonTap(i) )
    
    itemIconRects[i] = display.newImageRect(uiGroup,"resource/game_itemButton.png", 40, 40)
    itemIconRects[i].x = (display.contentCenterX+35) + (i - 3) * 70  -- 設置 x 座標
    itemIconRects[i].y = (display.contentCenterY+30)  -- 設置 y 座標
    itemIconRects[i].isHitTestable = false
    itemIconRects[i].alpha = 0
  end
  
  for i =5,8 do
    itemButtonRects[i] = display.newImageRect(uiGroup,"resource/game_itemButton.png", 50, 50)
    itemButtonRects[i].x = (display.contentCenterX+35) + (i - 7) * 70  -- 設置 x 座標
    itemButtonRects[i].y = (display.contentCenterY+30)+70  -- 設置 y 座標
    itemButtonRects[i]:toBack()
    itemButtonRects[i]:addEventListener( "tap", onItemButtonTap(i) )
    
    itemIconRects[i] = display.newImageRect(uiGroup,"resource/game_itemButton.png", 40, 40)
    itemIconRects[i].x = (display.contentCenterX+35) + (i - 7) * 70  -- 設置 x 座標
    itemIconRects[i].y = (display.contentCenterY+30)+70  -- 設置 y 座標
    itemIconRects[i].isHitTestable = false
    itemIconRects[i].alpha = 0
  end
   
  local waitMessageFrame = display.newImageRect(waitMessage,"resource/game_playerArea.png", 300, 250)
  waitMessageFrame.x = display.contentCenterX
  waitMessageFrame.y = display.contentCenterY-150
  local waitMessageText = display.newText( waitMessage, "決鬥準備開始",display.contentCenterX,display.contentCenterY-150 , native.systemFont, 40 )
  waitMessage:toFront()
  
  
  finalMessageBar = display.newImageRect(finalMessageGroup,"resource/game_playerArea.png", 300, 250)
  finalMessageBar.x = display.contentCenterX
  finalMessageBar.y = display.contentCenterY-150
  finalMessageText = display.newText( finalMessageGroup, "TESTTEST",display.contentCenterX,display.contentCenterY-150 , native.systemFont, 40 )
  finalMessageGroup.isVisible = false  
  finalMessageGroup:toFront()

end

local function setText()
    playerNameText.text = myPlayer.name
    playerNameText2.text = myPlayer.name

    playerHealthText.text ="HP:"..myPlayer.health
    playerPPText.text = "MP:".. myPlayer.MP
    playerMoneyText.text = "MONEY:".. myPlayer.money
    npcNameText2.text = myNPC.name
    npcNameTextUp.text = myNPC.name
    npcHealthText.text ="HP:"..myNPC.health
    npcPPText.text = "MP:".. myNPC.MP
    npcMoneyText.text = "MONEY:".. myNPC.money
    
end


--hide時，重置scene上的元素
local function reset()
  itemButtonIsClick={false,false,false,false,false,false,false,false}
  itemButtonTouchable={true,true,true,true,true,true,true,true}
  playerItemQueue={}
  npcItemQueue={}

  myPlayer = nil
  myNPC= nil  
  
    if allItemInfoGroup then
      while allItemInfoGroup.numChildren > 0 do
        local child = allItemInfoGroup[1]
        child:removeSelf()
      end
    end
    
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
local sceneGroup = self.view
local phase = event.phase
  if phase == "will" then
    initCharacter()
    setText()
    showMessage()
    setItemImage(playerTurn)
  
  elseif phase == "did" then
    if myPlayer.health == 0 or myNPC.health==0 then
      showFinalMessage()
      endGame()
    end
  end
  
end


-- hide()
function scene:hide( event )
local phase = event.phase

  if phase == "will" then

    
  elseif phase == "did" then

    reset()
  end
end


-- destroy()
function scene:destroy( event )

  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view


  
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
