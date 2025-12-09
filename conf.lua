-- conf.lua
function love.conf(t)
    t.window.title = "Lost Engine - Prototype"
    t.window.width = 800
    t.window.height = 600
    t.window.vsync = true 
    t.console = true -- Abre console para debug
    
    -- Estilo PS1: Desativa filtros de suavização
    t.modules.touch = false -- Desliga toque se for PC para economizar RAM
end
