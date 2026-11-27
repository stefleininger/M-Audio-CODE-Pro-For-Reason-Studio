--------------------------------------------------
-- CODE25 PRO
-- SYSEX PROTOCOL
-- F0 00 01 05 7F 31 04 6D 00 01 01 F7 = Open Session
-- F0 00 01 05 7F 31 04 6D 00 01 00 F7 = Close Session
-- 67 = Write
-- 68 = Read
-- 69 = Reply
--------------------------------------------------

--------------------------------------------------
-- LED ADDRESSES
--------------------------------------------------

local BTN17_OFF_HI = 0x03
local BTN17_OFF_LO = 0x4C
local BTN17_ON_HI  = 0x03
local BTN17_ON_LO  = 0x4D

local BTN18_OFF_HI = 0x03
local BTN18_OFF_LO = 0x5A
local BTN18_ON_HI  = 0x03
local BTN18_ON_LO  = 0x5B

local BTN19_OFF_HI = 0x03
local BTN19_OFF_LO = 0x68
local BTN19_ON_HI  = 0x03
local BTN19_ON_LO  = 0x69

local BTN20_OFF_HI = 0x03
local BTN20_OFF_LO = 0x76
local BTN20_ON_HI  = 0x03
local BTN20_ON_LO  = 0x77

--------------------------------------------------
-- LED COLORS
--------------------------------------------------

local COLOR_OFF     = 0x00
local COLOR_GREEN   = 0x01
local COLOR_CYAN    = 0x02
local COLOR_BLUE    = 0x03
local COLOR_MAGENTA = 0x04
local COLOR_RED     = 0x05
local COLOR_YELLOW  = 0x06
local COLOR_WHITE   = 0x07

--------------------------------------------------
-- XY ENGINE
--
-- Button 17 = SYNTH
-- Button 18 = FX
-- Button 19 = COMBI
-- Button 20 = PERFORMANCE
--
--------------------------------------------------

--------------------------------------------------
-- XY MODE ENGINE
--------------------------------------------------

local MODE_SYNTH = 1
local MODE_FX = 2
local MODE_COMBI = 3
local MODE_PERF = 4

local currentMode = MODE_SYNTH

local xyState =
{
    x = 0,
    y = 0
}

--------------------------------------------------
-- XY Anti-Jitter
-- 1 = très sensible
-- 2 = équilibré
-- 3 = très filtré
-- 4 = mouvements plus grossiers
--------------------------------------------------

local XY_THRESHOLD = 2

--------------------------------------------------
-- GLOBAL ITEM INDEXES
--------------------------------------------------

local g_macro_x_index = nil
local g_macro_y_index = nil

local g_fx_x_index = nil
local g_fx_y_index = nil

local g_combi_x_index = nil
local g_combi_y_index = nil

local g_perf_x_index = nil
local g_perf_y_index = nil

local g_button1_index = nil
local g_last_button1_on = nil

--------------------------------------------------
-- REMOTE INIT
--------------------------------------------------

function remote_init()
	local items={
        {name="Back Button", input="button"},
		{name="Forward Button", input="button"},
		{name="Stop Button", input="button"},
		{name="Play Button", input="button"},
        {name="Rec Button", input="button"},
        
        {name="Button 1", input="button"},
        {name="Button 2", input="button"},
        {name="Button 3", input="button"},
        {name="Button 4", input="button"},
        {name="Button 5", input="button"},
		{name="Fader 1", input="value", min=0, max=127},
		{name="Fader 2", input="value", min=0, max=127},
        {name="Fader 3", input="value", min=0, max=127},
        {name="Fader 4", input="value", min=0, max=127},
        {name="Fader 5", input="value", min=0, max=127},
        {name="Knob 1", input="value", min=0, max=127},
        {name="Knob 2", input="value", min=0, max=127},
        {name="Knob 3", input="value", min=0, max=127},
        {name="Knob 4", input="value", min=0, max=127},

        {name="Button 6", input="button"},
        {name="Button 7", input="button"},
        {name="Button 8", input="button"},
        {name="Button 9", input="button"},
        {name="Button 10", input="button"},
		{name="Fader 6", input="value", min=0, max=127},
		{name="Fader 7", input="value", min=0, max=127},
        {name="Fader 8", input="value", min=0, max=127},
        {name="Fader 9", input="value", min=0, max=127},
        {name="Fader 10", input="value", min=0, max=127},
        {name="Knob 5", input="value", min=0, max=127},
        {name="Knob 6", input="value", min=0, max=127},
        {name="Knob 7", input="value", min=0, max=127},
        {name="Knob 8", input="value", min=0, max=127},

        {name="Button 11", input="button"},
        {name="Button 12", input="button"},
        {name="Button 13", input="button"},
        {name="Button 14", input="button"},
        {name="Button 15", input="button"},
		{name="Fader 11", input="value", min=0, max=127},
		{name="Fader 12", input="value", min=0, max=127},
        {name="Fader 13", input="value", min=0, max=127},
        {name="Fader 14", input="value", min=0, max=127},
        {name="Fader 15", input="value", min=0, max=127},
        {name="Knob 9", input="value", min=0, max=127},
        {name="Knob 10", input="value", min=0, max=127},
        {name="Knob 11", input="value", min=0, max=127},
        {name="Knob 12", input="value", min=0, max=127},

        {name="Button 16", input="button"},
        {name="Button 17", input="button"},
        {name="Button 18", input="button"},
        {name="Button 19", input="button"},
        {name="Button 20", input="button"},
		{name="Fader 16", input="value", min=0, max=127},
		{name="Fader 17", input="value", min=0, max=127},
        {name="Fader 18", input="value", min=0, max=127},
        {name="Fader 19", input="value", min=0, max=127},
        {name="Fader 20", input="value", min=0, max=127},
        {name="Knob 13", input="value", min=0, max=127},
        {name="Knob 14", input="value", min=0, max=127},
        {name="Knob 15", input="value", min=0, max=127},
        {name="Knob 16", input="value", min=0, max=127},

		{name="Pad X", input="value", min=0, max=127},
		{name="Pad Y", input="value", min=0, max=127},

        {name="Macro X", input="value", min=0, max=127},
        {name="Macro Y", input="value", min=0, max=127},

        {name="FX X", input="value", min=0, max=127},
        {name="FX Y", input="value", min=0, max=127},

        {name="Combi X", input="value", min=0, max=127},
        {name="Combi Y", input="value", min=0, max=127},

        {name="Perf X", input="value", min=0, max=127},
        {name="Perf Y", input="value", min=0, max=127},
        
		{name="Pitch Bend", input="value", min=0, max=16383},
		{name="Modulation", input="value", min=0, max=127},
		{name="Aftertouch", input="value", min=0, max=127},
		{name="Sustain Pedal", input="value", min=0, max=127},
		{name="Volume Pedal", input="value", min=0, max=127},
		{name="Keyboard", input="keyboard"},
	}
	remote.define_items(items)

    for i,item in ipairs(items) do

        if item.name == "Macro X" then
            g_macro_x_index = i
        end

        if item.name == "Macro Y" then
            g_macro_y_index = i
        end

        if item.name == "FX X" then
            g_fx_x_index = i
        end

        if item.name == "FX Y" then
            g_fx_y_index = i
        end

        if item.name == "Combi X" then
            g_combi_x_index = i
        end

        if item.name == "Combi Y" then
            g_combi_y_index = i
        end

        if item.name == "Perf X" then
            g_perf_x_index = i
        end

        if item.name == "Perf Y" then
            g_perf_y_index = i
        end

        if item.name == "Button 1" then
            g_button1_index = i
        end

    end

	local inputs={
        {pattern="90 5B ?<???x>", name="Back Button", port=3},
		{pattern="90 5C ?<???x>", name="Forward Button", port=3},
		{pattern="90 5D ?<???x>", name="Stop Button", port=3},
		{pattern="90 5E ?<???x>", name="Play Button", port=3},
        {pattern="90 5F ?<???x>", name="Rec Button", port=3},

		{pattern="B? 03 ?<???x>", name="Button 1"},
		{pattern="B? 09 ?<???x>", name="Button 2"},
		{pattern="B? 0E ?<???x>", name="Button 3"},
		{pattern="B? 0F ?<???x>", name="Button 4"},
        {pattern="B? 10 ?<???x>", name="Button 5"},
        {pattern="B? 11 ?<???x>", name="Button 6"},
		{pattern="B? 12 ?<???x>", name="Button 7"},
		{pattern="B? 13 ?<???x>", name="Button 8"},
		{pattern="B? 14 ?<???x>", name="Button 9"},
        {pattern="B? 15 ?<???x>", name="Button 10"},
        {pattern="B? 16 ?<???x>", name="Button 11"},
		{pattern="B? 17 ?<???x>", name="Button 12"},
		{pattern="B? 18 ?<???x>", name="Button 13"},
        {pattern="B? 19 ?<???x>", name="Button 14"},
        {pattern="B? 1A ?<???x>", name="Button 15"},
        {pattern="B? 1B ?<???x>", name="Button 16"},
		{pattern="B? 1C ?<???x>", name="Button 17"},
		{pattern="B? 1D ?<???x>", name="Button 18"},
		{pattern="B? 1E ?<???x>", name="Button 19"},
        {pattern="B? 1F ?<???x>", name="Button 20"},

        {pattern="B? 3E xx", name= "Fader 1"},
        {pattern="B? 3F xx", name= "Fader 2"},
        {pattern="B? 4B xx", name= "Fader 3"},
        {pattern="B? 4C xx", name= "Fader 4"},
        {pattern="B? 4D xx", name= "Fader 5"},
        {pattern="B? 4E xx", name= "Fader 6"},
        {pattern="B? 4F xx", name= "Fader 7"},
        {pattern="B? 50 xx", name= "Fader 8"},
        {pattern="B? 51 xx", name= "Fader 9"},
        {pattern="B? 52 xx", name= "Fader 10"},
        {pattern="B? 53 xx", name= "Fader 11"},
        {pattern="B? 55 xx", name= "Fader 12"},
        {pattern="B? 56 xx", name= "Fader 13"},
        {pattern="B? 57 xx", name= "Fader 14"},
        {pattern="B? 59 xx", name= "Fader 15"},
        {pattern="B? 5A xx", name= "Fader 16"},
        {pattern="B? 66 xx", name= "Fader 17"},
        {pattern="B? 67 xx", name= "Fader 18"},
        {pattern="B? 68 xx", name= "Fader 19"},
        {pattern="B? 69 xx", name= "Fader 20"},

        {pattern="B? 23 xx", name= "Knob 1"},
        {pattern="B? 29 xx", name= "Knob 2"},
        {pattern="B? 2C xx", name= "Knob 3"},
        {pattern="B? 2D xx", name= "Knob 4"},
        {pattern="B? 2E xx", name= "Knob 5"},
        {pattern="B? 2F xx", name= "Knob 6"},
        {pattern="B? 34 xx", name= "Knob 7"},
        {pattern="B? 35 xx", name= "Knob 8"},
        {pattern="B? 36 xx", name= "Knob 9"},
        {pattern="B? 37 xx", name= "Knob 10"},
        {pattern="B? 38 xx", name= "Knob 11"},
        {pattern="B? 39 xx", name= "Knob 12"},
        {pattern="B? 3A xx", name= "Knob 13"},
        {pattern="B? 3B xx", name= "Knob 14"},
        {pattern="B? 3C xx", name= "Knob 15"},
        {pattern="B? 3D xx", name= "Knob 16"},

        {pattern="B? 6A xx", name= "Pad X"},
        {pattern="B? 6B xx", name= "Pad Y"},

		{pattern="E? xx yy", name="Pitch Bend", value="y*128 + x"},
		{pattern="B? 01 xx", name="Modulation"},
		{pattern="D? xx", name="Aftertouch"},
		{pattern="B? 40 xx", name="Sustain Pedal"},
		{pattern="B? 07 xx", name="Volume Pedal"},
		{pattern="9? xx 00", name="Keyboard", value="0", note="x", velocity="64", port=1},
		{pattern="<100x>? yy zz", name="Keyboard", port=1},
	}

    remote.define_auto_inputs(inputs)

    setMode(MODE_SYNTH)
    initButton1LedTest()
    
end

--------------------------------------------------
-- PROBE
--------------------------------------------------

function remote_probe(manufacturer,model,prober)
    local request_events={remote.make_midi("F0 7E 7F 06 01 F7")}
    local response="F0 7E 7F 06 02 00 01 05 31 04 ?? ?? ?? ?? F7"
    
    local results = {}

    local function match_events(mask,events)
        for i,event in ipairs(events) do
            local res=remote.match_midi(mask,event)
            if res~=nil then
              return true
            end
        end
        return false
    end

    local responsePairs={}
    for outPortIndex = 1,prober.out_ports do
        prober.midi_send_function(outPortIndex,request_events)
        prober.wait_function(50)
        for inPortIndex = 1,prober.in_ports do
            local tmp={}
            local events=prober.midi_receive_function(inPortIndex)
            local count = 0
            local respondingPort = 0
            if match_events(response,events) then
                respondingPort = inPortIndex
                count = count + 1
            end
            
            if count == 1 then
                responsePairs[outPortIndex] = respondingPort
            end
        end        
    end
    
    local ordered_keys = {}
    for k in pairs(responsePairs) do
        table.insert(ordered_keys, k)
    end
    table.sort(ordered_keys)
    local i=1
    while i <= #ordered_keys do
        local outPort = ordered_keys[i]
        local inPort = ordered_keys[i] -- tonumber(responsePairs[ordered_keys[i]])
        
        local nextOutPort = ordered_keys[i+1]
        if(nextOutPort ~= nil) then
            local nextInPort = responsePairs[ordered_keys[i+1]]
            
            if(inPort+3 == nextInPort and outPort+3 == nextOutPort) then
                local one_result={ in_ports={inPort, inPort+3, inPort+2}, out_ports={outPort, outPort+3, outPort+2}}
                table.insert(results,one_result)
                i = i + 1
            end
        end
        i = i + 1
    end
    return results
    
end

--------------------------------------------------
-- XY ROUTING
--------------------------------------------------

function routeXY()

    if currentMode == MODE_SYNTH then

        remote.handle_input({
            item = g_macro_x_index,
            value = xyState.x
        })

        remote.handle_input({
            item = g_macro_y_index,
            value = xyState.y
        })

    elseif currentMode == MODE_FX then

        remote.handle_input({
            item = g_fx_x_index,
            value = xyState.x
        })

        remote.handle_input({
            item = g_fx_y_index,
            value = xyState.y
        })

    elseif currentMode == MODE_COMBI then

        remote.handle_input({
            item = g_combi_x_index,
            value = xyState.x
        })

        remote.handle_input({
            item = g_combi_y_index,
            value = xyState.y
        })

    elseif currentMode == MODE_PERF then

        remote.handle_input({
            item = g_perf_x_index,
            value = xyState.x
        })

        remote.handle_input({
            item = g_perf_y_index,
            value = xyState.y
        })

    end

end

--------------------------------------------------
-- MODE MANAGEMENT
--------------------------------------------------

local pendingLedMessages = {}

function queueLed(addr_hi, addr_lo, color)

    table.insert(
        pendingLedMessages,
        code25_led(addr_hi, addr_lo, color)
    )

end

function code25_led(addr_hi, addr_lo, color)

    return remote.make_midi(string.format(
        "F0 00 01 05 7F 31 04 67 00 00 00 %02X %02X 00 %02X F7",
        addr_hi,
        addr_lo,
        color
    ))

end

function setMode(mode)

    currentMode = mode

    xyState.x = 0
    xyState.y = 0

    pendingLedMessages = {}

    --------------------------------------------------
    -- Tout éteindre
    --------------------------------------------------

    queueLed(BTN17_OFF_HI, BTN17_OFF_LO, COLOR_OFF)
    queueLed(BTN17_ON_HI, BTN17_ON_LO, COLOR_GREEN)
    queueLed(BTN18_OFF_HI, BTN18_OFF_LO, COLOR_OFF)
    queueLed(BTN18_ON_HI, BTN18_ON_LO, COLOR_CYAN)
    queueLed(BTN19_OFF_HI, BTN19_OFF_LO, COLOR_OFF)
    queueLed(BTN19_ON_HI, BTN19_ON_LO, COLOR_BLUE)
    queueLed(BTN20_OFF_HI, BTN20_OFF_LO, COLOR_OFF)
    queueLed(BTN20_ON_HI, BTN20_ON_LO, COLOR_MAGENTA)

    --------------------------------------------------
    -- Allumer le mode actif
    --------------------------------------------------

    if mode == MODE_SYNTH then

        queueLed(BTN17_OFF_HI, BTN17_OFF_LO, COLOR_GREEN)

    elseif mode == MODE_FX then

        queueLed(BTN18_OFF_HI, BTN18_OFF_LO, COLOR_CYAN)

    elseif mode == MODE_COMBI then

        queueLed(BTN19_OFF_HI, BTN19_OFF_LO, COLOR_BLUE)

    elseif mode == MODE_PERF then

        queueLed(BTN20_OFF_HI, BTN20_OFF_LO, COLOR_MAGENTA)

    end

end

--------------------------------------------------
-- MIDI PROCESSING
--------------------------------------------------

function remote_process_midi(event)

    --------------------------------------------------
    -- Boutons de mode : CC 28 à 31
    --------------------------------------------------

    if event[1] >= 176 and event[1] <= 191 then

        if event[2] == 28 and event[3] > 0 then

            setMode(MODE_SYNTH)
            return true

        elseif event[2] == 29 and event[3] > 0 then

            setMode(MODE_FX)
            return true

        elseif event[2] == 30 and event[3] > 0 then

            setMode(MODE_COMBI)
            return true

        elseif event[2] == 31 and event[3] > 0 then

            setMode(MODE_PERF)
            return true

        end

    end

    --------------------------------------------------
    -- Pad X : CC 106
    --------------------------------------------------

    if event[2] == 106 then

        local newValue = event[3]

        if math.abs(newValue - xyState.x) < XY_THRESHOLD then
            return true
        end

        xyState.x = newValue
        routeXY()

        return true

    end

    --------------------------------------------------
    -- Pad Y : CC 107
    --------------------------------------------------

    if event[2] == 107 then

        local newValue = event[3]

        if math.abs(newValue - xyState.y) < XY_THRESHOLD then
            return true
        end

        xyState.y = newValue

        routeXY()

        return true

    end

    return false

end

--------------------------------------------------
-- MIDI DELIVERY
--------------------------------------------------

--------------------------------------------------
-- SORTIE LED
-- Utiliser le port validé dans SendSX.
--
-- 1 = Code 25
-- 2 = MIDIOUT4 (Code 25) / Editor
-- 3 = MIDIOUT3 (Code 25) / HUI
--------------------------------------------------

local LED_OUTPUT_PORT = 2

function remote_deliver_midi(max_bytes, port)

    if port ~= LED_OUTPUT_PORT then
        return {}
    end

    if #pendingLedMessages == 0 then
        return {}
    end

    if max_bytes < 16 then
        return {}
    end

    local message = table.remove(pendingLedMessages, 1)

    return {message}

end

function remote_prepare_for_use()

-----------------------------------------------
-- OUVERTURE DE SESSION SYSEX
-----------------------------------------------

    return {

        remote.make_midi(
            "F0 00 01 05 7F 31 04 6D 00 01 01 F7"
        ),

    }

end

function remote_release_from_use()

-----------------------------------------------
-- FERMETURE DE SESSION SYSEX
-----------------------------------------------

    return {
        remote.make_midi(
            "F0 00 01 05 7F 31 04 6D 00 01 00 F7"
        )
    }

end

--------------------------------------------------
-- TEST ISOLD LED BOUTON 1 (VIA queueLed)
--------------------------------------------------

local BTN1_ADDR_HI = 0x01
local BTN1_ADDR_LO = 0x6C -- Tester 0x6D si 0x6C laisse la LED rouge fixe

local function queueButton1LedState(is_on)
	if g_last_button1_on == is_on then
		return
	end
	g_last_button1_on = is_on
	local color = is_on and COLOR_GREEN or COLOR_OFF
	queueLed(BTN1_ADDR_HI, BTN1_ADDR_LO, color)
end

function initButton1LedTest()
	g_last_button1_on = nil
	queueButton1LedState(false)
end

local function read_button1_is_on(entry)
	if type(entry) == "table" and entry.value ~= nil then
		return (tonumber(entry.value) or 0) > 0
	end
	if g_button1_index ~= nil and remote.get_item_value ~= nil then
		local v = remote.get_item_value(g_button1_index)
		if v ~= nil then
			return (tonumber(v) or 0) > 0
		end
	end
	return false
end

function remote_set_state(changed_items)
	if g_button1_index == nil or type(changed_items) ~= "table" then
		return
	end

	for _, entry in ipairs(changed_items) do
		local idx = nil
		if type(entry) == "number" then
			idx = entry
		elseif type(entry) == "table" then
			idx = entry.item or entry.item_index or entry.index
		end

		if idx == g_button1_index then
			queueButton1LedState(read_button1_is_on(entry))
		end
	end
end