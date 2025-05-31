-- main.lua
-- River Raid Remaster - Menú principal

function love.load()
    -- Tamaño de la ventana
    love.window.setMode(480, 640)
    love.window.setTitle("River Raid Remaster")

    -- Cargar sprites de fondo del menú
    menuBackgrounds = {
        love.graphics.newImage("Menu/Sprite fondo 1.png"),
        love.graphics.newImage("Menu/Sprite fondo 2.png"),
        love.graphics.newImage("Menu/Sprite fondo 3.png")
    }
    backgroundIndex = 1
    backgroundTimer = 0
    backgroundInterval = 0.3

    -- Cargar sprites de opciones del menú
    menuOptions = {
        love.graphics.newImage("Menu/Start.png"),
        love.graphics.newImage("Menu/Creditos.png"),
        love.graphics.newImage("Menu/Exit.png")
    }
    creatorImage = love.graphics.newImage("Menu/Creador.png")

    -- Estado del menú
    menuState = "main" -- "main" o "creator"
    selectedOption = 1 -- 1: Start, 2: Creditos, 3: Exit

    -- Cargar sonidos
    menuMusic = love.audio.newSource("Sonidos/Musica menu.wav", "stream")
    selectSound = love.audio.newSource("Sonidos/Seleccionar.wav", "static")

    -- Reproducir música del menú en loop
    menuMusic:setLooping(true)
    love.audio.play(menuMusic)
end

function love.update(dt)
    -- Animación del fondo del menú
    backgroundTimer = backgroundTimer + dt
    if backgroundTimer >= backgroundInterval then
        backgroundTimer = backgroundTimer - backgroundInterval
        backgroundIndex = backgroundIndex % #menuBackgrounds + 1
    end
end

function love.draw()
    -- Dibujar fondo animado
    love.graphics.draw(menuBackgrounds[backgroundIndex], 0, 0)

    if menuState == "main" then
        -- Dibujar la opción seleccionada
        love.graphics.draw(menuOptions[selectedOption], 0, 0)
    elseif menuState == "creator" then
        love.graphics.draw(creatorImage, 0, 0)
    end
end

function love.keypressed(key)
    if menuState == "main" then
        if key == "s" then
            selectedOption = selectedOption % #menuOptions + 1
            selectSound:stop()
            selectSound:play()
        elseif key == "w" then
            selectedOption = (selectedOption - 2) % #menuOptions + 1
            selectSound:stop()
            selectSound:play()
        elseif key == "space" then
            selectSound:stop()
            selectSound:play()
            if selectedOption == 1 then
                -- Comenzar el juego (a implementar)
                -- Por ahora solo para ejemplo, detener música
                menuMusic:stop()
                -- Aquí iría el cambio de estado al juego
            elseif selectedOption == 2 then
                menuState = "creator"
            elseif selectedOption == 3 then
                love.event.quit()
            end
        end
    elseif menuState == "creator" then
        if key == "space" then
            menuState = "main"
            selectSound:stop()
            selectSound:play()
        end
    end
end

-- Variables del juego
local gameState = "menu" -- "menu", "game"
local gameMap
local mapY = 0
local mapSpeed = 120 -- píxeles por segundo
local player
local playerSprite
local playerMarginBottom = 60
local playerMarginTop = 60
local playerSpeed = 200
local bulletSprite
local bullets = {}
local bulletSpeed = 400
local bulletCooldown = 0.3
local bulletTimer = 0
local canShoot = true
local shootSound
local gameMusic

-- Inicializar el juego
function startGame()
    -- Limpiar recursos del menú
    menuBackgrounds = nil
    menuOptions = nil
    creatorImage = nil
    menuMusic:stop()
    menuMusic = nil

    -- Cargar mapa y jugador
    gameMap = love.graphics.newImage("Mapa completo imagen.png")
    mapY = 0

    playerSprite = love.graphics.newImage("Jugador/Jugador nivel 1.png")
    local playerWidth = playerSprite:getWidth()
    local playerHeight = playerSprite:getHeight()
    player = {
        x = (480 - playerWidth) / 2,
        y = 640 - playerHeight - playerMarginBottom,
        w = playerWidth,
        h = playerHeight
    }

    bulletSprite = love.graphics.newImage("Balas/Bala 1.png")
    bullets = {}
    bulletTimer = 0
    canShoot = true

    shootSound = love.audio.newSource("Sonidos/Sonido disparo.wav", "static")
    gameMusic = love.audio.newSource("Sonidos/Musica de fondo.wav", "stream")
    gameMusic:setLooping(true)
    love.audio.play(gameMusic)

    gameState = "game"
end

-- Actualización del juego
local function updateGame(dt)
    -- Mover el mapa hacia abajo
    mapY = mapY + mapSpeed * dt
    if mapY >= gameMap:getHeight() then
        mapY = mapY - gameMap:getHeight()
    end

    -- Movimiento del jugador
    if love.keyboard.isDown("a") then
        player.x = math.max(0, player.x - playerSpeed * dt)
    end
    if love.keyboard.isDown("d") then
        player.x = math.min(480 - player.w, player.x + playerSpeed * dt)
    end
    if love.keyboard.isDown("w") then
        local minY = math.max(640 / 2, 640 - player.h - playerMarginBottom - (640 / 2 - playerMarginTop))
        player.y = math.max(minY, player.y - playerSpeed * dt)
    end
    if love.keyboard.isDown("s") then
        player.y = math.min(640 - player.h - playerMarginBottom, player.y + playerSpeed * dt)
    end

    -- Actualizar balas
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        b.y = b.y - bulletSpeed * dt
        if b.y + b.h < 0 then
            table.remove(bullets, i)
        end
    end

    -- Control de disparo
    if not canShoot then
        bulletTimer = bulletTimer + dt
        if bulletTimer >= bulletCooldown then
            canShoot = true
            bulletTimer = 0
        end
    end
end

-- Dibujo del juego
local function drawGame()
    -- Dibujar el mapa dos veces para el bucle
    love.graphics.draw(gameMap, 0, mapY)
    love.graphics.draw(gameMap, 0, mapY - gameMap:getHeight())

    -- Dibujar jugador
    love.graphics.draw(playerSprite, player.x, player.y)

    -- Dibujar balas
    for _, b in ipairs(bullets) do
        love.graphics.draw(bulletSprite, b.x, b.y)
    end
end

-- Sobrescribir love.update
local old_update = love.update
function love.update(dt)
    if gameState == "game" then
        updateGame(dt)
    else
        old_update(dt)
    end
end

-- Sobrescribir love.draw
local old_draw = love.draw
function love.draw()
    if gameState == "game" then
        drawGame()
    else
        old_draw()
    end
end

-- Sobrescribir love.keypressed
local old_keypressed = love.keypressed
function love.keypressed(key)
    if gameState == "menu" then
        old_keypressed(key)
        if menuState == "main" and key == "space" and selectedOption == 1 then
            startGame()
        end
    elseif gameState == "game" then
        if key == "space" and canShoot then
            -- Disparar
            local bx = player.x + player.w / 2 - bulletSprite:getWidth() / 2
            local by = player.y
            table.insert(bullets, {x = bx, y = by, w = bulletSprite:getWidth(), h = bulletSprite:getHeight()})
            shootSound:stop()
            shootSound:play()
            canShoot = false
            bulletTimer = 0
        end
    end
end

-- =========================
-- POWER UP SYSTEM
-- =========================

-- Cargar sprites de niveles de jugador y balas
local playerSprites = {
    love.graphics.newImage("Jugador/Jugador nivel 1.png"),
    love.graphics.newImage("Jugador/Jugador nivel 2.png"),
    love.graphics.newImage("Jugador/Jugador nivel 3.png")
}
local bulletSprites = {
    love.graphics.newImage("Balas/Bala 1.png"),
    love.graphics.newImage("Balas/Bala 2.png"),
    love.graphics.newImage("Balas/Bala 3.png")
}
local powerupSprite = love.graphics.newImage("Objetos/Power up.png")
local powerup = {
    active = false,
    x = 0,
    y = 0,
    speed = 80,
    timer = 0,
    interval = 25
}
local playerLevel = 1

-- =========================
-- ENEMY SYSTEM
-- =========================

-- Cargar sprites de enemigos y balas
local enemySprites = {
    love.graphics.newImage("Enemigos aereos/Enemigo 1.png"),
    love.graphics.newImage("Enemigos aereos/Enemigo 2.png"),
    love.graphics.newImage("Enemigos aereos/Enemigo 3.png"),
    love.graphics.newImage("Enemigos aereos/Enemigo 4.png")
}
local enemyBulletSprites = {
    love.graphics.newImage("Balas/Bala enemigo 1.png"),
    love.graphics.newImage("Balas/Bala enemigo 2.png"),
    love.graphics.newImage("Balas/Bala enemigo 3.png"),
    love.graphics.newImage("Balas/Bala enemigo 4.png")
}

-- Efecto de muerte
local deathSprites = {
    love.graphics.newImage("Efecto de muerte/Muerte 1.png"),
    love.graphics.newImage("Efecto de muerte/Muerte 2.png"),
    love.graphics.newImage("Efecto de muerte/Muerte 3.png"),
    love.graphics.newImage("Efecto de muerte/Muerte 4.png"),
    love.graphics.newImage("Efecto de muerte/Muerte 5.png")
}
local enemyDeathSound = love.audio.newSource("Sonidos/Muerte enemigo.wav", "static")

-- Configuración de enemigos
local enemyConfigs = {
    {
        spawnInterval = 3, shootInterval = 0.7, speed = 180, lateralSpeedMin = 80, lateralSpeedMax = 140, health = {4,2,1}
    },
    {
        spawnInterval = 6, shootInterval = 1.2, speed = 140, lateralSpeedMin = 50, lateralSpeedMax = 90, health = {8,5,3}
    },
    {
        spawnInterval = 11, shootInterval = 1.5, speed = 100, lateralSpeedMin = 30, lateralSpeedMax = 60, health = {12,9,7}
    },
    {
        spawnInterval = 15, shootInterval = 2, speed = 70, lateralSpeedMin = 15, lateralSpeedMax = 30, health = {20,16,10}
    }
}

local enemies = {}
local enemyTimers = {0,0,0,0}

-- =========================
-- ENEMY DEATH ANIMATION
-- =========================
local deaths = {}

-- =========================
-- ENEMY BULLETS
-- =========================
local enemyBullets = {}

-- =========================
-- POWER UP LOGIC
-- =========================
local function spawnPowerup()
    powerup.active = true
    powerup.x = math.random(20, 480-20-powerupSprite:getWidth())
    powerup.y = -powerupSprite:getHeight()
end

local function updatePowerup(dt)
    powerup.timer = powerup.timer + dt
    if not powerup.active and powerup.timer >= powerup.interval then
        spawnPowerup()
        powerup.timer = 0
    end
    if powerup.active then
        powerup.y = powerup.y + powerup.speed * dt
        -- Colisión con jugador
        if player.x < powerup.x + powerupSprite:getWidth() and
           player.x + player.w > powerup.x and
           player.y < powerup.y + powerupSprite:getHeight() and
           player.y + player.h > powerup.y then
            if playerLevel < 3 then
                playerLevel = playerLevel + 1
                playerSprite = playerSprites[playerLevel]
                bulletSprite = bulletSprites[playerLevel]
            end
            powerup.active = false
        elseif powerup.y > 640 then
            powerup.active = false
        end
    end
end

local function drawPowerup()
    if powerup.active then
        love.graphics.draw(powerupSprite, powerup.x, powerup.y)
    end
end

-- =========================
-- ENEMY LOGIC
-- =========================
local function spawnEnemy(typeIdx)
    local sprite = enemySprites[typeIdx]
    local w, h = sprite:getWidth(), sprite:getHeight()
    local x = math.random(0, 480 - w)
    local y = -h
    local config = enemyConfigs[typeIdx]
    local lateralSpeed = math.random(config.lateralSpeedMin, config.lateralSpeedMax)
    if math.random() < 0.5 then lateralSpeed = -lateralSpeed end
    table.insert(enemies, {
        type = typeIdx,
        x = x,
        y = y,
        w = w,
        h = h,
        vx = lateralSpeed,
        vy = config.speed,
        shootTimer = 0,
        health = config.health[playerLevel],
        alive = true,
        deathAnim = nil
    })
end

local function updateEnemies(dt)
    -- Spawning
    for i=1,4 do
        enemyTimers[i] = enemyTimers[i] + dt
        if enemyTimers[i] >= enemyConfigs[i].spawnInterval then
            spawnEnemy(i)
            enemyTimers[i] = 0
        end
    end

    -- Update
    for i=#enemies,1,-1 do
        local e = enemies[i]
        if e.alive then
            -- Movimiento
            e.x = e.x + e.vx * dt
            e.y = e.y + e.vy * dt
            -- Rebote lateral
            if e.x < 0 then e.x = 0; e.vx = -e.vx end
            if e.x + e.w > 480 then e.x = 480 - e.w; e.vx = -e.vx end
            -- Disparo
            e.shootTimer = e.shootTimer + dt
            if e.shootTimer >= enemyConfigs[e.type].shootInterval then
                table.insert(enemyBullets, {
                    type = e.type,
                    x = e.x + e.w/2 - enemyBulletSprites[e.type]:getWidth()/2,
                    y = e.y + e.h,
                    w = enemyBulletSprites[e.type]:getWidth(),
                    h = enemyBulletSprites[e.type]:getHeight(),
                    vy = 220 + 30*e.type
                })
                e.shootTimer = 0
            end
            -- Fuera de pantalla
            if e.y > 640 then
                table.remove(enemies, i)
            end
        elseif e.deathAnim then
            -- Animación de muerte
            e.deathAnim.timer = e.deathAnim.timer + dt
            if e.deathAnim.timer >= 0.2 then
                e.deathAnim.timer = 0
                e.deathAnim.frame = e.deathAnim.frame + 1
                if e.deathAnim.frame > #deathSprites then
                    table.remove(enemies, i)
                end
            end
        end
    end
end

local function drawEnemies()
    for _,e in ipairs(enemies) do
        if e.alive then
            love.graphics.draw(enemySprites[e.type], e.x, e.y)
        elseif e.deathAnim then
            if e.deathAnim.frame <= #deathSprites then
                love.graphics.draw(deathSprites[e.deathAnim.frame], e.x, e.y)
            end
        end
    end
end

-- =========================
-- ENEMY BULLETS LOGIC
-- =========================
local function updateEnemyBullets(dt)
    for i=#enemyBullets,1,-1 do
        local b = enemyBullets[i]
        b.y = b.y + b.vy * dt
        if b.y > 640 then
            table.remove(enemyBullets, i)
        end
    end
end

local function drawEnemyBullets()
    for _,b in ipairs(enemyBullets) do
        love.graphics.draw(enemyBulletSprites[b.type], b.x, b.y)
    end
end

-- =========================
-- PLAYER BULLET/ENEMY COLLISION & ENEMY DEATH
-- =========================
local function checkBulletEnemyCollision()
    for bi=#bullets,1,-1 do
        local b = bullets[bi]
        for ei=#enemies,1,-1 do
            local e = enemies[ei]
            if e.alive and
                b.x < e.x + e.w and
                b.x + b.w > e.x and
                b.y < e.y + e.h and
                b.y + b.h > e.y then
                -- Daño según nivel
                e.health = e.health - 1
                table.remove(bullets, bi)
                if e.health <= 0 then
                    e.alive = false
                    e.deathAnim = {frame=1, timer=0}
                    enemyDeathSound:stop()
                    enemyDeathSound:play()
                end
                break
            end
        end
    end
end

-- =========================
-- EXTENDER updateGame Y drawGame
-- =========================
local old_updateGame = updateGame
updateGame = function(dt)
    old_updateGame(dt)
    updatePowerup(dt)
    updateEnemies(dt)
    updateEnemyBullets(dt)
    checkBulletEnemyCollision()
end

local old_drawGame = drawGame
drawGame = function()
    old_drawGame()
    drawPowerup()
    drawEnemies()
    drawEnemyBullets()
end

-- =========================
-- REINICIAR NIVEL DEL JUGADOR AL INICIAR JUEGO
-- =========================
local old_startGame = startGame
startGame = function()
    old_startGame()
    playerLevel = 1
    playerSprite = playerSprites[playerLevel]
    bulletSprite = bulletSprites[playerLevel]
    powerup.active = false
    powerup.timer = 0
    for i=1,4 do enemyTimers[i]=0 end
    enemies = {}
    enemyBullets = {}
end

-- =========================
-- BARRA DE SALUD (HEALTH BAR)
-- =========================

-- Cargar sprites de la barra de salud
local healthBarSprites = {
    love.graphics.newImage("Barra de salud/Barra de salud 1.png"),
    love.graphics.newImage("Barra de salud/Barra de salud 2.png"),
    love.graphics.newImage("Barra de salud/Barra de salud 3.png"),
    love.graphics.newImage("Barra de salud/Barra de salud 4.png"),
    love.graphics.newImage("Barra de salud/Barra de salud 5.png"),
    love.graphics.newImage("Barra de salud/Barra de salud 6.png")
}
local healthBarScale = 0.25 -- Ajusta este valor para el tamaño pequeño en la esquina
local healthBarX = 340
local healthBarY = 0

local playerHealth = 1 -- 1 = lleno, 6 = vacío
local maxHealth = 6

local hitSound = love.audio.newSource("Sonidos/Sonido hit.wav", "static")
local invincible = false
local invincibleTimer = 0
local invincibleDuration = 3
local blinkTimer = 0
local blinkInterval = 0.12
local blinkVisible = true

-- Reiniciar salud al iniciar juego
local old_startGame_health = startGame
startGame = function()
    old_startGame_health()
    playerHealth = 1
    invincible = false
    invincibleTimer = 0
    blinkTimer = 0
    blinkVisible = true
end

-- Daño según tipo de bala enemiga
local enemyBulletDamage = {1, 1, 2, 3}

-- Colisión de balas enemigas con jugador
local function checkEnemyBulletPlayerCollision(dt)
    if invincible then
        invincibleTimer = invincibleTimer + dt
        blinkTimer = blinkTimer + dt
        if blinkTimer >= blinkInterval then
            blinkVisible = not blinkVisible
            blinkTimer = blinkTimer - blinkInterval
        end
        if invincibleTimer >= invincibleDuration then
            invincible = false
            invincibleTimer = 0
            blinkTimer = 0
            blinkVisible = true
        end
        return
    end

    for i = #enemyBullets, 1, -1 do
        local b = enemyBullets[i]
        if player.x < b.x + b.w and
           player.x + player.w > b.x and
           player.y < b.y + b.h and
           player.y + player.h > b.y then
            -- Recibe daño
            playerHealth = math.min(playerHealth + enemyBulletDamage[b.type], maxHealth)
            hitSound:stop()
            hitSound:play()
            invincible = true
            invincibleTimer = 0
            blinkTimer = 0
            blinkVisible = false
            table.remove(enemyBullets, i)
            break
        end
    end
end

-- Dibujar barra de salud
local function drawHealthBar()
    local sprite = healthBarSprites[math.min(playerHealth, maxHealth)]
    love.graphics.draw(sprite, healthBarX, healthBarY, 0, healthBarScale, healthBarScale)
end

-- Parpadeo del jugador al recibir daño
local old_drawGame_health = drawGame
drawGame = function()
    old_drawGame_health()
    drawHealthBar()
end

local old_updateGame_health = updateGame
updateGame = function(dt)
    old_updateGame_health(dt)
    checkEnemyBulletPlayerCollision(dt)
end

-- Parpadeo: solo dibujar jugador si corresponde
local old_draw = love.graphics.draw
love.graphics.draw = function(image, x, y, ...)
    if image == playerSprite and gameState == "game" then
        if invincible then
            if blinkVisible then
                old_draw(image, x, y, ...)
            end
        else
            old_draw(image, x, y, ...)
        end
    else
        old_draw(image, x, y, ...)
    end
end

-- =========================
-- CURACIÓN (HEALTH PICKUP)
-- =========================

-- Cargar sprite y sonido de curación
local healSprite = love.graphics.newImage("Objetos/Curacion.png")
local healSound = love.audio.newSource("Sonidos/Sonido power up.wav", "static")

-- Curación: objeto y temporizador
local heal = {
    active = false,
    x = 0,
    y = 0,
    speed = 100,
    timer = 0,
    interval = 6
}

-- Parpadeo de barra de vida al curarse
local healthBlink = {
    active = false,
    timer = 0,
    duration = 1,
    blinkTimer = 0,
    blinkInterval = 0.08,
    visible = true
}

-- Parpadeo de nave al power up
local powerupBlink = {
    active = false,
    timer = 0,
    duration = 1,
    blinkTimer = 0,
    blinkInterval = 0.08,
    visible = true
}

-- Spawnear curación
local function spawnHeal()
    heal.active = true
    heal.x = math.random(20, 480-20-healSprite:getWidth())
    heal.y = -healSprite:getHeight()
end

-- Actualizar curación
local function updateHeal(dt)
    heal.timer = heal.timer + dt
    if not heal.active and heal.timer >= heal.interval then
        spawnHeal()
        heal.timer = 0
    end
    if heal.active then
        heal.y = heal.y + heal.speed * dt
        -- Colisión con jugador
        if player.x < heal.x + healSprite:getWidth() and
           player.x + player.w > heal.x and
           player.y < heal.y + healSprite:getHeight() and
           player.y + player.h > heal.y then
            if playerHealth > 1 then
                playerHealth = playerHealth - 1
                healSound:stop()
                healSound:play()
                -- Iniciar parpadeo de barra de vida
                healthBlink.active = true
                healthBlink.timer = 0
                healthBlink.blinkTimer = 0
                healthBlink.visible = false
            end
            heal.active = false
        elseif heal.y > 640 then
            heal.active = false
        end
    end
end

-- Dibujar curación
local function drawHeal()
    if heal.active then
        love.graphics.draw(healSprite, heal.x, heal.y)
    end
end

-- Parpadeo de barra de vida al curarse
local old_drawHealthBar = drawHealthBar
drawHealthBar = function()
    if healthBlink.active then
        if healthBlink.visible then
            old_drawHealthBar()
        end
    else
        old_drawHealthBar()
    end
end

-- Actualizar parpadeo de barra de vida
local old_updateGame_heal = updateGame
updateGame = function(dt)
    old_updateGame_heal(dt)
    updateHeal(dt)
    -- Parpadeo barra de vida
    if healthBlink.active then
        healthBlink.timer = healthBlink.timer + dt
        healthBlink.blinkTimer = healthBlink.blinkTimer + dt
        if healthBlink.blinkTimer >= healthBlink.blinkInterval then
            healthBlink.visible = not healthBlink.visible
            healthBlink.blinkTimer = healthBlink.blinkTimer - healthBlink.blinkInterval
        end
        if healthBlink.timer >= healthBlink.duration then
            healthBlink.active = false
            healthBlink.visible = true
        end
    end
    -- Parpadeo nave por power up
    if powerupBlink.active then
        powerupBlink.timer = powerupBlink.timer + dt
        powerupBlink.blinkTimer = powerupBlink.blinkTimer + dt
        if powerupBlink.blinkTimer >= powerupBlink.blinkInterval then
            powerupBlink.visible = not powerupBlink.visible
            powerupBlink.blinkTimer = powerupBlink.blinkTimer - powerupBlink.blinkInterval
        end
        if powerupBlink.timer >= powerupBlink.duration then
            powerupBlink.active = false
            powerupBlink.visible = true
        end
    end
end

-- Parpadeo de nave por power up: hook en updatePowerup
local old_updatePowerup = updatePowerup
updatePowerup = function(dt)
    local prevLevel = playerLevel
    old_updatePowerup(dt)
    -- Si subió de nivel, reproducir sonido y parpadeo de nave
    if powerup.active == false and playerLevel > prevLevel then
        healSound:stop()
        healSound:play()
        powerupBlink.active = true
        powerupBlink.timer = 0
        powerupBlink.blinkTimer = 0
        powerupBlink.visible = false
    end
end

-- Parpadeo de nave por power up: hook en love.graphics.draw
local old_love_draw = love.graphics.draw
love.graphics.draw = function(image, x, y, ...)
    if image == playerSprite and gameState == "game" then
        if invincible then
            if blinkVisible then
                old_love_draw(image, x, y, ...)
            end
        elseif powerupBlink.active then
            if powerupBlink.visible then
                old_love_draw(image, x, y, ...)
            end
        else
            old_love_draw(image, x, y, ...)
        end
    else
        old_love_draw(image, x, y, ...)
    end
end

-- Hook drawGame para dibujar curación
local old_drawGame_heal = drawGame
drawGame = function()
    old_drawGame_heal()
    drawHeal()
end

-- Reiniciar curación y parpadeos al iniciar juego
local old_startGame_heal = startGame
startGame = function()
    old_startGame_heal()
    heal.active = false
    heal.timer = 0
    healthBlink.active = false
    healthBlink.timer = 0
    healthBlink.blinkTimer = 0
    healthBlink.visible = true
    powerupBlink.active = false
    powerupBlink.timer = 0
    powerupBlink.blinkTimer = 0
    powerupBlink.visible = true
end

-- =========================
-- MUERTE DEL JUGADOR Y GAME OVER
-- =========================

-- Sprites y sonidos de game over
local gameOverSprite = love.graphics.newImage("Game Over/Game over 1.png")
local gameOverButtonSprite = love.graphics.newImage("Game Over/Game over 2.png")
local playerDeathSound = love.audio.newSource("Sonidos/Sonido muerte jugador.wav", "static")
local gameOverMusic = love.audio.newSource("Sonidos/Game over sonido.wav", "stream")

-- Estados de muerte y game over
local playerDead = false
local playerDeathAnim = nil
local playerDeathAnimTimer = 0
local playerDeathAnimFrame = 1
local playerDeathAnimDelay = 0.2
local playerDeathWaitTimer = 0
local gameOverState = nil -- nil, "show", "wait_button"
local gameOverTimer = 0

-- Hook en updateGame para controlar muerte y game over
local old_updateGame_death = updateGame
updateGame = function(dt)
    -- Si el jugador está muerto, solo animar muerte y/o game over
    if playerDead then
        -- Animación de muerte
        if playerDeathAnim then
            playerDeathAnimTimer = playerDeathAnimTimer + dt
            if playerDeathAnimTimer >= playerDeathAnimDelay then
                playerDeathAnimTimer = playerDeathAnimTimer - playerDeathAnimDelay
                playerDeathAnimFrame = playerDeathAnimFrame + 1
                if playerDeathAnimFrame > #deathSprites then
                    playerDeathAnim = false
                    playerDeathWaitTimer = 0
                end
            end
        elseif playerDeathWaitTimer < 2 then
            playerDeathWaitTimer = playerDeathWaitTimer + dt
            if playerDeathWaitTimer >= 2 then
                -- Mostrar pantalla de game over y reproducir música
                gameOverState = "show"
                gameOverTimer = 0
                love.audio.play(gameOverMusic)
            end
        elseif gameOverState == "show" then
            gameOverTimer = gameOverTimer + dt
            if gameOverTimer >= 3 then
                gameOverState = "wait_button"
            end
        end
        return
    end

    -- Si no está muerto, lógica normal
    old_updateGame_death(dt)

    -- Detectar muerte del jugador
    if playerHealth >= maxHealth and not playerDead then
        playerDead = true
        playerDeathAnim = true
        playerDeathAnimFrame = 1
        playerDeathAnimTimer = 0
        playerDeathWaitTimer = 0
        gameOverState = nil
        -- Detener música de juego
        if gameMusic then gameMusic:stop() end
        -- Sonido de muerte
        playerDeathSound:stop()
        playerDeathSound:play()
        -- Limpiar enemigos y balas
        enemies = {}
        enemyBullets = {}
        bullets = {}
        -- Parar powerups y curaciones
        powerup.active = false
        heal.active = false
    end
end

-- Hook en drawGame para dibujar animación de muerte y game over
local old_drawGame_death = drawGame
drawGame = function()
    -- Si el jugador está muerto, dibujar animación y game over
    if playerDead then
        -- Dibujar mapa estático
        love.graphics.draw(gameMap, 0, mapY)
        love.graphics.draw(gameMap, 0, mapY - gameMap:getHeight())
        -- Animación de muerte
        if playerDeathAnim and playerDeathAnimFrame <= #deathSprites then
            local px = player.x
            local py = player.y
            love.graphics.draw(deathSprites[playerDeathAnimFrame], px, py)
        end
        -- Pantalla de game over
        if playerDeathAnim == false and playerDeathWaitTimer >= 2 then
            if gameOverState == "show" then
                love.graphics.draw(gameOverSprite, 0, 0)
            elseif gameOverState == "wait_button" then
                love.graphics.draw(gameOverButtonSprite, 0, 0)
            end
        end
        return
    end

    -- Si no está muerto, lógica normal
    old_drawGame_death()
end

-- Hook en drawHealthBar para ocultar barra de salud si está muerto
local old_drawHealthBar_death = drawHealthBar
drawHealthBar = function()
    if not playerDead then
        old_drawHealthBar_death()
    end
end

-- Hook en love.keypressed para reiniciar juego desde game over
local old_love_keypressed_death = love.keypressed
function love.keypressed(key)
    if gameState == "game" and playerDead and gameOverState == "wait_button" then
        if key == "space" then
            -- Reiniciar todo el juego
            -- Detener música de game over
            if gameOverMusic then gameOverMusic:stop() end
            -- Resetear variables de muerte y game over
            playerDead = false
            playerDeathAnim = nil
            playerDeathAnimTimer = 0
            playerDeathAnimFrame = 1
            playerDeathWaitTimer = 0
            gameOverState = nil
            gameOverTimer = 0
            -- Volver al menú principal
            gameState = "menu"
            menuState = "main"
            selectedOption = 1
            -- Reiniciar recursos del menú
            love.load()
        end
        return
    end
    old_love_keypressed_death(key)
end

-- =========================
-- SCORE IMAGE
-- =========================

-- Cargar sprite de "Score"
local scoreImage = love.graphics.newImage("Numeros/Score.png")
local scoreImageY = 2 -- Margen superior

-- Hook en drawGame para dibujar la imagen de Score arriba centrado
local old_drawGame_score = drawGame
drawGame = function()
    old_drawGame_score()
    if gameState == "game" then
        local screenWidth = 230
        local imgWidth = scoreImage:getWidth()
        local x = (screenWidth - imgWidth) / 2
        love.graphics.draw(scoreImage, x, scoreImageY)
    end
end

-- =========================
-- SISTEMA DE PUNTOS
-- =========================

-- Cargar sprites de números y signos
local numberSprites = {
    [0] = love.graphics.newImage("Numeros/Numero 0.png"),
    [1] = love.graphics.newImage("Numeros/Numero 1.png"),
    [2] = love.graphics.newImage("Numeros/Numero 2.png"),
    [3] = love.graphics.newImage("Numeros/Numero 3.png"),
    [4] = love.graphics.newImage("Numeros/Numero 4.png"),
    [5] = love.graphics.newImage("Numeros/Numero 5.png"),
    [6] = love.graphics.newImage("Numeros/Numero 6.png"),
    [7] = love.graphics.newImage("Numeros/Numero 7.png"),
    [8] = love.graphics.newImage("Numeros/Numero 8.png"),
    [9] = love.graphics.newImage("Numeros/Numero 9.png"),
    dot = love.graphics.newImage("Numeros/Signo de punto.png"),
    x = love.graphics.newImage("Numeros/Signo de multiplicacion.png"),
    div = love.graphics.newImage("Numeros/Signo de division.png"),
}

-- Puntuación máxima
local maxScore = 1000
local score = 0

-- Lugar donde estará el sistema de puntos (ajusta estas variables para moverlo)
local scoreX = 0 -- X en pantalla (por defecto esquina superior derecha)
local scoreY = 38   -- Y en pantalla

-- Función para dibujar la puntuación usando sprites
local function drawScore()
    -- Formatear score a "0.000" hasta "1.000"
    local displayScore = math.min(score, maxScore)
    local intPart = math.floor(displayScore / 1000)
    local fracPart = displayScore % 1000
    -- Asegura 3 dígitos en la parte decimal
    local fracStr = string.format("%03d", fracPart)
    -- Construir dígitos
    local digits = {
        intPart,
        ".",
        tonumber(fracStr:sub(1,1)),
        tonumber(fracStr:sub(2,2)),
        tonumber(fracStr:sub(3,3))
    }
    -- Dibujar los sprites
    local x = scoreX
    local y = scoreY
    local spacing = 40 -- Espacio entre dígitos (ajusta según tamaño de tus sprites)
    for i, d in ipairs(digits) do
        if d == "." then
            love.graphics.draw(numberSprites.dot, x, y)
            x = x + spacing
        else
            love.graphics.draw(numberSprites[d], x, y)
            x = x + spacing
        end
    end
end

-- Hook en drawGame para dibujar la puntuación
local old_drawGame_score_system = drawGame
drawGame = function()
    old_drawGame_score_system()
    if gameState == "game" then
        drawScore()
    end
end

-- Función para sumar puntos (y no pasar de 1000)
local function addScore(amount)
    score = math.min(score + amount, maxScore)
end

-- Hook en checkBulletEnemyCollision para sumar puntos al matar enemigos
local old_checkBulletEnemyCollision = checkBulletEnemyCollision
checkBulletEnemyCollision = function()
    for bi=#bullets,1,-1 do
        local b = bullets[bi]
        for ei=#enemies,1,-1 do
            local e = enemies[ei]
            if e.alive and
                b.x < e.x + e.w and
                b.x + b.w > e.x and
                b.y < e.y + e.h and
                b.y + b.h > e.y then
                -- Daño según nivel
                e.health = e.health - 1
                table.remove(bullets, bi)
                if e.health <= 0 then
                    e.alive = false
                    e.deathAnim = {frame=1, timer=0}
                    enemyDeathSound:stop()
                    enemyDeathSound:play()
                    -- Sumar puntos según tipo de enemigo
                    if e.type == 1 then addScore(10)
                    elseif e.type == 2 then addScore(15)
                    elseif e.type == 3 then addScore(20)
                    elseif e.type == 4 then addScore(30)
                    end
                end
                break
            end
        end
    end
end

-- Hook en updatePowerup para sumar puntos al recoger power up
local old_updatePowerup_score = updatePowerup
updatePowerup = function(dt)
    local prevLevel = playerLevel
    local prevActive = powerup.active
    old_updatePowerup_score(dt)
    -- Si recogió powerup (de activo a inactivo y subió de nivel)
    if prevActive and not powerup.active and playerLevel > prevLevel then
        addScore(30)
        healSound:stop()
        healSound:play()
        powerupBlink.active = true
        powerupBlink.timer = 0
        powerupBlink.blinkTimer = 0
        powerupBlink.visible = false
    end
end

-- Hook en updateHeal para sumar puntos al recoger curación
local old_updateHeal_score = updateHeal
updateHeal = function(dt)
    local prevActive = heal.active
    local prevHealth = playerHealth
    old_updateHeal_score(dt)
    -- Si recogió curación (de activo a inactivo y vida bajó)
    if prevActive and not heal.active and playerHealth < prevHealth then
        addScore(10)
    end
end

-- Reiniciar score al iniciar juego
local old_startGame_score = startGame
startGame = function()
    old_startGame_score()
    score = 0
end

-- =========================
-- OCULTAR NÚMEROS AL MORIR
-- =========================

-- Hook en love.graphics.draw para ocultar sprites de "Numeros" si el jugador está muerto
local old_love_graphics_draw_numeros = love.graphics.draw
love.graphics.draw = function(image, x, y, ...)
    -- Si el jugador está muerto y la imagen es de la carpeta "Numeros", no dibujar
    if playerDead and type(image) == "userdata" then
        -- Comprobar si la imagen es uno de los sprites de números o signos
        for _, numImg in pairs(numberSprites) do
            if image == numImg then
                return
            end
        end
        if image == scoreImage then
            return
        end
    end
    old_love_graphics_draw_numeros(image, x, y, ...)
end

-- =========================
-- FINAL DEL JUEGO (GANAR)
-- =========================

-- Cargar sprites y sonidos de créditos finales
local finalCreditsSprite = love.graphics.newImage("Creditos finales/Final.png")
local restartButtonSprite = love.graphics.newImage("Creditos finales/Reiniciar.png")
local winSound = love.audio.newSource("Sonidos/Gracias por jugar.wav", "stream")

-- Estados del final
local winState = nil -- nil, "player_exit", "credits", "fadeout", "restart"
local winTimer = 0
local playerExitY = nil
local playerExitSpeed = 300 -- VELOCIDAD DE SUBIDA DE LA NAVE (ajusta aquí)
local creditsY = nil
local creditsSpeed = 130 -- VELOCIDAD DE SUBIDA DE LOS CRÉDITOS (ajusta aquí)
local fadeAlpha = 0
local fadeDuration = 3 -- SEGUNDOS PARA FONDO NEGRO (ajusta aquí)
local fadeTimer = 0

-- Hook en addScore para detectar victoria
local old_addScore = addScore
addScore = function(amount)
    if score < maxScore then
        old_addScore(amount)
        if score >= maxScore and not winState then
            -- Ganó el juego
            winState = "player_exit"
            winTimer = 0
            -- Detener música de juego
            if gameMusic then gameMusic:stop() end
            -- Reproducir sonido de victoria
            winSound:setLooping(false)
            love.audio.play(winSound)
            -- Eliminar enemigos y balas
            enemies = {}
            enemyBullets = {}
            bullets = {}
            -- Preparar animación de nave
            playerExitY = player.y
            -- Desactivar powerups y curaciones
            powerup.active = false
            heal.active = false
        end
    end
end

-- Hook en updateGame para animación de victoria
local old_updateGame_win = updateGame
updateGame = function(dt)
    -- Si está en animación de victoria
    if winState then
        if winState == "player_exit" then
            -- Mover nave hacia arriba
            playerExitY = playerExitY - playerExitSpeed * dt
            winTimer = winTimer + dt
            -- Cuando la nave sale de la pantalla, pasar a créditos
            -- AJUSTA AQUÍ CUÁNTO SUBE LA NAVE: (playerExitY + player.h < -60) para más/menos alto
            if playerExitY + player.h < -60 then
                winState = "credits"
                winTimer = 0
                -- Iniciar créditos desde abajo
                creditsY = 640
            end
        elseif winState == "credits" then
            creditsY = creditsY - creditsSpeed * dt
            winTimer = winTimer + dt
            -- AJUSTA AQUÍ CUÁNTO SUBEN LOS CRÉDITOS Y HASTA DÓNDE: (winTimer >= 10) para más/menos tiempo
            if winTimer >= 10 then
                winState = "fadeout"
                fadeAlpha = 0
                fadeTimer = 0
            end
        elseif winState == "fadeout" then
            fadeTimer = fadeTimer + dt
            fadeAlpha = math.min(fadeTimer / fadeDuration, 1)
            if fadeTimer >= fadeDuration then
                winState = "restart"
                winTimer = 0
            end
        elseif winState == "restart" then
            winTimer = winTimer + dt
            -- Espera 1 segundo antes de mostrar el botón de reinicio
            -- El botón se muestra en drawGame
        end
        return
    end
    -- Si no está en victoria, lógica normal
    old_updateGame_win(dt)
end

-- Hook en drawGame para animación de victoria
local old_drawGame_win = drawGame
drawGame = function()
    if winState then
        -- Fondo y mapa
        if winState == "fadeout" or winState == "restart" then
            -- Fondo negro con fade
            love.graphics.setColor(1,1,1,1)
            love.graphics.draw(gameMap, 0, mapY)
            love.graphics.draw(gameMap, 0, mapY - gameMap:getHeight())
            -- Créditos encima
            love.graphics.draw(finalCreditsSprite, 0, creditsY)
            -- Fade negro
            love.graphics.setColor(0,0,0,fadeAlpha)
            love.graphics.rectangle("fill", 0, 0, 480, 640)
            love.graphics.setColor(1,1,1,1)
            if winState == "restart" and winTimer >= 1 then
                -- Mostrar botón de reinicio
                love.graphics.draw(restartButtonSprite, 0, 0)
            end
        elseif winState == "credits" then
            love.graphics.setColor(1,1,1,1)
            love.graphics.draw(gameMap, 0, mapY)
            love.graphics.draw(gameMap, 0, mapY - gameMap:getHeight())
            -- Créditos subiendo
            love.graphics.draw(finalCreditsSprite, 0, creditsY)
        elseif winState == "player_exit" then
            love.graphics.setColor(1,1,1,1)
            love.graphics.draw(gameMap, 0, mapY)
            love.graphics.draw(gameMap, 0, mapY - gameMap:getHeight())
            -- Dibujar nave subiendo
            love.graphics.draw(playerSprite, player.x, playerExitY)
        end
        return
    end
    -- Si no está en victoria, lógica normal
    old_drawGame_win()
end

-- Hook en love.keypressed para reiniciar desde el final
local old_love_keypressed_win = love.keypressed
function love.keypressed(key)
    if winState == "restart" and winTimer >= 1 then
        if key == "space" then
            -- Detener sonido de victoria
            if winSound then winSound:stop() end
            -- Reiniciar todo el juego
            winState = nil
            winTimer = 0
            playerExitY = nil
            creditsY = nil
            fadeAlpha = 0
            fadeTimer = 0
            -- Volver al menú principal
            gameState = "menu"
            menuState = "main"
            selectedOption = 1
            love.load()
            return
        end
    end
    -- Si está en animación de victoria, ignorar controles de juego
    if winState then return end
    old_love_keypressed_win(key)
end

-- Hook en love.keyboard.isDown para bloquear movimiento/disparo durante victoria
local old_love_keyboard_isDown = love.keyboard.isDown
love.keyboard.isDown = function(key, ...)
    if winState then
        return false
    end
    return old_love_keyboard_isDown(key, ...)
end