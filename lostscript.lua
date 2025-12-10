-- lostengine.lua - LOST ENGINE CORE (Mobile Edition)
-- Contém: Interpretador, Engine 3D (Simulada), Eventos e Logo.

local LS = {}
_G.lostscript = LS 

-- ===================================================================
-- 1. SISTEMA DE I/O (Entrada e Saída)
-- ===================================================================

function LS.print(text)
    io.write(tostring(text) .. "\n")
end

function LS.input(prompt)
    io.write(prompt or "")
    return io.read()
end

-- ===================================================================
-- 2. SISTEMA DE EVENTOS (O Coração da Modularidade)
-- ===================================================================
local Events = {}
local listeners = {}

function Events.on(eventName, handlerFunction)
    if not listeners[eventName] then
        listeners[eventName] = {}
    end
    table.insert(listeners[eventName], handlerFunction)
    LS.print(string.format("[EVENTOS]: Script inscrito em '%s'", eventName))
end

function Events.dispatch(eventName, eventData)
    if listeners[eventName] then
        for _, handler in ipairs(listeners[eventName]) do
            handler(eventData) 
        end
    end
end

-- ===================================================================
-- 3. MOTOR GRÁFICO E FÍSICO (Engine State)
-- ===================================================================
local Engine = {}

Engine.state = {} 

function Engine.initialize()
    -- Reseta o estado da engine
    Engine.state.camera = {x = 0, y = 1.7, z = 0, angle = 0}
    Engine.state.entities = {} 
    Engine.state.triggers = {}
    
    Engine.state.vars = {
        battery = 100,
        speed = 3
    }
end

-- --- COMANDOS DE CRIAÇÃO ---

function Engine.add_entity(id, type, x, z)
    Engine.state.entities[id] = {type = type, x = x, z = z}
    LS.print(string.format("[MUNDO]: Entidade '%s' (%s) criada em (%.1f, %.1f).", id, type, x, z))
end

function Engine.add_trigger(name, x, z, radius)
    table.insert(Engine.state.triggers, {name = name, x = x, z = z, radius = radius})
    LS.print(string.format("[MUNDO]: Gatilho '%s' criado.", name))
end

-- --- LÓGICA DE ATUALIZAÇÃO (Física e 3D) ---

function Engine.update_game(forward, rotate, dt)
    local s = Engine.state
    
    -- 1. Movimento da Câmera (Simulação 3D)
    s.camera.angle = s.camera.angle + rotate * dt * 90 
    
    if forward ~= 0 then
        -- Matemática para mover na direção que a câmera aponta
        local dx = math.sin(math.rad(s.camera.angle)) * s.vars.speed * dt * forward
        local dz = math.cos(math.rad(s.camera.angle)) * s.vars.speed * dt * forward
        
        s.camera.x = s.camera.x + dx
        s.camera.z = s.camera.z + dz
    end
    
    -- 2. Simulação de Bateria (Recurso de Terror)
    s.vars.battery = math.max(0, s.vars.battery - dt * 2)
    
    -- 3. Verificação de Triggers (Eventos)
    local px, pz = s.camera.x, s.camera.z
    
    for i, trigger in ipairs(s.state.triggers) do
        local dist = math.sqrt((px - trigger.x)^2 + (pz - trigger.z)^2)

        if dist < trigger.radius and trigger.radius > 0 then
            -- Dispara o evento para o script do usuário lidar
            Events.dispatch("OnTriggerEntered", {
                name = trigger.name, 
                dist = dist
            })
            trigger.radius = -1 -- Desativa trigger (evento único)
        end
    end
end

function Engine.render_frame()
    local c = Engine.state.camera
    LS.print("------------------------------------------------")
    LS.print("                 TELA DO JOGO                   ")
    LS.print("------------------------------------------------")
    LS.print(string.format(" VISÃO: X:%.1f | Z:%.1f | ANG: %.0f°", c.x, c.z, c.angle))
    LS.print(string.format(" HUD:   Bateria: %.0f%%", Engine.state.vars.battery))
    LS.print("------------------------------------------------")
end

function Engine.get_state(key)
    return Engine.state.vars[key] or Engine.state.camera[key]
end

-- ===================================================================
-- 4. TELA DE BOOT (LOGO DA LOST ENGINE)
-- ===================================================================

function LS.load()
    LS.print("\n[BOOT]: Inicializando Kernel... OK")
    LS.print("[BOOT]: Carregando Drivers 3D... OK")
    
    -- LOGO EM ASCII ART (Losango com F e Estrela)
    LS.print("\n")
    LS.print("           /\\")
    LS.print("          /  \\")
    LS.print("         / F  \\")
    LS.print("        /    * \\")
    LS.print("        \\      /")
    LS.print("         \\    /")
    LS.print("          \\  /")
    LS.print("           \\/")
    LS.print("")
    LS.print("      L  O  S  T")
    LS.print("     E N G I N E")
    LS.print("\n")
    LS.print("   (c) 2025 - Low Poly Horror")
    LS.print("")
    LS.print("   [TOQUE ENTER PARA INICIAR]")
    LS.print("\n")
    
    LS.input(">>> ") 
    
    Engine.initialize() 
    LS.print("\n[ENGINE]: Ambiente pronto. Aguardando scripts...")
end

-- ===================================================================
-- 5. INTERPRETADOR (SANDBOX)
-- ===================================================================

local ambiente = {
    -- Utilitários
    print = LS.print,
    input = LS.input,
    math = math,
    string = string,
    
    -- API DA ENGINE (Comandos para o Criador)
    add_entity = Engine.add_entity,
    add_trigger = Engine.add_trigger,
    update = Engine.update_game,
    render = Engine.render_frame,
    get = Engine.get_state,
    
    -- Eventos
    on = Events.on,
    dispatch = Events.dispatch
}
setmetatable(ambiente, { __index = _G })

function LS.run(code)
    local func, err = load(code, "LostScript", "t", ambiente)
    if not func then
        LS.print("ERRO DE SINTAXE: "..err)
    else
        local ok, res = pcall(func)
        if not ok then LS.print("ERRO DE EXECUÇÃO: "..res) end
    end
end

-- ===================================================================
-- 6. EXECUÇÃO
-- ===================================================================

LS.load() -- Mostra a logo

LS.print("=== CONSOLE ATIVO (Digite comandos ou /run) ===")
local buffer = {}

while true do
    io.write("> ")
    local linha = io.read()

    if linha == "/run" then
        LS.print("\n[PROCESSANDO SCRIPT...]")
        LS.run(table.concat(buffer, "\n"))
        buffer = {}
    elseif linha == "/exit" then
        break
    else
        table.insert(buffer, linha)
    end
end
