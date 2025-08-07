local wezterm = require("wezterm")

local config = wezterm.config_builder()

local act = wezterm.action

---  wezterm 的快捷键记录
-- 1. CTRL + Tab (切换wezterm 的窗口)

-- config.color_scheme = "Aardvark Blue"

config.color_scheme = "Abernathy"
config.font = wezterm.font("JetBrains Mono")

config.font_size = 12

--设置默认 Shell (可选，但推荐)
-- 如果你希望 wezterm 启动时默认 使用Powershell，可以取消下面的注释
-- 配置默认的启动程序为 PowerShell 取消隐藏版权信息

config.default_prog = {
	"powershell.exe",
	"-NoLogo",
	"-NoExit",
	"-Command",
	'$env:HTTP_PROXY="http://127.0.0.1:7897";$env:HTTPS_PROXY="http://127.0.0.1:7897" ',
}

-- 使用Powershell 7 作为默认终端
-- config.default_prog = { "pwsh.exe" }

-- --- 定义动态切换 Shell 的函数
local function switch_shell(window, pane)
	-- 获取当前 Pane 的前台进程信息
	local foreground_process = pane:get_foreground_process_name()

	-- wezterm 返回的进程名可能包含路径，我们只关心文件名部分
	local process_name = string.match(foreground_process, "[^\\]+$") or ""

	-- 定义要切换的 Shell 列表
	local shells = {
		{ name = "cmd.exe", path = "cmd.exe" },
		{ name = "powershell.exe", path = "powershell.exe" },

		-- 你可以在这添加更多的Shell,例如 Git Bash WSL 等等
		-- { name = 'bash.exe', path = ''}
		--
	}

	local next_shell_path = nil

	-- 遍历 Shell list ，找到当前shell的下一个
	for i, shell in ipairs(shells) do
		if process_name == shell.name then
			-- 如果找到当前Shell就获取下一个
			-- 如果是最后一个，则循环下一个
			next_shell_path = shells[i % #shells + 1].path
			break
		end
	end

	-- 在当前 Pane 中启动新的Shell
	-- 这会有效地"替换"如果找到当前Shell
	window:perform_action(
		act.SpawnCommandInNewWindow({
			args = { next_shell_path },
		}),
		pane
	)

	-- 为了实现政治的替换而不是开新的窗口，我们可以用 SendString来进行模拟
	-- 但更推荐方式是直接替换当前的 Pane 的内容
	-- 希迈纳是更加便捷的方式
	pane:send_text(wezterm.format({
		{ Text = "clear && " .. next_shell_path .. "\r" },
	}))
end

-- 定义快捷键绑定
config.keys = {
	-- 示例：绑定 Ctrl + Shift +F 切换全屏
	{
		key = "F11",
		mode = "",
		action = wezterm.action.ToggleFullScreen,
	},

	{
		key = "s",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(switch_shell),
	},
}

-- 隐藏标题栏和边框
-- config.window_decorations = "NONE"
--

return config
