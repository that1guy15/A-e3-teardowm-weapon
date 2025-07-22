-- Sa.i-5 Rifle Configuration Options

function init()
    SetBool("savegame.mod.uiOpen", false)
end

function draw()
    if GetBool("savegame.mod.uiOpen") then
        UiMakeInteractive()
        UiPush()
            UiBlur(0.5)
            UiColor(0, 0, 0, 0.5)
            UiRect(UiWidth(), UiHeight())
            UiColor(1, 1, 1, 1)
            UiTranslate(UiCenter(), 200)
            UiAlign("center middle")
            
            UiPush()
                UiFont("bold.ttf", 48)
                UiText("Sa.i-5 Rifle Settings")
            UiPop()
            
            UiTranslate(0, 100)
            UiFont("regular.ttf", 26)
            
            -- Mode Switch Key
            UiPush()
                UiTranslate(-200, 0)
                UiAlign("left middle")
                UiText("Mode Switch Key:")
                UiTranslate(300, 0)
                UiAlign("center middle")
                UiPush()
                    UiColor(0.2, 0.2, 0.2, 1)
                    UiRect(100, 40)
                    UiColor(1, 1, 1, 1)
                    local key = GetString("savegame.mod.modeKey", "x")
                    UiText(string.upper(key))
                UiPop()
                if UiTextButton("Change", 100, 40) then
                    SetString("savegame.mod.waitingForKey", "modeKey")
                end
            UiPop()
            
            UiTranslate(0, 60)
            
            -- Evaporate Radius
            UiPush()
                UiTranslate(-200, 0)
                UiAlign("left middle")
                UiText("Evaporate Radius:")
                UiTranslate(300, 0)
                UiAlign("center middle")
                local evapRadius = GetFloat("savegame.mod.evaporateRadius", 0.5)
                evapRadius = UiSlider("slider", "x", evapRadius * 100, 10, 200) / 100
                SetFloat("savegame.mod.evaporateRadius", evapRadius)
                UiTranslate(150, 0)
                UiText(string.format("%.1f", evapRadius))
            UiPop()
            
            UiTranslate(0, 60)
            
            -- Liquify Radius
            UiPush()
                UiTranslate(-200, 0)
                UiAlign("left middle")
                UiText("Liquify Radius:")
                UiTranslate(300, 0)
                UiAlign("center middle")
                local liqRadius = GetFloat("savegame.mod.liquifyRadius", 1.0)
                liqRadius = UiSlider("slider", "x", liqRadius * 100, 10, 300) / 100
                SetFloat("savegame.mod.liquifyRadius", liqRadius)
                UiTranslate(150, 0)
                UiText(string.format("%.1f", liqRadius))
            UiPop()
            
            UiTranslate(0, 60)
            
            -- Liquify Force
            UiPush()
                UiTranslate(-200, 0)
                UiAlign("left middle")
                UiText("Liquify Force:")
                UiTranslate(300, 0)
                UiAlign("center middle")
                local liqForce = GetFloat("savegame.mod.liquifyForce", 10)
                liqForce = UiSlider("slider", "x", liqForce * 10, 10, 500) / 10
                SetFloat("savegame.mod.liquifyForce", liqForce)
                UiTranslate(150, 0)
                UiText(string.format("%.1f", liqForce))
            UiPop()
            
            UiTranslate(0, 60)
            
            -- Liquify Particles
            UiPush()
                UiTranslate(-200, 0)
                UiAlign("left middle")
                UiText("Liquify Particles:")
                UiTranslate(300, 0)
                UiAlign("center middle")
                local liqParticles = GetInt("savegame.mod.liquifyParticles", 50)
                liqParticles = math.floor(UiSlider("slider", "x", liqParticles, 10, 200))
                SetInt("savegame.mod.liquifyParticles", liqParticles)
                UiTranslate(150, 0)
                UiText(tostring(liqParticles))
            UiPop()
            
            UiTranslate(0, 100)
            
            if UiTextButton("Close", 200, 50) then
                SetBool("savegame.mod.uiOpen", false)
            end
            
        UiPop()
        
        -- Handle key capture
        local waitingFor = GetString("savegame.mod.waitingForKey", "")
        if waitingFor ~= "" then
            local keys = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", 
                         "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
                         "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
                         "space", "tab", "return", "backspace", "delete",
                         "left", "right", "up", "down"}
            
            for _, key in ipairs(keys) do
                if InputPressed(key) then
                    SetString("savegame.mod." .. waitingFor, key)
                    SetString("savegame.mod.waitingForKey", "")
                    break
                end
            end
        end
    end
end

function tick()
    if InputPressed("esc") and GetBool("savegame.mod.uiOpen") then
        SetBool("savegame.mod.uiOpen", false)
    end
end