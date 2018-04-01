local defunico = {}

local WAIT_TYPE_SECONDS = 1
local WAIT_TYPE_UNTIL = 2
local WAIT_TYPE_WHILE = 3
local WAIT_TYPE_FRAME = 4

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
		function self:move_next()
			if (not is_waiting) then
				status, wait_type, wait_value = coroutine.resume(co_ins, instance)
				if status then
					is_waiting = true
				else
					print(debug.traceback(co_ins, wait_type))
				end
			end

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
		return self
	end
	
	function self.start_coroutine(f)
		local co = unico.new(self, f)
		table.insert(self.unico_list, co)
		return co
	end
	function self.update_coroutine(dt)
		self.dt = dt
		for i, co_ins in ipairs(self.unico_list) do
			if co_ins:move_next() == "dead" then
				-- remove unico
				table.remove(self.unico_list, i)
			end
		end
	end
	function self.stop_coroutine(co)
		for co_ins in #self.unico_list do
			if co_ins == co then
				table.remove(self.unico_list, i)
			end
		end
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
return defunico