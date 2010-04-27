local bar = _G.Zanzibar

do
	local obj = bar:NewObj({
		name = "time"
	})

	local tonumber = tonumber
	local date = date

	local sec = tonumber(date("%S"))

	local timer = sec
	local limit = 0

	function obj:OnUpdate(elapsed)
		timer = timer + elapsed
		if timer >= limit then
			-- HRT !
			limit = 60 - tonumber(date("%S"))

			self.text:SetText(date("%I:%M"))
			timer = 0
		end
	end

	bar:AddItem(obj)
end

do
	local obj = bar:NewObj({
		name = "honor",
		events = { "HONOR_CURRENCY_UPDATE" }
	})

	local today
	function obj:HONOR_CURRENCY_UPDATE()
		today = select(2, GetPVPSessionStats())

		self.text:SetText(GetHonorCurrency() .. " (" .. today .. ")")
	end

	obj.init = obj.HONOR_CURRENCY_UPDATE

	bar:AddItem(obj)
end

do
	local obj = bar:NewObj()
	obj.name = "gold"
	obj.events = { "PLAYER_MONEY" }

	local money, gold, silver, copper

	function obj:PLAYER_MONEY()
		money = GetMoney()
		if money > 1e7 then
			gold = math.floor((math.abs(money / 10000)) / 100)/10 .. "k"
		else
			gold = math.floor(money / 100) / 100 .. "g"
		end

		self.text:SetText(gold)
	end

	obj.init = obj.PLAYER_MONEY

	bar:AddItem(obj)
end

do
	local obj = bar:NewObj()
	obj.name = "talents"
	obj.events = { "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE" }

	local talents, str = {}
	local timer = 20
	function obj:OnUpdate(elap)
		timer = timer + elap
		if timer > 15 then
			timer = 0
			for i = 1, 3 do
				talents[i] = 0
				for j = 1, GetNumTalents(i) do
					talents[i] = talents[i] + select(5, GetTalentInfo(i, j))
				end
			end

			str = string.format("%d/%d/%d (%d)", talents[1], talents[2], talents[3], GetActiveTalentGroup())

			if not (talents[1] == 0 and talents[2] == 0 and talents[3] == 0) then
				self:SetScript("OnUpdate", nil)
				timer = 20
			end

			self.text:SetText(str)
		end
	end

	bar:AddItem(obj)
end

do
	local obj = bar:NewObj()
	obj.name = "fps"

	local timer = 0
	function obj:OnUpdate(elapsed)
		timer = timer + elapsed
		if timer > 5 then
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

	local timer = 30
	local mem = 0
	function obj:OnUpdate(elapsed)
		timer = timer + elapsed
		if timer > 30 then
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


do
	local GetNetStats = GetNetStats

	local obj = bar:NewObj()
	obj.name = mem

	local t = 11

	function obj:OnUpdate(e)
		t = t + e

		if t >= 10 then
			self.text:SetText(select(3, GetNetStats()) .. "ms")
			t = 0
		end
	end

	bar:AddItem(obj)
end

