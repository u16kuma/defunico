local defunico = {}

local WAIT_TYPE_SECONDS = 1
local WAIT_TYPE_UNTIL = 2
local WAIT_TYPE_WHILE = 3
local WAIT_TYPE_FRAME = 4
local WAIT_TYPE_MESSAGE = 5
local WAIT_TYPE_INPUT = 6

function defunico.init(self)
	self.unico_list = {}
	self.dt = 0.0

	local unico = {}
	function unico.new(instance, f)
		local self = {}
		local co_ins = coroutine.create(f)
		local status
		local wait_type
		local wait_value
		local is_waiting = false
		local time = 0
		function self:resume()
			if (not is_waiting) then
				status, wait_type, wait_value = coroutine.resume(co_ins, instance)
				if status then
					is_waiting = true
				else
					print(debug.traceback(co_ins, wait_type))
				end
			end
		end
		function self:update_move_next()
			self:resume()
			
			if is_waiting then
				if wait_type == WAIT_TYPE_SECONDS then
					time = time + instance.dt
					if time >= wait_value then
						is_waiting = false
						time = 0
					end
				elseif wait_type == WAIT_TYPE_UNTIL then
					if wait_value() then
						is_waiting = false
					end
				elseif wait_type == WAIT_TYPE_WHILE then
					if (not wait_value()) then
						is_waiting = false
					end
				elseif wait_type == WAIT_TYPE_FRAME then
					wait_value = wait_value - 1
					if wait_value <= 0 then
						is_waiting = false
					end
				end
			end
			
			return coroutine.status(co_ins)
		end
		function self:input_move_next()
			self:resume()

			if is_waiting then
				if wait_type == WAIT_TYPE_INPUT then
					if wait_value(instance.input_pack.action_id, instance.input_pack.action) then
						is_waiting = false
					end
				end
			end

			return coroutine.status(co_ins)
		end
		function self:message_move_next()
			self:resume()

			if is_waiting then
				if wait_type == WAIT_TYPE_MESSAGE then
					if wait_value(instance.message_pack.message_id, instance.message_pack.message, instance.message_pack.sender) then
						is_waiting = false
					end
				end
			end

			return coroutine.status(co_ins)
		end
		return self
	end
	
	function self.start_coroutine(f)
		local co = unico.new(self, f)
		table.insert(self.unico_list, co)
		return co
	end
	function self.stop_coroutine(co)
		for co_ins in #self.unico_list do
			if co_ins == co then
				table.remove(self.unico_list, i)
			end
		end
	end
	function self.update_coroutine(dt)
		self.dt = dt
		for i, co_ins in ipairs(self.unico_list) do
			if co_ins:update_move_next() == "dead" then
				-- remove unico
				table.remove(self.unico_list, i)
			end
		end
	end
	function self.on_input_coroutine(action_id, action)
		self.input_pack = { action_id = action_id, action = action }
		for i, co_ins in ipairs(self.unico_list) do
			if co_ins:input_move_next() == "dead" then
				-- remove unico
				table.remove(self.unico_list, i)
			end
		end
	end
	function self.on_message_coroutine(message_id, message, sender)
		self.message_pack = { message_id = message_id, message = message, sender = sender }
		for i, co_ins in ipairs(self.unico_list) do
			if co_ins:message_move_next() == "dead" then
				-- remove unico
				table.remove(self.unico_list, i)
			end
		end
	end
	function self.wait_until_input(func)
		coroutine.yield(WAIT_TYPE_INPUT, func)
		return self.input_pack
	end
	function self.wait_until_message(func)
		coroutine.yield(WAIT_TYPE_MESSAGE, func)
		return self.message_pack
	end
end

function wait_seconds(sec)
	coroutine.yield(WAIT_TYPE_SECONDS, sec)
end
function wait_msec(msec)
	coroutine.yield(WAIT_TYPE_SECONDS, msec / 1000)
end
function wait_until(func)
	coroutine.yield(WAIT_TYPE_UNTIL, func)
end
function wait_while(func)
	coroutine.yield(WAIT_TYPE_WHILE, func)
end
function wait_next_frame()
	coroutine.yield(WAIT_TYPE_FRAME, 1)
end
function wait_frame(frame)
	coroutine.yield(WAIT_TYPE_FRAME, frame)
end
function wait_infinite()
	while true do
		wait_next_frame()
	end
end
return defunico