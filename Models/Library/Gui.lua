local Native = {
pcall = pcall,
type = type,
typeof = typeof,
tostring = tostring,
tonumber = tonumber,
setmetatable = setmetatable,
getmetatable = getmetatable,
rawget = rawget,
rawset = rawset,
rawequal = rawequal,
select = select,
next = next,
char = string.char,
byte = string.byte,
sub = string.sub,
format = string.format,
concat = table.concat,
insert = table.insert,
remove = table.remove,
bxor = bit32.bxor,
spawn = task.spawn,
wait = task.wait,
defer = task.defer,
delay = task.delay,
newInstance = Instance.new,
clock = os.clock,
getrawmetatable = getrawmetatable,
iscclosure = iscclosure,
debugInfo = debug and debug.info,
}
local Ui = {}
Ui.__index = Ui
Ui.Version = "v1.0.0"
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer
local Guard = {}
local entries = {}
local warned = {}
local started = false
local SEALED = {
{ {22,51,50,16,62,18,5,66,43,17,7}, {232,84,85,238,45,97,56,104,225,110,54}, {78,88,102,15,84,67,83,125,91,90,102} },
{ {41,62,37,63,44,19,4,22,10,0,95,73,117,106,110,110,110,107,85,85,81,81,83,83,84,99,110,111}, {92,45,112,44,99,100,59,105,73,59,185,153,154,161,165,169,161,174,178,176,174,172,188,186,175,197,186,181}, {31,24,23,29,6,6,0,0,0,0,31,28,30,28,30,31,30,8,87,93,65,78,95,94,79,87,82,67} },
{ {41,62,37,63,44,19,4,22,10,0,95,73,117,106,108,107,110,105,87,87,85,90,81,80,85,107,107,105}, {92,45,112,44,99,100,59,105,73,59,185,153,154,161,159,178,161,180,184,182,186,193,182,183,178,173,171,187}, {25,29,31,28,5,4,11,4,2,2,29,28,27,30,30,31,30,8,87,93,65,78,95,94,79,87,82,67} },
{ {111,106}, {157,164}, {26,25} },
}
local function flag(reason)
if not warned[reason] then
warned[reason] = true
warn("MooNard - Stop Skidding Kid")
end
end
local function unseal(index)
local c = SEALED[index]
local n = #c[1]
local a, b, d = {}, {}, {}
for i = 1, n do
a[i] = Native.char(Native.bxor(c[1][i], 90 + (i % 13)))
b[i] = Native.char(((c[2][i] - i) * 84) % 251)
d[n - i + 1] = Native.char(Native.bxor(c[3][i], 43 + (i % 11)))
end
local sa, sb, sd = Native.concat(a), Native.concat(b), Native.concat(d)
if sa == sb and sb == sd then
return sa
end
flag("sealed data modified")
if sa == sb or sa == sd then
return sa
end
if sb == sd then
return sb
end
return sa
end
function Guard.name()
return unseal(1)
end
function Guard.logo()
return unseal(2)
end
function Guard.toggleIcon()
return unseal(3)
end
function Guard.toggleSize()
return Native.tonumber(unseal(4)) or 46
end
function Guard.yes()
return true
end
function Guard.zero()
return 0
end
local function signature(f)
local info = Native.debugInfo
if not info or Native.type(f) ~= "function" then
return ""
end
local ok, n, s, l = Native.pcall(function()
return info(f, "n"), info(f, "s"), info(f, "l")
end)
if not ok then
return ""
end
local c = ""
if Native.iscclosure then
local okc, v = Native.pcall(Native.iscclosure, f)
if okc then
c = Native.tostring(v)
end
end
return Native.tostring(n) .. "|" .. Native.tostring(s) .. "|" .. Native.tostring(l) .. "|" .. c
end
local watched = {}
local function watch(get, expectC)
local ok, f = Native.pcall(get)
if ok and f ~= nil then
Native.insert(watched, { get = get, fn = f, sig = signature(f), c = expectC })
end
end
watch(function() return pcall end, true)
watch(function() return type end, true)
watch(function() return typeof end, true)
watch(function() return tostring end, true)
watch(function() return tonumber end, true)
watch(function() return setmetatable end, true)
watch(function() return getmetatable end, true)
watch(function() return rawget end, true)
watch(function() return rawset end, true)
watch(function() return rawequal end, true)
watch(function() return select end, true)
watch(function() return next end, true)
watch(function() return Instance.new end, true)
watch(function() return string.char end, true)
watch(function() return string.byte end, true)
watch(function() return string.sub end, true)
watch(function() return string.format end, true)
watch(function() return table.concat end, true)
watch(function() return table.insert end, true)
watch(function() return bit32.bxor end, true)
watch(function() return task.spawn end, true)
watch(function() return task.wait end, true)
watch(function() return task.defer end, true)
watch(function() return task.delay end, true)
watch(function() return os.clock end, true)
watch(function() return Guard.name end, false)
watch(function() return Guard.logo end, false)
watch(function() return Guard.toggleIcon end, false)
watch(function() return Guard.toggleSize end, false)
watch(function() return Guard.lock end, false)
watch(function() return Guard.sweep end, false)
watch(function() return Guard.start end, false)
local gameMeta
local metaSnap = {}
local metaKeys = { "__index", "__newindex", "__namecall" }
if Native.getrawmetatable then
local ok, mt = Native.pcall(Native.getrawmetatable, game)
if ok and Native.type(mt) == "table" then
gameMeta = mt
for i = 1, #metaKeys do
local v = Native.rawget(mt, metaKeys[i])
metaSnap[i] = { fn = v, sig = signature(v) }
end
end
end
local function integrity()
for i = 1, #watched do
local w = watched[i]
local ok, cur = Native.pcall(w.get)
if not ok or not Native.rawequal(cur, w.fn) then
return false
end
if signature(cur) ~= w.sig then
return false
end
if Native.iscclosure and w.c ~= nil then
local okc, isC = Native.pcall(Native.iscclosure, cur)
if okc and isC ~= w.c then
return false
end
end
end
if gameMeta then
for i = 1, #metaKeys do
local v = Native.rawget(gameMeta, metaKeys[i])
local snap = metaSnap[i]
if not Native.rawequal(v, snap.fn) or signature(v) ~= snap.sig then
return false
end
end
end
return true
end
local function kill(e)
e.dead = true
for i = 1, #e.conns do
Native.pcall(function()
e.conns[i]:Disconnect()
end)
end
end
local function enforce(e)
if e.dead then
return
end
local host = e.host
if Native.typeof(host) ~= "Instance" or host.Parent == nil then
kill(e)
return
end
local inst = e.inst
if not inst:IsDescendantOf(host) then
kill(e)
if e.onMissing then
flag("instance removed")
Native.defer(e.onMissing)
end
return
end
local rules = e.rules
for i = 1, #rules do
local prop, getter = rules[i][1], rules[i][2]
local want = getter()
local ok, cur = Native.pcall(function()
return inst[prop]
end)
if not ok or cur ~= want then
flag("property " .. prop)
end
Native.pcall(function()
inst[prop] = want
end)
end
end
function Guard.lock(host, inst, rules, onMissing)
local e = { host = host, inst = inst, rules = rules, onMissing = onMissing, conns = {} }
Native.insert(entries, e)
for i = 1, #rules do
Native.pcall(function()
Native.insert(e.conns, inst:GetPropertyChangedSignal(rules[i][1]):Connect(function()
enforce(e)
end))
end)
end
Native.pcall(function()
Native.insert(e.conns, inst.AncestryChanged:Connect(function()
enforce(e)
end))
end)
enforce(e)
Guard.start()
end
function Guard.sweep()
Native.pcall(function()
if not integrity() then
flag("hook detected")
end
local want = unseal(1)
if Ui.Name ~= want then
Ui.Name = want
flag("ui name")
end
for i = #entries, 1, -1 do
local e = entries[i]
if e.dead then
Native.remove(entries, i)
else
enforce(e)
end
end
end)
end
function Guard.start()
if started then
return
end
started = true
local last = 0
RunService.Heartbeat:Connect(function()
local t = Native.clock()
if t - last >= 0.25 then
last = t
Guard.sweep()
end
end)
Native.spawn(function()
while true do
Native.wait(0.7)
Guard.sweep()
end
end)
end
Ui.Name = Guard.name()
local Env = (getgenv and getgenv()) or _G
local ROOT = Env.UiRoot or "https://raw.githubusercontent.com/z-6z/MooNardHub/main/"
local FILES = {
"Models/Themes.lua",
"Models/Icons.lua",
"Models/Library/Elements.lua",
"Models/Library/Advanced.lua",
"Models/Library/Window.lua",
"Models/Library/Extras.lua",
}
local CACHE = Env.UiCache
local remote = ROOT:match("^https?://") ~= nil
local sources = {}
local pending = #FILES
local function cachePath(path)
	return "UiCache/" .. path:gsub("/", "_")
end
local function read(path)
	if not remote then
		return readfile(ROOT .. path)
	end
	if CACHE and isfile and isfile(cachePath(path)) then
		return readfile(cachePath(path))
	end
	local src = game:HttpGet(ROOT .. path)
	if CACHE and writefile and isfolder and makefolder then
		if not isfolder("UiCache") then
			makefolder("UiCache")
		end
		Native.pcall(writefile, cachePath(path), src)
	end
	return src
end
for _, path in ipairs(FILES) do
	Native.spawn(function()
		local err
		for _ = 1, 3 do
			local ok, res = Native.pcall(read, path)
			if ok and Native.type(res) == "string" and #res > 0 then
				sources[path] = res
				break
			end
			err = res
			Native.wait(0.3)
		end
		if not sources[path] then
			sources[path] = false
			warn("Failed to load " .. path .. ": " .. Native.tostring(err))
		end
		pending = pending - 1
	end)
end
local waited = 0
while pending > 0 and waited < 40 do
	waited = waited + Native.wait()
end
for _, path in ipairs(FILES) do
	if not sources[path] then
		error("Library file missing: " .. path)
	end
end
local S = {
Native = Native,
Guard = Guard,
flag = flag,
TweenService = TweenService,
UserInputService = UserInputService,
RunService = RunService,
CoreGui = CoreGui,
TextService = TextService,
LocalPlayer = LocalPlayer,
}
local function include(path)
local fn, err = loadstring(sources[path], "=" .. path)
if not fn then
error(err)
end
Env.UiCtx = {Ui = Ui, S = S}
local result = fn(Ui, S)
Env.UiCtx = nil
return result
end
include("Models/Themes.lua")
include("Models/Icons.lua")
local ACTIVE = Ui.Themes.Dark
local REGISTRY = {}
local function track(inst, prop, token)
if typeof(inst) ~= "Instance" or ACTIVE[token] == nil then
return
end
table.insert(REGISTRY, {
inst = inst,
prop = prop,
token = token,
})
inst[prop] = ACTIVE[token]
inst.Destroying:Connect(function()
for i = #REGISTRY, 1, -1 do
if REGISTRY[i].inst == inst then
table.remove(REGISTRY, i)
end
end
end)
end
local function new(class, props, children)
local o = Instance.new(class)
for k, v in pairs(props or {}) do
if k ~= "Parent" and k ~= "Theme" then
o[k] = v
end
end
for prop, token in pairs((props or {}).Theme or {}) do
track(o, prop, token)
end
for _, c in ipairs(children or {}) do
c.Parent = o
end
if props and props.Parent then
o.Parent = props.Parent
end
return o
end
Ui.CornerScale = 1
local function corner(parent, r)
local base = r or 10
local soft = math.clamp(math.floor(base * (Ui.CornerScale or 1) + 0.5), 4, 32)
return new("UICorner", {
CornerRadius = UDim.new(0, soft),
Parent = parent,
})
end
local function stroke(parent, token, thickness)
local s = new("UIStroke", {
Thickness = thickness or 1,
ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
Parent = parent,
Theme = {
Color = token or "Stroke",
},
})
return s
end
local SHINE = {}
local function shineColor()
local a = ACTIVE.Stroke or Color3.new(0.3, 0.3, 0.3)
local b = ACTIVE.Accent or Color3.new(1, 1, 1)
return ColorSequence.new({
ColorSequenceKeypoint.new(0, a),
ColorSequenceKeypoint.new(0.42, a),
ColorSequenceKeypoint.new(0.5, b),
ColorSequenceKeypoint.new(0.58, a),
ColorSequenceKeypoint.new(1, a),
})
end
local function shine(target, speed)
local g = Instance.new("UIGradient")
g.Color = shineColor()
g.Parent = target
local entry = { g = g, speed = speed or 60, theme = ACTIVE }
table.insert(SHINE, entry)
g.Destroying:Connect(function()
for i = #SHINE, 1, -1 do
if SHINE[i] == entry then
table.remove(SHINE, i)
end
end
end)
return g
end
RunService.Heartbeat:Connect(function(dt)
for _, e in ipairs(SHINE) do
if e.g.Parent then
e.g.Rotation = (e.g.Rotation + dt * e.speed) % 360
if e.theme ~= ACTIVE then
e.theme = ACTIVE
e.g.Color = shineColor()
end
end
end
end)
local function ledBackdrop(parent)
local glowTop = new("Frame", {
Name = "Sheen",
Size = UDim2.new(1, 0, 1, 0),
BorderSizePixel = 0,
ZIndex = 0,
Parent = parent,
Theme = {
BackgroundColor3 = "Accent",
},
})
new("UIGradient", {
Rotation = 90,
Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0.93),
NumberSequenceKeypoint.new(0.3, 0.985),
NumberSequenceKeypoint.new(1, 1),
}),
Parent = glowTop,
})
corner(glowTop, 14)
end
local function glass(inst, opt)
opt = opt or {}
inst.BackgroundTransparency = 1
inst.BorderSizePixel = 0
track(inst, "BackgroundColor3", "Glass")
track(inst, "BackgroundTransparency", opt.Token or "GlassAlpha")
local g = new("UIGradient", {
Rotation = opt.Rotation or 115,
Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0.12),
NumberSequenceKeypoint.new(0.55, 0.34),
NumberSequenceKeypoint.new(1, 0.55),
}),
Parent = inst,
})
local s = new("UIStroke", {
Thickness = opt.Thickness or 1.2,
Transparency = 0.35,
ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
Parent = inst,
Theme = {
Color = "GlassStroke",
},
})
new("UIGradient", {
Rotation = 90,
Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(0.75, 0.75, 0.75)),
Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0),
NumberSequenceKeypoint.new(0.5, 0.45),
NumberSequenceKeypoint.new(1, 0.85),
}),
Parent = s,
})
inst:SetAttribute("BaseTransparency", ACTIVE[opt.Token or "GlassAlpha"])
return g, s
end
local function glassHover(inst)
local idle = ACTIVE.GlassAlpha
local hot = ACTIVE.GlassHoverAlpha
inst.MouseEnter:Connect(function()
tween(inst, 0.14, {
BackgroundTransparency = ACTIVE.GlassHoverAlpha or hot,
})
end)
inst.MouseLeave:Connect(function()
tween(inst, 0.18, {
BackgroundTransparency = ACTIVE.GlassAlpha or idle,
})
end)
end
local function pad(parent, l, r, t, b)
return new("UIPadding", {
PaddingLeft = UDim.new(0, l or 0),
PaddingRight = UDim.new(0, r or l or 0),
PaddingTop = UDim.new(0, t or 0),
PaddingBottom = UDim.new(0, b or t or 0),
Parent = parent,
})
end
local function list(parent, dir, padPx, align)
return new("UIListLayout", {
FillDirection = dir or Enum.FillDirection.Vertical,
Padding = UDim.new(0, padPx or 0),
SortOrder = Enum.SortOrder.LayoutOrder,
VerticalAlignment = Enum.VerticalAlignment.Center,
HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
Parent = parent,
})
end
local ANIM = {
enabled = true,
speed = 1,
}
local function tween(inst, time, goal, style)
if not ANIM.enabled then
for k, v in pairs(goal) do
inst[k] = v
end
return
end
local t = TweenService:Create(
inst,
TweenInfo.new(time * ANIM.speed, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
goal
)
t:Play()
return t
end
local function hoverable(button, base, hover)
button.MouseEnter:Connect(function()
tween(button, 0.12, {
BackgroundColor3 = ACTIVE[hover],
})
end)
button.MouseLeave:Connect(function()
tween(button, 0.12, {
BackgroundColor3 = ACTIVE[base],
})
end)
end
local clickSoundEnabled = true
local function playClickSound()
if not clickSoundEnabled then
return
end
pcall(function()
local s = Instance.new("Sound")
s.SoundId = "rbxassetid://97972687450528"
s.Volume = 0.4
s.Parent = game:GetService("SoundService")
s:Play()
s.Ended:Connect(function()
s:Destroy()
end)
end)
end
local function ripple(button)
button.MouseButton1Down:Connect(function()
playClickSound()
local base = button:GetAttribute("BaseTransparency")
if base == nil then
base = button.BackgroundTransparency
button:SetAttribute("BaseTransparency", base)
end
if base >= 1 then
if button:IsA("ImageButton") then
tween(button, 0.08, { ImageTransparency = 0.35 })
task.delay(0.1, function()
if button and button.Parent then
tween(button, 0.12, { ImageTransparency = 0 })
end
end)
end
return
end
tween(button, 0.08, {
BackgroundTransparency = math.clamp(base + 0.2, 0, 1),
})
task.delay(0.1, function()
if button and button.Parent then
tween(button, 0.12, { BackgroundTransparency = base })
end
end)
end)
end
local function iconNode(class, props)
props = props or {}
local name = props.Icon
props.Icon = nil
props.Image = Ui.GetIcon(name)
if props.BackgroundTransparency == nil then
props.BackgroundTransparency = 1
end
props.ScaleType = props.ScaleType or Enum.ScaleType.Fit
props.BorderSizePixel = 0
if class == "ImageButton" then
props.AutoButtonColor = false
end
local o = new(class, props)
o:SetAttribute("IconName", tostring(name or ""))
return o
end
local function iconLabel(props)
return iconNode("ImageLabel", props)
end
local function iconButton(props)
return iconNode("ImageButton", props)
end
local function setIcon(obj, name)
if not obj then
return
end
if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
obj.Image = Ui.GetIcon(name)
obj:SetAttribute("IconName", tostring(name or ""))
end
end
function Ui:SetIcon(obj, name)
setIcon(obj, name)
end
Ui._tabRestyle = {}
function Ui:SetTheme(name)
local theme = Ui.Themes[name] or Ui.Themes.Dark
ACTIVE = theme
Ui.CurrentTheme = theme
task.delay(0.25, function()
for i = #Ui._tabRestyle, 1, -1 do
local ok, alive = pcall(Ui._tabRestyle[i])
if not ok or alive == false then
table.remove(Ui._tabRestyle, i)
end
end
end)
for i = #REGISTRY, 1, -1 do
local r = REGISTRY[i]
local alive = typeof(r.inst) == "Instance" and pcall(function()
return r.inst.Name
end)
if not alive then
table.remove(REGISTRY, i)
elseif theme[r.token] ~= nil then
pcall(function()
tween(r.inst, 0.2, {
[r.prop] = theme[r.token],
})
end)
end
end
Ui.CurrentTheme = theme
return theme
end
Ui.CurrentTheme = ACTIVE
function Ui:CreateTheme(name, tokens, base)
local src = Ui.Themes[base or "Dark"] or Ui.Themes.Dark
local t = {}
for k, v in pairs(src) do
t[k] = v
end
for k, v in pairs(tokens or {}) do
t[k] = v
end
t.Name = name
Ui.Themes[name] = t
return t
end
function Ui:SetColors(tokens)
local current = Ui.CurrentTheme or ACTIVE
for k, v in pairs(tokens or {}) do
current[k] = v
end
return Ui:SetTheme(current.Name or "Dark")
end
function Ui:SetAccent(color, textColor)
return Ui:SetColors({
Accent = color,
Success = color,
AccentText = textColor or Ui.CurrentTheme.AccentText,
})
end
function Ui:SetAnimations(on)
ANIM.enabled = on and true or false
end
function Ui:SetAnimationSpeed(mult)
ANIM.speed = math.clamp(1 / math.max(mult, 0.1), 0.1, 5)
end
local function makeScreenGui()
local gui = Instance.new("ScreenGui")
gui.Name = "MooNardHub_" .. tostring(math.random(1e5, 1e6))
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.DisplayOrder = 9999
local ok = pcall(function()
if gethui then
gui.Parent = gethui()
elseif syn and syn.protect_gui then
syn.protect_gui(gui)
gui.Parent = CoreGui
else
gui.Parent = CoreGui
end
end)
if not ok then
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
return gui
end
local function screenSize(frame)
local gui = frame:FindFirstAncestorWhichIsA("ScreenGui")
if gui and gui.AbsoluteSize.X > 0 then
return gui.AbsoluteSize
end
local cam = workspace.CurrentCamera
return cam and cam.ViewportSize or Vector2.new(1280, 720)
end
local function clampedPosition(frame, size, x, y)
local scr = screenSize(frame)
local ax, ay = frame.AnchorPoint.X, frame.AnchorPoint.Y
local margin = 6
local left = math.clamp(x - size.X * ax, margin, math.max(margin, scr.X - size.X - margin))
local top = math.clamp(y - size.Y * ay, margin, math.max(margin, scr.Y - size.Y - margin))
return UDim2.new(0, left + size.X * ax, 0, top + size.Y * ay)
end
local function makeDraggable(frame, handle)
local dragging, startPos, startInput
local endConn
handle.InputBegan:Connect(function(input)
if
input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
then
dragging, startInput, startPos = true, input.Position, frame.Position
if endConn then
endConn:Disconnect()
end
endConn = input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
dragging = false
if endConn then
endConn:Disconnect()
endConn = nil
end
end
end)
end
end)
local moveConn
moveConn = UserInputService.InputChanged:Connect(function(input)
if not dragging then
return
end
if
input.UserInputType == Enum.UserInputType.MouseMovement
or input.UserInputType == Enum.UserInputType.Touch
then
local d = input.Position - startInput
local scr = screenSize(frame)
local bx = startPos.X.Scale * scr.X + startPos.X.Offset + d.X
local by = startPos.Y.Scale * scr.Y + startPos.Y.Offset + d.Y
frame.Position = clampedPosition(frame, frame.AbsoluteSize, bx, by)
end
end)
frame.Destroying:Connect(function()
dragging = false
if moveConn then
moveConn:Disconnect()
end
if endConn then
endConn:Disconnect()
end
end)
end
local Visualizer = {}
Visualizer.__index = Visualizer
function Visualizer.new(parent, barCount)
local self = setmetatable({}, Visualizer)
barCount = barCount or 4
self.bars = {}
self.active = true
self.frame = new("Frame", {
Name = "Visualizer",
BackgroundTransparency = 1,
Size = UDim2.new(0, barCount * 5, 1, 0),
Parent = parent,
})
local l = list(self.frame, Enum.FillDirection.Horizontal, 2, Enum.HorizontalAlignment.Center)
l.VerticalAlignment = Enum.VerticalAlignment.Bottom
for i = 1, barCount do
local maxH = 5 + (i - 1) * 4
local bar = new("Frame", {
Size = UDim2.new(0, 3, 0, maxH),
BorderSizePixel = 0,
LayoutOrder = i,
Parent = self.frame,
BackgroundColor3 = Color3.fromRGB(90, 90, 90),
})
corner(bar, 1)
self.bars[i] = { inst = bar, maxH = maxH }
end
local IDLE_COLOR = Color3.fromRGB(90, 90, 90)
local RED = Color3.fromRGB(240, 70, 70)
local YELLOW = Color3.fromRGB(240, 190, 60)
local GREEN = Color3.fromRGB(70, 210, 110)
local statsService = game:GetService("Stats")
local lastCheck, ping = 0, 0
local TIERS = {
{ maxPing = 60, ratio = 1, color = GREEN },
{ maxPing = 120, ratio = 0.75, color = GREEN },
{ maxPing = 200, ratio = 0.5, color = YELLOW },
{ maxPing = math.huge, ratio = 0.25, color = RED },
}
self.conn = RunService.RenderStepped:Connect(function()
if not self.active then
return
end
local now = os.clock()
if now - lastCheck > 1 then
lastCheck = now
local ok, p = pcall(function()
return statsService.Network.ServerStatsItem["Data Ping"]:GetValue()
end)
ping = (ok and type(p) == "number") and p or ping
end
local lit, color = 0, IDLE_COLOR
if ping > 0 then
for _, tier in ipairs(TIERS) do
if ping <= tier.maxPing then
lit = math.max(1, math.ceil(tier.ratio * #self.bars))
color = tier.color
break
end
end
end
for i, bar in ipairs(self.bars) do
local on = i <= lit
local targetColor = on and color or IDLE_COLOR
local targetTransparency = on and 0 or 0.55
bar.inst.BackgroundColor3 = bar.inst.BackgroundColor3:Lerp(targetColor, 0.35)
bar.inst.BackgroundTransparency = bar.inst.BackgroundTransparency
+ (targetTransparency - bar.inst.BackgroundTransparency) * 0.35
end
end)
return self
end
function Visualizer:SetActive(state)
self.active = state and true or false
end
function Visualizer:Destroy()
if self.conn then
self.conn:Disconnect()
end
self.frame:Destroy()
end
local CTRL_W, CTRL_H, CTRL_R, ROW_H = 160, 30, 15, 56
function S.setClick(v)
clickSoundEnabled = v
end
function S.getClick()
return clickSoundEnabled
end
S.track = track
S.new = new
S.corner = corner
S.stroke = stroke
S.shine = shine
S.ledBackdrop = ledBackdrop
S.glass = glass
S.glassHover = glassHover
S.pad = pad
S.list = list
S.tween = tween
S.hoverable = hoverable
S.playClickSound = playClickSound
S.ripple = ripple
S.iconLabel = iconLabel
S.iconButton = iconButton
S.makeScreenGui = makeScreenGui
S.clampedPosition = clampedPosition
S.makeDraggable = makeDraggable
S.Visualizer = Visualizer
S.CTRL_W = CTRL_W
S.CTRL_H = CTRL_H
S.CTRL_R = CTRL_R
S.ROW_H = ROW_H
include("Models/Library/Elements.lua")
include("Models/Library/Advanced.lua")
include("Models/Library/Window.lua")
include("Models/Library/Extras.lua")
return Native.setmetatable({}, {
__index = Ui,
__newindex = function(_, k, v)
if k == "Name" or k == "Logo" then
flag("write rejected: " .. Native.tostring(k))
return
end
Ui[k] = v
end,
__metatable = "locked",
})
