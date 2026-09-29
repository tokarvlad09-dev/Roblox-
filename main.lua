-- vibecoding_ware | Rivals | v3.0.0 | visual only

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local LP           = Players.LocalPlayer

local C = {
    bg     = Color3.fromRGB(10,10,16),
    panel  = Color3.fromRGB(16,16,24),
    card   = Color3.fromRGB(22,22,34),
    border = Color3.fromRGB(38,38,58),
    accent = Color3.fromRGB(124,92,252),
    text   = Color3.fromRGB(232,230,255),
    muted  = Color3.fromRGB(100,98,140),
    on     = Color3.fromRGB(167,139,250),
    green  = Color3.fromRGB(74,222,128),
    red    = Color3.fromRGB(248,113,113),
    white  = Color3.fromRGB(255,255,255),
}

local SG = Instance.new("ScreenGui")
SG.Name = "vibe_ui"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.DisplayOrder = 999
pcall(function() SG.Parent = game:GetService("CoreGui") end)
if not SG.Parent or SG.Parent.Name ~= "CoreGui" then SG.Parent = LP.PlayerGui end

local function mk(cls, props, parent)
    local i = Instance.new(cls)
    for k,v in pairs(props) do i[k]=v end
    if parent then i.Parent = parent end
    return i
end
local function tw(o,p,t) TweenService:Create(o,TweenInfo.new(t or 0.18,Enum.EasingStyle.Quad),p):Play() end
local function rnd(p,r) mk("UICorner",{CornerRadius=UDim.new(0,r or 8)},p) end
local function brd(p,c,t) mk("UIStroke",{Color=c or C.border,Thickness=t or 1},p) end

-- ── Toggle button (mobile-friendly, bottom right) ─────────────────────────
local TogBtn = mk("TextButton",{
    Size=UDim2.new(0,48,0,48),
    Position=UDim2.new(1,-62,1,-120),
    BackgroundColor3=C.accent,
    Text="☰",TextSize=22,Font=Enum.Font.GothamBold,
    TextColor3=C.white,BorderSizePixel=0,ZIndex=10,
},SG)
rnd(TogBtn,14)
mk("UIStroke",{Color=Color3.fromRGB(160,130,255),Thickness=1.5},TogBtn)

-- glow behind button
local Glow = mk("Frame",{
    Size=UDim2.new(0,64,0,64),
    Position=UDim2.new(1,-70,1,-128),
    BackgroundColor3=C.accent,
    BackgroundTransparency=0.82,
    BorderSizePixel=0,ZIndex=9,
},SG)
rnd(Glow,32)

-- ── Main window ───────────────────────────────────────────────────────────
local Win = mk("Frame",{
    Size=UDim2.new(0,320,0,480),
    Position=UDim2.new(0.5,-160,0.5,-240),
    BackgroundColor3=C.bg,
    BorderSizePixel=0,
    Visible=false,
},SG)
rnd(Win,16)
brd(Win,C.border,1)

-- subtle top gradient stripe
local TopStripe = mk("Frame",{
    Size=UDim2.new(1,0,0,3),
    BackgroundColor3=C.accent,
    BorderSizePixel=0,
},Win)
rnd(TopStripe,3)

-- ── Header ────────────────────────────────────────────────────────────────
local Hdr = mk("Frame",{
    Size=UDim2.new(1,0,0,54),
    Position=UDim2.new(0,0,0,3),
    BackgroundColor3=C.panel,
    BorderSizePixel=0,
},Win)
rnd(Hdr,14)
mk("Frame",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),BackgroundColor3=C.panel,BorderSizePixel=0},Hdr)

-- icon
local Ico = mk("Frame",{
    Size=UDim2.new(0,30,0,30),
    Position=UDim2.new(0,12,0.5,-15),
    BackgroundColor3=C.accent,BorderSizePixel=0,
},Hdr)
rnd(Ico,9)
mk("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="⚡",TextSize=17,Font=Enum.Font.GothamBold,TextColor3=C.white},Ico)

mk("TextLabel",{
    Size=UDim2.new(0,180,0,18),Position=UDim2.new(0,50,0,9),
    BackgroundTransparency=1,Text="vibecoding_ware",
    TextSize=14,Font=Enum.Font.GothamBold,TextColor3=C.text,
    TextXAlignment=Enum.TextXAlignment.Left,
},Hdr)
mk("TextLabel",{
    Size=UDim2.new(0,180,0,13),Position=UDim2.new(0,50,0,29),
    BackgroundTransparency=1,Text="rivals edition · delta",
    TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.muted,
    TextXAlignment=Enum.TextXAlignment.Left,
},Hdr)

-- status dot
local SDot = mk("Frame",{
    Size=UDim2.new(0,8,0,8),Position=UDim2.new(1,-60,0.5,-4),
    BackgroundColor3=C.green,BorderSizePixel=0,
},Hdr)
rnd(SDot,99)
mk("TextLabel",{
    Size=UDim2.new(0,50,1,0),Position=UDim2.new(1,-52,0,0),
    BackgroundTransparency=1,Text="injected",
    TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.green,
    TextXAlignment=Enum.TextXAlignment.Right,
},Hdr)

-- close button
local CloseBtn = mk("TextButton",{
    Size=UDim2.new(0,28,0,28),
    Position=UDim2.new(1,-10,0,-10),
    BackgroundColor3=Color3.fromRGB(40,30,60),
    Text="✕",TextSize=13,Font=Enum.Font.GothamBold,
    TextColor3=C.muted,BorderSizePixel=0,ZIndex=5,
},Hdr)
rnd(CloseBtn,8)

-- ── Tab bar ───────────────────────────────────────────────────────────────
local TABS = {"Aimbot","ESP","Move","Visuals","Misc"}

local TBar = mk("Frame",{
    Size=UDim2.new(1,0,0,32),Position=UDim2.new(0,0,0,57),
    BackgroundColor3=C.panel,BorderSizePixel=0,
    ClipsDescendants=true,
},Win)
mk("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.border,BorderSizePixel=0},TBar)

-- active tab indicator pill
local TabPill = mk("Frame",{
    Size=UDim2.new(0,math.floor(320/#TABS)-6,0,24),
    Position=UDim2.new(0,3,0,4),
    BackgroundColor3=C.accent,BorderSizePixel=0,
},TBar)
rnd(TabPill,8)
TabPill.BackgroundTransparency=0.15

local tabBtns = {}
local tabW = math.floor(320/#TABS)
for i,name in ipairs(TABS) do
    local b = mk("TextButton",{
        Name=name,
        Size=UDim2.new(0,tabW,1,0),
        Position=UDim2.new(0,(i-1)*tabW,0,0),
        BackgroundTransparency=1,
        Text=name,TextSize=10,Font=Enum.Font.Gotham,
        TextColor3=C.muted,AutoButtonColor=false,
    },TBar)
    tabBtns[name]=b
end

-- ── Content area ──────────────────────────────────────────────────────────
local ContentArea = mk("Frame",{
    Size=UDim2.new(1,0,1,-120),Position=UDim2.new(0,0,0,91),
    BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=true,
},Win)

local tabFrames = {}
local function makeScroll(name)
    local f = mk("ScrollingFrame",{
        Name=name,Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,BorderSizePixel=0,
        ScrollBarThickness=2,ScrollBarImageColor3=C.accent,
        CanvasSize=UDim2.new(0,0,0,0),Visible=false,
        ElasticBehavior=Enum.ElasticBehavior.Never,
    },ContentArea)
    local L=mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},f)
    mk("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10),PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8)},f)
    L:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        f.CanvasSize=UDim2.new(0,0,0,L.AbsoluteContentSize.Y+20)
    end)
    return f
end
for _,t in ipairs(TABS) do tabFrames[t]=makeScroll(t) end

-- ── Footer ────────────────────────────────────────────────────────────────
local Foot = mk("Frame",{
    Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,1,-28),
    BackgroundColor3=C.panel,BorderSizePixel=0,
},Win)
rnd(Foot,16)
mk("Frame",{Size=UDim2.new(1,0,0,14),BackgroundColor3=C.panel,BorderSizePixel=0},Foot)
mk("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=C.border,BorderSizePixel=0},Foot)
mk("TextLabel",{
    Size=UDim2.new(0.6,0,1,0),Position=UDim2.new(0,12,0,0),
    BackgroundTransparency=1,Text="vibecoding_ware · rivals",
    TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.muted,
    TextXAlignment=Enum.TextXAlignment.Left,
},Foot)
mk("TextLabel",{
    Size=UDim2.new(0.4,-12,1,0),Position=UDim2.new(0.6,0,0,0),
    BackgroundTransparency=1,Text="v3.0.0",
    TextSize=10,Font=Enum.Font.GothamBold,TextColor3=C.accent,
    TextXAlignment=Enum.TextXAlignment.Right,
},Foot)

-- ── UI helpers ────────────────────────────────────────────────────────────
local ord={}
for _,t in ipairs(TABS) do ord[t]=0 end
local function nextOrd(tab) ord[tab]=ord[tab]+1 return ord[tab] end

local function lbl(tab,text)
    mk("TextLabel",{
        Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,
        Text=text:upper(),TextSize=9,Font=Enum.Font.GothamBold,
        TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,
        LayoutOrder=nextOrd(tab),
    },tabFrames[tab])
end

local CFG = {}
local function tog(tab,name,desc,key)
    CFG[key]=false
    local o=nextOrd(tab)
    local row=mk("Frame",{
        Size=UDim2.new(1,0,0,48),BackgroundColor3=C.card,
        BorderSizePixel=0,LayoutOrder=o,
    },tabFrames[tab])
    rnd(row,10) brd(row,C.border,1)

    mk("TextLabel",{
        Size=UDim2.new(1,-56,0,17),Position=UDim2.new(0,12,0,8),
        BackgroundTransparency=1,Text=name,TextSize=13,
        Font=Enum.Font.GothamSemibold,TextColor3=C.text,
        TextXAlignment=Enum.TextXAlignment.Left,
    },row)
    mk("TextLabel",{
        Size=UDim2.new(1,-56,0,13),Position=UDim2.new(0,12,0,27),
        BackgroundTransparency=1,Text=desc,TextSize=11,
        Font=Enum.Font.Gotham,TextColor3=C.muted,
        TextXAlignment=Enum.TextXAlignment.Left,
    },row)

    local tr=mk("Frame",{
        Size=UDim2.new(0,38,0,22),Position=UDim2.new(1,-50,0.5,-11),
        BackgroundColor3=C.border,BorderSizePixel=0,
    },row)
    rnd(tr,11)
    local th=mk("Frame",{
        Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,3,0.5,-8),
        BackgroundColor3=C.white,BorderSizePixel=0,
    },tr)
    rnd(th,99)

    mk("TextButton",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=3,
    },row).MouseButton1Click:Connect(function()
        CFG[key]=not CFG[key]
        tw(tr,{BackgroundColor3=CFG[key] and C.accent or C.border})
        tw(th,{Position=CFG[key] and UDim2.new(0,19,0.5,-8) or UDim2.new(0,3,0.5,-8)})
    end)
end

local function sld(tab,name,key,mn,mx,def)
    CFG[key]=def
    local o=nextOrd(tab)
    local row=mk("Frame",{
        Size=UDim2.new(1,0,0,58),BackgroundColor3=C.card,
        BorderSizePixel=0,LayoutOrder=o,
    },tabFrames[tab])
    rnd(row,10) brd(row,C.border,1)

    mk("TextLabel",{
        Size=UDim2.new(0.65,0,0,18),Position=UDim2.new(0,12,0,7),
        BackgroundTransparency=1,Text=name,TextSize=13,
        Font=Enum.Font.GothamSemibold,TextColor3=C.text,
        TextXAlignment=Enum.TextXAlignment.Left,
    },row)
    local vl=mk("TextLabel",{
        Size=UDim2.new(0.35,-12,0,18),Position=UDim2.new(0.65,0,0,7),
        BackgroundTransparency=1,Text=tostring(def),TextSize=13,
        Font=Enum.Font.GothamBold,TextColor3=C.on,
        TextXAlignment=Enum.TextXAlignment.Right,
    },row)
    local bg=mk("Frame",{
        Size=UDim2.new(1,-24,0,4),Position=UDim2.new(0,12,0,40),
        BackgroundColor3=C.border,BorderSizePixel=0,
    },row)
    rnd(bg,2)
    local p0=math.clamp((def-mn)/(mx-mn),0,1)
    local fi=mk("Frame",{Size=UDim2.new(p0,0,1,0),BackgroundColor3=C.accent,BorderSizePixel=0},bg)
    rnd(fi,2)
    local th=mk("Frame",{
        Size=UDim2.new(0,16,0,16),Position=UDim2.new(p0,-8,0.5,-8),
        BackgroundColor3=C.white,BorderSizePixel=0,ZIndex=2,
    },bg)
    rnd(th,99) brd(th,C.accent,2)

    local drag=false
    local function sv(x)
        local abs=bg.AbsoluteSize.X
        if abs<1 then return end
        local pct=math.clamp((x-bg.AbsolutePosition.X)/abs,0,1)
        CFG[key]=math.round(mn+(mx-mn)*pct)
        vl.Text=tostring(CFG[key])
        fi.Size=UDim2.new(pct,0,1,0)
        th.Position=UDim2.new(pct,-8,0.5,-8)
    end
    local hb=mk("TextButton",{
        Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,28),
        BackgroundTransparency=1,Text="",ZIndex=4,
    },row)
    hb.MouseButton1Down:Connect(function(x) drag=true sv(x) end)
    hb.MouseMoved:Connect(function(x) if drag then sv(x) end end)
    hb.MouseButton1Up:Connect(function() drag=false end)
    hb.TouchLongPress:Connect(function() drag=true end)
    hb.TouchMoved:Connect(function(t) if drag and t[1] then sv(t[1].Position.X) end end)
    hb.TouchEnded:Connect(function() drag=false end)
end

local function pills(tab,name,key,opts)
    CFG[key]=opts[1]
    local o=nextOrd(tab)
    local row=mk("Frame",{
        Size=UDim2.new(1,0,0,42),BackgroundColor3=C.card,
        BorderSizePixel=0,LayoutOrder=o,
    },tabFrames[tab])
    rnd(row,10) brd(row,C.border,1)

    mk("TextLabel",{
        Size=UDim2.new(0.42,0,1,0),Position=UDim2.new(0,12,0,0),
        BackgroundTransparency=1,Text=name,TextSize=13,
        Font=Enum.Font.GothamSemibold,TextColor3=C.text,
        TextXAlignment=Enum.TextXAlignment.Left,
    },row)
    local pc=mk("Frame",{
        Size=UDim2.new(0.58,-10,0,26),Position=UDim2.new(0.42,0,0.5,-13),
        BackgroundTransparency=1,
    },row)
    mk("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,4),HorizontalAlignment=Enum.HorizontalAlignment.Right},pc)
    local ps={}
    local function ref()
        for _,p in ipairs(ps) do
            p.BackgroundColor3=(p.Name==CFG[key]) and C.accent or C.border
            p.TextColor3=(p.Name==CFG[key]) and C.white or C.muted
        end
    end
    for _,op in ipairs(opts) do
        local p=mk("TextButton",{
            Name=op,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.new(0,0,1,0),
            BackgroundColor3=(CFG[key]==op) and C.accent or C.border,
            Text=op,TextSize=10,Font=Enum.Font.Gotham,
            TextColor3=(CFG[key]==op) and C.white or C.muted,
            AutoButtonColor=false,
        },pc)
        rnd(p,20)
        mk("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,2)},p)
        table.insert(ps,p)
        p.MouseButton1Click:Connect(function() CFG[key]=op ref() end)
    end
end

-- ── Tab content ───────────────────────────────────────────────────────────
lbl("Aimbot","silent aim")
tog("Aimbot","Silent aim","Hook bullet to target","silent_aim")
sld("Aimbot","FOV radius","fov",1,180,45)
sld("Aimbot","Prediction","prediction",0,100,50)
lbl("Aimbot","target")
pills("Aimbot","Hitbox","hitbox",{"Head","Body","Neck"})
pills("Aimbot","Priority","priority",{"Closest","Low HP","FOV"})
tog("Aimbot","Visible only","Skip occluded","aim_vis")
tog("Aimbot","Teammates","Include teammates","aim_team")
lbl("Aimbot","triggerbot")
tog("Aimbot","Triggerbot","Fire on lock","trigger")
sld("Aimbot","Delay ms","trigger_delay",0,500,80)

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
sld("ESP","Max distance","esp_maxdist",100,2000,800)

lbl("Move","locomotion")
tog("Move","Bunny hop","Auto-jump","bhop")
tog("Move","Speedhack","Walk multiplier","speedhack")
sld("Move","Speed mult","speed_mult",10,50,15)
tog("Move","Fly hack","V to toggle","fly")
sld("Move","Fly speed","fly_speed",5,200,50)
tog("Move","Infinite jump","No jump limit","inf_jump")
tog("Move","No fall dmg","Negate fall","no_fall")
tog("Move","Anti-knockback","Zero impulse","anti_kb")

lbl("Visuals","world")
tog("Visuals","Fullbright","Max ambient","fullbright")
tog("Visuals","No fog","Remove fog","no_fog")
tog("Visuals","Wireframe","Mesh mode","wireframe")
lbl("Visuals","crosshair")
tog("Visuals","Custom crosshair","Override default","crosshair")
pills("Visuals","Style","ch_style",{"Dot","Cross","Circle"})
sld("Visuals","Size","ch_size",1,20,6)
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

-- ── Tab switching ─────────────────────────────────────────────────────────
local currentTab = "Aimbot"
local function switchTab(name)
    currentTab = name
    local tw2 = tabW
    for i,t in ipairs(TABS) do
        if t==name then
            tw(TabPill,{Position=UDim2.new(0,(i-1)*tw2+3,0,4)})
        end
        tabBtns[t].TextColor3=(t==name) and C.on or C.muted
        tabBtns[t].Font=(t==name) and Enum.Font.GothamBold or Enum.Font.Gotham
    end
    for n,f in pairs(tabFrames) do f.Visible=(n==name) end
end
for _,t in ipairs(TABS) do
    tabBtns[t].MouseButton1Click:Connect(function() switchTab(t) end)
end
switchTab("Aimbot")

-- ── Open / close ──────────────────────────────────────────────────────────
local isOpen = false
local function openWin()
    isOpen = true
    Win.Visible = true
    Win.Size = UDim2.new(0,320,0,0)
    Win.BackgroundTransparency = 1
    tw(Win,{Size=UDim2.new(0,320,0,480),BackgroundTransparency=0},0.22)
    tw(TogBtn,{BackgroundColor3=Color3.fromRGB(80,60,160)})
end
local function closeWin()
    isOpen = false
    tw(Win,{Size=UDim2.new(0,320,0,0),BackgroundTransparency=1},0.18)
    task.delay(0.2,function() if not isOpen then Win.Visible=false end end)
    tw(TogBtn,{BackgroundColor3=C.accent})
end

TogBtn.MouseButton1Click:Connect(function()
    if isOpen then closeWin() else openWin() end
end)
CloseBtn.MouseButton1Click:Connect(closeWin)

UIS.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.KeyCode==Enum.KeyCode.Insert then
        if isOpen then closeWin() else openWin() end
    end
end)

-- pulse glow on button
local pulse = true
task.spawn(function()
    while pulse do
        tw(Glow,{BackgroundTransparency=0.75},0.9)
        task.wait(0.95)
        tw(Glow,{BackgroundTransparency=0.88},0.9)
        task.wait(0.95)
    end
end)

print("[vibecoding_ware] v3.0.0 loaded")
