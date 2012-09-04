-------------------------------------------------------------------------------
-- @file awesomerc.lua
-- @author Gigamo &lt;gigamo@gmail.com&gt;
-------------------------------------------------------------------------------

-- {{{1 Tables

local tags      = { }
local statusbar = { }
local promptbox = { }
local taglist   = { }
local layoutbox = { }
local settings  = { }

-- {{{1 Imports

require('awful')
require('awful.autofocus')
require('awful.rules')
require('beautiful')
require('naughty')
require('functions')

require('debian.menu')

-- Load theme
beautiful.init(awful.util.getdir('config')..'/zenburn.lua')

-- {{{1 Variables

settings.modkey      = 'Mod4'
settings.term        = 'gnome-terminal'
settings.explorer    = 'marlin'
settings.browser     = 'google-chrome'
settings.editor_cmd  = 'gedit'
settings.gtg         = 'gtg'
settings.layouts     =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.max
--  awful.layout.suit.magnifier,
--  awful.layout.suit.floating
}

mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

-- {{{1 Tags


--tags.settings = {
--    { name = '1', layout = settings.layouts[1]  },
--    { name = '2', layout = settings.layouts[3]  },
--    { name = '3', layout = settings.layouts[1]  },
--    { name = '4', layout = settings.layouts[1], mwfact = 0.13 },
--    { name = '5', layout = settings.layouts[5]  },
--}

--for s = 1, screen.count() do
--    tags[s] = {}
--    for i, v in ipairs(tags.settings) do
--        tags[s][i] = tag({ name = v.name })
--        tags[s][i].screen = s
--        awful.tag.setproperty(tags[s][i], 'layout', v.layout)
--        awful.tag.setproperty(tags[s][i], 'mwfact', v.mwfact)
--        awful.tag.setproperty(tags[s][i], 'hide',   v.hide)
--    end
--    tags[s][1].selected = true
--end

tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5 }, s, settings.layouts[1])
end

-- {{{1 Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
--   { "manual", settings.term .. " -e man awesome" },
   { "edit config", settings.editor_cmd .. " " .. awesome.conffile },
   { "laptop-only", "/bin/sh /home/craig/.screenlayout/Laptop.sh" },
   { "home screens", "/bin/sh /home/craig/.screenlayout/Home.sh" },
   { "work screens", "/bin/sh /home/craig/.screenlayout/WorkDesk.sh" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu.new({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", settings.term }
                                  }
                         })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })


-- {{{1 Widgets

systray       = widget({ type = 'systray' })
thermalwidget = widget({ type = 'textbox', name = 'thermalwidget' })
memwidget     = widget({ type = 'textbox', name = 'memwidget' })
batwidget     = widget({ type = 'textbox', name = 'batwidget' })
cpuwidget     = widget({ type = 'textbox', name = 'cpuwidget' }) 
clockwidget   = awful.widget.textclock({ align = 'right' })

taglist.buttons = awful.util.table.join(
    awful.button({ }, 1, awful.tag.viewonly),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ settings.modkey }, 1, awful.client.movetotag),
    awful.button({ settings.modkey }, 3, awful.client.toggletag)
    )

for s = 1, screen.count() do
    promptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    layoutbox[s] = awful.widget.layoutbox(s)
    layoutbox[s]:buttons(awful.util.table.join(
                         awful.button({ }, 1, function () awful.layout.inc(settings.layouts, 1) end),
                         awful.button({ }, 3, function () awful.layout.inc(settings.layouts, -1) end)
    ))
    taglist[s] = awful.widget.taglist.new(s, awful.widget.taglist.label.all, taglist.buttons)
    mytasklist[s] = awful.widget.tasklist(function(c)
					    return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)
    statusbar[s] = awful.wibox(
    {
        position = 'top',
        height = '14',
        fg = beautiful.fg_normal,
        bg = beautiful.bg_normal,
        screen = s
    })
    statusbar[s].widgets =
    {
        {
            mylauncher,
            taglist[s],
      	    layoutbox[s],
            promptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        systray,
	clockwidget,
        batwidget,
        memwidget,
        cpuwidget,        
-- thermalwidget,
	mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end

-- {{{1 Binds

root.buttons(awful.util.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

local globalkeys = awful.util.table.join(
    awful.key({ settings.modkey            }, 'Left',  awful.tag.viewprev),
    awful.key({ settings.modkey            }, 'Right', awful.tag.viewnext),
    awful.key({ settings.modkey,           }, 'Escape',awful.tag.history.restore),
    awful.key({ settings.modkey            }, 'x',     function () awful.util.spawn(settings.term) end),
    awful.key({ settings.modkey            }, 'f',     function () awful.util.spawn(settings.browser) end),
    awful.key({ settings.modkey            }, 'e',     function () awful.util.spawn(settings.explorer) end),
    awful.key({ settings.modkey            }, 't',     function () awful.util.spawn(settings.gtg) end),
    awful.key({ settings.modkey, 'Control' }, 'r',     awesome.restart),
    awful.key({ settings.modkey, 'Shift'   }, 'q',     awesome.quit),
    awful.key({ settings.modkey,           }, 'j',     function ()
        awful.client.focus.byidx( 1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ settings.modkey,           }, 'k',     function ()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ settings.modkey, 'Shift'   }, 'j',    function () awful.client.swap.byidx(1) end),
    awful.key({ settings.modkey, 'Shift'   }, 'k',    function () awful.client.swap.byidx(-1) end),
    awful.key({ settings.modkey, 'Control' }, 'j',    function () awful.screen.focus_relative(1) end),
    awful.key({ settings.modkey, 'Control' }, 'k',    function () awful.screen.focus_relative(-1) end),
    awful.key({ settings.modkey,           }, 'u',    awful.client.urgent.jumpto),
    awful.key({ settings.modkey,           }, 'Tab',  function ()
        awful.client.focus.history.previous()
        if client.focus then client.focus:raise() end
    end),
    awful.key({ settings.modkey            }, 'l',     function () awful.tag.incmwfact(0.025) end),
    awful.key({ settings.modkey            }, 'h',     function () awful.tag.incmwfact(-0.025) end),
    awful.key({ settings.modkey, 'Shift'   }, 'h',     function () awful.client.incwfact(0.05) end),
    awful.key({ settings.modkey, 'Shift'   }, 'l',     function () awful.client.incwfact(-0.05) end),
    awful.key({ settings.modkey, 'Control' }, 'h',     function () awful.tag.incnmaster(1) end),
    awful.key({ settings.modkey, 'Control' }, 'l',     function () awful.tag.incnmaster(-1) end),
    awful.key({ settings.modkey            }, 'space', function () awful.layout.inc(settings.layouts, 1) end),
    awful.key({ settings.modkey, 'Shift'   }, 'space', function () awful.layout.inc(settings.layouts, -1) end),
    awful.key({ settings.modkey            }, 'r',     function () promptbox[mouse.screen]:run() end),
    awful.key({ settings.modkey            }, 'F12',   function () awful.util.spawn("xlock") end),
    awful.key({ }, '#121',  function () awful.util.spawn_with_shell('dvol -t') end),
    awful.key({ }, '#122',  function () awful.util.spawn_with_shell('dvol -d 2') end),
    awful.key({ }, '#123',  function () awful.util.spawn_with_shell('dvol -i 2') end)
)

local clientkeys = awful.util.table.join(
    awful.key({ settings.modkey            }, 'c',     function (c) c:kill() end),
    awful.key({ settings.modkey,           }, "o",     awful.client.movetoscreen),
    awful.key({ settings.modkey, 'Control' }, 'space', awful.client.floating.toggle),
    awful.key({ settings.modkey, 'Shift'   }, 'r',     function (c) c:redraw() end),
    awful.key({ settings.modkey            }, 't',     awful.client.togglemarked),
    awful.key({ settings.modkey            }, 'm',     function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical   = not c.maximized_vertical
    end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ settings.modkey }, '#' .. i + 9, function ()
            local screen = mouse.screen
            if tags[screen][i] then
                awful.tag.viewonly(tags[screen][i])
            end
        end),
        awful.key({ settings.modkey, 'Control' }, '#' .. i + 9, function ()
            local screen = mouse.screen
            if tags[screen][i] then
                awful.tag.viewtoggle(tags[screen][i])
            end
        end),
        awful.key({ settings.modkey, 'Shift' }, '#' .. i + 9, function ()
            if client.focus and tags[client.focus.screen][i] then
                awful.client.movetotag(tags[client.focus.screen][i])
            end
        end),
        awful.key({ settings.modkey, 'Control', 'Shift' }, '#' .. i + 9, function ()
            if client.focus and tags[client.focus.screen][i] then
                awful.client.toggletag(tags[client.focus.screen][i])
            end
        end)
    )
end

local clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ settings.modkey }, 1, awful.mouse.client.move),
    awful.button({ settings.modkey }, 3, awful.mouse.client.resize)
)

root.keys(globalkeys)


-- {{{1 Signals

client.add_signal('manage', function (c, startup)
    -- Enable sloppy focus
    c:add_signal('mouse::enter', function (c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
           and awful.client.focus.filter(c) then
               client.focus = c
        end
    end)

    if not startup then
        awful.client.setslave(c)
        awful.placement.no_overlap(c)
        awful.placement.no_offscreen(c)
    end

    c.size_hints_honor = false
end)


awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
}

client.add_signal('focus', function(c) c.border_color = beautiful.border_focus end)
client.add_signal('unfocus', function(c) c.border_color = beautiful.border_normal end)

-- {{{1 Functions

function battery(id)
    -- Ugly long HAL string
    hal = io.popen('hal-get-property --udi /org/freedesktop/Hal/devices/computer_power_supply_battery_'..id..' --key battery.charge_level.percentage')
    pwr = io.popen('hal-get-property --udi /org/freedesktop/Hal/devices/computer_power_supply_battery_'..id..' --key battery.rechargeable.is_charging')
    if hal then
        charge = hal:read('*all')
        hal:close()
    end
    if pwr then
        power = pwr:read('*all')
        pwr:close()
        if power:match('true') then
            crm_indicator = ' ^'
        else
            crm_indicator = ' v'
        end 
    end
    
    return charge:gsub("\n", '')..'%'.. crm_indicator .. ' |'
end

function memory()
    local memfile = io.open('/proc/meminfo')
    if memfile then
        for line in memfile:lines() do
            if line:match("^MemTotal.*") then
                mem_total = math.floor(tonumber(line:match("(%d+)")) / 1024)
            elseif line:match("^MemFree.*") then
                mem_free = math.floor(tonumber(line:match("(%d+)")) / 1024)
            elseif line:match("^Buffers.*") then
                mem_buffers = math.floor(tonumber(line:match("(%d+)")) / 1024)
            elseif line:match("^Cached.*") then
                mem_cached = math.floor(tonumber(line:match("(%d+)")) / 1024)
            end
        end
        memfile:close()
    end
    local mem_in_use = mem_total - (mem_free + mem_buffers + mem_cached)
    local mem_usage_percentage = math.floor(mem_in_use / mem_total * 100)

    return '  '..mem_in_use..'Mb'..' | '
end

function thermal()
    local temperature, howmany = 0, 0
    local sensors = io.popen('sensors')
    if sensors then
        for line in sensors:lines() do
            if line:match(':%s+%+([.%d]+)') then
                howmany = howmany + 1
                temperature = temperature + tonumber(line:match(':%s+%+([.%d]+)'))
            end
        end
        sensors:close()
    end
    temperature = temperature / howmany

    return temperature..'°C'..' | '
end

-- {{{1 Markup

function set_bg(bgcolor, text)
    if text then return '<span background="'..bgcolor..'">'..text..'</span>' end
end

function set_fg(fgcolor, text)
    if text then return '<span color="'..fgcolor..'">'..text..'</span>' end
end

function set_font(font, text)
    if text then return '<span font_desc="'..font..'">'..text..'</span>' end
end

local separator_l = ' '
local separator_r = '| '


function cpu(widget)

    local temperature, howmany = 0, 0
    local sensors = io.popen('sensors')
    if sensors then
        for line in sensors:lines() do
            if line:match(':%s+%+([.%d]+)') then
                howmany = howmany + 1
                temperature = temperature + tonumber(line:match(':%s+%+([.%d]+)'))
            end
        end
        sensors:close()
    end
    temperature = temperature / howmany
    local freq = {}

    --for i = 0, 1 do
        freq = io.fread('/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq'):match('(.*)000')
    --end

    widget.text = separator_l..freq..'/'..freq..'MHz @ '..temperature..'C'..separator_r

end

-- {{{1 Timers

battimer = timer { timeout = 30 }
battimer:add_signal('timeout', function() batwidget.text = battery('BAT1') end)
battimer:start()

memtimer = timer { timeout = 15 }
memtimer:add_signal('timeout', function() memwidget.text = memory() end)
memtimer:start()

thermaltimer = timer { timeout = 10 }
thermaltimer:add_signal('timeout', function() thermalwidget.text = thermal() end)
thermaltimer:start()

cputimer = timer { timeout = 1 }
cputimer:add_signal('timeout', function() cpu(cpuwidget) end)
cputimer:start()

io.stderr:write("\n\rAwesome loaded at "..os.date('%B %d, %H:%M').."\r\n\n")


