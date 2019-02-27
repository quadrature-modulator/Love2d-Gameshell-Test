local bump = require 'bump'
local world = bump.newWorld()
local player = {x=20, y=0, w=20, h=20, xv=0, yv=0, cj=false, spd=1}
local ground = {x=0, y=220, w=320, h=20}
local ground2 = {x=0, y=160, w=100, h=60}
local ground3 = {x=100, y=100, w=100, h=20}
local moving = {x=160, y=160, w=60, h=20, xv=-0.15}
local coin = {x=100, y=20, w=16, h=16}
local coins = 0
local lives = 3
local gravity = 0.005
local dspFlags = {vsync = false}

--[[

notes:

60hz = bad bad badddddddd
oh noes :(

run = j
jump = k

y = u
x = i

no vsync makes surface and desktop go at like same speed :/
hhmmm....
]]



local function drawBox(box, r,g,b)
  love.graphics.setColor(r,g,b)
  love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
end

function love.load()
    love.window.setMode(320, 240, dspFlags) --set the window dimensions to 320 by 240 with no fullscreen, vsync off, and no antialiasing
    
    coinImg = love.graphics.newImage("coin.png")
    coinSnd = love.audio.newSource("smb3_coin.wav", "static")
    oneupSnd = love.audio.newSource("smb3_1-up.wav", "static")
    --jumpSnd = love.audio.newSource("smb3_jump.wav", "static")
    world:add(player, player.x, player.y, player.w, player.h)
    world:add(ground, ground.x, ground.y, ground.w, ground.h)
    world:add(ground2, ground2.x, ground2.y, ground2.w, ground2.h)
    world:add(ground3, ground3.x, ground3.y, ground3.w, ground3.h)
    world:add(moving, moving.x, moving.y, moving.w, moving.h)
end

function love.update(dt)

  if love.keyboard.isDown("escape") then
    love.event.quit() --gameshell quit
  end

  

  local actualXM, actualYM, colsM, lenM = world:move(moving, moving.x + moving.xv, moving.y)
  local actualX, actualY, cols, len = world:move(player, player.x + player.xv, player.y + player.yv)
  local itemsR, lenR = world:queryRect(player.x,player.y + player.h - 1,player.w ,2)
  local itemsR2, lenR2 = world:queryRect(player.x,player.y - 1,player.w,2)
  local itemsC, lenC = world:queryRect(coin.x,coin.y,coin.w,coin.h)
  

  player.x = actualX
  player.y = actualY

  moving.x = actualXM
  moving.y = actualYM

  if lenM > 0 then
    for i=1,lenM do
      local obj = colsM[i].other
      if obj ~= player then
        moving.xv = moving.xv * -1
        
      end
    end
  end
  
  if moving.x >= 320 - moving.w then
    moving.xv = moving.xv * -1
  end

  if len >= 1 and lenR >= 2 then
      player.yv = 0
      player.cj = true
  elseif len >= 1 and lenR2 >= 2 then
    player.yv = 0
    
  else
    player.yv = player.yv + gravity
    player.cj = false
  end

  if love.keyboard.isDown("k") and player.cj then
    if love.keyboard.isDown("j") then
      player.yv = -0.9
    else
      player.yv = -0.8
    end
    --love.audio.stop()
    --love.audio.play(jumpSnd)
    player.cj = false
  end
  if love.keyboard.isDown("j") then
    player.spd = 0.5
  else
    player.spd = 0.25
  end



  if love.keyboard.isDown("left") and player.x > player.spd - 1 then
    player.xv = player.spd * -1
    
  elseif love.keyboard.isDown("right") and player.x + player.w < 320 then
    player.xv = player.spd
    
  else
    player.xv = 0
  end

  if lenC >= 1 then
    coin.x = love.math.random(0, 320 - coin.w)
    coin.y = love.math.random(0, 240 - coin.h)
    if itemsC[1] == player then
      love.audio.stop()
      love.audio.play(coinSnd)
      coins = coins + 1
    end
  end

  
  --1up
  if coins >= 100 then
    coins = coins - 100
    love.audio.stop()
    love.audio.play(oneupSnd)
    lives = lives + 1
  end
end

function love.draw()
    love.graphics.setBackgroundColor(0.6, 0.6, 1)
    drawBox(player, 0.8, 1, 0.8)
    drawBox(ground, 0.5, 1, 0.5)
    drawBox(ground2, 0.5, 1, 0.5)
    drawBox(ground3, 0.5, 1, 0.5)
    drawBox(moving, 0.8, 0.8, 0.8)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(coinImg, coin.x, coin.y)
    
    love.graphics.print("coins: "..coins, 0, 0)
    love.graphics.print("lives: "..lives, 220, 0)

end
