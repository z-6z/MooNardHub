local Ui, S = ...
local TweenService, UserInputService, TextService = S.TweenService, S.UserInputService, S.TextService
local Guard = S.Guard
local new, corner, stroke, shine, ledBackdrop, glass, pad, list = S.new, S.corner, S.stroke, S.shine, S.ledBackdrop, S.glass, S.pad, S.list
local tween, hoverable, playClickSound, ripple, iconLabel, iconButton, makeScreenGui, clampedPosition = S.tween, S.hoverable, S.playClickSound, S.ripple, S.iconLabel, S.iconButton, S.makeScreenGui, S.clampedPosition
local makeDraggable, Visualizer, Section = S.makeDraggable, S.Visualizer, S.Section
local Tab = {}
Tab.__index = Tab
function Tab:CreateSection(title)
local s = setmetatable({
_count = 0,
window = self.window,
}, Section)
local holder = new("Frame", {
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
BackgroundTransparency = 1,
LayoutOrder = self:_next(),
Parent = self.page,
})
local hl = list(holder, Enum.FillDirection.Vertical, 8)
hl.VerticalAlignment = Enum.VerticalAlignment.Top
if title and title ~= "" then
new("TextLabel", {
Text = string.upper(title),
Font = Enum.Font.GothamBold,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 0, 16),
LayoutOrder = 0,
Parent = holder,
Theme = {
TextColor3 = "SubText",
},
})
end
local card = new("Frame", {
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
BorderSizePixel = 0,
LayoutOrder = 1,
Parent = holder,
})
corner(card, 14)
glass(card)
local body = new("Frame", {
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
BackgroundTransparency = 1,
Parent = card,
})
local bl = list(body, Enum.FillDirection.Vertical, 0)
bl.VerticalAlignment = Enum.VerticalAlignment.Top
pad(body, 0, 0, 4, 8)
s.holder, s.card, s.body = holder, card, body
return s
end
function Tab:CreateGroup(title)
local s = self:CreateSection(title)
s.card.BackgroundTransparency = 1
for _, c in ipairs(s.card:GetChildren()) do
if c:IsA("UIStroke") then
c.Enabled = false
elseif c:IsA("UIGradient") then
c:Destroy()
end
end
local bl = s.body:FindFirstChildOfClass("UIListLayout")
if bl then
bl.Padding = UDim.new(0, 8)
end
return s
end
function Tab:CreateCardsGlass(opt)
opt = opt or {}
local s = self:CreateGroup(opt.Title)
return s:CreateCardsGlass(opt)
end
Tab.CreateCards = Tab.CreateCardsGlass
function Tab:CreateDiscordInvite(opt)
local group = self:CreateGroup()
return group:CreateDiscordInvite(opt)
end
Tab.DiscordInvite = Tab.CreateDiscordInvite
function Tab:_next()
self._order = (self._order or 0) + 1
return self._order
end
function Tab:Select()
self.window:SelectTab(self.id)
end
local Window = {}
Window.__index = Window
function Ui:CreateWindow(cfg)
cfg = cfg or {}
Ui:SetTheme(cfg.Theme or "Dark")
local self = setmetatable({}, Window)
self.tabs, self.navItems, self.tabCount = {}, {}, 0
self.gui = makeScreenGui()
local size = cfg.Size or UDim2.new(0, 900, 0, 560)
local root = new("Frame", {
Name = "Window",
Size = size,
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.new(0.5, 0, 0.5, 0),
BorderSizePixel = 0,
ClipsDescendants = true,
Parent = self.gui,
Theme = {
BackgroundColor3 = "Background",
},
})
corner(root, 14)
local rootStroke = stroke(root, "Stroke", 1.4)
rootStroke.Transparency = 0
shine(rootStroke, 45)
ledBackdrop(root)
self.root = root
do
local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
local w = math.min(size.X.Offset, math.floor(vp.X - 24))
local h = math.min(size.Y.Offset, math.floor(vp.Y - 24))
size = UDim2.new(0, math.max(320, w), 0, math.max(240, h))
root.Size = size
end
root.Size = UDim2.new(0, size.X.Offset * 0.92, 0, size.Y.Offset * 0.92)
root.BackgroundTransparency = 1
tween(root, 0.3, {
Size = size,
BackgroundTransparency = 0,
})
local title = new("Frame", {
Size = UDim2.new(1, 0, 0, 46),
BackgroundTransparency = 1,
Parent = root,
})
makeDraggable(root, title)
self.titleBar = title
local logoImg = iconLabel({
Icon = Guard.logo(),
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 18, 0.5, 0),
Size = UDim2.new(0, 22, 0, 22),
Parent = title,
Theme = {
ImageColor3 = "Text",
},
})
local nameLbl = new("TextLabel", {
Text = Guard.name(),
Font = Enum.Font.GothamBold,
TextSize = 15,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
Position = UDim2.new(0, 46, 0, 0),
Size = UDim2.new(0, 70, 1, 0),
Parent = title,
Theme = {
TextColor3 = "Text",
},
})
local nameTextWidth =
TextService:GetTextSize(nameLbl.Text, nameLbl.TextSize, nameLbl.Font, Vector2.new(1000, 100)).X
nameLbl.Size = UDim2.new(0, nameTextWidth + 2, 1, 0)
Guard.lock(self.gui, logoImg, {
{ "Image", Guard.logo },
{ "Visible", Guard.yes },
{ "ImageTransparency", Guard.zero },
}, function()
self:_destroy()
end)
Guard.lock(self.gui, nameLbl, {
{ "Text", Guard.name },
{ "Visible", Guard.yes },
{ "TextTransparency", Guard.zero },
}, function()
self:_destroy()
end)
local verLbl = new("TextLabel", {
Text = cfg.Version or Ui.Version,
Font = Enum.Font.Gotham,
TextSize = 10,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
Position = UDim2.new(0, 46 + 8 + nameTextWidth, 0, 0),
Size = UDim2.new(0, 44, 1, 0),
Parent = title,
Theme = {
TextColor3 = "Dim",
},
})
local verTextWidth = TextService:GetTextSize(verLbl.Text, verLbl.TextSize, verLbl.Font, Vector2.new(1000, 100)).X
local visHolder = new("Frame", {
AnchorPoint = Vector2.new(0, 0.5),
BackgroundTransparency = 1,
Size = UDim2.new(0, 30, 0, 17),
Position = UDim2.new(0, verLbl.Position.X.Offset + verTextWidth + 10, 0.5, 0),
Parent = title,
})
self.Visualizer = Visualizer.new(visHolder, 4)
self.visHolder = visHolder
local nav = new("Frame", {
BackgroundTransparency = 1,
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.new(0.5, 0, 0.5, 0),
Size = UDim2.new(0, 0, 0, 30),
AutomaticSize = Enum.AutomaticSize.X,
Parent = title,
})
local navList = list(nav, Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Center)
navList.VerticalAlignment = Enum.VerticalAlignment.Center
self.nav = nav
local winBtns = new("Frame", {
Name = "WindowButtons",
BackgroundTransparency = 1,
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -14, 0.5, 0),
Size = UDim2.new(0, 0, 0, 26),
AutomaticSize = Enum.AutomaticSize.X,
Parent = title,
})
local winList = list(winBtns, Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Right)
winList.VerticalAlignment = Enum.VerticalAlignment.Center
self.winBtns = winBtns
local function winBtn(icon, order)
local b = iconButton({
Icon = icon,
LayoutOrder = order,
Size = UDim2.new(0, 26, 0, 26),
BackgroundTransparency = 1,
Parent = winBtns,
Theme = {
ImageColor3 = "Dim",
BackgroundColor3 = "Hover",
},
})
local ip = new("UIPadding", { Parent = b })
ip.PaddingTop, ip.PaddingBottom = UDim.new(0, 7), UDim.new(0, 7)
ip.PaddingLeft, ip.PaddingRight = UDim.new(0, 7), UDim.new(0, 7)
new("UICorner", {
CornerRadius = UDim.new(1, 0),
Parent = b,
})
b.MouseEnter:Connect(function()
tween(b, 0.14, { BackgroundTransparency = 0 })
tween(b, 0.14, { ImageColor3 = Ui.CurrentTheme.Text })
end)
b.MouseLeave:Connect(function()
tween(b, 0.14, { BackgroundTransparency = 1 })
tween(b, 0.14, { ImageColor3 = Ui.CurrentTheme.Dim })
end)
return b
end
local sideBtn = winBtn(Ui.Icons.tab, 0)
self.sidebarButton = sideBtn
sideBtn.MouseButton1Click:Connect(function()
playClickSound()
self:ToggleSidebar()
end)
local minBtn = winBtn(Ui.Icons.minimize, 1)
local maxBtn = winBtn(Ui.Icons.maximize, 2)
local closeBtn = winBtn(Ui.Icons.close, 3)
self.minimized = false
minBtn.MouseButton1Click:Connect(function()
playClickSound()
self:Minimize()
end)
maxBtn.MouseButton1Click:Connect(function()
playClickSound()
self:Maximize()
end)
closeBtn.MouseButton1Click:Connect(function()
playClickSound()
self:Close()
end)
local body = new("Frame", {
Name = "Body",
Position = UDim2.new(0, 0, 0, 46),
Size = UDim2.new(1, 0, 1, -46),
BackgroundTransparency = 1,
ClipsDescendants = true,
Parent = root,
})
self.body = body
local sidebar = new("Frame", {
Size = UDim2.new(0, 200, 1, 0),
BorderSizePixel = 0,
ClipsDescendants = true,
Parent = body,
Theme = {
BackgroundColor3 = "Sidebar",
},
})
corner(sidebar, 14)
self.sidebar = sidebar
new("Frame", {
Size = UDim2.new(0, 1, 1, 0),
Position = UDim2.new(1, -1, 0, 0),
BorderSizePixel = 0,
Parent = sidebar,
Theme = {
BackgroundColor3 = "Stroke",
},
})
self.sidebarTitle = new("TextLabel", {
Text = cfg.SidebarTitle or "Explorer",
Font = Enum.Font.GothamBold,
TextSize = 17,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
Position = UDim2.new(0, 18, 0, 8),
Size = UDim2.new(1, -70, 0, 30),
Parent = sidebar,
Theme = {
TextColor3 = "Text",
},
})
local collapse = iconButton({
Icon = Ui.Icons.chevronLeft,
AnchorPoint = Vector2.new(1, 0),
Position = UDim2.new(1, -14, 0, 14),
Size = UDim2.new(0, 18, 0, 18),
Parent = sidebar,
Theme = {
ImageColor3 = "SubText",
},
})
collapse.MouseButton1Click:Connect(function()
self:ToggleSidebar()
end)
local searchWrap = new("Frame", {
Position = UDim2.new(0, 14, 0, 46),
Size = UDim2.new(1, -28, 0, 32),
BorderSizePixel = 0,
Parent = sidebar,
Theme = {
BackgroundColor3 = "Elevated",
},
})
corner(searchWrap, 8)
stroke(searchWrap)
iconLabel({
Icon = Ui.Icons.search,
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 10, 0.5, 0),
Size = UDim2.new(0, 15, 0, 15),
Parent = searchWrap,
Theme = {
ImageColor3 = "SubText",
},
})
local search = new("TextBox", {
Text = "",
PlaceholderText = cfg.SearchPlaceholder or "Search...",
Font = Enum.Font.Gotham,
TextSize = 12,
ClearTextOnFocus = false,
BackgroundTransparency = 1,
Position = UDim2.new(0, 32, 0, 0),
Size = UDim2.new(1, -42, 1, 0),
TextXAlignment = Enum.TextXAlignment.Left,
Parent = searchWrap,
Theme = {
TextColor3 = "Text",
PlaceholderColor3 = "Dim",
},
})
self.search = search
local tabHolder = new("ScrollingFrame", {
Position = UDim2.new(0, 10, 0, 90),
Size = UDim2.new(1, -20, 1, -104),
BackgroundTransparency = 1,
BorderSizePixel = 0,
ScrollBarThickness = 2,
CanvasSize = UDim2.new(),
AutomaticCanvasSize = Enum.AutomaticSize.Y,
ScrollBarImageTransparency = 0.6,
Parent = sidebar,
})
local thl = list(tabHolder, Enum.FillDirection.Vertical, 2)
thl.VerticalAlignment = Enum.VerticalAlignment.Top
self.tabHolder = tabHolder
local searchClear = iconButton({
Icon = Ui.Icons.close or Ui.Icons.x,
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -8, 0.5, 0),
Size = UDim2.new(0, 14, 0, 14),
Visible = false,
Parent = searchWrap,
Theme = {
ImageColor3 = "SubText",
},
})
self.searchClear = searchClear
local searchInfo = new("TextLabel", {
Text = "",
Font = Enum.Font.Gotham,
TextSize = 10,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
Position = UDim2.new(0, 16, 0, 78),
Size = UDim2.new(1, -32, 0, 12),
Visible = false,
Parent = sidebar,
Theme = {
TextColor3 = "Dim",
},
})
self.searchInfo = searchInfo
function self:ApplySearch(text)
local q = string.lower(text or "")
local total, visibleTabs, firstHit = 0, 0, nil
for i, t in pairs(self.tabs) do
local tabMatch = q == "" or string.find(string.lower(t.name), q, 1, true) ~= nil
local hits = 0
for _, d in ipairs(t.page:GetDescendants()) do
local st = d:GetAttribute("SearchText")
if st then
local ok = q == "" or tabMatch or string.find(st, q, 1, true) ~= nil
d.Visible = ok
if ok and q ~= "" and not tabMatch then
hits = hits + 1
end
end
end
for _, holder in ipairs(t.page:GetChildren()) do
if holder:IsA("GuiObject") then
local any = q == "" or tabMatch
if not any then
for _, d in ipairs(holder:GetDescendants()) do
if d:GetAttribute("SearchText") and d.Visible then
any = true
break
end
end
end
holder.Visible = any
end
end
total = total + hits
local show = (q == "" or tabMatch or hits > 0) and not t.hiddenFromSidebar
t.button.Visible = show
if show then
visibleTabs = visibleTabs + 1
if not firstHit and q ~= "" and (hits > 0 or tabMatch) then
firstHit = i
end
end
end
searchClear.Visible = q ~= ""
searchInfo.Visible = q ~= ""
searchInfo.Text = visibleTabs == 0 and "No results" or (visibleTabs .. " tab(s) • " .. total .. " result(s)")
return firstHit
end
search:GetPropertyChangedSignal("Text"):Connect(function()
self:ApplySearch(search.Text)
end)
search.FocusLost:Connect(function(enter)
if enter then
local first = self:ApplySearch(search.Text)
if first then
self:SelectTab(first)
end
end
end)
searchClear.MouseButton1Click:Connect(function()
search.Text = ""
end)
local content = new("Frame", {
Position = UDim2.new(0, 200, 0, 0),
Size = UDim2.new(1, -200, 1, 0),
BackgroundTransparency = 1,
ClipsDescendants = true,
Parent = body,
})
self.content = content
self.sidebarOpen = true
self.sidebarReopen = iconButton({
Icon = Ui.Icons.chevron,
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 0, 0.5, 0),
Size = UDim2.new(0, 20, 0, 72),
Visible = false,
ZIndex = 90,
BackgroundTransparency = 0,
Parent = content,
Theme = {
ImageColor3 = "Text",
BackgroundColor3 = "Elevated",
},
})
do
local ip = new("UIPadding", { Parent = self.sidebarReopen })
ip.PaddingTop, ip.PaddingBottom = UDim.new(0, 28), UDim.new(0, 28)
ip.PaddingLeft, ip.PaddingRight = UDim.new(0, 3), UDim.new(0, 3)
end
self.sidebarReopen.Parent = body
corner(self.sidebarReopen, 8)
stroke(self.sidebarReopen)
self.sidebarReopen.MouseButton1Click:Connect(function()
self:ToggleSidebar(true)
end)
if cfg.FloatingToggle ~= false then
task.defer(function()
self:CreateFloatingToggle(type(cfg.FloatingToggle) == "table" and cfg.FloatingToggle or nil)
end)
end
self.statusHeight = 0
self.overlay = new("Frame", {
Name = "Overlay",
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 1, 0),
ZIndex = 120,
Parent = root,
})
self.statusBar = new("Frame", {
AnchorPoint = Vector2.new(0, 1),
Position = UDim2.new(0, 0, 1, 0),
Size = UDim2.new(1, 0, 0, 32),
BorderSizePixel = 0,
Visible = false,
ZIndex = 60,
Parent = content,
Theme = {
BackgroundColor3 = "Sidebar",
},
})
corner(self.statusBar, 14)
new("Frame", {
Size = UDim2.new(1, 0, 0, 1),
BorderSizePixel = 0,
Parent = self.statusBar,
Theme = {
BackgroundColor3 = "Stroke",
},
})
return self
end
function Window:AddNavIcon(icon, tooltipOrCallback, maybeCallback)
local callback = type(tooltipOrCallback) == "function" and tooltipOrCallback or maybeCallback
local b = iconButton({
Icon = icon,
Size = UDim2.new(0, 32, 0, 30),
Parent = self.nav,
Theme = {
ImageColor3 = "SubText",
BackgroundColor3 = "Hover",
},
})
local ip = new("UIPadding", { Parent = b })
ip.PaddingTop, ip.PaddingBottom = UDim.new(0, 7), UDim.new(0, 7)
ip.PaddingLeft, ip.PaddingRight = UDim.new(0, 8), UDim.new(0, 8)
corner(b, 8)
b.MouseEnter:Connect(function()
b.BackgroundTransparency = 0
b.ImageColor3 = Ui.CurrentTheme.Text
end)
b.MouseLeave:Connect(function()
if not b:GetAttribute("Active") then
b.BackgroundTransparency = 1
b.ImageColor3 = Ui.CurrentTheme.SubText
end
end)
b.MouseButton1Click:Connect(function()
for _, o in ipairs(self.nav:GetChildren()) do
if o:IsA("ImageButton") or o:IsA("TextButton") then
o:SetAttribute("Active", false)
o.BackgroundTransparency = 1
if o:IsA("ImageButton") then
o.ImageColor3 = Ui.CurrentTheme.SubText
else
o.TextColor3 = Ui.CurrentTheme.SubText
end
end
end
b:SetAttribute("Active", true)
b.BackgroundTransparency = 0
b.ImageColor3 = Ui.CurrentTheme.Text
if callback then
task.spawn(callback)
end
end)
return b
end
function Window:CreateTab(cfg)
cfg = cfg or {}
self.tabCount = self.tabCount + 1
local id = self.tabCount
local btn = new("TextButton", {
Text = "",
AutoButtonColor = false,
BorderSizePixel = 0,
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 0, 38),
LayoutOrder = id,
Parent = self.tabHolder,
})
corner(btn, 8)
local fill = new("Frame", {
Name = "GlassFill",
BackgroundTransparency = 1,
BorderSizePixel = 0,
Position = UDim2.new(0, 3, 0, 3),
Size = UDim2.new(1, -6, 1, -6),
ZIndex = 1,
Parent = btn,
Theme = {
BackgroundColor3 = "Glass",
},
})
corner(fill, 7)
new("UIGradient", {
Rotation = 115,
Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0.3),
NumberSequenceKeypoint.new(1, 0.6),
}),
Parent = fill,
})
local fillStroke = new("UIStroke", {
Thickness = 1,
Transparency = 1,
ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
Parent = fill,
Theme = {
Color = "GlassStroke",
},
})
local bar = new("Frame", {
Name = "Indicator",
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 8, 0.5, 0),
Size = UDim2.new(0, 3, 0, 0),
BackgroundTransparency = 1,
BorderSizePixel = 0,
ZIndex = 3,
Parent = btn,
Theme = {
BackgroundColor3 = "Accent",
},
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })
local tabIcon = iconLabel({
Icon = cfg.Icon or Ui.Icons.box,
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 14, 0.5, 0),
Size = UDim2.new(0, 18, 0, 18),
ZIndex = 2,
Parent = btn,
Theme = {
ImageColor3 = "SubText",
},
})
local tabLabel = new("TextLabel", {
Text = cfg.Name or "Tab",
Font = Enum.Font.GothamBold,
TextSize = 13,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
Position = UDim2.new(0, 42, 0, 0),
Size = UDim2.new(1, -50, 1, 0),
ZIndex = 2,
Parent = btn,
Theme = {
TextColor3 = "SubText",
},
})
local page = new("ScrollingFrame", {
Visible = false,
BackgroundTransparency = 1,
BorderSizePixel = 0,
Position = UDim2.new(0, 0, 0, 0),
Size = UDim2.new(1, 0, 1, -(self.statusHeight or 0)),
CanvasSize = UDim2.new(),
AutomaticCanvasSize = Enum.AutomaticSize.Y,
ScrollBarThickness = 3,
ScrollBarImageTransparency = 0.7,
ClipsDescendants = true,
Parent = self.content,
})
local pl = list(page, Enum.FillDirection.Vertical, 18)
pl.VerticalAlignment = Enum.VerticalAlignment.Top
pad(page, 22, 24, 20, 30)
page.AutomaticCanvasSize = Enum.AutomaticSize.None
local function syncCanvas()
page.CanvasSize = UDim2.new(0, 0, 0, pl.AbsoluteContentSize.Y + 60)
end
pl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(syncCanvas)
task.defer(syncCanvas)
local tab = setmetatable({
id = id,
name = cfg.Name or "Tab",
button = btn,
page = page,
window = self,
_order = 0,
_fill = fill,
_fillStroke = fillStroke,
_bar = bar,
_icon = tabIcon,
_label = tabLabel,
}, Tab)
self.tabs[id] = tab
table.insert(Ui._tabRestyle, function()
if not btn.Parent then
return false
end
local active = self.current == id
fill.BackgroundTransparency = active and (Ui.CurrentTheme.GlassAlpha or 0.9) or 1
tabLabel.TextColor3 = active and Ui.CurrentTheme.Text or Ui.CurrentTheme.SubText
tabIcon.ImageColor3 = active and Ui.CurrentTheme.Text or Ui.CurrentTheme.SubText
return true
end)
btn.MouseButton1Click:Connect(function()
self:SelectTab(id)
end)
btn.MouseEnter:Connect(function()
if self.current ~= id then
tween(fill, 0.14, { BackgroundTransparency = math.clamp((Ui.CurrentTheme.GlassHoverAlpha or 0.84) + 0.08, 0, 1) })
tween(tabLabel, 0.14, { TextColor3 = Ui.CurrentTheme.Text })
tween(tabIcon, 0.14, { ImageColor3 = Ui.CurrentTheme.Text })
end
end)
btn.MouseLeave:Connect(function()
if self.current ~= id then
tween(fill, 0.18, { BackgroundTransparency = 1 })
tween(tabLabel, 0.18, { TextColor3 = Ui.CurrentTheme.SubText })
tween(tabIcon, 0.18, { ImageColor3 = Ui.CurrentTheme.SubText })
end
end)
if not self.current then
self:SelectTab(id)
end
return tab
end
function Window:CreateNavTab(cfg)
cfg = cfg or {}
local tab = self:CreateTab(cfg)
if cfg.ShowInSidebar ~= true then
tab.hiddenFromSidebar = true
tab.button.Visible = false
end
tab.navButton = self:AddNavIcon(cfg.Icon or Ui.Icons.box, function()
self:SelectTab(tab.id)
if cfg.Callback then
task.spawn(cfg.Callback, tab)
end
end)
return tab
end
function Window:CreateFloatingToggle(cfg)
cfg = cfg or {}
if self.floatingToggle then
return self.floatingToggle
end
local size = Guard.toggleSize()
local gui = makeScreenGui()
gui.Name = "MooNardHubFloating"
local btn = new("ImageButton", {
Name = "FloatingToggle",
Image = Guard.toggleIcon(),
ImageTransparency = 0,
AutoButtonColor = false,
BorderSizePixel = 0,
AnchorPoint = Vector2.new(0, 0),
Position = cfg.Position or UDim2.new(0, 20, 0.5, -size / 2),
Size = UDim2.new(0, size, 0, size),
ZIndex = 50,
Parent = gui,
Theme = {
BackgroundColor3 = "Elevated",
ImageColor3 = "Text",
},
})
do
local ip = new("UIPadding", { Parent = btn })
ip.PaddingTop, ip.PaddingBottom = UDim.new(0, 12), UDim.new(0, 12)
ip.PaddingLeft, ip.PaddingRight = UDim.new(0, 12), UDim.new(0, 12)
end
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = btn })
stroke(btn)
Guard.lock(gui, btn, {
{ "Image", Guard.toggleIcon },
{ "ImageTransparency", Guard.zero },
{
"Size",
function()
local s = Guard.toggleSize()
return UDim2.new(0, s, 0, s)
end,
},
}, function()
if self.floatingToggle then
self.floatingToggle:Destroy()
end
self:CreateFloatingToggle(cfg)
end)
local dragging, moved, startPos, startInput = false, false, nil, nil
btn.InputBegan:Connect(function(input)
if
input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
then
dragging, moved = true, false
startInput, startPos = input.Position, btn.Position
end
end)
local moveConn = UserInputService.InputChanged:Connect(function(input)
if not dragging then
return
end
if
input.UserInputType == Enum.UserInputType.MouseMovement
or input.UserInputType == Enum.UserInputType.Touch
then
local d = input.Position - startInput
if math.abs(d.X) > 4 or math.abs(d.Y) > 4 then
moved = true
end
btn.Position =
UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
end
end)
local endConn = UserInputService.InputEnded:Connect(function(input)
if not dragging then
return
end
if
input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
then
dragging = false
if not moved then
self:Toggle()
end
end
end)
btn.Destroying:Connect(function()
moveConn:Disconnect()
endConn:Disconnect()
end)
self.floatingToggle = {
Instance = btn,
Gui = gui,
SetVisible = function(_, v)
btn.Visible = v and true or false
end,
Destroy = function()
gui:Destroy()
self.floatingToggle = nil
end,
}
return self.floatingToggle
end
function Window:SelectTab(id)
for i, t in pairs(self.tabs) do
local active = (i == id)
t.page.Visible = active
if t._fill then
tween(t._fill, 0.2, {
BackgroundTransparency = active and (Ui.CurrentTheme.GlassAlpha or 0.9) or 1,
})
tween(t._fillStroke, 0.2, {
Transparency = active and 0.6 or 1,
})
tween(t._bar, 0.22, {
Size = UDim2.new(0, 3, 0, active and 18 or 0),
BackgroundTransparency = active and 0 or 1,
})
tween(t._label, 0.2, { TextColor3 = active and Ui.CurrentTheme.Text or Ui.CurrentTheme.SubText })
tween(t._icon, 0.2, { ImageColor3 = active and Ui.CurrentTheme.Text or Ui.CurrentTheme.SubText })
end
if active then
t.page.Size = UDim2.new(1, 0, 1, -(self.statusHeight or 0))
t.page.Position = UDim2.new(0, 0, 0, 8)
tween(t.page, 0.25, {
Position = UDim2.new(0, 0, 0, 0),
})
end
end
self.current = id
end
function Window:SetSidebarTitle(text)
self.sidebarTitle.Text = text
end
function Window:ToggleSidebar(force)
if self.sidebarOpen == nil then
self.sidebarOpen = true
end
local open = force
if open == nil then
open = not self.sidebarOpen
end
self.sidebarOpen = open
tween(self.sidebar, 0.25, {
Size = UDim2.new(0, open and 200 or 0, 1, 0),
})
tween(self.content, 0.25, {
Position = UDim2.new(0, open and 200 or 24, 0, 0),
Size = UDim2.new(1, open and -200 or -24, 1, 0),
})
if self.sidebarReopen then
self.sidebarReopen.Visible = not open
end
return open
end
function Window:OpenSidebar()
return self:ToggleSidebar(true)
end
function Window:CloseSidebar()
return self:ToggleSidebar(false)
end
function Window:_closePopups()
if Ui._openDropdown then
pcall(function()
Ui._openDropdown:Close()
end)
Ui._openDropdown = nil
end
if self.overlay then
for _, c in ipairs(self.overlay:GetChildren()) do
if c:IsA("GuiObject") then
c.Visible = false
end
end
end
end
function Window:Minimize()
if self._minBusy then
return self.minimized
end
self._minBusy = true
self.minimized = not self.minimized
self:_closePopups()
local root = self.root
local absPos, absSize = root.AbsolutePosition, root.AbsoluteSize
local ax, ay = root.AnchorPoint.X, root.AnchorPoint.Y
if self.minimized then
self._restoreSize = root.Size
self._restoreAbs = absSize
self.body.Visible = false
if self.overlay then
self.overlay.Visible = false
end
if self.statusBar then
self._statusWasVisible = self.statusBar.Visible
end
if self.nav then
self.nav.Visible = false
end
local need = 360
if self.visHolder and self.winBtns then
need = self.visHolder.Position.X.Offset + self.visHolder.Size.X.Offset + 24 + self.winBtns.AbsoluteSize.X + 14
end
local w = math.min(absSize.X, math.max(260, need))
local h = 46
tween(root, 0.22, {
Size = UDim2.new(0, w, 0, h),
Position = clampedPosition(root, Vector2.new(w, h), absPos.X + w * ax, absPos.Y + h * ay),
})
task.delay(0.24, function()
self._minBusy = false
end)
else
local target = self._restoreAbs or Vector2.new(900, 560)
tween(root, 0.22, {
Size = self._restoreSize or UDim2.new(0, 900, 0, 560),
Position = clampedPosition(root, target, absPos.X + target.X * ax, absPos.Y + target.Y * ay),
})
task.delay(0.2, function()
if not self.minimized then
self.body.Visible = true
if self.nav then
self.nav.Visible = true
end
if self.overlay then
self.overlay.Visible = true
end
end
self._minBusy = false
end)
end
return self.minimized
end
function Window:Maximize()
if self.minimized then
self:Minimize()
end
if self.sidebarReopen then
self.sidebarReopen.Visible = not (self.sidebarOpen ~= false)
end
if self._maxed then
tween(self.root, 0.25, {
Size = self._prevSize,
Position = self._prevPos,
})
self._maxed = false
else
self._prevSize, self._prevPos = self.root.Size, self.root.Position
tween(self.root, 0.25, {
Size = UDim2.new(1, -40, 1, -40),
Position = UDim2.new(0.5, 0, 0.5, 0),
})
self._maxed = true
end
end
function Window:_destroy()
tween(self.root, 0.2, {
Size = UDim2.new(0, self.root.AbsoluteSize.X * 0.9, 0, self.root.AbsoluteSize.Y * 0.9),
BackgroundTransparency = 1,
})
task.delay(0.25, function()
if self.Visualizer then
self.Visualizer:Destroy()
end
if self.floatingToggle then
self.floatingToggle:Destroy()
end
self.gui:Destroy()
end)
end
function Window:Close(force)
if force or self.ConfirmClose == false then
self:_destroy()
return
end
if self._confirmOpen then
return
end
self._confirmOpen = true
local overlay = new("TextButton", {
Name = "CloseConfirm",
Text = "",
AutoButtonColor = false,
Size = UDim2.new(1, 0, 1, 0),
BackgroundColor3 = Color3.new(0, 0, 0),
BackgroundTransparency = 1,
BorderSizePixel = 0,
ZIndex = 200,
Parent = self.root,
})
corner(overlay, 14)
tween(overlay, 0.2, { BackgroundTransparency = 0.45 })
local card = new("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.new(0.5, 0, 0.5, 0),
Size = UDim2.new(0, 300, 0, 150),
BorderSizePixel = 0,
ZIndex = 201,
Parent = overlay,
Theme = {
BackgroundColor3 = "Panel",
},
})
corner(card, 14)
shine(stroke(card, "Stroke", 1.4), 70)
local scale = new("UIScale", { Scale = 0.85, Parent = card })
tween(scale, 0.22, { Scale = 1 })
new("ImageLabel", {
Image = Ui.GetIcon("circle-alert"),
BackgroundTransparency = 1,
AnchorPoint = Vector2.new(0.5, 0),
Position = UDim2.new(0.5, 0, 0, 16),
Size = UDim2.new(0, 26, 0, 26),
ZIndex = 202,
Parent = card,
Theme = {
ImageColor3 = "Text",
},
})
new("TextLabel", {
Text = "Are You Sure Wanna Close Script?",
Font = Enum.Font.GothamBold,
TextSize = 14,
BackgroundTransparency = 1,
Position = UDim2.new(0, 12, 0, 50),
Size = UDim2.new(1, -24, 0, 34),
TextWrapped = true,
ZIndex = 202,
Parent = card,
Theme = {
TextColor3 = "Text",
},
})
local function closeDialog()
tween(scale, 0.15, { Scale = 0.85 })
tween(overlay, 0.15, { BackgroundTransparency = 1 })
task.delay(0.16, function()
overlay:Destroy()
self._confirmOpen = false
end)
end
local function makeBtn(text, x, primary)
local b = new("TextButton", {
Text = text,
Font = Enum.Font.GothamBold,
TextSize = 13,
AutoButtonColor = false,
AnchorPoint = Vector2.new(x, 1),
Position = UDim2.new(x, x == 0 and 14 or -14, 1, -14),
Size = UDim2.new(0.5, -20, 0, 34),
BorderSizePixel = 0,
ZIndex = 202,
Parent = card,
Theme = primary and {
BackgroundColor3 = "Accent",
TextColor3 = "AccentText",
} or {
BackgroundColor3 = "Elevated",
TextColor3 = "Text",
},
})
corner(b, 9)
if not primary then
stroke(b, "Stroke", 1)
end
b.MouseEnter:Connect(function()
tween(b, 0.12, { BackgroundTransparency = 0.15 })
end)
b.MouseLeave:Connect(function()
tween(b, 0.12, { BackgroundTransparency = 0 })
end)
return b
end
makeBtn("No", 0, false).MouseButton1Click:Connect(closeDialog)
makeBtn("Yes", 1, true).MouseButton1Click:Connect(function()
overlay:Destroy()
self._confirmOpen = false
self:_destroy()
end)
overlay.MouseButton1Click:Connect(function() end)
end
function Window:Hide()
self:_closePopups()
self.root.Visible = false
self.gui.Enabled = false
self.hidden = true
if self.Visualizer then
self.Visualizer:SetActive(false)
end
end
function Window:Show()
self.gui.Enabled = true
self.root.Visible = true
self.hidden = false
if self.Visualizer then
self.Visualizer:SetActive(true)
end
end
function Window:Toggle()
if self.hidden or not self.gui.Enabled then
self:Show()
else
self:Hide()
end
return not self.hidden
end
function Window:BindToggleKey(key)
UserInputService.InputBegan:Connect(function(input, gpe)
if not gpe and input.KeyCode == key then
self:Toggle()
end
end)
end
function Window:CreateStatusBar(items, rightText)
self.statusBar.Visible = true
self.statusHeight = 32
for _, t in pairs(self.tabs) do
t.page.Size = UDim2.new(1, 0, 1, -32)
end
self._statusHooked = true
local holder = new("Frame", {
BackgroundTransparency = 1,
Position = UDim2.new(0, 12, 0, 0),
Size = UDim2.new(1, -180, 1, 0),
Parent = self.statusBar,
})
local hl = list(holder, Enum.FillDirection.Horizontal, 18)
hl.VerticalAlignment = Enum.VerticalAlignment.Center
local labels = {}
for i, item in ipairs(items or {}) do
local it = type(item) == "table" and tostring(item.Text or item.Name or "") or tostring(item)
local b = new("TextButton", {
Text = it,
Font = Enum.Font.GothamMedium,
TextSize = 11,
BackgroundTransparency = 1,
AutoButtonColor = false,
Size = UDim2.new(
0,
TextService:GetTextSize(it, 11, Enum.Font.GothamMedium, Vector2.new(400, 20)).X + 6,
1,
0
),
LayoutOrder = i,
Parent = holder,
Theme = {
TextColor3 = i == 1 and "Text" or "SubText",
},
})
b.MouseButton1Click:Connect(function()
for _, o in ipairs(labels) do
o.TextColor3 = Ui.CurrentTheme.SubText
end
b.TextColor3 = Ui.CurrentTheme.Text
end)
labels[#labels + 1] = b
end
local right = new("TextLabel", {
Text = rightText or "\u{25cf} Ready",
Font = Enum.Font.Gotham,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Right,
BackgroundTransparency = 1,
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -14, 0.5, 0),
Size = UDim2.new(0, 160, 1, 0),
Parent = self.statusBar,
Theme = {
TextColor3 = "SubText",
},
})
return {
SetStatus = function(_, txt, ok)
right.Text = (ok and "\u{25cf} " or "\u{25cf} ") .. txt
right.TextColor3 = ok and Ui.CurrentTheme.Success or Ui.CurrentTheme.SubText
end,
}
end
function Window:CreateToolbar(tab, buttons, rightButton)
local bar = new("Frame", {
Size = UDim2.new(1, 0, 0, 36),
BorderSizePixel = 0,
LayoutOrder = tab:_next(),
Parent = tab.page,
Theme = {
BackgroundColor3 = "Panel",
},
})
corner(bar, 10)
stroke(bar)
local left = new("Frame", {
BackgroundTransparency = 1,
Position = UDim2.new(0, 8, 0, 0),
Size = UDim2.new(1, -16, 1, 0),
Parent = bar,
})
local hl = list(left, Enum.FillDirection.Horizontal, 4)
hl.VerticalAlignment = Enum.VerticalAlignment.Center
local function mk(def, parent, order)
local primary = def.Primary == true
local w = TextService:GetTextSize(def.Name, 12, Enum.Font.GothamBold, Vector2.new(400, 20)).X + 44
local b = new("TextButton", {
Text = "",
AutoButtonColor = false,
BackgroundTransparency = primary and 0 or 1,
BorderSizePixel = 0,
Size = UDim2.new(0, w, 0, 26),
LayoutOrder = order,
Parent = parent,
Theme = {
BackgroundColor3 = primary and "Accent" or "Hover",
},
})
corner(b, 6)
iconLabel({
Icon = def.Icon or Ui.Icons.play,
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 8, 0.5, 0),
Size = UDim2.new(0, 15, 0, 15),
Parent = b,
Theme = {
ImageColor3 = primary and "AccentText" or (def.Disabled and "Dim" or "SubText"),
},
})
new("TextLabel", {
Text = def.Name,
Font = Enum.Font.GothamBold,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
Position = UDim2.new(0, 28, 0, 0),
Size = UDim2.new(1, -34, 1, 0),
Parent = b,
Theme = {
TextColor3 = primary and "AccentText" or (def.Disabled and "Dim" or "Text"),
},
})
b.MouseEnter:Connect(function()
if not def.Disabled then
b.BackgroundTransparency = primary and 0.15 or 0
end
end)
b.MouseLeave:Connect(function()
b.BackgroundTransparency = primary and 0 or 1
end)
b.MouseButton1Click:Connect(function()
if not def.Disabled and def.Callback then
task.spawn(def.Callback)
end
end)
return b
end
for i, def in ipairs(buttons or {}) do
mk(def, left, i)
end
if rightButton then
local rb = mk(rightButton, bar, 1)
rb.AnchorPoint = Vector2.new(1, 0.5)
rb.Position = UDim2.new(1, -8, 0.5, 0)
left.Size = UDim2.new(1, -(rb.Size.X.Offset + 24), 1, 0)
end
return bar
end
function Window:CreateTabStrip(tab, cfg)
cfg = cfg or {}
local strip = new("Frame", {
Size = UDim2.new(1, 0, 0, 34),
BackgroundTransparency = 1,
LayoutOrder = tab:_next(),
Parent = tab.page,
})
local hl = list(strip, Enum.FillDirection.Horizontal, 2)
hl.VerticalAlignment = Enum.VerticalAlignment.Center
local api = { files = {} }
local function addFile(name, order)
local w = TextService:GetTextSize(name, 12, Enum.Font.GothamBold, Vector2.new(400, 20)).X + 60
local f = new("TextButton", {
Text = "",
AutoButtonColor = false,
BorderSizePixel = 0,
Size = UDim2.new(0, w, 0, 30),
LayoutOrder = order,
Parent = strip,
Theme = {
BackgroundColor3 = "Panel",
},
})
corner(f, 8)
iconLabel({
Icon = cfg.FileIcon or Ui.Icons.file,
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 10, 0.5, 0),
Size = UDim2.new(0, 14, 0, 14),
Parent = f,
Theme = {
ImageColor3 = "SubText",
},
})
new("TextLabel", {
Text = name,
Font = Enum.Font.GothamBold,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
Position = UDim2.new(0, 28, 0, 0),
Size = UDim2.new(1, -56, 1, 0),
Parent = f,
Theme = {
TextColor3 = "Text",
},
})
local x = iconButton({
Icon = Ui.Icons.close,
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -8, 0.5, 0),
Size = UDim2.new(0, 14, 0, 14),
Parent = f,
Theme = {
ImageColor3 = "SubText",
},
})
x.MouseButton1Click:Connect(function()
f:Destroy()
end)
return f
end
for i, name in
ipairs(cfg.Files or {
"Welcome",
})
do
api.files[i] = addFile(name, i + 1)
end
local plus = iconButton({
Icon = Ui.Icons.plus,
Size = UDim2.new(0, 30, 0, 30),
LayoutOrder = 999,
Parent = strip,
Theme = {
ImageColor3 = "SubText",
BackgroundColor3 = "Hover",
},
})
do
local ip = new("UIPadding", { Parent = plus })
ip.PaddingTop, ip.PaddingBottom = UDim.new(0, 7), UDim.new(0, 7)
ip.PaddingLeft, ip.PaddingRight = UDim.new(0, 7), UDim.new(0, 7)
end
corner(plus, 8)
plus.MouseEnter:Connect(function()
plus.BackgroundTransparency = 0
end)
plus.MouseLeave:Connect(function()
plus.BackgroundTransparency = 1
end)
plus.MouseButton1Click:Connect(function()
local n = #api.files + 1
api.files[n] = addFile(cfg.NewName and (cfg.NewName .. " " .. n) or ("Script " .. n), n + 1)
if cfg.OnNew then
task.spawn(cfg.OnNew, n)
end
end)
api.AddFile = function(_, name)
local n = #api.files + 1
api.files[n] = addFile(name, n + 1)
end
return api
end
function Window:CreateWelcome(tab, cfg)
cfg = cfg or {}
local startCount = #(cfg.Start or {})
local recentCount = math.max(#(cfg.Recent or {}), 1)
local recentY = 70 + 22 + startCount * 30 + 16
local leftH = recentY + 22 + recentCount * 30 + 10
local rightH = 24 + #(cfg.Cards or {}) * 50 + 10
local wrapH = math.max(230, leftH, rightH)
local wrap = new("Frame", {
Size = UDim2.new(1, 0, 0, wrapH),
BackgroundTransparency = 1,
LayoutOrder = tab:_next(),
Parent = tab.page,
})
local left = new("Frame", {
Size = UDim2.new(0.42, 0, 1, 0),
BackgroundTransparency = 1,
Parent = wrap,
})
local welcomeTitle = new("TextLabel", {
Text = Guard.name(),
Font = Enum.Font.GothamBold,
TextSize = 24,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 0, 30),
Parent = left,
Theme = {
TextColor3 = "Text",
},
})
Guard.lock(self.gui, welcomeTitle, {
{ "Text", Guard.name },
{ "Visible", Guard.yes },
{ "TextTransparency", Guard.zero },
})
new("TextLabel", {
Text = cfg.Subtitle or "Script interfaces, designed fast",
Font = Enum.Font.Gotham,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
Position = UDim2.new(0, 0, 0, 32),
Size = UDim2.new(1, 0, 0, 16),
Parent = left,
Theme = {
TextColor3 = "SubText",
},
})
local function column(parent, heading, items, yPos, emptyText)
new("TextLabel", {
Text = string.upper(heading),
Font = Enum.Font.GothamBold,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
Position = UDim2.new(0, 0, 0, yPos),
Size = UDim2.new(1, 0, 0, 16),
Parent = parent,
Theme = {
TextColor3 = "SubText",
},
})
local holder = new("Frame", {
Position = UDim2.new(0, 0, 0, yPos + 22),
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
BackgroundTransparency = 1,
Parent = parent,
})
local l = list(holder, Enum.FillDirection.Vertical, 4)
l.VerticalAlignment = Enum.VerticalAlignment.Top
if #items == 0 then
new("TextLabel", {
Text = emptyText or "Nothing yet",
Font = Enum.Font.Gotham,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 0, 22),
Parent = holder,
Theme = {
TextColor3 = "Dim",
},
})
end
for i, it in ipairs(items) do
local b = new("TextButton", {
Text = "",
AutoButtonColor = false,
BackgroundTransparency = 1,
BorderSizePixel = 0,
Size = UDim2.new(1, 0, 0, 26),
LayoutOrder = i,
Parent = holder,
Theme = {
BackgroundColor3 = "Hover",
},
})
corner(b, 6)
iconLabel({
Icon = it.Icon or Ui.Icons.plus,
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 2, 0.5, 0),
Size = UDim2.new(0, 15, 0, 15),
Parent = b,
Theme = {
ImageColor3 = "SubText",
},
})
new("TextLabel", {
Text = it.Name,
Font = Enum.Font.Gotham,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
Position = UDim2.new(0, 24, 0, 0),
Size = UDim2.new(1, -24, 1, 0),
Parent = b,
Theme = {
TextColor3 = "Text",
},
})
b.MouseEnter:Connect(function()
b.BackgroundTransparency = 0
end)
b.MouseLeave:Connect(function()
b.BackgroundTransparency = 1
end)
b.MouseButton1Click:Connect(function()
if it.Callback then
task.spawn(it.Callback)
end
end)
end
end
column(left, "Start", cfg.Start or {}, 70)
column(left, "Recent", cfg.Recent or {}, recentY, cfg.RecentEmpty or "No scripts run yet")
new("Frame", {
Position = UDim2.new(0.46, 0, 0, 10),
Size = UDim2.new(0, 1, 1, -30),
BorderSizePixel = 0,
Parent = wrap,
Theme = {
BackgroundColor3 = "Stroke",
},
})
local right = new("Frame", {
Position = UDim2.new(0.52, 0, 0, 0),
Size = UDim2.new(0.48, 0, 1, 0),
BackgroundTransparency = 1,
Parent = wrap,
})
new("TextLabel", {
Text = "GET STARTED",
Font = Enum.Font.GothamBold,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 0, 16),
Parent = right,
Theme = {
TextColor3 = "SubText",
},
})
local cards = new("Frame", {
Position = UDim2.new(0, 0, 0, 24),
Size = UDim2.new(1, 0, 1, -24),
BackgroundTransparency = 1,
Parent = right,
})
local cl = list(cards, Enum.FillDirection.Vertical, 8)
cl.VerticalAlignment = Enum.VerticalAlignment.Top
for i, c in ipairs(cfg.Cards or {}) do
local b = new("TextButton", {
Text = "",
AutoButtonColor = false,
BorderSizePixel = 0,
Size = UDim2.new(1, 0, 0, 42),
LayoutOrder = i,
Parent = cards,
Theme = {
BackgroundColor3 = "Panel",
},
})
corner(b, 8)
stroke(b)
hoverable(b, "Panel", "Hover")
iconLabel({
Icon = c.Icon or Ui.Icons.box,
AnchorPoint = Vector2.new(0, 0.5),
Position = UDim2.new(0, 14, 0.5, 0),
Size = UDim2.new(0, 18, 0, 18),
Parent = b,
Theme = {
ImageColor3 = "SubText",
},
})
new("TextLabel", {
Text = c.Name,
Font = Enum.Font.GothamBold,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
Position = UDim2.new(0, 44, 0, 0),
Size = UDim2.new(1, -54, 1, 0),
Parent = b,
Theme = {
TextColor3 = "Text",
},
})
b.MouseButton1Click:Connect(function()
if c.Callback then
task.spawn(c.Callback)
end
end)
end
return wrap
end
local NOTIFY_ICONS = {
Info = "info",
Success = "circle-check",
Warning = "triangle-alert",
Error = "circle-x",
}
function Window:_notifyHolder()
if self._notifyHolder_ and self._notifyHolder_.Parent then
return self._notifyHolder_
end
local holder = new("Frame", {
Name = "Notifications",
AnchorPoint = Vector2.new(1, 0),
Position = UDim2.new(1, -12, 0, 12),
BackgroundTransparency = 1,
ZIndex = 300,
Parent = self.gui,
})
local function resize()
local size = self.gui.AbsoluteSize
holder.Size = UDim2.new(0, math.min(260, math.max(160, size.X - 24)), 0, math.max(0, size.Y - 32))
end
resize()
self.gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
new("UIListLayout", {
Padding = UDim.new(0, 6),
VerticalAlignment = Enum.VerticalAlignment.Top,
HorizontalAlignment = Enum.HorizontalAlignment.Right,
SortOrder = Enum.SortOrder.LayoutOrder,
Parent = holder,
})
self._notifyHolder_ = holder
self._notifyCount = 0
self._activeNotifications = {}
return holder
end
function Window:Notify(cfg)
cfg = cfg or {}
local holder = self:_notifyHolder()
self._notifyCount = self._notifyCount + 1
local buttons = type(cfg.Buttons) == "table" and cfg.Buttons or {}
local hasButtons = #buttons > 0
local hasProgress = cfg.Progress ~= nil
local duration = math.max(0, tonumber(cfg.Duration) or (hasProgress and 0) or (hasButtons and 8) or 4)
local content = tostring(cfg.Content or cfg.Description or "")
local width = holder.Size.X.Offset
local textWidth = math.max(60, width - 76)
local textH = TextService:GetTextSize(content, 11, Enum.Font.Gotham, Vector2.new(textWidth, 100000)).Y
local contentH = content == "" and 0 or math.min(70, math.max(14, textH + 2))
local hasTrack = duration > 0 or hasProgress
local height = math.max(44, 26 + contentH + (hasTrack and 14 or 8) + (hasButtons and 30 or 0))
local slot = new("Frame", {
Name = "NotificationSlot",
Size = UDim2.new(1, 0, 0, height),
BackgroundTransparency = 1,
LayoutOrder = -self._notifyCount,
ZIndex = 300,
Parent = holder,
})
local n = new("CanvasGroup", {
Name = "Notification",
Position = UDim2.new(0, 36, 0, 0),
Size = UDim2.new(1, 0, 1, 0),
BorderSizePixel = 0,
BackgroundTransparency = 0.08,
GroupTransparency = 1,
ZIndex = 301,
Parent = slot,
Theme = { BackgroundColor3 = "Panel" },
})
corner(n, 10)
local edge = stroke(n, "GlassStroke", 1.2)
edge.Transparency = 0.35
new("UIGradient", {
Rotation = 90,
Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(0.75, 0.75, 0.75)),
Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0),
NumberSequenceKeypoint.new(0.5, 0.45),
NumberSequenceKeypoint.new(1, 0.85),
}),
Parent = edge,
})
local sheen = new("Frame", {
Name = "Sheen",
Size = UDim2.new(1, 0, 1, 0),
BorderSizePixel = 0,
ZIndex = 301,
Parent = n,
Theme = { BackgroundColor3 = "Glass" },
})
new("UIGradient", {
Rotation = 115,
Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0.88),
NumberSequenceKeypoint.new(0.55, 0.95),
NumberSequenceKeypoint.new(1, 1),
}),
Parent = sheen,
})
local badge = new("Frame", {
Name = "Badge",
Position = UDim2.new(0, 10, 0, 10),
Size = UDim2.new(0, 24, 0, 24),
BorderSizePixel = 0,
ZIndex = 302,
Parent = n,
Theme = { BackgroundColor3 = "Accent" },
})
corner(badge, 12)
iconLabel({
Icon = cfg.Icon or NOTIFY_ICONS[cfg.Type or "Info"] or "bell",
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.new(0.5, 0, 0.5, 0),
Size = UDim2.new(0, 12, 0, 12),
ZIndex = 303,
Parent = badge,
Theme = { ImageColor3 = "AccentText" },
})
local titleLabel = new("TextLabel", {
Text = tostring(cfg.Title or Guard.name()),
Font = Enum.Font.GothamBold,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
BackgroundTransparency = 1,
Position = UDim2.new(0, 42, 0, 8),
Size = UDim2.new(1, -76, 0, 16),
ZIndex = 302,
Parent = n,
Theme = { TextColor3 = "Text" },
})
local body = new("ScrollingFrame", {
BackgroundTransparency = 1,
BorderSizePixel = 0,
Position = UDim2.new(0, 42, 0, 25),
Size = UDim2.new(1, -76, 0, contentH),
CanvasSize = UDim2.new(0, 0, 0, textH + 2),
ScrollBarThickness = 2,
ScrollingDirection = Enum.ScrollingDirection.Y,
Visible = content ~= "",
ZIndex = 302,
Parent = n,
Theme = { ScrollBarImageColor3 = "Dim" },
})
local contentLabel = new("TextLabel", {
Text = content,
Font = Enum.Font.Gotham,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left,
TextYAlignment = Enum.TextYAlignment.Top,
TextWrapped = true,
BackgroundTransparency = 1,
Size = UDim2.new(1, -4, 0, textH + 2),
ZIndex = 303,
Parent = body,
Theme = { TextColor3 = "SubText" },
})
local x = iconButton({
Icon = "x",
BackgroundTransparency = 1,
Position = UDim2.new(1, -26, 0, 8),
Size = UDim2.new(0, 16, 0, 16),
ZIndex = 304,
Parent = n,
Theme = { ImageColor3 = "Dim" },
})
ripple(x)
x.MouseEnter:Connect(function()
tween(x, 0.12, { ImageColor3 = Ui.CurrentTheme.Text })
end)
x.MouseLeave:Connect(function()
tween(x, 0.12, { ImageColor3 = Ui.CurrentTheme.Dim })
end)
local fill
if hasTrack then
local track_ = new("Frame", {
Name = "Track",
Position = UDim2.new(0, 10, 1, -7),
Size = UDim2.new(1, -20, 0, 2),
BorderSizePixel = 0,
ZIndex = 302,
Parent = n,
Theme = { BackgroundColor3 = "TrackEmpty" },
})
corner(track_, 4)
fill = new("Frame", {
Name = "Fill",
Size = UDim2.new(hasProgress and math.clamp(tonumber(cfg.Progress) or 0, 0, 1) or 1, 0, 1, 0),
BorderSizePixel = 0,
ZIndex = 303,
Parent = track_,
Theme = { BackgroundColor3 = "Accent" },
})
corner(fill, 4)
end
local closed = false
local api
local function dismiss()
if closed then
return
end
closed = true
for i, item in ipairs(self._activeNotifications) do
if item == api then
table.remove(self._activeNotifications, i)
break
end
end
if slot.Parent then
tween(n, 0.18, { Position = UDim2.new(0, 36, 0, 0), GroupTransparency = 1 })
task.delay(0.18, function()
if slot.Parent then
tween(slot, 0.16, { Size = UDim2.new(1, 0, 0, 0) })
end
end)
task.delay(0.36, function()
if slot.Parent then slot:Destroy() end
end)
end
end
api = { Frame = n, Close = dismiss }
function api:SetProgress(value)
value = math.clamp(tonumber(value) or 0, 0, 1)
if fill then
tween(fill, 0.15, { Size = UDim2.new(value, 0, 1, 0) })
end
if value >= 1 and hasProgress and cfg.AutoClose ~= false then
task.delay(1.2, dismiss)
end
end
function api:SetContent(text)
contentLabel.Text = tostring(text or "")
end
function api:SetTitle(text)
titleLabel.Text = tostring(text or "")
end
if hasButtons then
local row = new("Frame", {
BackgroundTransparency = 1,
Position = UDim2.new(0, 42, 0, 26 + contentH + 4),
Size = UDim2.new(1, -52, 0, 24),
ZIndex = 303,
Parent = n,
})
local rl = list(row, Enum.FillDirection.Horizontal, 6)
rl.VerticalAlignment = Enum.VerticalAlignment.Center
for i, def in ipairs(buttons) do
local label = tostring(def.Name or def.Text or "OK")
local w = TextService:GetTextSize(label, 11, Enum.Font.GothamBold, Vector2.new(300, 20)).X + 22
local primary = def.Primary == true or (def.Primary == nil and i == 1)
local b = new("TextButton", {
Text = label,
Font = Enum.Font.GothamBold,
TextSize = 11,
AutoButtonColor = false,
BorderSizePixel = 0,
Size = UDim2.new(0, w, 0, 22),
LayoutOrder = i,
ZIndex = 304,
Parent = row,
Theme = {
BackgroundColor3 = primary and "Accent" or "Elevated",
TextColor3 = primary and "AccentText" or "Text",
},
})
corner(b, 6)
if not primary then
stroke(b)
end
ripple(b)
b.MouseButton1Click:Connect(function()
if def.Callback then
task.spawn(def.Callback, api)
end
if def.Close ~= false then
dismiss()
end
end)
end
end
if #self._activeNotifications >= 3 then
self._activeNotifications[1].Close()
end
table.insert(self._activeNotifications, api)
tween(n, 0.26, { Position = UDim2.new(0, 0, 0, 0), GroupTransparency = 0 })
if fill and not hasProgress then
TweenService:Create(fill, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) }):Play()
end
x.Activated:Connect(dismiss)
if duration > 0 then task.delay(duration, dismiss) end
return api
end
S.Window = Window
