-- main.lua
-- Carrega os módulos
local Player = require "src/player"
local World = require "src/world"
local Audio = require "src/audio"

local gameState = "LOADING" -- LOADING, GAME, GAMEOVER
local assets = {}
local loadingTimer = 0

function love.load()
    -- Carrega a logo da engine
    assets.logo = love.graphics.newImage("assets/logo.png")
    
    -- Configura filtro "Nearest" para visual crocante (PS1 style)
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- Trava o mouse no centro da tela (FPS style)
    love.mouse.setRelativeMode(true)
end

function love.update(dt)
    if gameState == "LOADING" then
        loadingTimer = loadingTimer + dt
        -- Simula carregamento de assets pesados
        if loadingTimer > 3 then 
            World.load()
            gameState = "GAME" 
        end
    elseif gameState == "GAME" then
        -- Sai do jogo com ESC
        if love.keyboard.isDown("escape") then love.event.quit() end
        
        Player.update(dt, World.walls)
        World.update(dt, Player)
    end
end

function love.draw()
    if gameState == "LOADING" then
        -- Renderiza a Logo centralizada
        local w, h = love.graphics.getDimensions()
        local logoW, logoH = assets.logo:getDimensions()
        -- Fundo Preto
        love.graphics.clear(0, 0, 0) 
        -- Desenha logo
        love.graphics.setColor(1, 1, 1, math.min(loadingTimer, 1)) -- Fade in
        love.graphics.draw(assets.logo, w/2, h/2, 0, 1, 1, logoW/2, logoH/2)
        love.graphics.print("LOADING...", w - 100, h - 30)
        
    elseif gameState == "GAME" then
        -- Renderização 3D simulada
        World.draw(Player)
        
        -- UI (HUD)
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
        if Player.flashlightOn then
            love.graphics.print("LANTERNA: ON", 10, 30)
        end
    end
end

function love.mousemoved(x, y, dx, dy)
    if gameState == "GAME" then
        Player.look(dx, dy)
    end
end
