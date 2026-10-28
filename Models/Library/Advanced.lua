local UiCtx__ = (getgenv and getgenv() or _G).UiCtx
local Ui, S = UiCtx__.Ui, UiCtx__.S
local UserInputService, TextService = S.UserInputService, S.TextService
local new, corner, stroke, glass, pad, list, tween, iconLabel = S.new, S.corner, S.stroke, S.glass, S.pad, S.list, S.tween, S.iconLabel
local CTRL_W, CTRL_H, CTRL_R, ROW_H, Section, rowBase, rowLabel = S.CTRL_W, S.CTRL_H, S.CTRL_R, S.ROW_H, S.Section, S.rowBase, S.rowLabel
Ui.SyntaxColors = {
Keyword = Color3.fromRGB(255, 99, 132),
Builtin = Color3.fromRGB(180, 110, 255),
Function = Color3.fromRGB(97, 175, 239),
String = Color3.fromRGB(120, 220, 100),
Number = Color3.fromRGB(255, 160, 80),
Constant = Color3.fromRGB(255, 160, 80),
Bracket = Color3.fromRGB(255, 214, 10),
Comment = Color3.fromRGB(106, 115, 125),
Property = Color3.fromRGB(125, 200, 230),
Self = Color3.fromRGB(255, 130, 150),
Operator = Color3.fromRGB(200, 200, 210),
}
Ui.Syntax = { Listeners = {}, MaxLength = 60000 }
do
local Syntax = Ui.Syntax
local KEYWORDS = {}
for w in
("and break continue do else elseif end for function goto if in local not or repeat return then until while export type"):gmatch(
"%S+"
)
do
KEYWORDS[w] = true
end
local BUILTINS = {}
for w in
(
"print warn error assert pcall xpcall pairs ipairs next type typeof tostring tonumber select unpack require loadstring "
.. "setmetatable getmetatable rawget rawset rawequal rawlen tick time wait spawn delay task game workspace script "
.. "math string table os coroutine Instance Vector3 Vector2 CFrame Color3 BrickColor UDim UDim2 Enum Random Ray "
.. "TweenInfo NumberRange NumberSequence ColorSequence Rect bit32 utf8 debug buffer shared _G _VERSION newproxy "
.. "collectgarbage getgenv getrenv getfenv setfenv getrawmetatable setreadonly hookfunction hookmetamethod "
.. "newcclosure checkcaller firesignal fireclickdetector fireproximityprompt firetouchinterest "
.. "setclipboard Drawing isfile readfile writefile makefolder listfiles request http_request"
):gmatch("%S+")
do
BUILTINS[w] = true
end
local ESC = {
["&"] = "&amp;",
["<"] = "&lt;",
[">"] = "&gt;",
['"'] = "&quot;",
["'"] = "&apos;",
}
local function esc(s)
return (s:gsub("[&<>\"']", ESC))
end
local HEX = {}
function Syntax.Rebuild()
HEX = {}
for k, c in pairs(Ui.SyntaxColors) do
if typeof(c) == "Color3" then
HEX[k] = string.format(
'<font color="#%02x%02x%02x">',
math.floor(c.R * 255 + 0.5),
math.floor(c.G * 255 + 0.5),
math.floor(c.B * 255 + 0.5)
)
end
end
end
Syntax.Rebuild()
function Syntax.Highlight(src)
src = tostring(src or "")
local out, n = {}, 0
local function push(text, kind)
n = n + 1
local open = kind and HEX[kind]
if open then
out[n] = open .. esc(text) .. "</font>"
else
out[n] = esc(text)
end
end
local i, len = 1, #src
local prev = ""
while i <= len do
local c = src:sub(i, i)
local ws = src:match("^%s+", i)
if ws then
push(ws)
i = i + #ws
elseif c == "-" and src:sub(i + 1, i + 1) == "-" then
local lvl = src:match("^%-%-%[(=*)%[", i)
local e
if lvl then
local _, ce = src:find("]" .. lvl .. "]", i + 4 + #lvl, true)
e = ce or len
else
local nl = src:find("\n", i, true)
e = nl and (nl - 1) or len
end
push(src:sub(i, e), "Comment")
i = e + 1
prev = "--"
elseif c == '"' or c == "'" or c == "`" then
local j = i + 1
local e
while j <= len do
local d = src:sub(j, j)
if d == "\\" then
j = j + 2
elseif d == c then
e = j
break
elseif d == "\n" then
e = j - 1
break
else
j = j + 1
end
end
e = math.min(e or len, len)
push(src:sub(i, e), "String")
i = e + 1
prev = '"'
elseif c == "[" and src:match("^%[=*%[", i) then
local lvl = src:match("^%[(=*)%[", i)
local _, ce = src:find("]" .. lvl .. "]", i + 2 + #lvl, true)
local e = ce or len
push(src:sub(i, e), "String")
i = e + 1
prev = '"'
elseif c:match("%d") or (c == "." and src:sub(i + 1, i + 1):match("%d")) then
local num = src:match("^0[xXbB][%x_]+", i)
or src:match("^%d[%d_]*%.?[%d_]*[eE][%+%-]?%d+", i)
or src:match("^%.%d[%d_]*[eE][%+%-]?%d+", i)
or src:match("^%d[%d_]*%.?[%d_]*", i)
or src:match("^%.%d[%d_]*", i)
or c
push(num, "Number")
i = i + #num
prev = "0"
elseif c:match("[%a_]") then
local word = src:match("^[%a_][%w_]*", i)
local j = i + #word
local isCall = src:match("^%s*%(", j) ~= nil
local kind
if prev == "." or prev == ":" then
kind = isCall and "Function" or "Property"
elseif KEYWORDS[word] and not (word == "type" or word == "export") then
kind = "Keyword"
elseif word == "true" or word == "false" or word == "nil" then
kind = "Constant"
elseif word == "self" then
kind = "Self"
elseif prev == "function" then
kind = "Function"
elseif BUILTINS[word] then
kind = "Builtin"
elseif isCall then
kind = "Function"
end
push(word, kind)
i = j
prev = word
elseif c:match("[%(%)%[%]{}]") then
push(c, "Bracket")
i = i + 1
prev = c
else
local op = src:match("^%.%.%.?", i)
if op then
push(op, "Operator")
i = i + #op
prev = ".."
elseif c:match("[%+%-%*/%%%^#=<>~:;,%.&|!?@]") then
push(c, "Operator")
i = i + 1
prev = c
else
push(c)
i = i + 1
end
end
end
return table.concat(out)
end
function Syntax.OnColorsChanged(fn)
table.insert(Syntax.Listeners, fn)
end
end
function Ui:SetSyntaxColors(tbl)
for k, v in pairs(tbl or {}) do
Ui.SyntaxColors[k] = v
end
Ui.Syntax.Rebuild()
for _, fn in ipairs(Ui.Syntax.Listeners) do
pcall(fn)
end
end
function Section:CreateEditor(opt)
opt = opt or {}
local highlight = opt.Highlight ~= false
local FONT, SIZE = Enum.Font.Code, opt.TextSize or 13
local holder = new("Frame", {
Size = UDim2.new(1, 0, 0, opt.Height or 240),
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
local box = new("TextBox", {
Text = opt.Default or "",
MultiLine = true,
ClearTextOnFocus = false,
Font = FONT,
TextSize = SIZE,
TextWrapped = false,
TextXAlignment = Enum.TextXAlignment.Left,
TextYAlignment = Enum.TextYAlignment.Top,
BackgroundTransparency = 1,
AutomaticSize = Enum.AutomaticSize.XY,
Size = UDim2.new(1, 0, 1, 0),
PlaceholderText = opt.Placeholder or "-- write your script here",
Parent = scroller,
Theme = {
TextColor3 = "Text",
PlaceholderColor3 = "Dim",
},
})
local overlay = new("TextLabel", {
Text = "",
RichText = true,
Font = FONT,
TextSize = SIZE,
TextWrapped = false,
TextXAlignment = Enum.TextXAlignment.Left,
TextYAlignment = Enum.TextYAlignment.Top,
BackgroundTransparency = 1,
Active = false,
Size = UDim2.new(1, 0, 1, 0),
ZIndex = box.ZIndex + 1,
Parent = box,
Theme = {
TextColor3 = "Text",
},
})
local function refresh()
if highlight and #box.Text <= Ui.Syntax.MaxLength then
overlay.Visible = true
box.TextTransparency = 1
local ok, rich = pcall(Ui.Syntax.Highlight, box.Text)
overlay.Text = ok and rich or ""
if not ok then
box.TextTransparency = 0
overlay.Visible = false
end
else
overlay.Visible = false
box.TextTransparency = 0
end
end
local function followCursor()
if not box:IsFocused() then
return
end
local pos = box.CursorPosition
if pos < 1 then
return
end
local before = box.Text:sub(1, pos - 1)
local _, lines = before:gsub("\n", "")
local lineStart = before:match(".*\n()") or 1
local col = before:sub(lineStart)
local big = Vector2.new(100000, 100000)
local lineH = TextService:GetTextSize("A", SIZE, FONT, big).Y
local w = TextService:GetTextSize(col, SIZE, FONT, big).X
local y = lines * lineH
local view = scroller.AbsoluteWindowSize
local cp = scroller.CanvasPosition
local nx, ny = cp.X, cp.Y
if y < cp.Y then
ny = y
elseif y + lineH > cp.Y + view.Y then
ny = y + lineH - view.Y
end
if w < cp.X then
nx = w
elseif w + 8 > cp.X + view.X then
nx = w + 8 - view.X
end
scroller.CanvasPosition = Vector2.new(math.max(nx, 0), math.max(ny, 0))
end
box:GetPropertyChangedSignal("Text"):Connect(function()
refresh()
task.defer(followCursor)
end)
box:GetPropertyChangedSignal("CursorPosition"):Connect(function()
task.defer(followCursor)
end)
Ui.Syntax.OnColorsChanged(refresh)
refresh()
return {
Instance = holder,
TextBox = box,
Scroller = scroller,
Overlay = overlay,
Get = function()
return box.Text
end,
Set = function(_, v)
box.Text = v
end,
SetHighlight = function(_, on)
highlight = on and true or false
refresh()
end,
}
end
function Section:CreateCheckbox(opt)
opt = opt or {}
local state = opt.Default and true or false
local row = rowBase(self, ROW_H)
rowLabel(row, opt.Icon, opt.Name or "Checkbox", opt.Description, 44)
local box = new("TextButton", {
Text = "",
AutoButtonColor = false,
BorderSizePixel = 0,
Size = UDim2.new(0, 22, 0, 22),
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -14, 0.5, 0),
Parent = row,
Theme = {
BackgroundColor3 = state and "Accent" or "Elevated",
},
})
corner(box, 6)
local bs = stroke(box)
bs.Transparency = state and 1 or 0
local mark1 = new("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5),
Size = UDim2.new(0, 2, 0, 7),
Position = UDim2.new(0.34, 0, 0.56, 0),
Rotation = 45,
BorderSizePixel = 0,
BackgroundTransparency = state and 0 or 1,
Parent = box,
Theme = {
BackgroundColor3 = "AccentText",
},
})
corner(mark1, 1)
local mark2 = new("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5),
Size = UDim2.new(0, 2, 0, 12),
Position = UDim2.new(0.6, 0, 0.4, 0),
Rotation = -45,
BorderSizePixel = 0,
BackgroundTransparency = state and 0 or 1,
Parent = box,
Theme = {
BackgroundColor3 = "AccentText",
},
})
corner(mark2, 1)
local api = {}
function api:Set(v, silent)
state = v and true or false
tween(box, 0.15, {
BackgroundColor3 = state and Ui.CurrentTheme.Accent or Ui.CurrentTheme.Elevated,
})
tween(bs, 0.15, {
Transparency = state and 1 or 0,
})
tween(mark1, 0.12, { BackgroundTransparency = state and 0 or 1 })
tween(mark2, 0.12, { BackgroundTransparency = state and 0 or 1 })
if not silent and opt.Callback then
task.spawn(opt.Callback, state)
end
end
function api:Get()
return state
end
box.MouseButton1Click:Connect(function()
api:Set(not state)
end)
api.Instance = row
return api
end
function Section:CreateProgressBar(opt)
opt = opt or {}
local min, max = opt.Min or 0, opt.Max or 100
local value = math.clamp(opt.Default or min, min, max)
local suffix = opt.Suffix or "%"
local row = rowBase(self, ROW_H)
rowLabel(row, opt.Icon, opt.Name or "Progress", opt.Description)
local function pct(v)
return math.floor(((v - min) / math.max(max - min, 1e-6)) * 100 + 0.5)
end
local valueLabel = new("TextLabel", {
Text = tostring(pct(value)) .. suffix,
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
local bar = new("Frame", {
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
Size = UDim2.new(math.clamp((value - min) / math.max(max - min, 1e-6), 0, 1), 0, 1, 0),
BorderSizePixel = 0,
Parent = bar,
Theme = {
BackgroundColor3 = "Accent",
},
})
corner(fill, 2)
local api = {}
function api:Set(v, silent)
value = math.clamp(v, min, max)
local a = (value - min) / math.max(max - min, 1e-6)
tween(fill, 0.2, {
Size = UDim2.new(a, 0, 1, 0),
})
valueLabel.Text = tostring(pct(value)) .. suffix
if not silent and opt.Callback then
task.spawn(opt.Callback, value)
end
end
function api:Get()
return value
end
api.Instance = row
return api
end
function Section:CreateColorPicker(opt)
opt = opt or {}
local color = opt.Default or Color3.fromRGB(255, 255, 255)
local h, s, v = color:ToHSV()
local open = false
local row = rowBase(self, ROW_H)
rowLabel(row, opt.Icon, opt.Name or "Color", opt.Description)
local swatch = new("TextButton", {
Text = "",
AutoButtonColor = false,
BorderSizePixel = 0,
BackgroundColor3 = color,
Size = UDim2.new(0, 46, 0, CTRL_H),
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -14, 0.5, 0),
Parent = row,
})
corner(swatch, CTRL_R)
stroke(swatch)
local overlay = self.window and self.window.overlay
local PANEL_W, PANEL_H = 210, 190
local panel = new("Frame", {
Size = UDim2.new(0, PANEL_W, 0, 0),
ClipsDescendants = true,
Visible = false,
AnchorPoint = overlay and Vector2.new(0, 0) or Vector2.new(1, 0),
Position = overlay and UDim2.new(0, 0, 0, 0) or UDim2.new(1, -14, 0.5, 18),
BorderSizePixel = 0,
ZIndex = 150,
Parent = overlay or row,
Theme = {
BackgroundColor3 = "Elevated",
},
})
local function place()
if not overlay then
return
end
local rootAbs = self.window.root.AbsolutePosition
local rootSize = self.window.root.AbsoluteSize
local sp = swatch.AbsolutePosition
local x =
math.clamp(sp.X - rootAbs.X - PANEL_W + swatch.AbsoluteSize.X, 8, math.max(8, rootSize.X - PANEL_W - 8))
panel.Position = UDim2.new(0, x, 0, sp.Y - rootAbs.Y + swatch.AbsoluteSize.Y + 6)
end
corner(panel, 10)
stroke(panel)
local sv = new("Frame", {
Active = true,
BorderSizePixel = 0,
BackgroundColor3 = Color3.fromHSV(h, 1, 1),
Position = UDim2.new(0, 12, 0, 12),
Size = UDim2.new(1, -24, 0, 100),
ZIndex = 151,
Parent = panel,
})
corner(sv, 8)
new("UIGradient", {
Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255)),
Transparency = NumberSequence.new(0, 1),
Parent = sv,
})
local svBlack = new("Frame", {
BorderSizePixel = 0,
BackgroundColor3 = Color3.fromRGB(0, 0, 0),
Size = UDim2.new(1, 0, 1, 0),
ZIndex = 152,
Parent = sv,
})
corner(svBlack, 8)
new("UIGradient", {
Rotation = 90,
Transparency = NumberSequence.new(1, 0),
Parent = svBlack,
})
local svCursor = new("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5),
Size = UDim2.new(0, 10, 0, 10),
BackgroundColor3 = Color3.fromRGB(255, 255, 255),
BorderSizePixel = 0,
ZIndex = 154,
Parent = sv,
})
corner(svCursor, 5)
stroke(svCursor, "Stroke", 1.5)
local hue = new("Frame", {
Active = true,
BorderSizePixel = 0,
Position = UDim2.new(0, 12, 0, 124),
Size = UDim2.new(1, -24, 0, 14),
ZIndex = 151,
Parent = panel,
})
corner(hue, 7)
new("UIGradient", {
Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
}),
Parent = hue,
})
local hueCursor = new("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5),
Size = UDim2.new(0, 4, 1, 4),
Position = UDim2.new(0, 0, 0.5, 0),
BackgroundColor3 = Color3.fromRGB(255, 255, 255),
BorderSizePixel = 0,
ZIndex = 154,
Parent = hue,
})
corner(hueCursor, 2)
stroke(hueCursor, "Stroke", 1.5)
local hexBox = new("TextBox", {
Text = string.format(
"#%02X%02X%02X",
math.floor(color.R * 255 + 0.5),
math.floor(color.G * 255 + 0.5),
math.floor(color.B * 255 + 0.5)
),
Font = Enum.Font.Code,
TextSize = 13,
ClearTextOnFocus = false,
TextXAlignment = Enum.TextXAlignment.Center,
BorderSizePixel = 0,
Position = UDim2.new(0, 12, 0, 148),
Size = UDim2.new(1, -24, 0, 30),
ZIndex = 151,
Parent = panel,
Theme = {
TextColor3 = "Text",
BackgroundColor3 = "Elevated",
},
})
corner(hexBox, 8)
stroke(hexBox)
local api = {}
local function apply(silent)
color = Color3.fromHSV(h, s, v)
swatch.BackgroundColor3 = color
sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
hexBox.Text = string.format(
"#%02X%02X%02X",
math.floor(color.R * 255 + 0.5),
math.floor(color.G * 255 + 0.5),
math.floor(color.B * 255 + 0.5)
)
if not silent and opt.Callback then
task.spawn(opt.Callback, color)
end
end
local svDragging, hueDragging = false, false
local function svFromInput(input)
local ap, asz = sv.AbsolutePosition, sv.AbsoluteSize
if asz.X <= 0 or asz.Y <= 0 then
return
end
s = math.clamp((input.Position.X - ap.X) / asz.X, 0, 1)
v = 1 - math.clamp((input.Position.Y - ap.Y) / asz.Y, 0, 1)
apply()
end
local function hueFromInput(input)
local ap, asz = hue.AbsolutePosition, hue.AbsoluteSize
if asz.X <= 0 then
return
end
h = math.clamp((input.Position.X - ap.X) / asz.X, 0, 1)
apply()
end
sv.InputBegan:Connect(function(input)
if
input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
then
svDragging = true
svFromInput(input)
end
end)
hue.InputBegan:Connect(function(input)
if
input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
then
hueDragging = true
hueFromInput(input)
end
end)
UserInputService.InputChanged:Connect(function(input)
if
input.UserInputType ~= Enum.UserInputType.MouseMovement
and input.UserInputType ~= Enum.UserInputType.Touch
then
return
end
if svDragging then
svFromInput(input)
end
if hueDragging then
hueFromInput(input)
end
end)
UserInputService.InputEnded:Connect(function(input)
if
input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
then
svDragging, hueDragging = false, false
end
end)
hexBox.FocusLost:Connect(function()
local text = hexBox.Text:gsub("#", "")
if #text == 6 and text:match("^%x+$") then
local r = tonumber(text:sub(1, 2), 16)
local g = tonumber(text:sub(3, 4), 16)
local b = tonumber(text:sub(5, 6), 16)
color = Color3.fromRGB(r, g, b)
h, s, v = color:ToHSV()
end
apply()
end)
function api:Set(c, silent)
color = c
h, s, v = color:ToHSV()
apply(silent)
end
function api:Get()
return color
end
function api:Open()
if Ui._openPopup and Ui._openPopup ~= api then
pcall(function()
Ui._openPopup:Close()
end)
end
if Ui._openDropdown then
pcall(function()
Ui._openDropdown:Close()
end)
end
Ui._openPopup = api
open = true
panel.Visible = true
place()
tween(panel, 0.18, {
Size = UDim2.new(0, PANEL_W, 0, PANEL_H),
})
end
function api:Close()
open = false
if Ui._openPopup == api then
Ui._openPopup = nil
end
tween(panel, 0.15, {
Size = UDim2.new(0, PANEL_W, 0, 0),
})
task.delay(0.16, function()
if not open then
panel.Visible = false
end
end)
end
swatch.MouseButton1Click:Connect(function()
if open then
api:Close()
else
api:Open()
end
end)
row.AncestryChanged:Connect(function()
if not row:IsDescendantOf(game) then
panel:Destroy()
end
end)
UserInputService.InputBegan:Connect(function(input)
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
if not inside(swatch) and not inside(panel) then
api:Close()
end
end)
apply(true)
api.Instance = row
return api
end
function Section:CreateMultiDropdown(opt)
opt = opt or {}
local options = opt.Options or {}
local selected = {}
if opt.Default then
for _, v in ipairs(opt.Default) do
selected[v] = true
end
end
local open = false
local row = rowBase(self, ROW_H)
rowLabel(row, opt.Icon, opt.Name or "Multi-Select", opt.Description)
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
local function summary()
local count = 0
for _ in pairs(selected) do
count = count + 1
end
if count == 0 then
return opt.Placeholder or "None selected"
end
if count == #options then
return "All selected"
end
return count .. " selected"
end
local sel = new("TextLabel", {
Text = summary(),
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
Text = "",
AutoButtonColor = false,
BorderSizePixel = 0,
BackgroundTransparency = 1,
ZIndex = 151,
Size = UDim2.new(1, 0, 0, 26),
LayoutOrder = i,
Parent = menu,
Theme = {
BackgroundColor3 = "Hover",
},
})
corner(item, 6)
items[#items + 1] = { button = item, text = string.lower(tostring(o)) }
local tick = new("Frame", {
AnchorPoint = Vector2.new(0, 0.5),
Size = UDim2.new(0, 14, 0, 14),
Position = UDim2.new(0, 8, 0.5, 0),
BorderSizePixel = 0,
ZIndex = 152,
Parent = item,
Theme = {
BackgroundColor3 = selected[o] and "Accent" or "TrackEmpty",
},
})
corner(tick, 4)
new("TextLabel", {
Text = tostring(o),
Font = Enum.Font.Gotham,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
ZIndex = 152,
Position = UDim2.new(0, 30, 0, 0),
Size = UDim2.new(1, -38, 1, 0),
Parent = item,
Theme = {
TextColor3 = "Text",
},
})
item.MouseEnter:Connect(function()
item.BackgroundTransparency = 0
end)
item.MouseLeave:Connect(function()
item.BackgroundTransparency = 1
end)
item.MouseButton1Click:Connect(function()
selected[o] = not selected[o] or nil
if selected[o] == false then
selected[o] = nil
end
tick.BackgroundColor3 = (selected[o] and Ui.CurrentTheme.Accent) or Ui.CurrentTheme.TrackEmpty
sel.Text = summary()
if opt.Callback then
local arr = {}
for _, v in ipairs(options) do
if selected[v] then
table.insert(arr, v)
end
end
task.spawn(opt.Callback, arr)
end
end)
end
end
function api:Open()
searchBox.Visible = searchEnabled()
searchBox.Text = ""
if Ui._openPopup and Ui._openPopup ~= api then
pcall(function()
Ui._openPopup:Close()
end)
end
if Ui._openDropdown then
pcall(function()
Ui._openDropdown:Close()
end)
end
Ui._openPopup = api
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
if Ui._openPopup == api then
Ui._openPopup = nil
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
local arr = {}
for _, v in ipairs(options) do
if selected[v] then
table.insert(arr, v)
end
end
return arr
end
function api:Set(arr)
selected = {}
for _, v in ipairs(arr or {}) do
selected[v] = true
end
sel.Text = summary()
rebuild()
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
function Section:CreateTable(opt)
opt = opt or {}
local headers = opt.Headers or {}
local rows = opt.Rows or {}
local widths = opt.Widths
local rowHeight = opt.RowHeight or 28
local maxHeight = opt.MaxHeight or 160
local holder = new("Frame", {
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
BackgroundTransparency = 1,
LayoutOrder = self:_next(),
Parent = self.body,
})
pad(holder, 14, 14, 6, 10)
list(holder, Enum.FillDirection.Vertical, 0)
local function colX(i)
local n = math.max(#headers, 1)
if widths then
local sum, before = 0, 0
for j = 1, #widths do
sum = sum + widths[j]
end
for j = 1, i - 1 do
before = before + widths[j]
end
return before / sum, widths[i] / sum
end
return (i - 1) / n, 1 / n
end
local function makeRow(parent, cells, bold, order)
local r = new("Frame", {
Size = UDim2.new(1, 0, 0, rowHeight),
BackgroundTransparency = 1,
LayoutOrder = order,
Parent = parent,
})
for i, text in ipairs(cells) do
local x, w = colX(i)
new("TextLabel", {
Text = tostring(text),
Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
BackgroundTransparency = 1,
Position = UDim2.new(x, 0, 0, 0),
Size = UDim2.new(w, -6, 1, 0),
Parent = r,
Theme = {
TextColor3 = bold and "SubText" or "Text",
},
})
end
return r
end
if #headers > 0 then
makeRow(holder, headers, true, 0)
new("Frame", {
Size = UDim2.new(1, 0, 0, 1),
BorderSizePixel = 0,
LayoutOrder = 1,
Parent = holder,
Theme = {
BackgroundColor3 = "Stroke",
},
})
end
local scroller = new("ScrollingFrame", {
AutomaticCanvasSize = Enum.AutomaticSize.Y,
CanvasSize = UDim2.new(0, 0, 0, 0),
ScrollBarThickness = 4,
BackgroundTransparency = 1,
BorderSizePixel = 0,
Size = UDim2.new(1, 0, 0, math.min(maxHeight, math.max(#rows, 1) * rowHeight)),
LayoutOrder = 2,
Parent = holder,
Theme = {
ScrollBarImageColor3 = "Dim",
},
})
list(scroller, Enum.FillDirection.Vertical, 0)
local api = {}
local function rebuildRows()
for _, c in ipairs(scroller:GetChildren()) do
if c:IsA("Frame") then
c:Destroy()
end
end
for i, row in ipairs(rows) do
makeRow(scroller, row, false, i)
end
scroller.Size = UDim2.new(1, 0, 0, math.min(maxHeight, math.max(#rows, 1) * rowHeight))
end
function api:SetRows(t)
rows = t
rebuildRows()
end
function api:AddRow(r)
table.insert(rows, r)
rebuildRows()
end
function api:Clear()
rows = {}
rebuildRows()
end
rebuildRows()
api.Instance = holder
return api
end
