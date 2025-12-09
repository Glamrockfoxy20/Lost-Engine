-- src/player.lua
local Player = {
    x = 0, y = 1.5, z = 0,   -- Posição
    angle = 0,               -- Rotação Horizontal (Yaw)
    pitch = 0,               -- Rotação Vertical (Pitch)
    speed = 4,
    runSpeed = 7,
    radius = 0.3,            -- Tamanho da colisão do jogador
    flashlightOn = true
}

function Player.update(dt, walls)
    local moveSpeed = love.keyboard.isDown("lshift") and Player.runSpeed or Player.speed
    local dx, dz = 0, 0

    -- Input WASD
    if love.keyboard.isDown("w") then
        dx = dx + math.cos(Player.angle)
        dz = dz + math.sin(Player.angle)
    end
    if love.keyboard.isDown("s") then
        dx = dx - math.cos(Player.angle)
        dz = dz - math.sin(Player.angle)
    end
    if love.keyboard.isDown("a") then
        dx = dx + math.cos(Player.angle - math.pi/2)
        dz = dz + math.sin(Player.angle - math.pi/2)
    end
    if love.keyboard.isDown("d") then
        dx = dx + math.cos(Player.angle + math.pi/2)
        dz = dz + math.sin(Player.angle + math.pi/2)
    end

    -- Lanterna (Toggle com F)
    if love.keyboard.isDown("f") then
        -- Lógica simples de debounce seria necessária aqui
        Player.flashlightOn = not Player.flashlightOn
    end

    -- Normaliza vetor (para não andar mais rápido na diagonal) e aplica movimento
    if dx ~= 0 or dz ~= 0 then
        local length = math.sqrt(dx*dx + dz*dz)
        dx = dx / length * moveSpeed * dt
        dz = dz / length * moveSpeed * dt
        
        -- Colisão Simples (Circle vs AABB)
        local nextX = Player.x + dx
        local nextZ = Player.z + dz
        
        if not Player.checkCollision(nextX, Player.z, walls) then Player.x = nextX end
        if not Player.checkCollision(Player.x, nextZ, walls) then Player.z = nextZ end
    end
end

function Player.look(dx, dy)
    local sensitivity = 0.005
    Player.angle = Player.angle + dx * sensitivity
    Player.pitch = Player.pitch - dy * sensitivity
    -- Trava o pescoço para não quebrar (Clamp)
    Player.pitch = math.max(-1.5, math.min(1.5, Player.pitch))
end

function Player.checkCollision(newX, newZ, walls)
    for _, wall in ipairs(walls) do
        -- AABB simples: verifica se jogador entra na caixa da parede
        if newX > wall.x - wall.w/2 and newX < wall.x + wall.w/2 and
           newZ > wall.z - wall.d/2 and newZ < wall.z + wall.d/2 then
            return true -- Colidiu
        end
    end
    return false
end

return Player
