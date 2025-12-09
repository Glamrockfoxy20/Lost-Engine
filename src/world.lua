-- src/world.lua
local World = {
    walls = {},
    triggers = {},
    lights = {}
}

function World.load()
    -- Criação procedual de nível (exemplo de corredor)
    -- Parede: {x, z, largura, profundidade, cor}
    table.insert(World.walls, {x = 5, z = 0, w = 1, d = 10, color = {0.5, 0.5, 0.5}}) -- Parede Direita
    table.insert(World.walls, {x = -5, z = 0, w = 1, d = 10, color = {0.5, 0.5, 0.5}}) -- Parede Esquerda
    table.insert(World.walls, {x = 0, z = 10, w = 10, d = 1, color = {0.3, 0, 0}})    -- Parede Final (Sangue?)

    -- Trigger de Susto
    table.insert(World.triggers, {
        x = 0, z = 5, radius = 1.5, active = true,
        onEnter = function()
            print("EVENTO: JUMPSCARE!") 
            -- Aqui tocaria o som: Audio.play("scream")
            -- Piscaria a luz
        end
    })
    
    -- Luz de ambiente
    table.insert(World.lights, {x = 0, y = 2, z = 8, intensity = 10})
end

function World.update(dt, player)
    -- Verifica triggers
    for _, trig in ipairs(World.triggers) do
        if trig.active then
            local dist = math.sqrt((player.x - trig.x)^2 + (player.z - trig.z)^2)
            if dist < trig.radius then
                trig.onEnter()
                trig.active = false -- Desativa após uso (evento único)
            end
        end
    end
end

-- Simulação de Renderização 3D (Raycasting simplificado ou Wireframe para teste)
function World.draw(player)
    -- Limpa a tela com "Darkness"
    love.graphics.clear(0.05, 0.05, 0.05)
    
    love.graphics.push()
    -- Centraliza tudo como se fosse a câmera
    love.graphics.translate(400, 300) 
    
    -- Desenha paredes (Lógica 2.5D simulada para protótipo)
    -- Em uma engine real, aqui entraria a chamada OpenGL/Shader
    for _, wall in ipairs(World.walls) do
        -- Matemática de projeção básica para converter Mundo 3D -> Tela 2D
        local relativeX = wall.x - player.x
        local relativeZ = wall.z - player.z
        
        -- Rotaciona ponto baseado no ângulo do jogador
        local rotX = relativeX * math.cos(-player.angle) - relativeZ * math.sin(-player.angle)
        local rotZ = relativeX * math.sin(-player.angle) + relativeZ * math.cos(-player.angle)
        
        -- Só desenha se estiver na frente da câmera
        if rotZ > 0 then
            local scale = 200 / rotZ -- Perspectiva
            local screenX = rotX * scale
            local screenW = wall.w * scale * 5
            local screenH = 400 / rotZ -- Altura baseada na distância
            
            -- Sistema de Luz Simples (Diminui cor com distância)
            local brightness = math.max(0, 1 - (rotZ / 15))
            if player.flashlightOn then brightness = brightness + 0.2 end
            
            love.graphics.setColor(wall.color[1]*brightness, wall.color[2]*brightness, wall.color[3]*brightness)
            love.graphics.rectangle("fill", screenX - screenW/2, -screenH/2 + (player.pitch * 200), screenW, screenH)
        end
    end
    love.graphics.pop()
end

return World
