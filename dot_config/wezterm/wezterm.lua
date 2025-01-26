-- Pull in the wezterm API
-- parts of code taken from gist https://gist.github.com/alexpls/83d7af23426c8928402d6d79e72f9401

local os              = require 'os'
local wezterm         = require 'wezterm'
local session_manager = require 'wezterm-session-manager/session-manager'
local act             = wezterm.action
local mux             = wezterm.mux
local appearance      = require 'appearance'
local projects        = require 'projects'


-- --------------------------------------------------------------------
-- FUNCTIONS AND EVENT BINDINGS
-- --------------------------------------------------------------------

-- On startup
wezterm.on("gui-startup", function(cmd)
	local _, _, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

local function is_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end

local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "resize" and "CTRL|SHIFT" or "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "CTRL|SHIFT" or "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 5 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end

-- Session Manager event bindings
-- See https://github.com/danielcopper/wezterm-session-manager
wezterm.on("save_session", function(window) session_manager.save_state(window) end)
wezterm.on("load_session", function(window) session_manager.load_state(window) end)
wezterm.on("restore_session", function(window) session_manager.restore_state(window) end)

-- Wezterm <-> nvim pane navigation
-- You will need to install https://github.com/aca/wezterm.nvim
-- and ensure you export NVIM_LISTEN_ADDRESS per the README in that repo

local move_around = function(window, pane, direction_wez, direction_nvim)
    local result = os.execute("env NVIM_LISTEN_ADDRESS=/tmp/nvim" .. pane:pane_id() .. " " .. wezterm.home_dir .. "/.local/bin/wezterm.nvim.navigator" .. " " .. direction_nvim)
    if result then
		window:perform_action(
            act({ SendString = "\x17" .. direction_nvim }),
            pane
        )
    else
        window:perform_action(
            act({ ActivatePaneDirection = direction_wez }),
            pane
        )
    end
end

wezterm.on("move-left", function(window, pane)
	move_around(window, pane, "Left", "h")
end)

wezterm.on("move-right", function(window, pane)
	move_around(window, pane, "Right", "l")
end)

wezterm.on("move-up", function(window, pane)
	move_around(window, pane, "Up", "k")
end)

wezterm.on("move-down", function(window, pane)
	move_around(window, pane, "Down", "j")
end)

-- local vim_resize = function(window, pane, direction_wez, direction_nvim)
-- 	local result = os.execute(
-- 		"env NVIM_LISTEN_ADDRESS=/tmp/nvim"
-- 			.. pane:pane_id()
-- 			.. " "
--             .. wezterm.home_dir
-- 			.. "/.local/bin/wezterm.nvim.navigator"
-- 			.. " "
-- 			.. direction_nvim
-- 	)
-- 	if result then
-- 		window:perform_action(act({ SendString = "\x1b" .. direction_nvim }), pane)
-- 	else
-- 		window:perform_action(act({ ActivatePaneDirection = direction_wez }), pane)
-- 	end
-- end

-- wezterm.on("resize-left", function(window, pane)
-- 	vim_resize(window, pane, "Left", "h")
-- end)

-- wezterm.on("resize-right", function(window, pane)
-- 	vim_resize(window, pane, "Right", "l")
-- end)

-- wezterm.on("resize-up", function(window, pane)
-- 	vim_resize(window, pane, "Up", "k")
-- end)

-- wezterm.on("resize-down", function(window, pane)
-- 	vim_resize(window, pane, "Down", "j")
-- end)

-- --------------------------------------------------------------------
-- CONFIGURATION
-- --------------------------------------------------------------------

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.adjust_window_size_when_changing_font_size = false
config.automatically_reload_config = true
config.color_scheme = 'rose-pine'
config.enable_scroll_bar = true
config.enable_wayland = true
-- config.font = wezterm.font('Hack')
-- config.font = wezterm.font('Monaspace Neon')
config.font = wezterm.font('JetBrains Mono')
config.font_size = 16.0
config.hide_tab_bar_if_only_one_tab = false
-- The leader is similar to how tmux defines a set of keys to hit in order to
-- invoke tmux bindings. Binding to ctrl-a here to mimic tmux
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 5000 }
config.mouse_bindings = {
    -- Open URLs with Ctrl+Click
    {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'CTRL',
        action = act.OpenLinkAtMouseCursor,
    }
}
config.pane_focus_follows_mouse = true
config.scrollback_lines = 5000
config.use_dead_keys = false
config.warn_about_missing_glyphs = false
config.window_decorations = 'TITLE | RESIZE'
config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}

-- Tab bar
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = true
config.switch_to_last_active_tab_when_closing_tab = true
config.tab_max_width = 32
config.colors = {
    tab_bar = {
        active_tab = {
            fg_color = '#073642',
            bg_color = '#2aa198',
        }
    }
}

-- Setup muxing by default
config.unix_domains = {
  {
    name = 'unix',
  },
}

-- Custom key bindings
config.keys = {
    -- -- Disable Alt-Enter combination (already used in tmux to split pane)
    -- {
    --     key = 'Enter',
    --     mods = 'ALT',
    --     action = act.DisableDefaultAssignment,
    -- },

    -- List of commands
    -- { key = "/", mods = "ALT", action = wezterm.action.ShowLauncher },

    -- Copy mode
    {
        key = '[',
        mods = 'LEADER',
        action = act.ActivateCopyMode,
    },

    -- ----------------------------------------------------------------
    -- TABS
    --
    -- Where possible, I'm using the same combinations as I would in tmux
    -- ----------------------------------------------------------------

    -- Show tab navigator; similar to listing panes in tmux
    {
        key = 'w',
        mods = 'LEADER',
        action = act.ShowTabNavigator,
    },
    -- Create a tab (alternative to Ctrl-Shift-Tab)
    {
        key = 'c',
        mods = 'LEADER',
        action = act.SpawnTab 'CurrentPaneDomain',
    },
    -- Rename current tab; analagous to command in tmux
    {
        key = ',',
        mods = 'LEADER',
        action = act.PromptInputLine {
            description = 'Enter new name for tab',
            action = wezterm.action_callback(
                function(window, pane, line)
                    if line then
                        window:active_tab():set_title(line)
                    end
                end
            ),
        },
    },
    -- Move to next/previous TAB
    {
        key = 'n',
        mods = 'LEADER',
        action = act.ActivateTabRelative(1),
    },
    {
        key = 'p',
        mods = 'LEADER',
        action = act.ActivateTabRelative(-1),
    },
    -- Close tab
    {
        key = '&',
        mods = 'LEADER|SHIFT',
        action = act.CloseCurrentTab{ confirm = true },
    },
    {
		key = "9",
		mods = "ALT",
		action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|TABS|WORKSPACES" }),
	},
    -- ----------------------------------------------------------------
    -- PANES
    --
    -- These are great and get me most of the way to replacing tmux
    -- entirely, particularly as you can use "wezterm ssh" to ssh to another
    -- server, and still retain Wezterm as your terminal there.
    -- ----------------------------------------------------------------

    -- -- Vertical split
    {
        -- |
        key = '|',
        mods = 'LEADER|SHIFT',
        action = act.SplitPane {
            direction = 'Right',
            size = { Percent = 50 },
        },
    },
    -- Horizontal split
    {
        -- -
        key = '-',
        mods = 'LEADER',
        action = act.SplitPane {
            direction = 'Down',
            size = { Percent = 50 },
        },
    },
    -- CTRL + (h,j,k,l) to move between panes
    {
        key = 'h',
        mods = 'CTRL',
        action = act({ EmitEvent = "move-left" }),
    },
    {
        key = 'j',
        mods = 'CTRL',
        action = act({ EmitEvent = "move-down" }),
    },
    {
        key = 'k',
        mods = 'CTRL',
        action = act({ EmitEvent = "move-up" }),
    },
    {
        key = 'l',
        mods = 'CTRL',
        action = act({ EmitEvent = "move-right" }),
    },
    -- ALT + (h,j,k,l) to resize panes
    split_nav("resize", "h"),
	split_nav("resize", "j"),
	split_nav("resize", "k"),
	split_nav("resize", "l"),
    -- {
    --     key = 'h',
    --     mods = 'ALT',
    --     action = act({ EmitEvent = "resize-left" }),
    -- },
    -- {
    --     key = 'j',
    --     mods = 'ALT',
    --     action = act({ EmitEvent = "resize-down" }),
    -- },
    -- {
    --     key = 'k',
    --     mods = 'ALT',
    --     action = act({ EmitEvent = "resize-up" }),
    -- },
    -- {
    --     key = 'l',
    --     mods = 'ALT',
    --     action = act({ EmitEvent = "resize-right" }),
    -- },
    -- Close/kill active pane
    {
        key = 'x',
        mods = 'LEADER',
        action = act.CloseCurrentPane { confirm = true },
    },
    -- Swap active pane with another one
    {
        key = '{',
        mods = 'LEADER|SHIFT',
        action = act.PaneSelect { mode = "SwapWithActiveKeepFocus" },
    },
    -- Zoom current pane (toggle)
    {
        key = 'z',
        mods = 'LEADER',
        action = act.TogglePaneZoomState,
    },
    {
        key = 'f',
        mods = 'ALT',
        action = act.TogglePaneZoomState,
    },
    -- Move to next/previous pane
    {
        key = ';',
        mods = 'LEADER',
        action = act.ActivatePaneDirection('Prev'),
    },
    {
        key = 'o',
        mods = 'LEADER',
        action = act.ActivatePaneDirection('Next'),
    },

    -- ----------------------------------------------------------------
    -- Workspaces
    --
    -- These are roughly equivalent to tmux sessions.
    -- ----------------------------------------------------------------

    -- Attach to muxer
    {
        key = 'a',
        mods = 'LEADER',
        action = act.AttachDomain 'unix',
    },

    -- Detach from muxer
    {
        key = 'd',
        mods = 'LEADER',
        action = act.DetachDomain { DomainName = 'unix' },
    },

    -- Show list of workspaces
    {
        key = 's',
        mods = 'LEADER',
        action = act.ShowLauncherArgs { flags = 'WORKSPACES' },
    },
    -- Rename current session; analagous to command in tmux
    {
        key = '$',
        mods = 'LEADER|SHIFT',
        action = act.PromptInputLine {
            description = 'Enter new name for session',
            action = wezterm.action_callback(
                function(window, pane, line)
                    if line then
                        mux.rename_workspace(
                            window:mux_window():get_workspace(),
                            line
                        )
                    end
                end
            ),
        },
    },

    -- Projects
    {
        key = 'p',
        mods = 'LEADER',
        -- Present in to our project picker
        action = projects.choose_project(),
    },

    -- Session manager bindings
    {
        key = 's',
        mods = 'LEADER|SHIFT',
        action = act({ EmitEvent = "save_session" }),
    },
    {
        key = 'L',
        mods = 'LEADER|SHIFT',
        action = act({ EmitEvent = "load_session" }),
    },
    {
        key = 'R',
        mods = 'LEADER|SHIFT',
        action = act({ EmitEvent = "restore_session" }),
    },

	-- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
	{
		key="LeftArrow",
		mods="OPT",
		action=act({SendString="\x1bb"})
	},

	-- Make Option-Right equivalent to Alt-f; forward-word
	{
		key="RightArrow",
		mods="OPT",
		action=act({SendString="\x1bf"})
	},

	-- Launch commands in a new pane
	{
		key = 'g',
		mods = 'CMD',
		action = act.SplitHorizontal{args = { os.getenv("SHELL"), "-c", "lazygit" } }
	}
}

for i = 1, 9 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = "LEADER",
        action = act.ActivateTab(i - 1),
    })
end

-- Header
-- Sets the font for the window frame (tab bar)
config.window_frame = {
    -- Berkeley Mono for me again, though an idea could be to try a
    -- serif font here instead of monospace for a nicer look?
    font = wezterm.font({ family = 'Berkeley Mono', weight = 'Bold' }),
    font_size = 11,
}

local function segments_for_right_status(window)
    return {
      window:active_workspace(),
      wezterm.strftime('%a %b %-d %H:%M:%S'),
      wezterm.hostname(),
    }
  end

  wezterm.on('update-status', function(window, _)
    local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
    local segments = segments_for_right_status(window)

    local color_scheme = window:effective_config().resolved_palette
    -- Note the use of wezterm.color.parse here, this returns
    -- a Color object, which comes with functionality for lightening
    -- or darkening the colour (amongst other things).
    local bg = wezterm.color.parse(color_scheme.background)
    local fg = color_scheme.foreground

    -- Each powerline segment is going to be coloured progressively
    -- darker/lighter depending on whether we're on a dark/light colour
    -- scheme. Let's establish the "from" and "to" bounds of our gradient.
    local gradient_to, gradient_from = bg, bg
    if appearance.is_dark() then
      gradient_from = gradient_to:lighten(0.2)
    else
      gradient_from = gradient_to:darken(0.2)
    end

    -- Yes, WezTerm supports creating gradients, because why not?! Although
    -- they'd usually be used for setting high fidelity gradients on your terminal's
    -- background, we'll use them here to give us a sample of the powerline segment
    -- colours we need.
    local gradient = wezterm.color.gradient(
      {
        orientation = 'Horizontal',
        colors = { gradient_from, gradient_to },
      },
      #segments -- only gives us as many colours as we have segments.
    )

    -- We'll build up the elements to send to wezterm.format in this table.
    local elements = {}

    for i, seg in ipairs(segments) do
      local is_first = i == 1

      if is_first then
        table.insert(elements, { Background = { Color = 'none' } })
      end
      table.insert(elements, { Foreground = { Color = gradient[i] } })
      table.insert(elements, { Text = SOLID_LEFT_ARROW })

      table.insert(elements, { Foreground = { Color = fg } })
      table.insert(elements, { Background = { Color = gradient[i] } })
      table.insert(elements, { Text = ' ' .. seg .. ' ' })
    end

    window:set_right_status(wezterm.format(elements))
  end)

-- and finally, return the configuration to wezterm
return config
