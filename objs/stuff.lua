local bar = _G.Zanzibar

do
	local obj = bar:NewObj()

	obj.name = "honor"
	obj.events = { "HONOR_CURRENCY_UPDATE" }

	local today
	function obj:HONOR_CURRENCY_UPDATE()
		toady = select(2, GetPVPSessionStats())

		self.text:SetText(toady .. " (" .. GetHonorCurrency() .. ")")
	end

	obj.init = obj.HONOR_CURRENCY_UPDATE

	bar:AddItem(obj)
end

do
	local obj = bar:NewObj()
	obj.name = "time"

	local timer = 60
	function obj:OnUpdate(elapsed)
		timer = timer + elapsed
		if timer >= 59 then
			self.text:SetText(date("%H:%M"))
			timer = 0
		end
	end

	bar:AddItem(obj)
end

do
	local obj = bar:NewObj()
	obj.name = "gold"
	obj.events = { "PLAYER_MONEY" }

	local money, gold, silver, copper

	function obj:PLAYER_MONEY()
		money = GetMoney()
		gold = math.floor(math.abs(money / 10000))
		silver = math.floor(math.abs(math.fmod(money / 100, 100)))

		self.text:SetText(gold .. "." .. silver .. "k")
	end

	obj.init = obj.PLAYER_MONEY

	bar:AddItem(obj)
end

do
	local obj = bar:NewObj()
	obj.name = "talents"
	obj.events = { "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE" }

	local talents, str = {}
	function obj:Update()
		for i = 1, 3 do
			talents[i] = 0
			for j = 1, GetNumTalents(i) do
				talents[i] = talents[i] + select(5, GetTalentInfo(i, j))
			end
		end

		str = string.format("%d/%d/%d (%d)", talents[1], talents[2], talents[3], GetActiveTalentGroup())

		self.text:SetText(str)
	end

	obj.init = obj.Update
	obj.ACTIVE_TALENT_GROUP_CHANGED = obj.Update
	obj.PLAYER_TALENT_UPDATE = obj.Update

	bar:AddItem(obj)
end

do
	local obj = bar:NewObj()
	obj.name = "fps"

	local timer = 0
	function obj:OnUpdate(elapsed)
		timer = timer + elapsed
		if timer > 0.8 then
			self.text:SetText(math.floor(GetFramerate()) .. " fps")
			timer = 0
		end
	end

	bar:AddItem(obj)
end

do
	local GetAddOnMemoryUsage = GetAddOnMemoryUsage
	local UpdateAddOnMemoryUsage = UpdateAddOnMemoryUsage

	local obj = bar:NewObj()
	obj.name = "mem"

	local timer = 0
	local mem = 0
	function obj:OnUpdate(elapsed)
		timer = timer + elapsed
		if timer > 0.8 then
			mem = 0

			UpdateAddOnMemoryUsage()

			for i = 1, GetNumAddOns() do
				mem = mem + GetAddOnMemoryUsage(i)
			end

			self.text:SetText(math.floor(mem * 100 / 1024) / 100 .. "mb")

			timer = 0
		end
	end

	bar:AddItem(obj)
end

