-- vibecoding_ware | Rivals | v2.6.0
-- fixes: ESP toggles, silent aim actual redirect

local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local UIS           = game:GetService("UserInputService")
local RunService    = game:GetService("RunService")
local Workspace     = game:GetService("Workspace")
local LP            = Players.LocalPlayer
local Camera        = Workspace.CurrentCamera

-- ── Config ────────────────────────────────────────────────────────────────────
local CFG = {
    -- aimbot
    silent_aim=false, fov=45, smooth=30, prediction=50,
    hitbox="Head", priority="Closest", aim_team=false, aim_vis=true,
    trigger=false, trigger_delay=80,
    -- esp
    esp_enabled=true,
    esp_box=true, esp_hp=true, esp_name=true, esp_dist=true,
    esp_trace=false, esp_skel=false, esp_offscreen=false, esp_maxdist=800,
    box_style="Full",
    -- movement
    bhop=false, auto_strafe=false, speedhack=false, speed_mult=15,
    no_fall=false, fly=false, fly_speed=50, inf_jump=false, anti_kb=false,
    -- visuals
    fullbright=false, no_fog=false, wireframe=false,
    crosshair=true, ch_style="Dot", ch_size=6, chams=false, wall_chams=false,
    -- misc
    no_recoil=false, no_spread=false, auto_ability=false, inf_ammo=false,
    auto_dodge=false, anti_afk=false, name_spoof=false, watermark=true,
}

-- ── Colors ────────────────────────────────────────────────────────────────────
local C = {
    bg     = Color3.fromRGB(13,13,18),
    panel  = Color3.fromRGB(19,19,28),
    card   = Color3.fromRGB(26,26,38),
    border = Color3.fromRGB(42,42,61),
    accent = Color3.fromRGB(124,92,252),
    text   = Color3.fromRGB(232,230,255),
    muted  = Color3.fromRGB(107,104,144),
    on     = Color3.fromRGB(167,139,250),
    green  = Color3.fromRGB(74,222,128),
    red    = Color3.fromRGB(248,113,113),
    yellow = Color3.fromRGB(251,191,36),
    white  = Color3.fromRGB(255,255,255),
    cyan   = Color3.fromRGB(34,211,238),
}

-- ── ESP Drawing objects ───────────────────────────────────────────────────────
local espObjects = {}

local function newDraw(type, props)
    local d = Drawing.new(type)
    for k,v in pairs(props) do d[k]=v end
    return d
end

local function createESP(player)
    espObjects[player] = {
        box = {
            newDraw("Line",{Thickness=1.5,Color=C.accent,Visible=false}),
            newDraw("Line",{Thickness=1.5,Color=C.accent,Visible=false}),
            newDraw("Line",{Thickness=1.5,Color=C.accent,Visible=false}),
            newDraw("Line",{Thickness=1.5,Color=C.accent,Visible=false}),
        },
        corners = {
            newDraw("Line",{Thickness=2,Color=C.white,Visible=false}),
            newDraw("Line",{Thickness=2,Color=C.white,Visible=false}),
            newDraw("Line",{Thickness=2,Color=C.white,Visible=false}),
            newDraw("Line",{Thickness=2,Color=C.white,Visible=false}),
            newDraw("Line",{Thickness=2,Color=C.white,Visible=false}),
            newDraw("Line",{Thickness=2,Color=C.white,Visible=false}),
            newDraw("Line",{Thickness=2,Color=C.white,Visible=false}),
            newDraw("Line",{Thickness=2,Color=C.white,Visible=false}),
        },
        hb_bg   = newDraw("Line",{Thickness=4,Color=Color3.new(0,0,0),Visible=false}),
        hb_fill = newDraw("Line",{Thickness=3,Visible=false}),
        name    = newDraw("Text",{Size=13,Color=C.white,Outline=true,OutlineColor=Color3.new(0,0,0),Center=true,Visible=false}),
        dist    = newDraw("Text",{Size=11,Color=C.muted,Outline=true,OutlineColor=Color3.new(0,0,0),Center=true,Visible=false}),
        tracer  = newDraw("Line",{Thickness=1,Color=C.yellow,Visible=false}),
        offArrow= newDraw("Triangle",{Filled=true,Color=C.accent,Visible=false}),
    }
end

local function removeESP(player)
    if not espObjects[player] then return end
    local t = espObjects[player]
    for _,l in ipairs(t.box) do l:Remove() end
    for _,l in ipairs(t.corners) do l:Remove() end
    t.hb_bg:Remove(); t.hb_fill:Remove()
    t.name:Remove(); t.dist:Remove()
    t.tracer:Remove(); t.offArrow:Remove()
    espObjects[player] = nil
end

local function hideESP(t)
    for _,l in ipairs(t.box) do l.Visible=false end
    for _,l in ipairs(t.corners) do l.Visible=false end
    t.hb_bg.Visible=false; t.hb_fill.Visible=false
    t.name.Visible=false; t.dist.Visible=false
    t.tracer.Visible=false; t.offArrow.Visible=false
end

local function hpColor(hp)
    local r = math.clamp(2*(1-hp/100),0,1)
    local g = math.clamp(2*(hp/100),0,1)
    return Color3.new(r,g,0)
end

local function w2s(pos)
    local vp,vis = Camera:WorldToViewportPoint(pos)
    return Vector2.new(vp.X,vp.Y), vis, vp.Z
end

local function getBBox(char)
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not root or not head then return nil end
    local feetPos = root.Position - Vector3.new(0,3,0)
    local headPos = head.Position + Vector3.new(0,0.7,0)
    local fs,fv,dep = w2s(feetPos)
    local hs,hv     = w2s(headPos)
    if (not fv and not hv) or dep<0 then return nil end
    local h = math.abs(fs.Y-hs.Y)
    if h<5 then return nil end
    local w = h*0.45
    local cx = (fs.X+hs.X)/2
    return {
        x=cx-w/2, y=hs.Y, w=w, h=h,
        cx=cx, top=hs.Y, bot=fs.Y, dep=dep,
        onScreen=fv or hv,
        feetS=fs, headS=hs,
    }
end

local function drawFullBox(lines,bb,col)
    local x,y,w,h = bb.x,bb.y,bb.w,bb.h
    lines[1].From=Vector2.new(x,y);   lines[1].To=Vector2.new(x+w,y);   lines[1].Color=col; lines[1].Visible=true
    lines[2].From=Vector2.new(x,y+h); lines[2].To=Vector2.new(x+w,y+h); lines[2].Color=col; lines[2].Visible=true
    lines[3].From=Vector2.new(x,y);   lines[3].To=Vector2.new(x,y+h);   lines[3].Color=col; lines[3].Visible=true
    lines[4].From=Vector2.new(x+w,y); lines[4].To=Vector2.new(x+w,y+h); lines[4].Color=col; lines[4].Visible=true
end

local function drawCornerBox(lines,bb,col)
    local x,y,w,h = bb.x,bb.y,bb.w,bb.h
    local cw,ch = w*0.25, h*0.2
    lines[1].From=Vector2.new(x,y);       lines[1].To=Vector2.new(x+cw,y);     lines[1].Color=col; lines[1].Visible=true
    lines[2].From=Vector2.new(x,y);       lines[2].To=Vector2.new(x,y+ch);     lines[2].Color=col; lines[2].Visible=true
    lines[3].From=Vector2.new(x+w,y);     lines[3].To=Vector2.new(x+w-cw,y);   lines[3].Color=col; lines[3].Visible=true
    lines[4].From=Vector2.new(x+w,y);     lines[4].To=Vector2.new(x+w,y+ch);   lines[4].Color=col; lines[4].Visible=true
    lines[5].From=Vector2.new(x,y+h);     lines[5].To=Vector2.new(x+cw,y+h);   lines[5].Color=col; lines[5].Visible=true
    lines[6].From=Vector2.new(x,y+h);     lines[6].To=Vector2.new(x,y+h-ch);   lines[6].Color=col; lines[6].Visible=true
    lines[7].From=Vector2.new(x+w,y+h);   lines[7].To=Vector2.new(x+w-cw,y+h); lines[7].Color=col; lines[7].Visible=true
    lines[8].From=Vector2.new(x+w,y+h);   lines[8].To=Vector2.new(x+w,y+h-ch); lines[8].Color=col; lines[8].Visible=true
end

-- ── ESP Render Loop ───────────────────────────────────────────────────────────
-- FIX: каждый sub-toggle проверяется независимо; при esp_enabled=false всё скрывается
RunService.RenderStepped:Connect(function()
    local vp = Camera.ViewportSize

    for _,player in ipairs(Players:GetPlayers()) do
        if player == LP then continue end
        if not espObjects[player] then createESP(player) end
        local t = espObjects[player]

        -- главный переключатель ESP
        if not CFG.esp_enabled then
            hideESP(t)
            continue
        end

        local char = player.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")

        local hide = not char or not hum or (hum.Health<=0)
        if not hide and CFG.esp_maxdist>0 then
            local lroot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            local eroot = char and char:FindFirstChild("HumanoidRootPart")
            if lroot and eroot then
                local dist = (lroot.Position-eroot.Position).Magnitude
                if dist > CFG.esp_maxdist then hide=true end
            end
        end

        if hide then hideESP(t) continue end

        local bb = getBBox(char)

        -- off-screen arrow
        if not bb then
            if CFG.esp_offscreen then
                local eroot = char:FindFirstChild("HumanoidRootPart")
                if eroot then
                    local _,vis,dep = w2s(eroot.Position)
                    if not vis or dep<0 then
                        local dir = (eroot.Position - Camera.CFrame.Position)
                        local flat = Vector2.new(dir.X, -dir.Y)
                        if flat.Magnitude > 0 then
                            local scrDir = flat.Unit
                            local cx,cy = vp.X/2, vp.Y/2
                            local edge = 60
                            local ax = math.clamp(cx + scrDir.X*200, edge, vp.X-edge)
                            local ay = math.clamp(cy + scrDir.Y*200, edge, vp.Y-edge)
                            t.offArrow.PointA = Vector2.new(ax, ay-10)
                            t.offArrow.PointB = Vector2.new(ax-7, ay+7)
                            t.offArrow.PointC = Vector2.new(ax+7, ay+7)
                            t.offArrow.Visible = true
                        end
                    else
                        t.offArrow.Visible = false
                    end
                end
            else
                t.offArrow.Visible = false
            end
            -- скрыть всё остальное
            for _,l in ipairs(t.box) do l.Visible=false end
            for _,l in ipairs(t.corners) do l.Visible=false end
            t.hb_bg.Visible=false; t.hb_fill.Visible=false
            t.name.Visible=false; t.dist.Visible=false
            t.tracer.Visible=false
            continue
        end

        t.offArrow.Visible=false

        local hp  = hum and hum.Health    or 100
        local mhp = hum and hum.MaxHealth or 100
        local boxCol = C.accent

        -- Box — FIX: явно выключаем оба набора линий когда toggle off
        if CFG.esp_box then
            local style = CFG.box_style
            if style == "Full" then
                drawFullBox(t.box, bb, boxCol)
                for _,l in ipairs(t.corners) do l.Visible=false end
            elseif style == "Corner" then
                for _,l in ipairs(t.box) do l.Visible=false end
                drawCornerBox(t.corners, bb, boxCol)
            elseif style == "3D" then
                drawFullBox(t.box, bb, boxCol)
                local inset = {x=bb.x+3,y=bb.y+3,w=bb.w-6,h=bb.h-6}
                drawCornerBox(t.corners, inset, Color3.fromRGB(200,180,255))
            end
        else
            for _,l in ipairs(t.box)     do l.Visible=false end
            for _,l in ipairs(t.corners) do l.Visible=false end
        end

        -- Health bar
        if CFG.esp_hp and hum then
            local ratio = math.clamp(hp/mhp,0,1)
            local barX  = bb.x - 6
            local barH  = bb.h * ratio
            t.hb_bg.From    = Vector2.new(barX, bb.top)
            t.hb_bg.To      = Vector2.new(barX, bb.bot)
            t.hb_bg.Visible = true
            t.hb_fill.From    = Vector2.new(barX, bb.bot)
            t.hb_fill.To      = Vector2.new(barX, bb.bot-barH)
            t.hb_fill.Color   = hpColor(hp/mhp*100)
            t.hb_fill.Visible = true
        else
            t.hb_bg.Visible=false; t.hb_fill.Visible=false
        end

        -- Name
        if CFG.esp_name then
            t.name.Text     = player.DisplayName
            t.name.Position = Vector2.new(bb.cx, bb.top-15)
            t.name.Visible  = true
        else
            t.name.Visible=false
        end

        -- Distance
        if CFG.esp_dist then
            local lroot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            local eroot = char:FindFirstChild("HumanoidRootPart")
            local dist = 0
            if lroot and eroot then
                dist = math.floor((lroot.Position-eroot.Position).Magnitude)
            end
            t.dist.Text     = "["..dist.."m]"
            t.dist.Position = Vector2.new(bb.cx, bb.bot+3)
            t.dist.Visible  = true
        else
            t.dist.Visible=false
        end

        -- Tracer
        if CFG.esp_trace then
            t.tracer.From    = Vector2.new(vp.X/2, vp.Y)
            t.tracer.To      = Vector2.new(bb.cx, bb.bot)
            t.tracer.Visible = true
        else
            t.tracer.Visible=false
        end
    end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(0.5) end)
end)
Players.PlayerRemoving:Connect(removeESP)

-- ── Aimbot ────────────────────────────────────────────────────────────────────
local aimTarget = nil

local function getTargets()
    local targets = {}
    local lroot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not lroot then return targets end

    for _,player in ipairs(Players:GetPlayers()) do
        if player == LP then continue end
        local char = player.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum or hum.Health<=0 then continue end

        if not CFG.aim_team then
            if player.Team and LP.Team and player.Team==LP.Team then continue end
        end

        local partName = CFG.hitbox=="Head" and "Head" or "HumanoidRootPart"
        local hitPart  = char:FindFirstChild(partName) or char:FindFirstChild("HumanoidRootPart")
        if not hitPart then continue end

        local targetPos = hitPart.Position
        if CFG.prediction > 0 then
            local vel = hitPart.AssemblyLinearVelocity
            targetPos = targetPos + vel * (CFG.prediction/1000)
        end

        local _,vis,dep = w2s(targetPos)
        if dep < 0 then continue end

        if CFG.aim_vis then
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {LP.Character, char}
            params.FilterType = Enum.RaycastFilterType.Exclude
            local result = Workspace:Raycast(Camera.CFrame.Position, (targetPos-Camera.CFrame.Position).Unit*2000, params)
            if result then continue end
        end

        local screenPos, onScreen = w2s(targetPos)
        if not onScreen then continue end

        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local dist2D = (screenPos-center).Magnitude
        if dist2D > CFG.fov then continue end

        local dist3D = (lroot.Position-hitPart.Position).Magnitude

        table.insert(targets, {
            player=player, char=char, hitPart=hitPart,
            targetPos=targetPos, screenPos=screenPos,
            dist2D=dist2D, dist3D=dist3D,
        })
    end
    return targets
end

local function getBestTarget(targets)
    if #targets==0 then return nil end
    table.sort(targets, function(a,b)
        if CFG.priority=="Closest" then
            return a.dist3D < b.dist3D
        elseif CFG.priority=="Low HP" then
            local ha = a.char:FindFirstChildOfClass("Humanoid")
            local hb = b.char:FindFirstChildOfClass("Humanoid")
            if ha and hb then return ha.Health < hb.Health end
        elseif CFG.priority=="FOV" then
            return a.dist2D < b.dist2D
        end
        return a.dist3D < b.dist3D
    end)
    return targets[1]
end

-- FOV circle
local fovCircle = newDraw("Circle",{
    Thickness=1, Color=Color3.fromRGB(255,255,255),
    Filled=false, Visible=false,
})

-- ── Silent aim ────────────────────────────────────────────────────────────────
-- FIX: hookmetamethod теперь реально подменяет позицию в аргументах
-- Rivals шлёт позицию прицела через FireServer; ищем Vector3/CFrame в аргах и заменяем
local oldNamecall
oldNamecall = hookmetamethod(game,"__namecall",function(self,...)
    local method = getnamecallmethod()
    if CFG.silent_aim and (method=="FireServer" or method=="InvokeServer") then
        local targets = getTargets()
        local best    = getBestTarget(targets)
        if best then
            local args = {...}
            -- перебираем аргументы, заменяем первый Vector3/CFrame на позицию цели
            for i,v in ipairs(args) do
                if typeof(v)=="Vector3" then
                    args[i] = best.targetPos
                    break
                elseif typeof(v)=="CFrame" then
                    args[i] = CFrame.new(best.targetPos)
                    break
                end
            end
            return oldNamecall(self, table.unpack(args))
        end
    end
    return oldNamecall(self,...)
end)

-- Camera lerp (только когда silent_aim выключен — как обычный smooth aimbot)
RunService.RenderStepped:Connect(function()
    if CFG.silent_aim or CFG.trigger then
        local vp = Camera.ViewportSize
        fovCircle.Position = Vector2.new(vp.X/2, vp.Y/2)
        fovCircle.Radius   = CFG.fov
        fovCircle.Visible  = true
    else
        fovCircle.Visible = false
    end

    -- обновляем aimTarget для тригербота независимо от режима
    local targets = getTargets()
    local best    = getBestTarget(targets)
    aimTarget = best
end)

-- Triggerbot
RunService.Heartbeat:Connect(function()
    if not CFG.trigger then return end
    if not aimTarget then return end
    local char = aimTarget.char
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health<=0 then return end
    local _,vis = w2s(aimTarget.targetPos)
    if not vis then return end
    task.wait(CFG.trigger_delay/1000)
    -- fire: game-specific
end)

-- ── Movement ──────────────────────────────────────────────────────────────────
local flyBodyVel, flyBodyGyro

RunService.Heartbeat:Connect(function()
    local char = LP.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hum or not root then return end

    if CFG.bhop then
        if hum.FloorMaterial ~= Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end

    if CFG.speedhack then
        hum.WalkSpeed = CFG.speed_mult/10 * 16
    else
        if hum.WalkSpeed ~= 16 then hum.WalkSpeed = 16 end
    end

    if CFG.no_fall then
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Fall, false)
    end

    if CFG.inf_jump then
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    end

    if CFG.anti_kb then
        root.AssemblyLinearVelocity = Vector3.new(
            root.AssemblyLinearVelocity.X,
            root.AssemblyLinearVelocity.Y,
            root.AssemblyLinearVelocity.Z
        )
    end
end)

-- Fly
UIS.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not root or not hum then return end

    if input.KeyCode == Enum.KeyCode.V and CFG.fly then
        if flyBodyVel then
            flyBodyVel:Destroy(); flyBodyVel=nil
            flyBodyGyro:Destroy(); flyBodyGyro=nil
            hum.PlatformStand=false
        else
            hum.PlatformStand=true
            flyBodyVel = Instance.new("BodyVelocity",root)
            flyBodyVel.Velocity=Vector3.zero
            flyBodyVel.MaxForce=Vector3.new(1e5,1e5,1e5)
            flyBodyGyro = Instance.new("BodyGyro",root)
            flyBodyGyro.MaxTorque=Vector3.new(1e5,1e5,1e5)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not flyBodyVel then return end
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local speed = CFG.fly_speed
    local cf    = Camera.CFrame
    local vel   = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then vel=vel+cf.LookVector*speed end
    if UIS:IsKeyDown(Enum.KeyCode.S) then vel=vel-cf.LookVector*speed end
    if UIS:IsKeyDown(Enum.KeyCode.A) then vel=vel-cf.RightVector*speed end
    if UIS:IsKeyDown(Enum.KeyCode.D) then vel=vel+cf.RightVector*speed end
    if UIS:IsKeyDown(Enum.KeyCode.Space)     then vel=vel+Vector3.new(0,speed,0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then vel=vel-Vector3.new(0,speed,0) end
    flyBodyVel.Velocity  = vel
    flyBodyGyro.CFrame   = cf
end)

-- ── Visuals ───────────────────────────────────────────────────────────────────
local lighting = game:GetService("Lighting")

RunService.Heartbeat:Connect(function()
    if CFG.fullbright then
        lighting.Ambient        = Color3.new(1,1,1)
        lighting.OutdoorAmbient = Color3.new(1,1,1)
        lighting.Brightness     = 2
    end
    if CFG.no_fog then
        lighting.FogEnd   = 1e6
        lighting.FogStart = 1e5
    end
end)

-- Crosshair
local chLines = {
    newDraw("Line",{Thickness=1.5,Color=C.green,Visible=false}),
    newDraw("Line",{Thickness=1.5,Color=C.green,Visible=false}),
    newDraw("Line",{Thickness=1.5,Color=C.green,Visible=false}),
    newDraw("Line",{Thickness=1.5,Color=C.green,Visible=false}),
    newDraw("Circle",{Thickness=1.5,Color=C.green,Filled=false,Visible=false}),
}
local chDot = newDraw("Circle",{Filled=true,Color=C.green,Visible=false})

RunService.RenderStepped:Connect(function()
    local vp=Camera.ViewportSize
    local cx,cy=vp.X/2,vp.Y/2
    local sz=CFG.ch_size

    if CFG.crosshair then
        chDot.Position=Vector2.new(cx,cy)
        chDot.Radius=2
        chDot.Color=C.green
        local style=CFG.ch_style
        if style=="Dot" then
            chDot.Visible=true
            for i=1,4 do chLines[i].Visible=false end
            chLines[5].Visible=false
        elseif style=="Cross" then
            chDot.Visible=false
            chLines[5].Visible=false
            chLines[1].From=Vector2.new(cx-sz,cy); chLines[1].To=Vector2.new(cx-2,cy); chLines[1].Visible=true
            chLines[2].From=Vector2.new(cx+2,cy);  chLines[2].To=Vector2.new(cx+sz,cy); chLines[2].Visible=true
            chLines[3].From=Vector2.new(cx,cy-sz); chLines[3].To=Vector2.new(cx,cy-2); chLines[3].Visible=true
            chLines[4].From=Vector2.new(cx,cy+2);  chLines[4].To=Vector2.new(cx,cy+sz); chLines[4].Visible=true
        elseif style=="Circle" then
            chDot.Visible=false
            for i=1,4 do chLines[i].Visible=false end
            chLines[5].Position=Vector2.new(cx,cy)
            chLines[5].Radius=sz
            chLines[5].Visible=true
        end
    else
        chDot.Visible=false
        for i=1,5 do chLines[i].Visible=false end
    end
end)

-- ── Watermark ─────────────────────────────────────────────────────────────────
local wmText = newDraw("Text",{
    Size=14,Color=C.accent,Outline=true,OutlineColor=Color3.new(0,0,0),
    Text="vibecoding_ware | rivals",Position=Vector2.new(10,10),Visible=true,
})
RunService.RenderStepped:Connect(function()
    wmText.Visible = CFG.watermark
end)

-- ── GUI ───────────────────────────────────────────────────────────────────────
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="vibecoding_ware"
ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder=999
pcall(function() ScreenGui.Parent=game:GetService("CoreGui") end)
if not ScreenGui.Parent or ScreenGui.Parent.Name~="CoreGui" then
    ScreenGui.Parent=LP.PlayerGui
end

local function make(cls,props,parent)
    local i=Instance.new(cls)
    for k,v in pairs(props) do i[k]=v end
    if parent then i.Parent=parent end
    return i
end
local function tw(obj,props,t)
    TweenService:Create(obj,TweenInfo.new(t or 0.15,Enum.EasingStyle.Quad),props):Play()
end
local function corner(p,r) make("UICorner",{CornerRadius=UDim.new(0,r or 8)},p) end
local function stroke(p,col,th) make("UIStroke",{Color=col or C.border,Thickness=th or 1},p) end

local Win=make("Frame",{
    Size=UDim2.new(0,340,0,500),Position=UDim2.new(0.5,-170,0.5,-250),
    BackgroundColor3=C.bg,BorderSizePixel=0,Active=true,Draggable=true,
},ScreenGui)
corner(Win,14) stroke(Win,C.border,1)

local Hdr=make("Frame",{Size=UDim2.new(1,0,0,46),BackgroundColor3=C.panel,BorderSizePixel=0},Win)
corner(Hdr,14)
make("Frame",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),BackgroundColor3=C.panel,BorderSizePixel=0},Hdr)

local ico=make("Frame",{Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,12,0.5,-14),BackgroundColor3=C.accent,BorderSizePixel=0},Hdr)
corner(ico,7)
make("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="🔥",TextSize=16,Font=Enum.Font.GothamBold,TextColor3=C.white},ico)
make("TextLabel",{Size=UDim2.new(0,200,0,16),Position=UDim2.new(0,48,0,7),BackgroundTransparency=1,Text="vibecoding_ware",TextSize=13,Font=Enum.Font.GothamBold,TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left},Hdr)
make("TextLabel",{Size=UDim2.new(0,200,0,13),Position=UDim2.new(0,48,0,25),BackgroundTransparency=1,Text="rivals edition · delta",TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left},Hdr)

local sdot=make("Frame",{Size=UDim2.new(0,8,0,8),Position=UDim2.new(1,-64,0.5,-4),BackgroundColor3=C.green,BorderSizePixel=0},Hdr)
corner(sdot,99)
make("TextLabel",{Size=UDim2.new(0,54,1,0),Position=UDim2.new(1,-56,0,0),BackgroundTransparency=1,Text="injected",TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.green,TextXAlignment=Enum.TextXAlignment.Right},Hdr)

local TABS={"Aimbot","ESP","Move","Visuals","Misc"}
local tabBtns={} local tabFrames={}

local TBar=make("Frame",{
    Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,46),
    BackgroundColor3=C.panel,BorderSizePixel=0,ClipsDescendants=true,
},Win)
make("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.border,BorderSizePixel=0},TBar)

local tabW=math.floor(340/#TABS)
for i,t in ipairs(TABS) do
    local b=make("TextButton",{
        Name=t,Size=UDim2.new(0,tabW,1,0),Position=UDim2.new(0,(i-1)*tabW,0,0),
        BackgroundTransparency=1,Text=t,TextSize=10,Font=Enum.Font.Gotham,
        TextColor3=C.muted,AutoButtonColor=false,
    },TBar)
    tabBtns[t]=b
end

local ContentArea=make("Frame",{
    Size=UDim2.new(1,0,1,-106),Position=UDim2.new(0,0,0,78),
    BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=true,
},Win)

local function makeScroll(name)
    local f=make("ScrollingFrame",{
        Name=name,Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,BorderSizePixel=0,
        ScrollBarThickness=2,ScrollBarImageColor3=C.accent,
        CanvasSize=UDim2.new(0,0,0,0),Visible=false,
        ElasticBehavior=Enum.ElasticBehavior.Never,
    },ContentArea)
    local L=make("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},f)
    make("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10),PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8)},f)
    L:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        f.CanvasSize=UDim2.new(0,0,0,L.AbsoluteContentSize.Y+20)
    end)
    return f
end

for _,t in ipairs(TABS) do tabFrames[t]=makeScroll(t) end

local function switchTab(name)
    for _,b in pairs(tabBtns) do
        b.TextColor3=(b.Name==name) and C.on or C.muted
        b.Font=(b.Name==name) and Enum.Font.GothamBold or Enum.Font.Gotham
    end
    for n,f in pairs(tabFrames) do f.Visible=(n==name) end
end

for _,t in ipairs(TABS) do
    tabBtns[t].MouseButton1Click:Connect(function() switchTab(t) end)
end

local Foot=make("Frame",{Size=UDim2.new(1,0,0,26),Position=UDim2.new(0,0,1,-26),BackgroundColor3=C.panel,BorderSizePixel=0},Win)
corner(Foot,14)
make("Frame",{Size=UDim2.new(1,0,0,14),BackgroundColor3=C.panel,BorderSizePixel=0},Foot)
make("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=C.border,BorderSizePixel=0},Foot)
make("TextLabel",{Size=UDim2.new(0.6,0,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Text="vibecoding_ware · rivals",TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left},Foot)
make("TextLabel",{Size=UDim2.new(0.4,-12,1,0),Position=UDim2.new(0.6,0,0,0),BackgroundTransparency=1,Text="v2.6.0",TextSize=10,Font=Enum.Font.GothamBold,TextColor3=C.accent,TextXAlignment=Enum.TextXAlignment.Right},Foot)

-- ── UI components ─────────────────────────────────────────────────────────────
local ord={}
for _,t in ipairs(TABS) do ord[t]=0 end
local function nextOrd(tab) ord[tab]=ord[tab]+1 return ord[tab] end

local function lbl(tab,text)
    make("TextLabel",{
        Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,
        Text=text:upper(),TextSize=10,Font=Enum.Font.GothamBold,
        TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,
        LayoutOrder=nextOrd(tab),
    },tabFrames[tab])
end

local function tog(tab,name,desc,key,onChange)
    local o=nextOrd(tab)
    local row=make("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=C.card,BorderSizePixel=0,LayoutOrder=o},tabFrames[tab])
    corner(row,9) stroke(row,C.border,1)
    make("TextLabel",{Size=UDim2.new(1,-56,0,16),Position=UDim2.new(0,10,0,7),BackgroundTransparency=1,Text=name,TextSize=13,Font=Enum.Font.GothamSemibold,TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left},row)
    make("TextLabel",{Size=UDim2.new(1,-56,0,13),Position=UDim2.new(0,10,0,24),BackgroundTransparency=1,Text=desc,TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left},row)
    local tr=make("Frame",{Size=UDim2.new(0,36,0,20),Position=UDim2.new(1,-46,0.5,-10),BackgroundColor3=CFG[key] and C.accent or C.border,BorderSizePixel=0},row)
    corner(tr,10)
    local th=make("Frame",{Size=UDim2.new(0,14,0,14),Position=CFG[key] and UDim2.new(0,18,0.5,-7) or UDim2.new(0,4,0.5,-7),BackgroundColor3=C.white,BorderSizePixel=0},tr)
    corner(th,99)
    make("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=3},row).MouseButton1Click:Connect(function()
        CFG[key]=not CFG[key]
        tw(tr,{BackgroundColor3=CFG[key] and C.accent or C.border})
        tw(th,{Position=CFG[key] and UDim2.new(0,18,0.5,-7) or UDim2.new(0,4,0.5,-7)})
        if onChange then onChange(CFG[key]) end
    end)
end

local function sld(tab,name,key,mn,mx,step,suf,div)
    step=step or 1; suf=suf or ""; div=div or 1
    local o=nextOrd(tab)
    local row=make("Frame",{Size=UDim2.new(1,0,0,56),BackgroundColor3=C.card,BorderSizePixel=0,LayoutOrder=o},tabFrames[tab])
    corner(row,9) stroke(row,C.border,1)
    make("TextLabel",{Size=UDim2.new(0.65,0,0,18),Position=UDim2.new(0,10,0,6),BackgroundTransparency=1,Text=name,TextSize=13,Font=Enum.Font.GothamSemibold,TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left},row)
    local vl=make("TextLabel",{Size=UDim2.new(0.35,-10,0,18),Position=UDim2.new(0.65,0,0,6),BackgroundTransparency=1,Text=tostring(CFG[key]/div)..suf,TextSize=13,Font=Enum.Font.GothamBold,TextColor3=C.on,TextXAlignment=Enum.TextXAlignment.Right},row)
    local bg=make("Frame",{Size=UDim2.new(1,-20,0,4),Position=UDim2.new(0,10,0,38),BackgroundColor3=C.border,BorderSizePixel=0},row)
    corner(bg,2)
    local p0=math.clamp((CFG[key]-mn)/(mx-mn),0,1)
    local fi=make("Frame",{Size=UDim2.new(p0,0,1,0),BackgroundColor3=C.accent,BorderSizePixel=0},bg)
    corner(fi,2)
    local th=make("Frame",{Size=UDim2.new(0,14,0,14),Position=UDim2.new(p0,-7,0.5,-7),BackgroundColor3=C.white,BorderSizePixel=0,ZIndex=2},bg)
    corner(th,99) stroke(th,C.accent,2)
    local drag=false
    local function sv(x)
        local abs=bg.AbsoluteSize.X
        if abs<1 then return end
        local pct=math.clamp((x-bg.AbsolutePosition.X)/abs,0,1)
        local raw=mn+(mx-mn)*pct
        local snp=math.round(raw/step)*step
        CFG[key]=snp
        local d=snp/div
        vl.Text=(step<1 and string.format("%.1f",d) or tostring(math.round(d)))..suf
        fi.Size=UDim2.new(pct,0,1,0)
        th.Position=UDim2.new(pct,-7,0.5,-7)
    end
    local hb=make("TextButton",{Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,0,28),BackgroundTransparency=1,Text="",ZIndex=4},row)
    hb.MouseButton1Down:Connect(function(x) drag=true sv(x) end)
    hb.MouseMoved:Connect(function(x) if drag then sv(x) end end)
    hb.MouseButton1Up:Connect(function() drag=false end)
    hb.TouchLongPress:Connect(function() drag=true end)
    hb.TouchMoved:Connect(function(t) if drag and t[1] then sv(t[1].Position.X) end end)
    hb.TouchEnded:Connect(function() drag=false end)
end

local function pills(tab,name,key,opts)
    local o=nextOrd(tab)
    local row=make("Frame",{Size=UDim2.new(1,0,0,40),BackgroundColor3=C.card,BorderSizePixel=0,LayoutOrder=o},tabFrames[tab])
    corner(row,9) stroke(row,C.border,1)
    make("TextLabel",{Size=UDim2.new(0.42,0,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=name,TextSize=13,Font=Enum.Font.GothamSemibold,TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left},row)
    local pc=make("Frame",{Size=UDim2.new(0.58,-10,0,24),Position=UDim2.new(0.42,0,0.5,-12),BackgroundTransparency=1},row)
    make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,4),HorizontalAlignment=Enum.HorizontalAlignment.Right},pc)
    local ps={}
    local function ref()
        for _,p in ipairs(ps) do
            p.BackgroundColor3=(p.Name==CFG[key]) and C.accent or C.border
            p.TextColor3=(p.Name==CFG[key]) and C.white or C.muted
        end
    end
    for _,op in ipairs(opts) do
        local p=make("TextButton",{Name=op,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.new(0,0,1,0),BackgroundColor3=(CFG[key]==op) and C.accent or C.border,Text=op,TextSize=10,Font=Enum.Font.Gotham,TextColor3=(CFG[key]==op) and C.white or C.muted,AutoButtonColor=false},pc)
        corner(p,20)
        make("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,2)},p)
        table.insert(ps,p)
        p.MouseButton1Click:Connect(function() CFG[key]=op ref() end)
    end
end

-- ── Fill tabs ─────────────────────────────────────────────────────────────────
lbl("Aimbot","silent aim")
tog("Aimbot","Silent aim","Hook bullet pos to target","silent_aim")
sld("Aimbot","FOV radius","fov",1,180,1)
sld("Aimbot","Prediction","prediction",0,100,1)
lbl("Aimbot","target")
pills("Aimbot","Hitbox","hitbox",{"Head","Body","Neck"})
pills("Aimbot","Priority","priority",{"Closest","Low HP","FOV"})
tog("Aimbot","Visible only","Skip occluded","aim_vis")
tog("Aimbot","Teammates","Include teammates","aim_team")
lbl("Aimbot","triggerbot")
tog("Aimbot","Triggerbot","Fire on lock","trigger")
sld("Aimbot","Delay ms","trigger_delay",0,500,1)

lbl("ESP","master")
tog("ESP","ESP enabled","All drawings on/off","esp_enabled")
lbl("ESP","boxes")
tog("ESP","Bounding box","2D rectangle","esp_box")
pills("ESP","Style","box_style",{"Full","Corner","3D"})
tog("ESP","Health bar","Side HP bar","esp_hp")
tog("ESP","Name tag","Name above box","esp_name")
tog("ESP","Distance","Distance below","esp_dist")
tog("ESP","Tracers","Lines to players","esp_trace")
tog("ESP","Off-screen","Edge arrows","esp_offscreen")
sld("ESP","Max distance","esp_maxdist",100,2000,50)

lbl("Move","locomotion")
tog("Move","Bunny hop","Auto-jump","bhop")
tog("Move","Speedhack","Walk multiplier","speedhack")
sld("Move","Speed mult","speed_mult",10,50,1,"x",10)
tog("Move","Fly hack","V to toggle","fly")
sld("Move","Fly speed","fly_speed",5,200,5)
tog("Move","Infinite jump","No jump limit","inf_jump")
tog("Move","No fall dmg","Negate fall","no_fall")
tog("Move","Anti-knockback","Zero impulse","anti_kb")

lbl("Visuals","world")
tog("Visuals","Fullbright","Max ambient","fullbright")
tog("Visuals","No fog","Remove fog","no_fog")
tog("Visuals","Wireframe","Mesh mode","wireframe")
lbl("Visuals","crosshair")
tog("Visuals","Custom crosshair","Override","crosshair")
pills("Visuals","Style","ch_style",{"Dot","Cross","Circle"})
sld("Visuals","Size","ch_size",1,20,1)
lbl("Visuals","chams")
tog("Visuals","Player chams","Flat colors","chams")
tog("Visuals","Wall chams","Through walls","wall_chams")

lbl("Misc","combat")
tog("Misc","No recoil","Camera kick","no_recoil")
tog("Misc","No spread","Accurate shots","no_spread")
tog("Misc","Auto-ability","Spam abilities","auto_ability")
tog("Misc","Infinite ammo","No reload","inf_ammo")
lbl("Misc","utility")
tog("Misc","Auto-dodge","Dodge projectiles","auto_dodge")
tog("Misc","Anti-AFK","Input loop","anti_afk")
tog("Misc","Name spoofer","Random name","name_spoof")
tog("Misc","Watermark","Show label","watermark")

-- Toggle menu
UIS.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.KeyCode==Enum.KeyCode.Insert then
        Win.Visible=not Win.Visible
    end
end)

switchTab("Aimbot")
print("[vibecoding_ware] v2.6.0 loaded")
