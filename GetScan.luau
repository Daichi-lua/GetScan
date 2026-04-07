--[[
    ============================================================================
    GET-SCAN PROPRIETARY SOURCE LICENSE (DPSL-1.0)
    Copyright © 2026 Daichi (@DaichiAlt_kage/4076266120) / Heavenly Creation. All Rights Reserved.
    ============================================================================
    
    [ 1. ACCEPTANCE OF TERMS ]
    BY ACCESSING, COPYING, INSTALLING, OR OTHERWISE USING THIS SOFTWARE, YOU 
    AGREE TO BE BOUND BY THE TERMS OF THIS LICENSE. IF YOU DO NOT AGREE TO 
    THESE TERMS, YOU ARE NOT PERMITTED TO USE THE SOFTWARE AND MUST DELETE 
    ALL COPIES IMMEDIATELY.
    
    [ 2. GRANT OF LICENSE ]
    Subject to the terms and conditions of this License, the Licensor hereby 
    grants you a non-exclusive, non-transferable, royalty-free license to 
    use, modify, and integrate this Software into private, non-commercial 
    projects within the Roblox platform.
    
    [ 3. RESTRICTIONS ]
    3.1 NON-COMMERCIAL USE ONLY: You may not sell, rent, lease, or otherwise 
        commercialize this Software or any derivative works.
    3.2 PROHIBITION ON REDISTRIBUTION: You may not redistribute this Software 
        as a standalone product, library, or plugin on any public marketplace 
        or repository for profit or as your own work.
    3.3 PROHIBITION ON PLAGIARISM: You may not remove, obscure, or alter 
        any copyright notices or identification of the Licensor (Daichi) 
        contained within the Software.
    
    [ 4. DERIVATIVE WORKS & ATTRIBUTION ]
    You may create derivative works based on this Software for private use. 
    However, any such derivative work that is shared or distributed must 
    prominently credit "Daichi" as the original author of the underlying 
    architecture and logic.
    
    [ 5. NO VIRAL REQUIREMENT ]
    The use of this Software in your project does not require you to 
    release your own project’s source code under this or any other license. 
    Your original logic remains your proprietary property.
    
    [ 6. DISCLAIMER OF WARRANTY ]
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
    OR IMPLIED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY CLAIM, 
    DAMAGES, OR OTHER LIABILITY ARISING FROM THE USE OF THIS SOFTWARE.
    
    ============================================================================
]]
local GetScan = {}
local Dictionary = require(script.Dictionary)

-- [ SETTINGS ] --
local DEBUG_MODE = false

-- [ INTERNAL STORAGE ] --
local ClassMap = {} 

-- [ PRIVATE UTILITIES ] --
local function Log(msg)
	if DEBUG_MODE then print("? [GetScan]: " .. msg) end
end

local function Warn(msg)
	if DEBUG_MODE then warn("? [GetScan]: " .. msg) end
end

-- [ PROXY BUILT-IN METHODS ] --
-- These are "Special" functions you can call on any Scanned Proxy.
local ProxyMethods = {
	-- Returns a table: [HexID] = CurrentValue
	Serialize = function(proxy)
		local instance = proxy() -- Unwrap via __call
		local allowed = ClassMap[instance.ClassName]
		local data = {}
		for propName, hexID in pairs(allowed) do
			data[hexID] = instance[propName]
		end
		return data
	end,

	-- Returns the HexID for a specific property name
	GetPropHex = function(proxy, propName)
		local instance = proxy()
		return ClassMap[instance.ClassName][propName]
	end
}

-- [ THE UNIFIED SCANNER ] --
function GetScan.Scan(instance)
	if not instance then return Warn("Scan failed: Instance is nil.") end

	local className = instance.ClassName
	local startClock = os.clock()

	-- 1. DISCOVERY PHASE (Discovery Tax: Paid once per Class)
	if not ClassMap[className] then
		Log("Initiating Scan for Class '" .. className .. "'...")
		local validProperties = {}
		local count = 0

		for propName, hexID in pairs(Dictionary) do
			local success = pcall(function() return instance[propName] end)
			if success then
				validProperties[propName] = hexID
				count += 1
			end
		end

		ClassMap[className] = validProperties
		local duration = math.floor((os.clock() - startClock) * 1000)
		Log("Scan Complete: Found " .. count .. " properties in " .. duration .. "ms.")
	end

	-- 2. THE LUAU+ PROXY
	local allowed = ClassMap[className]
	local proxy = {}

	return setmetatable(proxy, {
		__index = function(_, key)
			-- Check if we are calling a Proxy Method (Serialize, etc.)
			if ProxyMethods[key] then 
				return function(...) return ProxyMethods[key](proxy, ...) end 
			end

			-- Check if it's a valid Roblox property
			if allowed[key] then
				return instance[key]
			end

			Warn("Property Access Denied: '" .. tostring(key) .. "' is not valid for " .. className)
			return nil
		end,

		__newindex = function(_, key, value)
			if allowed[key] then
				instance[key] = value
			else
				Warn("Modification Denied: Cannot set '" .. tostring(key) .. "' on " .. className)
			end
		end,

		__call = function() return instance end,
		__tostring = function() return "Dictionary<" .. className .. ">(" .. instance.Name .. ")" end
	})
end

-- [ RECURSIVE DEEP SCAN ] --
-- Scans an object and all its children, returning a table of Proxies.
function GetScan.ScanDeep(root)
	if not root then return {} end
	local hierarchy = {}

	-- Scan the root object
	hierarchy[root.Name] = GetScan.Scan(root)

	-- Scan all descendants
	for _, item in ipairs(root:GetDescendants()) do
		-- Only scan things that are real engine objects (not scripts/folders usually)
		if item:IsA("BasePart") or item:IsA("Humanoid") or item:IsA("DataModelMesh") then
			hierarchy[item.Name] = GetScan.Scan(item)
		end
	end

	Log("Deep Scan Complete for '" .. root.Name .. "'.")
	return hierarchy
end

-- [ GLOBAL UTILITIES ] --
function GetScan.SetDebug(state)
	DEBUG_MODE = state
	print("[GetScan]: Debug Mode set to " .. tostring(state))
end

function GetScan.FlushCache()
	ClassMap = {}
	Log("Internal ClassMap Cache cleared.")
end

return GetScan