local UiCtx__ = (getgenv and getgenv() or _G).UiCtx
local Ui, S = UiCtx__.Ui, UiCtx__.S
local UserInputService = S.UserInputService
local new, corner, stroke, glass, glassHover, pad, list, tween = S.new, S.corner, S.stroke, S.glass, S.glassHover, S.pad, S.list, S.tween
local ripple, iconLabel, CTRL_W, CTRL_H, CTRL_R, ROW_H = S.ripple, S.iconLabel, S.CTRL_W, S.CTRL_H, S.CTRL_R, S.ROW_H
local Section = {}
Section.__index = Section
local function rowBase(section, height)
local row = new("Frame", {
Size = UDim2.new(1, 0, 0, height or 58),
BackgroundTransparency = 1,
LayoutOrder = section:_next(),
Parent = section.body,
})
local line = new("Frame", {
Size = UDim2.new(1, -20, 0, 1),
Position = UDim2.new(0, 10, 0, 0),
BorderSizePixel = 0,
Parent = row,
Theme = {
BackgroundColor3 = "Stroke",
},
})
line.Visible = section._count > 1
return row
end
local function rowLabel(row, icon, title, desc, rightW)
local x = 14
local rw = rightW or (CTRL_W + 24)
if icon then
iconLabel({
Icon = icon,
Size = UDim2.new(0, 20, 0, 20),
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, x, 0.5, 0),
Parent = row,
Theme = {
ImageColor3 = "SubText",
},
})
x = x + 32
end
local hasDesc = desc and desc ~= ""
new("TextLabel", {
Text = title,
Font = Enum.Font.GothamBold,
TextSize = 13,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
TextTruncate = Enum.TextTruncate.AtEnd,
Position = UDim2.new(0, x, 0, hasDesc and 12 or 0),
Size = UDim2.new(1, -x - rw, 0, hasDesc and 18 or 0),
Parent = row,
Theme = {
TextColor3 = "Text",
},
}).Size = hasDesc
and UDim2.new(1, -x - rw, 0, 18)
or UDim2.new(1, -x - rw, 1, 0)
if hasDesc then
new("TextLabel", {
Text = desc,
Font = Enum.Font.Gotham,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
TextTruncate = Enum.TextTruncate.AtEnd,
Position = UDim2.new(0, x, 0, 31),
Size = UDim2.new(1, -x - rw, 0, 16),
Parent = row,
Theme = {
TextColor3 = "SubText",
},
})
end
row:SetAttribute("SearchText", string.lower(tostring(title or "") .. " " .. tostring(desc or "")))
return x
end
function Section:_next()
self._count = (self._count or 0) + 1
return self._count
end
function Section:CreateButton(opt)
opt = opt or {}
local row = rowBase(self, ROW_H)
rowLabel(row, opt.Icon, opt.Name or "Button", opt.Description)
local btn = new("TextButton", {
Text = opt.ButtonText or "Run",
Font = Enum.Font.GothamBold,
TextSize = 12,
AutoButtonColor = false,
BorderSizePixel = 0,
Size = UDim2.new(0, CTRL_W, 0, CTRL_H),
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -14, 0.5, 0),
Parent = row,
Theme = {
BackgroundColor3 = "Accent",
TextColor3 = "AccentText",
},
})
corner(btn, CTRL_R)
ripple(btn)
btn.MouseButton1Click:Connect(function()
if opt.Callback then
task.spawn(opt.Callback)
end
end)
return {
Instance = row,
Button = btn,
}
end
local function discordInviteCode(value)
local text = tostring(value or "")
local code = text:match("discord%.gg/([%w_-]+)") or text:match("discord%.com/invite/([%w_-]+)") or text:match("^([%w_-]+)$")
if code == "YOUR_INVITE_CODE" then
return nil
end
return code
end
local function discordImage(value, filename)
if not value or value == "" then
return ""
end
value = tostring(value)
if value:match("^%d+$") then
return "rbxassetid://" .. value
end
if value:match("^rbxasset") then
return value
end
if not value:match("^https://cdn%.discordapp%.com/") then
return ""
end
if not writefile or not getcustomasset then
return ""
end
local ok, result = pcall(function()
local data = game:HttpGet(value)
if type(data) ~= "string" or #data == 0 then
return ""
end
writefile(filename, data)
return getcustomasset(filename)
end)
return ok and result or ""
end
function Section:CreateDiscordInvite(opt)
opt = opt or {}
local row = rowBase(self, 262)
row.Name = "DiscordInvite"
local panel = new("Frame", {
Name = "Card",
Size = UDim2.new(1, -28, 1, -20),
Position = UDim2.new(0, 14, 0, 10),
BorderSizePixel = 0,
Parent = row,
})
corner(panel, 12)
glass(panel)
local banner = new("ImageLabel", {
Name = "ServerBanner",
Image = "",
Position = UDim2.new(0, 8, 0, 8),
Size = UDim2.new(1, -16, 0, 76),
BorderSizePixel = 0,
ScaleType = Enum.ScaleType.Crop,
Parent = panel,
Theme = { BackgroundColor3 = "Elevated" },
})
corner(banner, 10)
local sheen = new("Frame", {
Name = "Sheen",
Size = UDim2.new(1, 0, 1, 0),
BorderSizePixel = 0,
Parent = banner,
Theme = { BackgroundColor3 = "Accent" },
})
corner(sheen, 10)
new("UIGradient", {
Rotation = 90,
Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0.82),
NumberSequenceKeypoint.new(1, 1),
}),
Parent = sheen,
})
local chip = new("Frame", {
Name = "Chip",
Position = UDim2.new(0, 10, 0, 10),
Size = UDim2.new(0, 118, 0, 22),
BorderSizePixel = 0,
BackgroundTransparency = 0.15,
ZIndex = 2,
Parent = banner,
Theme = { BackgroundColor3 = "Panel" },
})
corner(chip, 11)
stroke(chip, "Stroke", 1).Transparency = 0.4
iconLabel({
Icon = "users",
Position = UDim2.new(0, 9, 0.5, -7),
Size = UDim2.new(0, 14, 0, 14),
ZIndex = 3,
Parent = chip,
Theme = { ImageColor3 = "Text" },
})
new("TextLabel", {
Text = "DISCORD INVITE",
Font = Enum.Font.GothamBold,
TextSize = 10,
BackgroundTransparency = 1,
Position = UDim2.new(0, 29, 0, 0),
Size = UDim2.new(1, -35, 1, 0),
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 3,
Parent = chip,
Theme = { TextColor3 = "Text" },
})
local ring = new("Frame", {
Name = "LogoRing",
Position = UDim2.new(0, 16, 0, 54),
Size = UDim2.new(0, 60, 0, 60),
BorderSizePixel = 0,
ZIndex = 2,
Parent = panel,
Theme = { BackgroundColor3 = "Panel" },
})
corner(ring, 16)
stroke(ring, "Stroke", 1).Transparency = 0.35
local logo = new("ImageLabel", {
Name = "ServerLogo",
Position = UDim2.new(0, 4, 0, 4),
Size = UDim2.new(1, -8, 1, -8),
BorderSizePixel = 0,
ScaleType = Enum.ScaleType.Crop,
Image = "",
ZIndex = 3,
Parent = ring,
Theme = { BackgroundColor3 = "Elevated" },
})
corner(logo, 12)
local fallback = iconLabel({
Icon = "users",
Size = UDim2.new(0, 22, 0, 22),
Position = UDim2.new(0.5, -11, 0.5, -11),
ZIndex = 4,
Parent = logo,
Theme = { ImageColor3 = "SubText" },
})
local name = new("TextLabel", {
Text = tostring(opt.Name or "Discord Server"),
Font = Enum.Font.GothamBold,
TextSize = 15,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
BackgroundTransparency = 1,
Position = UDim2.new(0, 88, 0, 90),
Size = UDim2.new(1, -104, 0, 20),
Parent = panel,
Theme = { TextColor3 = "Text" },
})
local subtitle = new("TextLabel", {
Text = tostring(opt.Description or "Discord community"),
Font = Enum.Font.Gotham,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
BackgroundTransparency = 1,
Position = UDim2.new(0, 88, 0, 111),
Size = UDim2.new(1, -104, 0, 16),
Parent = panel,
Theme = { TextColor3 = "SubText" },
})
local function pill(x, offset, icon, caption)
local p = new("Frame", {
Position = UDim2.new(x, offset, 0, 138),
Size = UDim2.new(0.5, -21, 0, 38),
BorderSizePixel = 0,
Parent = panel,
Theme = { BackgroundColor3 = "Elevated" },
})
corner(p, 10)
stroke(p, "Stroke", 1).Transparency = 0.5
iconLabel({
Icon = icon,
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 12, 0.5, 0),
Size = UDim2.new(0, 16, 0, 16),
Parent = p,
Theme = { ImageColor3 = "SubText" },
})
local value = new("TextLabel", {
Text = "--",
Font = Enum.Font.GothamBold,
TextSize = 13,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
BackgroundTransparency = 1,
Position = UDim2.new(0, 38, 0, 4),
Size = UDim2.new(1, -46, 0, 16),
Parent = p,
Theme = { TextColor3 = "Text" },
})
new("TextLabel", {
Text = caption,
Font = Enum.Font.Gotham,
TextSize = 10,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
Position = UDim2.new(0, 38, 0, 20),
Size = UDim2.new(1, -46, 0, 13),
Parent = p,
Theme = { TextColor3 = "Dim" },
})
return value
end
local membersValue = pill(0, 16, "users", "Members")
local onlineValue = pill(0.5, 5, "activity", "Online")
local button = new("TextButton", {
Text = opt.ButtonText or (opt.Callback and "Join Discord" or "Copy Invite"),
Font = Enum.Font.GothamBold,
TextSize = 12,
AutoButtonColor = false,
BorderSizePixel = 0,
Position = UDim2.new(0, 16, 0, 188),
Size = UDim2.new(1, -32, 0, 38),
Parent = panel,
Theme = { BackgroundColor3 = "Accent", TextColor3 = "AccentText" },
})
corner(button, 19)
ripple(button)
local code = discordInviteCode(opt.Invite or opt.Code)
local members, online = opt.Members, opt.Online
local api = { Instance = row, Button = button, Banner = banner, Logo = logo }
local revision = 0
local function fmt(v)
if type(v) ~= "number" then
return tostring(v or "--")
end
local s = tostring(math.floor(v))
local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
return (out:gsub("^,", ""))
end
local function renderStats()
membersValue.Text = fmt(members)
onlineValue.Text = fmt(online)
end
function api:SetCounts(memberCount, onlineCount)
members, online = memberCount, onlineCount
renderStats()
end
function api:Refresh()
revision = revision + 1
local current = revision
local invite = code
row:SetAttribute("SearchText", string.lower("discord invite " .. name.Text))
if not invite then
button.Text = "Set Discord Invite"
return
end
button.Text = opt.ButtonText or (opt.Callback and "Join Discord" or "Copy Invite")
if opt.AutoFetch == false then
return
end
task.spawn(function()
local ok, data = pcall(function()
return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://discord.com/api/v10/invites/" .. invite .. "?with_counts=true&with_expiration=true"))
end)
if not row.Parent or current ~= revision then
return
end
if not ok or type(data) ~= "table" or type(data.guild) ~= "table" then
subtitle.Text = "Server details unavailable"
return
end
local guild = data.guild
name.Text = tostring(guild.name or opt.Name or "Discord Server")
subtitle.Text = tostring(opt.Description or guild.description or "Discord community")
api:SetCounts(data.approximate_member_count or members, data.approximate_presence_count or online)
row:SetAttribute("SearchText", string.lower("discord invite " .. name.Text))
local prefix = "MooNardDiscord_" .. invite
if not opt.Logo and guild.icon and guild.id then
local image = discordImage("https://cdn.discordapp.com/icons/" .. guild.id .. "/" .. guild.icon .. ".png?size=128", prefix .. "_logo.png")
if row.Parent and current == revision then
logo.Image = image
fallback.Visible = image == ""
end
end
if not opt.Banner and (guild.banner or guild.splash) and guild.id then
local field = guild.banner and "banners" or "splashes"
local hash = guild.banner or guild.splash
local image = discordImage("https://cdn.discordapp.com/" .. field .. "/" .. guild.id .. "/" .. hash .. ".png?size=512", prefix .. "_banner.png")
if row.Parent and current == revision then
banner.Image = image
end
end
end)
end
function api:SetInvite(value)
code = discordInviteCode(value)
members, online = nil, nil
name.Text = tostring(opt.Name or "Discord Server")
subtitle.Text = tostring(opt.Description or "Discord community")
logo.Image = ""
banner.Image = ""
fallback.Visible = true
renderStats()
self:Refresh()
end
function api:Destroy()
revision = revision + 1
row:Destroy()
end
button.Activated:Connect(function()
if not code then
if self.window then self.window:Notify({ Title = "Discord Invite", Content = "Add a valid Discord invite code.", Type = "Warning" }) end
return
end
local url = "https://discord.gg/" .. code
if opt.Callback then
task.spawn(opt.Callback, url, api)
return
end
local copied = false
if setclipboard then copied = pcall(setclipboard, url) end
if self.window then
self.window:Notify({
Title = "Discord Invite",
Content = copied and "Invite copied to clipboard." or url,
Type = copied and "Success" or "Info",
Duration = copied and 3 or 0,
})
end
end)
renderStats()
if opt.Logo or opt.Banner then
task.spawn(function()
if opt.Logo then
local image = discordImage(opt.Logo, "MooNardDiscord_CustomLogo.png")
if row.Parent then
logo.Image = image
fallback.Visible = image == ""
end
end
if opt.Banner then
local image = discordImage(opt.Banner, "MooNardDiscord_CustomBanner.png")
if row.Parent then
banner.Image = image
end
end
end)
end
api:Refresh()
return api
end
Section.DiscordInvite = Section.CreateDiscordInvite
function Section:CreateToggle(opt)
opt = opt or {}
local state = opt.Default and true or false
local row = rowBase(self, ROW_H)
rowLabel(row, opt.Icon, opt.Name or "Toggle", opt.Description, 64)
local track_ = new("TextButton", {
Text = "",
AutoButtonColor = false,
BorderSizePixel = 0,
Size = UDim2.new(0, 46, 0, 26),
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -14, 0.5, 0),
Parent = row,
Theme = {
BackgroundColor3 = state and "Accent" or "TrackEmpty",
},
})
corner(track_, 13)
local knob = new("Frame", {
Size = UDim2.new(0, 20, 0, 20),
BorderSizePixel = 0,
AnchorPoint = Vector2.new(0, 0.5),
Position = state and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
Parent = track_,
Theme = {
BackgroundColor3 = state and "AccentText" or "Background",
},
})
corner(knob, 10)
local api = {}
function api:Set(v, silent)
state = v and true or false
tween(track_, 0.18, {
BackgroundColor3 = state and Ui.CurrentTheme.Accent or Ui.CurrentTheme.TrackEmpty,
})
tween(knob, 0.18, {
Position = state and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
BackgroundColor3 = state and Ui.CurrentTheme.AccentText or Ui.CurrentTheme.Background,
})
if not silent and opt.Callback then
task.spawn(opt.Callback, state)
end
end
function api:Get()
return state
end
track_.MouseButton1Click:Connect(function()
api:Set(not state)
end)
api.Instance = row
return api
end
function Section:CreateSlider(opt)
opt = opt or {}
local min, max = opt.Min or 0, opt.Max or 100
local value = math.clamp(opt.Default or min, min, max)
local suffix = opt.Suffix or ""
local row = rowBase(self, ROW_H)
rowLabel(row, opt.Icon, opt.Name or "Slider", opt.Description)
local valueLabel = new("TextLabel", {
Text = tostring(value) .. suffix,
Font = Enum.Font.Gotham,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Right,
BackgroundTransparency = 1,
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -14, 0.5, 0),
Size = UDim2.new(0, 42, 0, 16),
Parent = row,
Theme = {
TextColor3 = "SubText",
},
})
local bar = new("TextButton", {
Text = "",
AutoButtonColor = false,
BorderSizePixel = 0,
Size = UDim2.new(0, CTRL_W - 64, 0, 4),
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -64, 0.5, 0),
Parent = row,
Theme = {
BackgroundColor3 = "TrackEmpty",
},
})
corner(bar, 2)
local fill = new("Frame", {
Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
BorderSizePixel = 0,
Parent = bar,
Theme = {
BackgroundColor3 = "Accent",
},
})
corner(fill, 2)
local knob = new("Frame", {
Size = UDim2.new(0, 14, 0, 14),
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
BorderSizePixel = 0,
Parent = bar,
Theme = {
BackgroundColor3 = "Background",
},
})
corner(knob, 7)
stroke(knob, "Stroke", 1.5)
local api = {}
local function apply(alpha, silent)
alpha = math.clamp(alpha, 0, 1)
value = min + (max - min) * alpha
if not opt.Decimals or opt.Decimals == 0 then
value = math.floor(value + 0.5)
else
value = math.floor(value * 10 ^ opt.Decimals + 0.5) / 10 ^ opt.Decimals
end
local a = (value - min) / (max - min)
fill.Size = UDim2.new(a, 0, 1, 0)
knob.Position = UDim2.new(a, 0, 0.5, 0)
valueLabel.Text = tostring(value) .. suffix
if not silent and opt.Callback then
task.spawn(opt.Callback, value)
end
end
function api:Set(v, silent)
apply(((v - min) / (max - min)), silent)
end
function api:Get()
return value
end
local dragging = false
local function fromInput(input)
apply((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X)
end
bar.InputBegan:Connect(function(input)
if
input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
then
dragging = true
fromInput(input)
tween(knob, 0.1, {
Size = UDim2.new(0, 17, 0, 17),
})
end
end)
UserInputService.InputEnded:Connect(function(input)
if
input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
then
if dragging then
tween(knob, 0.1, {
Size = UDim2.new(0, 14, 0, 14),
})
end
dragging = false
end
end)
UserInputService.InputChanged:Connect(function(input)
if
dragging
and (
input.UserInputType == Enum.UserInputType.MouseMovement
or input.UserInputType == Enum.UserInputType.Touch
)
then
fromInput(input)
end
end)
api.Instance = row
return api
end
function Section:CreateInput(opt)
opt = opt or {}
local row = rowBase(self, ROW_H)
rowLabel(row, opt.Icon, opt.Name or "Input", opt.Description)
local box = new("Frame", {
Size = UDim2.new(0, CTRL_W, 0, CTRL_H),
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -14, 0.5, 0),
BorderSizePixel = 0,
Parent = row,
Theme = {
BackgroundColor3 = "Elevated",
},
})
corner(box, CTRL_R)
stroke(box)
box.ClipsDescendants = true
local tb = new("TextBox", {
Text = tostring(opt.Default or ""),
ClipsDescendants = true,
TextTruncate = Enum.TextTruncate.AtEnd,
PlaceholderText = opt.Placeholder or "Type here...",
Font = Enum.Font.Gotham,
TextSize = 12,
ClearTextOnFocus = false,
BackgroundTransparency = 1,
Size = UDim2.new(1, -24, 1, 0),
Position = UDim2.new(0, 12, 0, 0),
TextXAlignment = Enum.TextXAlignment.Left,
Parent = box,
Theme = {
TextColor3 = "Text",
PlaceholderColor3 = "Dim",
},
})
tb.FocusLost:Connect(function(enter)
if opt.Callback then
task.spawn(opt.Callback, tb.Text, enter)
end
end)
return {
Instance = row,
TextBox = tb,
Set = function(_, v, silent)
tb.Text = tostring(v or "")
if not silent and opt.Callback then
task.spawn(opt.Callback, tb.Text, false)
end
end,
Get = function()
return tb.Text
end,
}
end
function Section:CreateDropdown(opt)
opt = opt or {}
local options = opt.Options or {}
local selected = opt.Default or options[1] or ""
local open = false
local row = rowBase(self, ROW_H)
rowLabel(row, opt.Icon, opt.Name or "Dropdown", opt.Description)
local head = new("TextButton", {
Text = "",
AutoButtonColor = false,
BorderSizePixel = 0,
Size = UDim2.new(0, CTRL_W, 0, CTRL_H),
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -14, 0.5, 0),
Parent = row,
Theme = {
BackgroundColor3 = "Elevated",
},
})
corner(head, CTRL_R)
stroke(head)
local sel = new("TextLabel", {
Text = tostring(selected),
Font = Enum.Font.GothamMedium,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
BackgroundTransparency = 1,
Position = UDim2.new(0, 12, 0, 0),
Size = UDim2.new(1, -34, 1, 0),
Parent = head,
Theme = {
TextColor3 = "Text",
},
})
local arrow = iconLabel({
Icon = Ui.Icons.chevronDown,
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -10, 0.5, 0),
Size = UDim2.new(0, 14, 0, 14),
Parent = head,
Theme = {
ImageColor3 = "SubText",
},
})
local overlay = self.window and self.window.overlay
local menu = new("ScrollingFrame", {
Size = UDim2.new(0, CTRL_W, 0, 0),
ClipsDescendants = true,
Visible = false,
Active = true,
AnchorPoint = overlay and Vector2.new(0, 0) or Vector2.new(1, 0),
Position = overlay and UDim2.new(0, 0, 0, 0) or UDim2.new(1, -14, 0.5, 18),
BorderSizePixel = 0,
ZIndex = 150,
CanvasSize = UDim2.new(),
AutomaticCanvasSize = Enum.AutomaticSize.Y,
ScrollBarThickness = 3,
ScrollBarImageTransparency = 0.5,
ScrollingDirection = Enum.ScrollingDirection.Y,
Parent = overlay or row,
Theme = {
BackgroundColor3 = "Elevated",
},
})
local function place(wantedH)
wantedH = wantedH or 0
if not overlay then
return wantedH
end
local root = self.window.root
local rootAbs, rootSize = root.AbsolutePosition, root.AbsoluteSize
local hp, hs = head.AbsolutePosition, head.AbsoluteSize
local relX = hp.X - rootAbs.X
local relY = hp.Y - rootAbs.Y
local below = rootSize.Y - (relY + hs.Y) - 10
local above = relY - 10
local flip = false
local h = wantedH
if wantedH > below and above > below then
flip = true
h = math.min(wantedH, above)
else
h = math.min(wantedH, below)
end
h = math.max(math.floor(h), 34)
relX = math.clamp(relX, 6, math.max(6, rootSize.X - CTRL_W - 6))
menu.Position = UDim2.new(0, relX, 0, flip and (relY - h - 6) or (relY + hs.Y + 6))
return h
end
corner(menu, 8)
stroke(menu)
local ml = list(menu, Enum.FillDirection.Vertical, 2)
ml.VerticalAlignment = Enum.VerticalAlignment.Top
pad(menu, 4, 4, 4, 4)
local items = {}
local searchBox = new("TextBox", {
Text = "",
PlaceholderText = "Search...",
ClearTextOnFocus = false,
Font = Enum.Font.Gotham,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Left,
BorderSizePixel = 0,
ZIndex = 152,
Size = UDim2.new(1, 0, 0, 26),
LayoutOrder = 0,
Visible = false,
Parent = menu,
Theme = {
BackgroundColor3 = "Panel",
TextColor3 = "Text",
PlaceholderColor3 = "Dim",
},
})
corner(searchBox, 6)
pad(searchBox, 8, 8, 0, 0)
local function searchEnabled()
return opt.Search == true or (opt.Search ~= false and #options >= 8)
end
local function visibleHeight()
local count = 0
for _, it in ipairs(items) do
if it.button.Visible then
count = count + 1
end
end
return math.max(count, 1) * 28 + 8 + (searchBox.Visible and 30 or 0)
end
local function applyFilter()
local query = string.lower(searchBox.Text)
for _, it in ipairs(items) do
it.button.Visible = query == "" or string.find(it.text, query, 1, true) ~= nil
end
if open then
local h = place(visibleHeight())
tween(menu, 0.12, {
Size = UDim2.new(0, CTRL_W, 0, h),
})
end
end
searchBox:GetPropertyChangedSignal("Text"):Connect(applyFilter)
local api = {}
local function rebuild()
items = {}
for _, c in ipairs(menu:GetChildren()) do
if c:IsA("TextButton") then
c:Destroy()
end
end
for i, o in ipairs(options) do
local item = new("TextButton", {
Text = tostring(o),
Font = Enum.Font.Gotham,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Left,
AutoButtonColor = false,
BorderSizePixel = 0,
BackgroundTransparency = 1,
ZIndex = 151,
Size = UDim2.new(1, 0, 0, 26),
LayoutOrder = i,
Parent = menu,
Theme = {
TextColor3 = "Text",
BackgroundColor3 = "Hover",
},
})
corner(item, 6)
items[#items + 1] = { button = item, text = string.lower(tostring(o)) }
pad(item, 8, 8, 0, 0)
item.BackgroundTransparency = 1
item.MouseEnter:Connect(function()
item.BackgroundTransparency = 0
end)
item.MouseLeave:Connect(function()
item.BackgroundTransparency = 1
end)
item.MouseButton1Click:Connect(function()
selected = o
sel.Text = tostring(o)
api:Close()
if opt.Callback then
task.spawn(opt.Callback, o)
end
end)
end
end
function api:Open()
searchBox.Visible = searchEnabled()
searchBox.Text = ""
if Ui._openDropdown and Ui._openDropdown ~= api then
pcall(function()
Ui._openDropdown:Close()
end)
end
if Ui._openPopup then
pcall(function()
Ui._openPopup:Close()
end)
end
Ui._openDropdown = api
open = true
menu.Visible = true
menu.Size = UDim2.new(0, CTRL_W, 0, 0)
menu.CanvasPosition = Vector2.new(0, 0)
local h = place(visibleHeight())
tween(menu, 0.18, {
Size = UDim2.new(0, CTRL_W, 0, h),
})
tween(arrow, 0.18, { Rotation = 180 })
end
function api:Close()
open = false
if Ui._openDropdown == api then
Ui._openDropdown = nil
end
tween(menu, 0.15, {
Size = UDim2.new(0, CTRL_W, 0, 0),
})
tween(arrow, 0.15, { Rotation = 0 })
task.delay(0.16, function()
if not open then
menu.Visible = false
end
end)
end
function api:SetOptions(t)
options = t
rebuild()
end
function api:Get()
return selected
end
function api:Set(v)
selected = v
sel.Text = tostring(v)
end
head.MouseButton1Click:Connect(function()
if open then
api:Close()
else
api:Open()
end
end)
local outsideConn
row.AncestryChanged:Connect(function()
if not row:IsDescendantOf(game) then
if outsideConn then
outsideConn:Disconnect()
outsideConn = nil
end
menu:Destroy()
end
end)
outsideConn = UserInputService.InputBegan:Connect(function(input)
if not open then
return
end
if
input.UserInputType ~= Enum.UserInputType.MouseButton1
and input.UserInputType ~= Enum.UserInputType.Touch
then
return
end
local p = input.Position
local function inside(o)
local a, b = o.AbsolutePosition, o.AbsoluteSize
return p.X >= a.X and p.X <= a.X + b.X and p.Y >= a.Y and p.Y <= a.Y + b.Y
end
if not inside(head) and not inside(menu) then
api:Close()
end
end)
rebuild()
api.Instance = row
return api
end
function Section:CreateKeybind(opt)
opt = opt or {}
local key = opt.Default or Enum.KeyCode.RightShift
local listening = false
local row = rowBase(self, ROW_H)
rowLabel(row, opt.Icon or Ui.Icons.keyboard, opt.Name or "Keybind", opt.Description)
local btn = new("TextButton", {
Text = key.Name,
Font = Enum.Font.GothamBold,
TextSize = 12,
AutoButtonColor = false,
BorderSizePixel = 0,
Size = UDim2.new(0, CTRL_W, 0, CTRL_H),
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -14, 0.5, 0),
Parent = row,
Theme = {
BackgroundColor3 = "Elevated",
TextColor3 = "Text",
},
})
corner(btn, CTRL_R)
stroke(btn)
btn.MouseButton1Click:Connect(function()
listening = true
btn.Text = "..."
end)
UserInputService.InputBegan:Connect(function(input, gpe)
if listening and input.UserInputType == Enum.UserInputType.Keyboard then
listening = false
key = input.KeyCode
btn.Text = key.Name
if opt.Changed then
task.spawn(opt.Changed, key)
end
elseif not gpe and input.KeyCode == key and opt.Callback then
task.spawn(opt.Callback, key)
end
end)
return {
Instance = row,
Get = function()
return key
end,
}
end
function Section:CreateLabel(text)
local row = rowBase(self, 34)
new("TextLabel", {
Text = text,
Font = Enum.Font.Gotham,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
Position = UDim2.new(0, 14, 0, 0),
Size = UDim2.new(1, -28, 1, 0),
Parent = row,
Theme = {
TextColor3 = "SubText",
},
})
return { Instance = row }
end
function Section:CreateCard(opt)
opt = opt or {}
local card = new("TextButton", {
Text = "",
AutoButtonColor = false,
BorderSizePixel = 0,
Size = UDim2.new(1, 0, 0, 46),
LayoutOrder = self:_next(),
Parent = self.body,
})
corner(card, 12)
glass(card)
glassHover(card)
ripple(card)
iconLabel({
Icon = opt.Icon or Ui.Icons.box,
Size = UDim2.new(0, 20, 0, 20),
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 16, 0.5, 0),
Parent = card,
Theme = {
ImageColor3 = "SubText",
},
})
new("TextLabel", {
Text = opt.Name or "Action",
Font = Enum.Font.GothamBold,
TextSize = 13,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
BackgroundTransparency = 1,
Position = UDim2.new(0, 48, 0, 0),
Size = UDim2.new(1, -60, 1, 0),
Parent = card,
Theme = {
TextColor3 = "Text",
},
})
card:SetAttribute("SearchText", string.lower(tostring(opt.Name or "")))
card.MouseButton1Click:Connect(function()
if opt.Callback then
task.spawn(opt.Callback)
end
end)
return { Instance = card }
end
function Section:CreateCardsGlass(opt)
opt = opt or {}
local cols = math.max(1, opt.Columns or 2)
local gap = opt.Gap or 8
local height = opt.CardHeight or 74
local holder = new("Frame", {
Name = "CardsGlass",
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
BackgroundTransparency = 1,
LayoutOrder = self:_next(),
Parent = self.body,
})
pad(holder, 12, 12, 6, 6)
local grid = new("UIGridLayout", {
Parent = holder,
SortOrder = Enum.SortOrder.LayoutOrder,
CellPadding = UDim2.new(0, gap, 0, gap),
CellSize = UDim2.new(1 / cols, -math.floor(gap * (cols - 1) / cols) - 1, 0, height),
})
local api = {
Instance = holder,
Cards = {},
}
function api:AddCard(c)
c = c or {}
local n = #api.Cards + 1
local card = new("TextButton", {
Text = "",
AutoButtonColor = false,
BorderSizePixel = 0,
LayoutOrder = n,
Parent = holder,
})
corner(card, 14)
glass(card)
glassHover(card)
if ripple then
pcall(ripple, card)
end
local iconBox = new("Frame", {
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 12, 0.5, 0),
Size = UDim2.new(0, 36, 0, 36),
BackgroundTransparency = 0.4,
BorderSizePixel = 0,
Parent = card,
Theme = {
BackgroundColor3 = "Elevated",
},
})
corner(iconBox, 10)
stroke(iconBox)
iconLabel({
Icon = c.Icon or Ui.Icons.box,
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.new(0.5, 0, 0.5, 0),
Size = UDim2.new(0, 18, 0, 18),
Parent = iconBox,
Theme = {
ImageColor3 = "Text",
},
})
local title = new("TextLabel", {
Text = c.Name or ("Card " .. n),
Font = Enum.Font.GothamBold,
TextSize = 13,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
BackgroundTransparency = 1,
Position = UDim2.new(0, 58, 0, 14),
Size = UDim2.new(1, -70, 0, 16),
Parent = card,
Theme = {
TextColor3 = "Text",
},
})
local desc = new("TextLabel", {
Text = c.Description or "",
Font = Enum.Font.Gotham,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
BackgroundTransparency = 1,
Position = UDim2.new(0, 58, 0, 32),
Size = UDim2.new(1, -70, 0, 28),
TextWrapped = true,
ClipsDescendants = true,
TextYAlignment = Enum.TextYAlignment.Top,
Parent = card,
Theme = {
TextColor3 = "SubText",
},
})
local entry = {
Instance = card,
Index = n,
}
function entry:SetName(t)
title.Text = t
end
function entry:SetDescription(t)
desc.Text = t or ""
end
function entry:Destroy()
card:Destroy()
end
card:SetAttribute("SearchText", string.lower(tostring(c.Name or "") .. " " .. tostring(c.Description or "")))
card.MouseButton1Click:Connect(function()
if c.Callback then
task.spawn(c.Callback, entry)
end
end)
api.Cards[n] = entry
return entry
end
for _, c in ipairs(opt.Cards or {}) do
api:AddCard(c)
end
return api
end
Section.CreateCards = Section.CreateCardsGlass
S.Section = Section
S.rowBase = rowBase
S.rowLabel = rowLabel
