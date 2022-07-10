
-- Awesome WM Configuration File -- 
-- https://github.com/misfitxtm/awesomewmconfig -- 

-- **Required libraries
--
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
 pcall(require, "luarocks.loader")

 local gears	= require("gears")
 local awful	= require("awful")
                require("awful.autofocus")
                local wibox	= require("wibox")
                local beautiful	= require("beautiful")
                local naughty	= require("naughty")
                local lain	= require("lain")
		local freedesktop	= require("freedesktop")
		local hotkeys_popup	= require("awful.hotkeys_popup")
		local mytable	= awful.util.table or gears.table

-- Error Handling
-- Fallback to OG template if errors exist
if awesome.startup_errors then
	naughty.notify {
		preset = naughty.config.presets.critical,
		title = "There were errors during startup!",
		text = awesome.startup_errors
	}
end

-- Handle Runtime errors after Startup
do 
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
	if in_error then return end

	in_error = true
	naughty.notify {
		preset = naughty.config.preset.critical,
		title = "There were errors at runtime!",
		text = tostring(err)
	}
	
	in_error = false
end)
end
-- Autotstart windowles processes
-- Function runs once everytime Awesome is started

local function run_once(cmd_arr)
for _, cmd in ipairs(cmd_arr) do 
	awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
end
end

-- Variable Definitions

local themes = {
	"blackburn", 		--1
	"copeland", 		--2
	"dremora", 		--3
	"holo", 		--4
	"multicolor", 		--5
	"powerarrow", 		--6 
	"powerarror-dark", 	--7
	"raindbow", 		--8
	"steamburn", 		--9
	"vertex" 		--10
}

local chosen_theme	= themes[4]
local modkey		= "Mod1"
local altkey		= "Mod4"
local terminal		= "alacritty"
local vi_focus		= false
local cycle_prev	= true
local editor		= "vim"
local browser		= "firefox"
local explorer		= "thunar"
local screenshot	= ""
local powermenu		= "archlinux-logout"
local screenlocker	= "betterlockscreen -l"
awful.util.terminal	= terminal
awful.util.tagnames	= {"Web", "Terminal", "Gaming", "Files", "Other"}
awful.layout.layouts	= { awful.layout.suit.tile, awful.layout.suit.floating}

lain.layout.termfair.nmaster			= 3
lain.layout.termfair.ncol			= 1
lain.layout.termfair.center.nmaster		= 3
lain.layout.termfair.center.ncol		= 1
lain.layout.cascade.tile.offset_x		= 2
lain.layout.cascade.tile.offset_y		= 32
lain.layout.cascade.tile.extra_padding		= 5
lain.layout.cascade.tile.nmaster		= 5
lain.layout.cascade.tile.ncol			= 2

awful.util.taglist_buttons = mytable.join(
	awful.button({}, 1, function(t) t:view_only() end),
	awful.button({modkey}, 1, function(t)
		if client.focus then client.focus:move_to_tag(t) end end),

	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({modkey}, 3, function(t)
		if client.focue then client.focus:toggle_tag(t) end end),

	awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({}, 5, function(t) aeful.tag.viewprev(t.screen) end))

awful.util.tasklist_buttons = mytable.join(
	awful.button({}, 1, function(c)
	if 
		c == client.focus then c.minimized = true
	else
		c:emit_signal("request::actiate", "tasklist", {raise = true}) end
	end),

	awful.button({}, 3, function()
		awful.menu.client_list({theme = {width = 450}}) end),
		awful.button({}, 4, function() awful.client.focus.byidx(1) end),
		awful.button({}, 5, function() awful.client.focus.byidx(-1) end))

beautiful.init(string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme))

-- Create a Launcher widget w/ Main Menu
local myawesomemenu = {
	{"Hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end},
	{"Edit Config", string.format("%s -e %s %s", terminal, editor, awesome.conffile)},
	{"Reload Awesome", awesome.restart},
	{"Logout", function() awesome.quit() end},
}

local mymainmenu = freedesktop.menu.build {
	before = {
		{"Menu", myawesomemenu, beautiful.awesome_icon},
	},

	after = {
		{"Open Terminal", terminal},
	}
}

--No borders when rearranging only 1 non-floating or maximized client
screen.connect_signal("arrange", function(s)
	local only_one = #s.tiled_clients == 1
	for _, c in pairs(s.clients) do
		if only_one and not c.floating or c.maximized then
			c.border_width = 0
		else
			c.border_width = beautiful.border_width
		end end end)
-- Hide Menu when mouse leaves it
mymainmenu.wibox:connect_signal("mouse::leave", function() mymainemenu:hide() end)

-- Create wibox for each screen
awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s) end)

-- Mouse bindings
root.buttons(mytable.join(
	awful.button({}, 3, function() mymainmenu:toggle() end),
	awful.button({}, 4, awful.tag.viewnext),
	awful.button({}, 5, awful.tag.viewprev)
	))

-- Keyboard Bindings
globalkeys = mytable.join(
	
	-- ScreenShot
	awful.key({altkey}, "p", function() awful.spawn(screenshot) end,
	{description = "Take a ScreenShot", group = "hotkeys"}),
	
	-- ScreenLock
	awful.key({altkey, "Control"}, "l", function () awful.spawn(screenlocker) end,
	{description = "Lock Screen", group = "hotkeys"}),
	
	-- Tag Browsing
	awful.key({modkey,}, "Left", awful.tag.viewprev,
		{description = "View Previous", group = "tag"}),
	awful.key({modkey,}, "Right", awful.tag.viewnext,
		{description = "View Next", group = "tag"}),
	awful.key({modkey,}, "Escape", awful.tag.history.restore,
		{description = "Go Back", group = "tag"}),

	-- Non-Empty tag browsing
	awful.key({altkey}, "Left", function () lain.util.tag_view_nonempty(-1) end,
		{description = "View Previous Non-Empty", group = "tag"}),
	awful.key({altkey}, "Right", function () lain.util.tag_view_nonempty(1) end,
		{description = "View Previous Non-Empty", group = "tag"}),

	-- Default Client Focus
	awful.key({altkey,}, "j", function () awful.client.focus.byidx(1) end,
		{description = "Focus Next By Index", group = "client"}),
	awful.key({altkey,}, "k", function () awful.client.focus.byidx(-1) end,
		{description = "Focus Previous By Index", group = "client"}),

	-- By-Direction Client Focus
	awful.key({modkey}, "j", function() awful.client.focus.global_bydirection("down")
		if client.focus then client.focus:raise() end end,
		{description = "Focus Down", group = "client"}),
	awful.key({modkey}, "k", function() awful.client.focus.global_bydirection("up")
		if client.focus then client.focus:raise() end end,
		{description = "Focus Up", group = "client"}),
	awful.key({modkey}, "h", function() awful.client.focus.global_bydirection("left")
		if client.focus then client.focus:raise() end end,
		{description = "Focus Left", group = "client"}),
	awful.key({modkey}, "l", function() awful.client.focus.global_bydirection("right")
		if client.focus then client.focus:raise() end end,
		{description = "Focus Right", group = "client"}),

	-- Layout Manipulation
	awful.key({modkey, "Shift"}, "j", function () awful.client.swap.byidx(1) end,
		{description = "Swap with next client by index", group = "client"}),
	awful.key({modkey, "Shift"}, "k", function () awful.client.swap.byidx(-1) end, 
		{description = "Swap with previous client by index", group = "client"}),
	awful.key({modkey}, "j", function () awful.screen.focus_relative(1) end,
		{description = "Focus Next Screen", group = "screen"}),
	awful.key({modkey}, "k", function () awful.screen.focus_relative(-1) end,
		{description = "Focus Previos Screen", group = "screen"}),
	awful.key({modkey,}, "u", awful.client.urgent.jumpto,
		{description = "Jump to urgent client", group = "client"}),
	awful.key({modkey,}, "Tab", function () 
		if cycle_prev then
			awful.client.focus.history.previous()
		else
			awful.client.focus.byidx(-1)
		end
		if client.focus then
			client.focus:raise()
		end
	end,
		{description = "Cycle with previous", group = "client"}),
		
	-- Change GAPS OTF
	awful.key({altkey, "Control"}, "+", function () lain.util.useless_gaps_resize(2) end,
		{description = "GAPS +1", group = "tag"}),
	awful.key({altkey, "Control"}, "-", function () lain.util.useless_gaps_resize(-2) end,
		{description = "GAPS -1", group = "tag"}),

	-- Dynamic Tagging
	awful.key({modkey, "Shift"}, "n", function () lain.util.add_tag() end,
		{description = "Add new Tag", group = "tag"}),
	awful.key({modkey, "Shift"}, "r", function () lain.util.rename_tag() end,
		{description = "Rename Tag", group = "tag"}),
	awful.key({modkey, "Shift"}, "Left", function () lain.util.move_tag(-1) end,
		{description = "Move Tag Left", group = "tag"}),
	awful.key({modkey, "Shift"}, "Right", function () lain.util.move_tag(1) end,
		{description = "Move Taf Right", group = "tag"}),
	awful.key({modkey, "Shift"}, "d", function () lain.util.delete_tag() end,
		{description = "Delete Tag", group = "tag"}),

	-- Standard Programs
	awful.key({modkey,}, "t", function () awful.spawn(terminal) end,
		{description = "Launch Terminal", group = "launcher"}),
	awful.key({modkey, "Control"}, "r", awesome.restart,
		{description = "Reload Awesome", group = "awesome"}),
	awful.key({modkey, "Control"}, "q", awesome.quit,
		{description = "Quit Awesome", group = "awesome"}),
	awful.key({modkey, "Control"}, "x", function() awful.util.spawn(powermenu) end, 
		{description = "Launch Exit Menu", group = "hotkeys"}),		
	awful.key({modkey, altkey}, "l", function() awful.tag.incmwfact(0.05) end,
		{description = "Increase Master Width Factor", group = "layout"}),	
	awful.key({modkey, altkey}, "h", function() awful.tag.incmwfact(-0.05) end,
		{description = "Decrease Master Width Factor", group = "layout"}),
	awful.key({modkey, "Shift"}, "h",     function () awful.tag.incnmaster( 1, nil, true)	end,
		{description = "increase the number of master clients", group = "layout"}),
	awful.key({modkey, "Shift"}, "l",     function () awful.tag.incnmaster(-1, nil, true)	end,
		{description = "decrease the number of master clients", group = "layout"}),
	awful.key({modkey, "Control"}, "h",     function () awful.tag.incncol( 1, nil, true)    end,
		{description = "increase the number of columns", group = "layout"}),
	awful.key({modkey, "Control"}, "l",     function () awful.tag.incncol(-1, nil, true)	end,
		{description = "decrease the number of columns", group = "layout"}),								    
	awful.key({modkey,}, "space", function () awful.layout.inc(1)	end,
		{description = "select next", group = "layout"}),
	awful.key({modkey, "Shift"}, "space", function () awful.layout.inc(-1)	end,
		{description = "select previous", group = "layout"}),
	awful.key({modkey, "Control"}, "n", function ()
		local c = awful.client.restore()
		if c then
		c:emit_signal("request::activate", "key.unminimize", {raise = true})
	end end,
		{description = "restore minimized", group = "client"}),

	-- Dropdown Application
	awful.key({modkey,}, "z", function() awful.screen.focused().quake:toggle() end,
		{description = "Dropdown Application", group = "launcher"}),

	-- Screen Brightness / Laptop ONLY
--	awful.key({ }, "XF86MonBrightnessUp", function () os.execute("xbacklight -inc 10") end,
--		{description = "+10%", group = "hotkeys"}),
--	awful.key({ }, "XF86MonBrightnessDown", function () os.execute("xbacklight -dec 10") end,
--		{description = "-10%", group = "hotkeys"}),

	-- Volume Control ALSA
	awful.key({}, "XF86AudioRaiseVolume", function() os.execute(string.format("amixer -q set %s 1%%+", beautiful.volume.channel)) beautiful.volume.update() end,
		{description = "Volume UP", group = "hotkeys"}),
	awful.key({}, "XF86AudioLowerVolume", function() os.execute(string.format("amixer -q set %s 1%%-", beautiful.volume.channel)) beautiful.volume.update() end,
		{description = "Volume Down", group = "hotkeys"}),
	awful.key({}, "XF86AudioMute", function() os.execute(string.format("amixer -q set %s toggle", beautiful.volume.togglechannel or beautiful.volume.channel)) beautiful.volume.update()
	end,
		{description = "Volume Mute", group = "hotkeys"}),
	
	-- User Programs
	awful.key({modkey}, "b", function () awful.spawn(browser) end, 
		{description = "Launch Browser", group = "launcher"}),
	awful.key({modkey}, "e", function () awful.spawn(explorer) end,
		{description = "Launch FileManager", group = "launcher"}),
	
	-- Rofi Launcher
	awful.key({modkey}, "r", function () os.execute(string.format("rofi -show %s -theme %s", 'drun', 'Pop-Dark')) end,
		{description = "Launch Rofi", group = "launcher"}),
	
	-- Prompt
	awful.key({modkey, altkey}, "x", function () awful.screen.focused().mypromptbox:run() end,
		{description = "Run Prompt", group = "launcher"}),
	awful.key({modkey, "Shift"}, "x", function () awful.prompt.run
		{
			prompt		= "Run LUA Code::",
			textbox		= awful.screen.focused().mypromptbox.widget,
			exe_callback	= awful.util.eval,
			history_path	= awful.util.get_cache_dir() .. "/history_eval"
		} 
	end,
		{description = "LUA Exec Prompt", group = "awesome"})
	
)
	-- Client Keys
clientkeys = mytable.join(
	awful.key({altkey, "Shift"}, "m", lain.util.magnify_client,
		{description = "Magnify Client", group = "client"}),
	awful.key({modkey,}, "f", function (c) c.fullscreen = not c.fullscreen c:raise() end,
		{description = "Toggle Fullscreen", group = "client"}),
	awful.key({modkey,}, "q", function (c) c:kill() end,
		{description = "Close focused client", group = "client"}),
	awful.key({modkey, "Control"}, "return", function (c) c:swap(awful.client.getmaster()) end,
		{description = "Move to Master", group = "client"}),
	awful.key({modkey,}, "o", function (c) c:move_to_screen() end,
		{description = "Move to Screen", group = "client"}),
	awful.key({modkey, "Shift"}, "t", function (c) c.ontop = not c.ontop end,
		{description = "Toggle Keep on Top", group = "client"}),
	awful.key({modkey,}, "n", function (c) c.minimized = true end,
		{description = "Minimize Client", group = "client"}),
	awful.key({modkey,}, "m", function (c) c.macimized = not c.maximized c:raise() end,
		{description = "Maximize Client", group = "client"}),	
	awful.key({modkey, "Control"}, "m", function (c) c.maximized_vertical = not c.maximized_vertical c:raise() end,
		{description = "Maximize Vertically", group = "client"}),	
	awful.key({modkey, "Shift"}, "m", function (c) c.maximized_horizontal = not c.maximized_horizontal c:raise() end,
		{description = "Maximize Horizontally", group = "client"}))

	-- Bind all key numbers to tags.
	-- WARNING:: Keycodes designed for any keyboard layout
	-- should be mapped to top row of keyboard, ie; 1-9
	for i = 1, 9 do
	globalkeys = mytable.join(globalkeys,
-- View Tag Only.
	awful.key({modkey}, "#" .. i + 9, function ()
		local screen	= awful.screen.focused()
		local tag 	= screen.tags[i]
		if tag then tag:view_only() end end,
	{description = "View Tag #" ..i, group = "tag"}),

-- Toggle Tag Display.
	awful.key({modky, "Control"}, "#" .. i + 9, function ()
		local screeen	= awful.screen.focused()
		local tag	= screen.tags[i]
		if tag then tag:viewtoggle(tag) end end,
	{description = "Toggle Tag #" .. i, group = "tag"}),

-- Move Client to Tag.
	awful.key({modkey, "Shift"}, "#" .. i + 9, function ()
		if client.focus then
		local tag = client.focus.screen.tags[i]
		if tag then
			client.focus:move_to_tag(tag) end end end,
	{description = "Move focused client ot tag #" .. i, group = "tag"}),

--Toggle Tag on Focused Client.
	awful.key({modkey, "Control", "Shift"}, "#" .. i + 9, function ()
		if client.focus then
		local tag = client.focus.screen.tags[i]
		if tag then
			client.focus:toggle_tag(tag) end end end,
	{description = "Toggle Focused Client on Tag #" .. i, group = "tag"})
	) 
end

clientbuttons = mytable.join(
	awful.button({}, 1, function (c) c:emit_signal("request::activate", "mouse_click", {raise = true}) end),
	awful.button({modkey}, 1, function (c) c:emit_signal("request::activate", "mouse_click", {raise = true}) 
		awful.mouse.client.move(c) end),
	awful.button({modkey}, 3, function (c) c:emit_signal("request::activate", "mouse_click", {raise = true})
		awful.mouse.client.resize(c) end) )

-- Set Keys
root.keys(globalkeys)

-- RULES
-- Rules apply to new client ("Manage signal")

awful.rules.rules = {
	{ rule = {},
	properties = {
		border_width		= beautiful.border_width,
		border_color		= beautiful.border_normal,
		focus			= awful.client.focus.filter,
		raise			= true,
		keys			= clientkeys,
		buttons 		= clientbuttons,
		screen			= awful.screen.preferred,
		placement		= awful.placement.no_overlap+awful.placement.no_offscreen,
		size_hints_honor	= false
	}
},

-- Force Floating Clients
	{ rule_any = {
		instance = {
		"pinetry",
		"copyq"
	},
		class = {
		"Spotify",
		"Pcmanfm",
		"disks",
		"Lutris",
		"Galculator"},

-- Note that the name property shown in xprop might be set slightly after creation of the client
-- and the name shown there might not match defined rules here.
name = {
	"Event Tester", --xev
	},
	role = {
		"AlarmWindow",
		"ConfigManager",
		"pop-up"
	}
},
	properties = {
		floating = true
	}},
	 
-- Add TitleBars to Normal Clients and Dialog
	{ rule_any = {type = {"normal", "dialog"}},
	properties = {titlebars_enabled = false }},

	} 
		
-- Signal function exec when client appears
	client.connect_signal("manage", function(c)
		if awesome.startup
			and not c.size_hints.user_position
			and not c.size_hints.program_position then
				awful.placement.no_offscreen(c) end end)

-- Add TitleBars if Rule is set to true.
	client.connect_signal("request::titlebars", function(c)
-- Custom Option
	if beautiful.titlebar_fun then
	beautiful.titlebar_fun(c)
	return
end
-- Default Option
	local buttons = mytable.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", {raise = true})
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", {raise = true})
			awful.mouse.client.resize(c)
		end)
		)

	awful.titlebar(c, {size = 16}) : setup {
-- Left
		{ 
		awful.titlebar.widget.iconwidget(c),
		buttons = buttons,
		layout = wibox.layout.fixed.horizontal
		},
-- Middle
	{
		{-- Title
		align = "center",
		widget = awful.titlebar.widget.titlewidget(c)
		},
		buttons = buttons,
		layout = wibox.layout.flex.horizontal
	},
--Right
	{
		awful.titlebar.widget.floatingbutton (c),
		awful.titlebar.widget.maximizebutton (c),
		awful.titlebar.widget.stickybutton	 (c),
		awful.titlebar.widget.ontopbutton	 (c),
		awful.titlebar.widget.closebutton	 (c),
		layout = wibox.layout.fixed.horizontal()
	},
		layout = wibox.layout.align.horizontal
	}
end)

-- Focus behavior
	client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
	client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- User Variables and Definitions
-- }}}
--
--
awful.spawn.with_shell("nitrogen --restore")
awful.spawn.with_shell("lxsession")
--awful.spawn.with_shell("picom")
