-- Idea is to have a bar which is none dynamic to display fat itams

local registry = {}
local items = {}
local queue = {}

local CENTER = UIParent:GetCenter()

local bar = CreateFrame("Frame", nil, UIParent)
bar:SetHeight(20)
bar:SetWidth(UIParent:GetWidth())

bar:SetPoint("TOP", UIParent, "TOP")
--bar:SetPoint("CENTER", UIParent, "CENTER")

bar:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 10,
		insets = {left = 1, right = 1, top = 1, bottom = 1},
})
bar:SetBackdropColor(0, 0, 0, 0)
bar:SetBackdropBorderColor(0, 0, 0, 0)

local eventFunc = function(self, event, ...)
	if not self[event] then print(self.name, event) end
	return self[event](self, ...)
end

bar:SetScript("OnEvent", eventFunc)
bar:RegisterEvent("PLAYER_ENTERING_WORLD")

local scale = 0.63999998569489

function bar:PLAYER_ENTERING_WORLD()
	self.init = true

	scale = UIParent:GetScale()

	for init, f in pairs(queue) do
		init(f)
		queue[init] = nil
	end
end

function bar:AddItem(obj)
	local name = obj.name

	if registry[name] then
		return registry[name]
	end

	local f = CreateFrame("Frame", nil, self)
	f.name = name
	f.width = obj.width

	f:SetHeight(20)

	f:SetPoint("TOP", bar, "TOP", 0, - 2)

	if #items > 0 then
		f:SetPoint("LEFT", items[#items], "RIGHT", 5, 0)
	else
		f:SetPoint("LEFT", bar, "LEFT")
	end

	local t = f:CreateFontString(nil, "ARTWORK")
	t:SetFont(obj.font, obj.fontSize, obj.fontFlags)
	t:SetPoint("TOPLEFT")
	t:SetJustifyH(obj.justify)
	t:SetTextColor(obj.col.r, obj.col.g, obj.col.b, obj.col.a)
	t:SetShadowColor(0, 0, 0, 0.8)
	t:SetShadowOffset(0.8, - 0.8)

	f.text = t

	local settext = t.SetText
	function t:SetText(str)
		settext(t, str .. obj.seperator)

		local width = t:GetStringWidth() + 5
		f:SetWidth(width)

		if width ~= f.width then
			bar:Reposition()
		end

		f.width = width
	end

	f:SetScript("OnUpdate", obj.OnUpdate)

	if type(obj.events) == "table" then
		f:SetScript("OnEvent", eventFunc)

		for id, event in pairs(obj.events) do
			f:RegisterEvent(event)
			f[event] = obj[event]
		end
	end

	if obj.OnEnter and obj.OnLeave then
		f:SetScript("OnEnter", obj.OnEnter)
		f:SetScript("OnLeave", obj.OnLeave)
	end

	if self.init then
		obj.init(f)
	else
		queue[obj.init] = f
	end

	registry[name] = f
	table.insert(items, f)

	self:Reposition()

	return f
end

function bar:Reposition()
	local width = 0

	for id, obj in pairs(items) do
		width = width + obj:GetWidth()
	end

	local left = (UIParent:GetCenter()) - (width / 2)
	bar:SetPoint("LEFT", UIParent, "LEFT", left, 0)
end

do
	local objProto = {
		name = "newobj",
		width = 0,
		font = STANDARD_TEXT_FONT,
		fontSize = 14,
		justify = "LEFT",
		point = "CENTER",
		seperator = "    |",
		col = {
			r = 1,
			g = 1,
			b = 1,
			a = 1,
		}
	}

	function objProto:init()
	end

	function bar:NewObj()
		return setmetatable({}, { __index = objProto })
	end
end

_G.Zanzibar = bar
