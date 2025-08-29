-- Sa.i-5 Sci-Fi Rifle Mod for Teardown
-- Two modes: Evaporate (instant removal) and Liquify (voxelize into particles)

local tool = {}
tool.id = "sai5"
tool.name = "Sa.i-5 Rifle"
tool.model = "MOD/vox/rifle.vox" -- Uses default rifle model

-- Configuration
local config = {
    evaporateRadius = GetFloat("savegame.mod.evaporateRadius", 0.5),
    liquifyRadius = GetFloat("savegame.mod.liquifyRadius", 1.0),
    liquifyForce = GetFloat("savegame.mod.liquifyForce", 10),
    liquifyParticles = GetInt("savegame.mod.liquifyParticles", 50),
    modeKey = GetString("savegame.mod.modeKey", "x")
}

-- State
local currentMode = "evaporate" -- "evaporate" or "liquify"
local modeChangeTime = 0
local lastShot = 0

function tool:init()
    self.ammo = 9999
    RegisterTool(self.id, self.name, self.model)
    SetBool("game.tool." .. self.id .. ".enabled", true)
end

function tool:draw()
    -- UI feedback for current mode
    UiPush()
    UiTranslate(UiCenter(), UiHeight() - 150)
    UiAlign("center middle")
    
    -- Mode indicator
    if currentMode == "evaporate" then
        UiColor(1, 0.2, 0.2, 1)
        UiFont("bold.ttf", 28)
        UiText("EVAPORATE MODE")
    else
        UiColor(0.2, 0.6, 1, 1)
        UiFont("bold.ttf", 28)
        UiText("LIQUIFY MODE")
    end
    
    -- Mode change feedback
    if modeChangeTime > 0 then
        local alpha = math.min(1, modeChangeTime * 2)
        UiColor(1, 1, 1, alpha)
        UiTranslate(0, 30)
        UiFont("regular.ttf", 20)
        UiText("Press [" .. string.upper(config.modeKey) .. "] to switch modes")
    end
    
    UiPop()
end

function tool:tick(dt)
    -- Handle mode switching
    if InputPressed(config.modeKey) then
        if currentMode == "evaporate" then
            currentMode = "liquify"
            PlaySound(LoadSound("beep.ogg"), GetPlayerTransform().pos, 0.5)
        else
            currentMode = "evaporate"
            PlaySound(LoadSound("beep.ogg"), GetPlayerTransform().pos, 0.3)
        end
        modeChangeTime = 1.0
    end
    
    if modeChangeTime > 0 then
        modeChangeTime = modeChangeTime - dt
    end
    
    -- Handle shooting
    if InputDown("lmb") and GetTime() - lastShot > 0.1 then
        lastShot = GetTime()
        self:shoot()
    end
end

function tool:shoot()
    local camera = GetPlayerCameraTransform()
    local dir = TransformToParentVec(camera, Vec(0, 0, -1))
    
    -- Raycast from camera
    local hit, dist, normal, shape = QueryRaycast(camera.pos, dir, 50)
    
    if hit then
        local hitPos = VecAdd(camera.pos, VecScale(dir, dist))
        
        if currentMode == "evaporate" then
            self:evaporate(hitPos, shape)
        else
            self:liquify(hitPos, normal)
        end
    end
end

function tool:evaporate(pos, shape)
    -- Visual effect
    PointLight(pos, 1, 0.2, 0.2, 5)
    
    -- Particle effect
    ParticleReset()
    ParticleType("smoke")
    ParticleColor(1, 0.2, 0.2)
    ParticleRadius(0.2, 0.8)
    ParticleAlpha(1, 0)
    ParticleGravity(-5)
    ParticleStretch(5)
    ParticleEmissive(5, 0)
    
    for i = 1, 20 do
        local vel = VecAdd(Vec(0, 5, 0), VecScale(Vec(math.random()-0.5, math.random()-0.5, math.random()-0.5), 5))
        SpawnParticle(pos, vel, 0.5 + math.random() * 0.5)
    end
    
    -- Sound effect
    PlaySound(LoadSound("tools/blowtorch-loop.ogg"), pos, 1)
    
    -- Remove voxels in radius
    MakeHole(pos, config.evaporateRadius, config.evaporateRadius, config.evaporateRadius)
    
    -- If shape still exists and is small enough, destroy it
    if shape and IsShapeValid(shape) then
        local shapeBody = GetShapeBody(shape)
        if IsBodyValid(shapeBody) then
            local mass = GetBodyMass(shapeBody)
            if mass < 100 then
                Delete(shapeBody)
            end
        end
    end
end

function tool:liquify(pos, normal)
    -- Visual effect
    PointLight(pos, 0.2, 0.6, 1, 5)
    
    -- Create voxel particles
    local bodies = QueryAabbBodies(VecSub(pos, Vec(config.liquifyRadius, config.liquifyRadius, config.liquifyRadius)), 
                                  VecAdd(pos, Vec(config.liquifyRadius, config.liquifyRadius, config.liquifyRadius)))
    
    -- Particle effect for liquification
    ParticleReset()
    ParticleType("plain")
    ParticleRadius(0.1, 0.2)
    ParticleAlpha(1, 0.3)
    ParticleGravity(-10)
    ParticleStretch(5)
    ParticleTile(5)
    
    -- Spawn liquid-like particles
    for i = 1, config.liquifyParticles do
        local offset = VecScale(Vec(math.random()-0.5, math.random()-0.5, math.random()-0.5), config.liquifyRadius * 2)
        local particlePos = VecAdd(pos, offset)
        local vel = VecAdd(VecScale(normal, config.liquifyForce), VecScale(Vec(math.random()-0.5, math.random(), math.random()-0.5), 5))
        
        -- Random colors for voxel effect
        local r = 0.2 + math.random() * 0.8
        local g = 0.2 + math.random() * 0.8
        local b = 0.2 + math.random() * 0.8
        ParticleColor(r, g, b)
        
        SpawnParticle(particlePos, vel, 2 + math.random())
    end
    
    -- Sound effect
    PlaySound(LoadSound("impact/masonry-medium.ogg"), pos, 1)
    
    -- Create hole and spawn debris
    MakeHole(pos, config.liquifyRadius * 0.8, config.liquifyRadius * 0.8, config.liquifyRadius * 0.8)
    
    -- Apply force to nearby bodies
    for i, body in ipairs(bodies) do
        if IsBodyValid(body) then
            local bodyPos = GetBodyTransform(body).pos
            local dir = VecNormalize(VecSub(bodyPos, pos))
            local dist = VecLength(VecSub(bodyPos, pos))
            local force = math.max(0, (config.liquifyRadius - dist) / config.liquifyRadius) * config.liquifyForce
            ApplyBodyImpulse(body, bodyPos, VecScale(dir, force))
        end
    end
end

-- Register the tool
function init()
    tool:init()
end

function tick(dt)
    if GetString("game.player.tool") == tool.id then
        tool:tick(dt)
    end
end

function draw()
    if GetString("game.player.tool") == tool.id then
        tool:draw()
    end
end