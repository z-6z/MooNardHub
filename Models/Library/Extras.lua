local UiCtx__ = (getgenv and getgenv() or _G).UiCtx
local Ui, S = UiCtx__.Ui, UiCtx__.S
local UserInputService, RunService = S.UserInputService, S.RunService
local track, new, corner, stroke, glass, pad, list, tween = S.track, S.new, S.corner, S.stroke, S.glass, S.pad, S.list, S.tween
local iconLabel, Section, Window = S.iconLabel, S.Section, S.Window
function Section:CreateParagraph(opt)
opt = opt or {}
if type(opt) == "string" then
opt = { Content = opt }
end
local holder = new("Frame", {
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
BackgroundTransparency = 1,
LayoutOrder = self:_next(),
Parent = self.body,
})
local line = new("Frame", {
Size = UDim2.new(1, -20, 0, 1),
Position = UDim2.new(0, 10, 0, 0),
BorderSizePixel = 0,
Parent = holder,
Theme = {
BackgroundColor3 = "Stroke",
},
})
line.Visible = self._count > 1
local inner = new("Frame", {
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
BackgroundTransparency = 1,
Parent = holder,
})
pad(inner, 14, 14, 12, 12)
list(inner, Enum.FillDirection.Vertical, 4)
local title = new("TextLabel", {
Text = opt.Title or opt.Name or "",
Font = Enum.Font.GothamBold,
TextSize = 13,
TextXAlignment = Enum.TextXAlignment.Left,
TextWrapped = true,
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
LayoutOrder = 1,
Parent = inner,
Theme = {
TextColor3 = "Text",
},
})
title.Visible = title.Text ~= ""
local body = new("TextLabel", {
Text = opt.Content or opt.Text or "",
Font = Enum.Font.Gotham,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Left,
TextYAlignment = Enum.TextYAlignment.Top,
TextWrapped = true,
RichText = opt.RichText ~= false,
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
LayoutOrder = 2,
Parent = inner,
Theme = {
TextColor3 = "SubText",
},
})
holder:SetAttribute("SearchText", string.lower(title.Text .. " " .. body.Text))
local api = { Instance = holder }
function api:SetTitle(t)
title.Text = tostring(t or "")
title.Visible = title.Text ~= ""
end
function api:SetContent(t)
body.Text = tostring(t or "")
end
function api:Get()
return body.Text
end
function api:Set(t)
api:SetContent(t)
end
return api
end
function Section:CreateCodeBlock(opt)
opt = opt or {}
if type(opt) == "string" then
opt = { Code = opt }
end
local code = tostring(opt.Code or opt.Content or "")
local raw = code
local highlight = opt.Highlight ~= false
local holder = new("Frame", {
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
BorderSizePixel = 0,
LayoutOrder = self:_next(),
Parent = self.body,
})
corner(holder, 12)
glass(holder)
local header = new("Frame", {
Size = UDim2.new(1, 0, 0, 34),
BackgroundTransparency = 1,
Parent = holder,
})
new("TextLabel", {
Text = opt.Title or opt.Name or opt.Language or "Code",
Font = Enum.Font.GothamBold,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
BackgroundTransparency = 1,
Position = UDim2.new(0, 14, 0, 0),
Size = UDim2.new(1, -100, 1, 0),
Parent = header,
Theme = {
TextColor3 = "SubText",
},
})
local copyBtn = new("TextButton", {
Text = "Copy",
Font = Enum.Font.GothamMedium,
TextSize = 11,
AutoButtonColor = false,
BorderSizePixel = 0,
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -10, 0.5, 0),
Size = UDim2.new(0, 64, 0, 22),
Parent = header,
Theme = {
BackgroundColor3 = "Elevated",
TextColor3 = "Text",
},
})
corner(copyBtn, 11)
stroke(copyBtn)
local sep = new("Frame", {
Size = UDim2.new(1, -20, 0, 1),
Position = UDim2.new(0, 10, 0, 34),
BorderSizePixel = 0,
Parent = holder,
Theme = {
BackgroundColor3 = "Stroke",
},
})
sep.Name = "Separator"
local scroller = new("ScrollingFrame", {
Size = UDim2.new(1, -24, 0, 0),
Position = UDim2.new(0, 12, 0, 42),
BackgroundTransparency = 1,
BorderSizePixel = 0,
CanvasSize = UDim2.new(),
AutomaticCanvasSize = Enum.AutomaticSize.XY,
ScrollBarThickness = 3,
ScrollBarImageTransparency = 0.5,
ScrollingDirection = Enum.ScrollingDirection.XY,
Parent = holder,
})
local label = new("TextLabel", {
Text = "",
RichText = true,
Font = Enum.Font.Code,
TextSize = 13,
TextWrapped = opt.Wrap == true,
TextXAlignment = Enum.TextXAlignment.Left,
TextYAlignment = Enum.TextYAlignment.Top,
BackgroundTransparency = 1,
Size = UDim2.new(opt.Wrap == true and 1 or 0, 0, 0, 0),
AutomaticSize = opt.Wrap == true and Enum.AutomaticSize.Y or Enum.AutomaticSize.XY,
Parent = scroller,
Theme = {
TextColor3 = "Text",
},
})
local function render()
if highlight and #raw <= Ui.Syntax.MaxLength then
local ok, rich = pcall(Ui.Syntax.Highlight, raw)
if ok then
label.RichText = true
label.Text = rich
return
end
end
label.RichText = false
label.Text = raw
end
render()
Ui.Syntax.OnColorsChanged(render)
local maxH = opt.MaxHeight or 220
new("Frame", {
Size = UDim2.new(1, 0, 0, 10),
BackgroundTransparency = 1,
Position = UDim2.new(0, 0, 0, 0),
Parent = holder,
}).Name = "BottomPad"
local function resize()
local h = math.min(label.AbsoluteSize.Y + 6, maxH)
scroller.Size = UDim2.new(1, -24, 0, math.max(h, 20))
holder.AutomaticSize = Enum.AutomaticSize.None
holder.Size = UDim2.new(1, 0, 0, 42 + scroller.Size.Y.Offset + 10)
end
label:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
task.defer(resize)
copyBtn.MouseButton1Click:Connect(function()
local ok = false
if setclipboard then
ok = pcall(setclipboard, raw)
elseif toclipboard then
ok = pcall(toclipboard, raw)
end
copyBtn.Text = ok and "Copied" or "Failed"
task.delay(1.2, function()
if copyBtn.Parent then
copyBtn.Text = "Copy"
end
end)
if opt.Callback then
task.spawn(opt.Callback, raw)
end
end)
holder:SetAttribute("SearchText", string.lower(tostring(opt.Title or opt.Name or "") .. " " .. code))
local api = { Instance = holder, Label = label }
function api:Get()
return raw
end
function api:Set(v)
raw = tostring(v or "")
render()
task.defer(resize)
end
return api
end
local HttpService = game:GetService("HttpService")
local CONFIG_FOLDER = "MooNard Hub"
local CONFIG_FILE = CONFIG_FOLDER .. "/Config.json"
local ConfigData = {}
local saveQueued = false
local function canFiles()
return typeof(writefile) == "function" and typeof(readfile) == "function"
end
local function encodeValue(v)
local t = typeof(v)
if t == "Color3" then
return { __t = "Color3", r = v.R, g = v.G, b = v.B }
elseif t == "EnumItem" then
return { __t = "Enum", e = tostring(v.EnumType), n = v.Name }
end
return v
end
local function decodeValue(v)
if type(v) == "table" and v.__t == "Color3" then
return Color3.new(v.r, v.g, v.b)
elseif type(v) == "table" and v.__t == "Enum" then
local ok, item = pcall(function() return Enum[v.e][v.n] end)
return ok and item or nil
end
return v
end
local function loadConfig()
if not canFiles() then
return
end
local ok, data = pcall(function()
if typeof(isfile) == "function" and not isfile(CONFIG_FILE) then
return nil
end
return HttpService:JSONDecode(readfile(CONFIG_FILE))
end)
if ok and type(data) == "table" then ConfigData = data end
S.setClick(ConfigData.ClickSound ~= false)
end
local function saveConfig()
if not canFiles() or saveQueued then
return
end
saveQueued = true
task.delay(0.5, function()
saveQueued = false
pcall(function()
if typeof(isfolder) == "function" and typeof(makefolder) == "function" and not isfolder(CONFIG_FOLDER) then
makefolder(CONFIG_FOLDER)
end
writefile(CONFIG_FILE, HttpService:JSONEncode(ConfigData))
end)
end)
end
loadConfig()
ConfigData.Flags = type(ConfigData.Flags) == "table" and ConfigData.Flags or {}
Ui.ConfigVersion = 1
local function applyConfigVersion(version, migrate)
version = tonumber(version) or 1
local old = tonumber(ConfigData.ConfigVersion)
if old == nil then
ConfigData.ConfigVersion = version
saveConfig()
return
end
if old == version then
return
end
local flags = ConfigData.Flags or {}
local result
if type(migrate) == "function" then
local ok, res = pcall(migrate, old, version, flags)
if ok then
result = type(res) == "table" and res or flags
end
end
ConfigData.Flags = result or {}
ConfigData.ConfigVersion = version
saveConfig()
end
applyConfigVersion(Ui.ConfigVersion)
function Ui:SetConfigVersion(version, migrate)
Ui.ConfigVersion = tonumber(version) or 1
applyConfigVersion(Ui.ConfigVersion, migrate)
end
function Ui:GetConfigVersion()
return tonumber(ConfigData.ConfigVersion) or Ui.ConfigVersion
end
function Ui:ResetConfig()
ConfigData.Flags = {}
ConfigData.ConfigVersion = Ui.ConfigVersion
saveConfig()
end
local function setFlag(key, value)
ConfigData.Flags[key] = encodeValue(value)
saveConfig()
end
local function wrapElement(method, cbName)
local original = Section[method]
if not original then
return
end
Section[method] = function(self, opt)
opt = opt or {}
local key = opt.Flag or (opt.Name and (method .. ":" .. tostring(opt.Name)))
if key and opt.Save ~= false then
local saved = ConfigData.Flags[key]
if saved ~= nil then
local value = decodeValue(saved)
if value ~= nil then opt.Default = value end
end
local userCb = opt[cbName]
opt[cbName] = function(...)
setFlag(key, (...))
if userCb then
return userCb(...)
end
end
end
return original(self, opt)
end
end
wrapElement("CreateToggle", "Callback")
wrapElement("CreateCheckbox", "Callback")
wrapElement("CreateSlider", "Callback")
wrapElement("CreateInput", "Callback")
wrapElement("CreateDropdown", "Callback")
wrapElement("CreateMultiDropdown", "Callback")
wrapElement("CreateColorPicker", "Callback")
wrapElement("CreateKeybind", "Changed")
local originalSelectTab = Window.SelectTab
function Window:SelectTab(id)
originalSelectTab(self, id)
if self._restoringTab == nil or self._restoringTab == false then
ConfigData.LastTab = id
saveConfig()
end
end
local originalCreateTab = Window.CreateTab
function Window:CreateTab(cfg)
local tab = originalCreateTab(self, cfg)
local id = self.tabCount
if ConfigData.LastTab == id then
task.defer(function()
if self.tabs and self.tabs[id] then
self:SelectTab(id)
end
end)
end
return tab
end
local NOTIFY_SOUNDS = {
Info = "rbxassetid://6026984224",
Success = "rbxassetid://6026984224",
Warning = "rbxassetid://6026984224",
Error = "rbxassetid://6026984224",
}
local NOTIFY_PITCH = {
Info = 1,
Success = 1.2,
Warning = 0.9,
Error = 0.7,
}
function Ui:SetNotifySounds(map)
for kind, v in pairs(map or {}) do
local id, pitch = v, nil
if type(v) == "table" then
id, pitch = v.Id, v.Pitch
end
local digits = id and tostring(id):match("%d+")
if digits then
NOTIFY_SOUNDS[kind] = "rbxassetid://" .. digits
end
if tonumber(pitch) then
NOTIFY_PITCH[kind] = tonumber(pitch)
end
end
end
local originalNotify = Window.Notify
function Window:Notify(cfg)
cfg = cfg or {}
if cfg.Sound ~= false and ConfigData.NotifySound ~= false then
pcall(function()
local kind = cfg.Type or "Info"
local s = Instance.new("Sound")
s.SoundId = type(cfg.Sound) == "string" and cfg.Sound or NOTIFY_SOUNDS[kind] or NOTIFY_SOUNDS.Info
s.PlaybackSpeed = NOTIFY_PITCH[kind] or 1
s.Volume = tonumber(cfg.Volume) or 0.5
s.Parent = game:GetService("SoundService")
s:Play()
s.Ended:Connect(function() s:Destroy() end)
task.delay(5, function() if s.Parent then s:Destroy() end end)
end)
end
return originalNotify(self, cfg)
end
function Ui:SetNotifySound(on)
ConfigData.NotifySound = on and true or false
saveConfig()
end
function Ui:GetNotifySound()
return ConfigData.NotifySound ~= false
end
function Ui:SetClickSound(on)
S.setClick(on and true or false)
ConfigData.ClickSound = S.getClick()
saveConfig()
end
function Ui:GetClickSound()
return S.getClick()
end
function Ui:SaveConfig()
saveConfig()
end
function Section:CreateConsole(opt)
opt = opt or {}
local maxLines = opt.MaxLines or 300
local lines = {}
local levelFilter = 1
local paused = false
local dirty = false
local KIND = {
Output = { level = 1, color = nil },
Info = { level = 1, color = "#6cb6ff" },
Warning = { level = 2, color = "#ffd60a" },
Error = { level = 3, color = "#ff6b6b" },
}
local ESC = { ["&"] = "&amp;", ["<"] = "&lt;", [">"] = "&gt;", ['"'] = "&quot;", ["'"] = "&apos;" }
local holder = new("Frame", {
Size = UDim2.new(1, 0, 0, opt.Height or 200),
BorderSizePixel = 0,
LayoutOrder = self:_next(),
Parent = self.body,
})
corner(holder, 12)
glass(holder)
local scroller = new("ScrollingFrame", {
Size = UDim2.new(1, -24, 1, -20),
Position = UDim2.new(0, 12, 0, 10),
BackgroundTransparency = 1,
BorderSizePixel = 0,
Active = true,
CanvasSize = UDim2.new(),
AutomaticCanvasSize = Enum.AutomaticSize.XY,
ScrollBarThickness = 3,
ScrollBarImageTransparency = 0.5,
ScrollingDirection = Enum.ScrollingDirection.XY,
Parent = holder,
})
local label = new("TextLabel", {
Text = "",
RichText = true,
Font = Enum.Font.Code,
TextSize = 12,
TextWrapped = false,
TextXAlignment = Enum.TextXAlignment.Left,
TextYAlignment = Enum.TextYAlignment.Top,
BackgroundTransparency = 1,
Size = UDim2.new(0, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.XY,
Parent = scroller,
Theme = {
TextColor3 = "Text",
},
})
local function toBottom()
if paused then
return
end
scroller.CanvasPosition = Vector2.new(0, math.max(0, scroller.AbsoluteCanvasSize.Y - scroller.AbsoluteWindowSize.Y))
end
label:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
task.defer(toBottom)
end)
local function render()
dirty = false
local out = {}
for _, l in ipairs(lines) do
if l.level >= levelFilter then
local text = tostring(l.text):gsub("[&<>\"']", ESC)
local line = '<font color="#8c8c8c">' .. l.time .. "</font>  " .. text
local c = KIND[l.kind] and KIND[l.kind].color
if c then
line = '<font color="#8c8c8c">' .. l.time .. '</font>  <font color="' .. c .. '">' .. text .. "</font>"
end
out[#out + 1] = line
end
end
if #out == 0 then
label.Text = '<font color="#8c8c8c">Console is empty. Output from print, warn and error appears here.</font>'
else
label.Text = table.concat(out, "\n")
end
end
local function queue()
if not dirty then
dirty = true
task.defer(render)
end
end
local api = { Instance = holder, Label = label, Scroller = scroller }
function api:Log(text, kind)
kind = KIND[kind] and kind or "Output"
lines[#lines + 1] = {
time = os.date("%H:%M:%S"),
text = tostring(text),
kind = kind,
level = KIND[kind].level,
}
if #lines > maxLines then
table.remove(lines, 1)
end
queue()
end
function api:Clear()
lines = {}
queue()
end
function api:Get()
local out = {}
for _, l in ipairs(lines) do
if l.level >= levelFilter then
out[#out + 1] = "[" .. l.time .. "] " .. l.text
end
end
return table.concat(out, "\n")
end
function api:SetFilter(level)
levelFilter = level == "Errors" and 3 or (level == "Warnings" and 2 or 1)
queue()
end
function api:SetPaused(state)
paused = state and true or false
if not paused then
task.defer(toBottom)
end
end
function api:IsPaused()
return paused
end
render()
return api
end
Ui.Music = {
Songs = {
{ Name = "Arcade Weekend", Id = 1842976958, Category = "Upbeat" },
{ Name = "Collider", Id = 1841905171, Category = "Upbeat" },
{ Name = "Crystal Clear", Id = 1837848642, Category = "Upbeat" },
{ Name = "Night Vision", Id = 1837849285, Category = "Upbeat" },
{ Name = "Shooting Star", Id = 1840044242, Category = "Upbeat" },
{ Name = "Happy Song", Id = 1843404009, Category = "Upbeat" },
{ Name = "Crab Rave", Id = 5410086218, Category = "Popular" },
{ Name = "Sandstorm", Id = 166562385, Category = "Popular" },
{ Name = "PLAY", Id = 5410085763, Category = "Popular" },
{ Name = "Lo-Fi Chill", Id = 9043887091, Category = "Chill" },
{ Name = "Sunset Chill", Id = 9046862941, Category = "Chill" },
{ Name = "Smooth Jazz", Id = 1845341094, Category = "Chill" },
{ Name = "Claire De Lune", Id = 1838457617, Category = "Chill" },
{ Name = "Sad End (Solo Piano)", Id = 1838635121, Category = "Chill" },
{ Name = "Dreamstate", Id = 5410083912, Category = "Ambient" },
{ Name = "Rain on Leaves", Id = 9112854440, Category = "Ambient" },
},
Current = nil,
Volume = 0.5,
Looped = false,
Speed = 1,
Listeners = {},
SongListeners = {},
}
do
local Music = Ui.Music
local SoundService = game:GetService("SoundService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local nameCache = {}
local sound = Instance.new("Sound")
sound.Name = "UiMusic"
sound.Volume = Music.Volume
sound.Parent = SoundService
local function fire()
for _, fn in ipairs(Music.Listeners) do
task.spawn(fn, Music.Current)
end
end
local function fireSongs()
for _, fn in ipairs(Music.SongListeners) do
task.spawn(fn, Music.Songs)
end
end
local function resolveName(id, callback)
if nameCache[id] then
callback(nameCache[id])
return
end
task.spawn(function()
local ok, info = pcall(function()
return MarketplaceService:GetProductInfo(id)
end)
local name = ok and info and info.Name or ("Audio " .. id)
nameCache[id] = name
callback(name)
end)
end
function Music:OnChanged(fn)
table.insert(self.Listeners, fn)
end
function Music:OnSongsChanged(fn)
table.insert(self.SongListeners, fn)
end
function Music:Play(target, name)
local id, label
if type(target) == "table" then
id, label = tonumber(target.Id), target.Name
else
id, label = tonumber(tostring(target or ""):match("%d+")), name
end
if not id then
return false
end
sound:Stop()
sound.SoundId = "rbxassetid://" .. id
sound.Volume = self.Volume
sound.Looped = self.Looped
sound.PlaybackSpeed = self.Speed
sound.TimePosition = 0
local current = { Id = id, Name = label or nameCache[id] or ("Audio " .. id), Loading = true, Failed = false }
self.Current = current
fire()
sound:Play()
task.spawn(function()
local started = os.clock()
while self.Current == current and not sound.IsLoaded and os.clock() - started < 8 do
task.wait(0.1)
end
if self.Current ~= current then
return
end
current.Loading = false
if not (sound.IsLoaded and sound.TimeLength > 0) then
current.Failed = true
sound:Stop()
end
fire()
end)
if not label then
resolveName(id, function(resolved)
if self.Current == current then
current.Name = resolved
fire()
end
end)
end
return true
end
function Music:Toggle()
local current = self.Current
if not current then
return false
end
if current.Failed then
return self:Play(current.Id, current.Name)
end
if sound.IsPlaying then
sound:Pause()
elseif sound.IsPaused then
sound:Resume()
else
sound.TimePosition = 0
sound:Play()
end
fire()
return true
end
function Music:Pause()
sound:Pause()
fire()
end
function Music:Resume()
if self.Current and not self.Current.Failed then
sound:Resume()
fire()
end
end
function Music:Stop()
sound:Stop()
fire()
end
function Music:Restart()
local current = self.Current
if not current then
return false
end
if current.Failed then
return self:Play(current.Id, current.Name)
end
sound.TimePosition = 0
if not sound.IsPlaying then
sound:Play()
end
fire()
return true
end
function Music:Seek(seconds)
if sound.TimeLength > 0 then
sound.TimePosition = math.clamp(tonumber(seconds) or 0, 0, sound.TimeLength)
end
end
function Music:SetVolume(value)
self.Volume = math.clamp(tonumber(value) or 0, 0, 1)
sound.Volume = self.Volume
end
function Music:SetLooped(state)
self.Looped = state and true or false
sound.Looped = self.Looped
end
function Music:SetSpeed(value)
self.Speed = math.clamp(tonumber(value) or 1, 0.25, 4)
sound.PlaybackSpeed = self.Speed
end
function Music:GetTime()
return sound.TimePosition, sound.TimeLength
end
function Music:IsPlaying()
return sound.IsPlaying
end
function Music:GetSongs()
return self.Songs
end
function Music:AddSong(name, id, category)
id = tonumber(tostring(id or ""):match("%d+"))
if not id then
return false
end
table.insert(self.Songs, { Name = tostring(name or ("Audio " .. id)), Id = id, Category = category or "Custom" })
fireSongs()
return true
end
function Music:SetSongs(songs)
self.Songs = type(songs) == "table" and songs or {}
fireSongs()
end
function Music:GetSound()
return sound
end
local function formatTime(seconds)
seconds = math.max(0, math.floor(seconds))
return string.format("%d:%02d", seconds // 60, seconds % 60)
end
function Window:CreateMusicMenu(tab)
local window = self
local player = tab:CreateSection("Player")
player:CreateInput({
Name = "Sound ID",
Description = "Paste an audio ID and press Enter",
Icon = "music",
Placeholder = "1842976958",
Save = false,
Callback = function(value)
if value and value ~= "" and not Music:Play(value) then
window:Notify({ Title = "Music", Content = "Enter a valid sound ID", Type = "Warning" })
end
end,
})
local card = new("Frame", {
Size = UDim2.new(1, 0, 0, 108),
BackgroundTransparency = 1,
LayoutOrder = player:_next(),
Parent = player.body,
})
local title = new("TextLabel", {
Text = "Nothing playing",
Font = Enum.Font.GothamBold,
TextSize = 13,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
BackgroundTransparency = 1,
Position = UDim2.new(0, 14, 0, 10),
Size = UDim2.new(1, -28, 0, 18),
Parent = card,
Theme = {
TextColor3 = "Text",
},
})
local subtitle = new("TextLabel", {
Text = "Enter a sound ID or pick a ready song",
Font = Enum.Font.Gotham,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
BackgroundTransparency = 1,
Position = UDim2.new(0, 14, 0, 29),
Size = UDim2.new(1, -28, 0, 14),
Parent = card,
Theme = {
TextColor3 = "SubText",
},
})
local function sideButton(icon, position)
local button = new("TextButton", {
Text = "",
AutoButtonColor = false,
BorderSizePixel = 0,
Position = position,
Size = UDim2.new(0, 30, 0, 30),
Parent = card,
Theme = {
BackgroundColor3 = "Elevated",
},
})
corner(button, 8)
stroke(button)
local glyph = iconLabel({
Icon = icon,
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.new(0.5, 0, 0.5, 0),
Size = UDim2.new(0, 15, 0, 15),
Parent = button,
Theme = {
ImageColor3 = "Text",
},
})
button.MouseEnter:Connect(function()
tween(button, 0.12, { BackgroundTransparency = 0.25 })
end)
button.MouseLeave:Connect(function()
tween(button, 0.15, { BackgroundTransparency = 0 })
end)
return button, glyph
end
local restart = sideButton("rotate-ccw", UDim2.new(0, 14, 0, 52))
local toggle, toggleIcon = sideButton("play", UDim2.new(1, -44, 0, 52))
local hit = new("TextButton", {
Text = "",
AutoButtonColor = false,
BackgroundTransparency = 1,
Position = UDim2.new(0, 54, 0, 52),
Size = UDim2.new(1, -108, 0, 30),
Parent = card,
})
local track = new("Frame", {
Position = UDim2.new(0, 0, 0.5, -3),
Size = UDim2.new(1, 0, 0, 6),
BorderSizePixel = 0,
Parent = hit,
Theme = {
BackgroundColor3 = "Elevated",
},
})
corner(track, 3)
stroke(track)
local fill = new("Frame", {
Size = UDim2.new(0, 0, 1, 0),
BorderSizePixel = 0,
Parent = track,
Theme = {
BackgroundColor3 = "Accent",
},
})
corner(fill, 3)
local knob = new("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.new(0, 0, 0.5, 0),
Size = UDim2.new(0, 12, 0, 12),
BorderSizePixel = 0,
ZIndex = 2,
Parent = track,
Theme = {
BackgroundColor3 = "Accent",
},
})
corner(knob, 6)
local elapsed = new("TextLabel", {
Text = "0:00",
Font = Enum.Font.Gotham,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
Position = UDim2.new(0, 54, 0, 86),
Size = UDim2.new(0, 60, 0, 14),
Parent = card,
Theme = {
TextColor3 = "Dim",
},
})
local total = new("TextLabel", {
Text = "0:00",
Font = Enum.Font.Gotham,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Right,
BackgroundTransparency = 1,
AnchorPoint = Vector2.new(1, 0),
Position = UDim2.new(1, -54, 0, 86),
Size = UDim2.new(0, 60, 0, 14),
Parent = card,
Theme = {
TextColor3 = "Dim",
},
})
local dragging = false
local function seekFromX(x)
local width = hit.AbsoluteSize.X
if width <= 0 then
return
end
local alpha = math.clamp((x - hit.AbsolutePosition.X) / width, 0, 1)
local _, length = Music:GetTime()
Music:Seek(alpha * length)
end
hit.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
seekFromX(input.Position.X)
end
end)
local changedConn = UserInputService.InputChanged:Connect(function(input)
if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
seekFromX(input.Position.X)
end
end)
local endedConn = UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = false
end
end)
local lastPlaying, lastElapsed, lastTotal = nil, "", ""
local stepConn = RunService.Heartbeat:Connect(function()
local position, length = Music:GetTime()
local alpha = length > 0 and math.clamp(position / length, 0, 1) or 0
fill.Size = UDim2.new(alpha, 0, 1, 0)
knob.Position = UDim2.new(alpha, 0, 0.5, 0)
local e, t = formatTime(position), formatTime(length)
if e ~= lastElapsed then
lastElapsed = e
elapsed.Text = e
end
if t ~= lastTotal then
lastTotal = t
total.Text = t
end
local playing = Music:IsPlaying()
if playing ~= lastPlaying then
lastPlaying = playing
Ui:SetIcon(toggleIcon, playing and "pause" or "play")
end
end)
card.Destroying:Connect(function()
changedConn:Disconnect()
endedConn:Disconnect()
stepConn:Disconnect()
end)
restart.MouseButton1Click:Connect(function()
if not Music:Restart() then
window:Notify({ Title = "Music", Content = "Pick a song first", Type = "Warning" })
end
end)
toggle.MouseButton1Click:Connect(function()
if not Music:Toggle() then
window:Notify({ Title = "Music", Content = "Pick a song first", Type = "Warning" })
end
end)
Music:OnChanged(function(current)
if not card.Parent then
return
end
if not current then
title.Text = "Nothing playing"
subtitle.Text = "Enter a sound ID or pick a ready song"
return
end
title.Text = current.Name
if current.Loading then
subtitle.Text = "Loading..."
elseif current.Failed then
subtitle.Text = "Could not load this sound. It may be private or removed"
else
subtitle.Text = "ID: " .. current.Id
end
end)
local options = tab:CreateSection("Options")
options:CreateSlider({
Name = "Music Volume",
Icon = "volume-2",
Min = 0,
Max = 100,
Default = math.floor(Music.Volume * 100),
Suffix = "%",
Save = false,
Callback = function(value)
Music:SetVolume(value / 100)
end,
})
options:CreateSlider({
Name = "Music Speed",
Icon = "gauge",
Min = 0.5,
Max = 2,
Default = Music.Speed,
Decimals = 1,
Suffix = "x",
Save = false,
Callback = function(value)
Music:SetSpeed(value)
end,
})
options:CreateToggle({
Name = "Music Loop",
Description = "Repeat the current sound",
Icon = "repeat",
Default = Music.Looped,
Save = false,
Callback = function(value)
Music:SetLooped(value)
end,
})
local library = tab:CreateGroup("Ready Songs")
local grid
local function build()
if grid then
grid.Instance:Destroy()
end
local cards = {}
for _, song in ipairs(Music.Songs) do
table.insert(cards, {
Name = song.Name,
Description = (song.Category or "Custom") .. "  •  " .. song.Id,
Icon = "music",
Callback = function()
Music:Play(song)
end,
})
end
if #cards == 0 then
table.insert(cards, { Name = "No songs", Description = "Use Ui:AddSong(name, id)", Icon = "list-music" })
end
grid = library:CreateCardsGlass({ Columns = 2, CardHeight = 66, Cards = cards })
end
Music:OnSongsChanged(function()
if card.Parent then
build()
end
end)
build()
return { Player = player, Options = options, Songs = library }
end
function Window:CreateMusicTab(cfg)
cfg = cfg or {}
local tab = self:CreateTab({ Name = cfg.Name or "Music", Icon = cfg.Icon or "music" })
self:CreateMusicMenu(tab)
return tab
end
function Ui:AddSong(name, id, category)
return Music:AddSong(name, id, category)
end
function Ui:SetSongs(songs)
Music:SetSongs(songs)
end
function Ui:PlaySong(target, name)
return Music:Play(target, name)
end
end
