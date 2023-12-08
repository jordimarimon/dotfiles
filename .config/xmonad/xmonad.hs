-- Base
import XMonad

-- Hooks
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks (manageDocks)
import XMonad.Hooks.ManageHelpers (isFullscreen, isDialog, doFullFloat)

-- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.Spacing				-- Allows us to define the gap between windows in each layout
import XMonad.Layout.LimitWindows (limitWindows)	-- Allows us to control the amount of windows in a given layout
import XMonad.Layout.Renamed
import XMonad.Layout.Simplest
import XMonad.Layout.SubLayouts
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile

-- Utilities
import XMonad.Util.EZConfig				-- Allows to have access to special keys and also create our own keybindings
import XMonad.Util.SpawnOnce				-- Allows us to execute commands only once
import XMonad.Util.Run (spawnPipe)			-- Allows us to run external applications
import XMonad.Util.Hacks (javaHack)			-- Allows us to use some hacks to solve common problems


myModMask :: KeyMask		-- Sets modkey to super/windows key
myModMask = mod4Mask

myTerminal :: String		-- Sets default terminal
myTerminal = "alacritty"

myBorderWidth :: Dimension  	-- Sets border width for windows
myBorderWidth = 2

myNormColor :: String       	-- Border color of normal windows
myNormColor = "#282c34"

myFocusColor :: String     	-- Border color of focused windows
myFocusColor = "#46d9ff"

-- What to launch when the WM initializes
myStartupHook :: X ()
myStartupHook = do
	spawnOnce "lxsession" 			-- start session manager
	spawnOnce "picom" 			-- start the compositor
	spawnOnce "nitrogen --restore &"	-- set the background image
	spawnOnce "setxkbmap es &"		-- set the correct keyboard layout

-- Makes setting the spacingRaw simpler to write. 
-- The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Defining the custom layout
tall = renamed [Replace "tall"]
	$ limitWindows 5
        $ smartBorders
        $ subLayout [] (smartBorders Simplest)
        $ mySpacing 8
        $ ResizableTall nmaster delta ratio []
		where
			nmaster = 1      -- Default number of windows in the master pane
    			ratio   = 1/2    -- Default proportion of screen occupied by master pane
    			delta   = 3/100  -- Percent of screen to increment by when resizing panes

myLayout = withBorder myBorderWidth tall ||| Full

-- The names of the workspaces
myWorkspaces :: [String]
myWorkspaces = [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "]

-- Custom keybindings
myKeys = [ ("M-p", spawn "keepassxc $HOME/Documents/database.kdbx")
    , ("M-f", spawn "firefox")
    , ("M-r", spawn "rofi -show drun")
    , ("M-q", spawn "xmonad --recompile; xmonad --restart")
    , ("<XF86AudioMute>", spawn "pamixer --toggle-mute")
    , ("<XF86AudioLowerVolume>", spawn "pamixer --decrease 5")
    , ("<XF86AudioRaiseVolume>", spawn "pamixer --increase 5")
    ] 

-- Programs that we don’t want xmonad to tile (programs that popup windows) 
myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "Gimp"		--> doFloat
    , className =? "confirm"		--> doFloat
    , className =? "file_progress"	--> doFloat
    , className =? "download"		--> doFloat
    , className =? "error"		--> doFloat
    , className =? "notification"	--> doFloat
    , isDialog				--> doFloat
    , isFullscreen			--> doFullFloat
    ]

-- The main function
main :: IO ()
main = do
  -- Apply the Java hack for JetBrains IDEs
  xmonad . ewmhFullscreen . ewmh . javaHack $ def
	{ modMask 		= myModMask
	, terminal 		= myTerminal
	, startupHook		= myStartupHook
	, workspaces		= myWorkspaces
	, borderWidth		= myBorderWidth
	, normalBorderColor	= myNormColor
	, focusedBorderColor	= myFocusColor
	, layoutHook 		= myLayout			-- Use custom layouts
	, manageHook		= myManageHook <+> manageDocks	-- Match on certain windows
	}
	`additionalKeysP` myKeys

