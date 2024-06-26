-- Base
import XMonad
import System.IO (hPutStrLn)

-- Hooks
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers (isFullscreen, isDialog, doFullFloat)
import XMonad.Hooks.SetWMName
import XMonad.Hooks.DynamicLog

-- Data
import qualified Data.Map as M
import Data.Maybe (fromJust)
import Data.Char (toLower)

-- Layout
import XMonad.Layout.LayoutModifier
import XMonad.Layout.Spacing                            -- Allows us to define the gap between windows in each layout
import XMonad.Layout.LimitWindows (limitWindows)        -- Allows us to control the amount of windows in a given layout
import XMonad.Layout.Renamed
import XMonad.Layout.Simplest
import XMonad.Layout.SubLayouts
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
import XMonad.Layout.IndependentScreens

-- Utilities
import XMonad.Util.EZConfig (additionalKeysP)           -- Allows to have access to special keys and also create our own keybindings
import XMonad.Util.SpawnOnce                            -- Allows us to execute commands only once
import XMonad.Util.Run (spawnPipe)                      -- Allows us to run external applications
import XMonad.Util.Hacks (javaHack)                     -- Allows us to use some hacks to solve common problems

-------------------------------------------------------------------------------
-- VARIABLES / UTILITY FUNCTIONS
-------------------------------------------------------------------------------

-- Sets modkey to super/windows key
myModMask :: KeyMask
myModMask = mod4Mask

-- Sets default terminal
myTerminal :: String
myTerminal = "alacritty"

-- Sets border width for windows
myBorderWidth :: Dimension
myBorderWidth = 2

-- Border color of normal windows
myNormColor :: String
myNormColor = "#EFF6FF"

-- Border color of focused windows
myFocusColor :: String
myFocusColor = "#2563EB"

trayerRestartCommand :: [Char]
trayerRestartCommand = "killall trayer; trayer --monitor 1 --edge top --align right --widthtype request --padding 7 --iconspacing 10 --SetDockType true --SetPartialStrut true --expand true --transparent true --alpha 0 --tint 0xF5F5F5  --height 30 --distance 5 &"

-------------------------------------------------------------------------------
-- START UP
-------------------------------------------------------------------------------

-- What to launch when the WM initializes
myStartupHook :: X ()
myStartupHook = do
        spawn trayerRestartCommand              -- restart trayer

        spawnOnce "lxsession"                   -- start session manager
        spawnOnce "picom"                       -- start the compositor
        spawnOnce "~/.fehbg"                    -- set last saved feh wallpaper
        spawnOnce "setxkbmap es"                -- set the correct keyboard layout
        spawnOnce "xsettingsd"                  -- set fonts for Java applications
        spawnOnce "cbatticon"                   -- start the battery tray
        spawnOnce "nm-applet"                   -- start the network manager tray
        spawnOnce "blueman-applet"              -- start the bluetooth manager tray
        spawnOnce "redshift-gtk"                -- adjusts the color temperature of the screen
        spawnOnce "dunst"                       -- starts the notification server

        -- The Java gui toolkit has a hardcoded list of so-called 
        -- "non-reparenting" window managers. xmonad is not on 
        -- this list (nor are many of the newer window managers).
        -- In reality we're already using the JavaHack but still
        -- we will add this to make sure that things don't break.
        setWMName "LG3D"

-------------------------------------------------------------------------------
-- LAYOUTS
-------------------------------------------------------------------------------

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

myLayout = avoidStruts $ withBorder myBorderWidth tall ||| Full

-------------------------------------------------------------------------------
-- WORKSPACES
-------------------------------------------------------------------------------

-- The names of the workspaces
myWorkspaces :: [String]
myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

-------------------------------------------------------------------------------
-- KEYBINDINGS
-------------------------------------------------------------------------------

-- Custom keybindings
myAditionalKeys :: [(String, X ())]
myAditionalKeys = [ ("M-r", spawn "$HOME/Scripts/run.sh")
    , ("M-q", spawn "killall xmobar; xmonad --recompile; xmonad --restart")
    , ("<XF86AudioMute>", spawn "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
    , ("<XF86AudioLowerVolume>", spawn "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
    , ("<XF86AudioRaiseVolume>", spawn "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+")
    , ("<XF86MonBrightnessUp>", spawn "brightnessctl set +10%")
    , ("<XF86MonBrightnessDown>", spawn "brightnessctl set 10%-")
    , ("<Print>", spawn "flameshot gui")
    ]

-------------------------------------------------------------------------------
-- SPECIAL WINDOW MANAGEMENT
-------------------------------------------------------------------------------

-- Programs that we don’t want xmonad to tile (programs that popup windows) 
myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "Gimp"               --> doFloat
    , className =? "confirm"            --> doFloat
    , className =? "file_progress"      --> doFloat
    , className =? "download"           --> doFloat
    , className =? "error"              --> doFloat
    , className =? "notification"       --> doFloat
    , className =? "Tk"                 --> doFloat
    , className =? "Toplevel"           --> doFloat
    , isDialog                          --> doFloat
    , isFullscreen                      --> doFullFloat
    ]

-------------------------------------------------------------------------------
-- STATUS BAR
-------------------------------------------------------------------------------

myWorkspaceIndices :: M.Map [Char] Integer
myWorkspaceIndices = M.fromList $ zip myWorkspaces [1..]

actionPrefix, actionButton, actionSuffix :: [Char]
actionPrefix = "<action=`xdotool key super+"
actionButton = "` button="
actionSuffix = "</action>"

addActions :: [(String, Int)] -> String -> String
addActions [] ws = ws
addActions (x:xs) ws = addActions xs (actionPrefix ++ k ++ actionButton ++ show b ++ ">" ++ ws ++ actionSuffix)
    where k = fst x
          b = snd x

clickable :: [Char] -> [Char] -> [Char]
clickable icon ws = addActions [ (show i, 1), ("q", 2), ("Left", 4), ("Right", 5) ] icon
                    where i = fromJust $ M.lookup ws myWorkspaceIndices

wsIconFull   = "  <fn=2>\xf111</fn>   "
wsIconHidden = "  <fn=2>\xf111</fn>   "
wsIconEmpty  = "  <fn=2>\xf10c</fn>   "

-------------------------------------------------------------------------------
-- MAIN
-------------------------------------------------------------------------------

main :: IO ()
main = do
        nScreens <- countScreens
        xmprocs <- mapM (\i -> spawnPipe $ "xmobar -x " ++ show i ++ " $HOME/.config/xmobar/xmobar.hs") [0..nScreens-1]

        xmonad $ ewmhFullscreen $ ewmh $ javaHack $ docks $ def
                { modMask               = myModMask
                , terminal              = myTerminal
                , startupHook           = myStartupHook
                , workspaces            = myWorkspaces
                , borderWidth           = myBorderWidth
                , normalBorderColor     = myNormColor
                , focusedBorderColor    = myFocusColor
                , layoutHook            = myLayout                      -- Use custom layouts
                , manageHook            = myManageHook <+> manageDocks  -- Match on certain windows
                , logHook               = dynamicLogWithPP $ xmobarPP
                        { ppOutput = \x -> mapM_ (\handle -> hPutStrLn handle x) xmprocs
                        -- Separator between workspaces
                        , ppWsSep = ""
                        -- Current workspace
                        , ppCurrent = xmobarColor "#8BABF0" "" . clickable wsIconFull
                        -- Visible but not current workspace
                        , ppVisible = xmobarColor "#8691A8" "" . clickable wsIconFull
                        -- Hidden workspace
                        , ppHidden = xmobarColor "#555E70" "" . clickable wsIconHidden
                        -- Hidden workspaces (no windows)
                        , ppHiddenNoWindows = xmobarColor "#555E70" ""  . clickable wsIconEmpty
                        -- Separator character
                        , ppSep =  "   "
                        -- Urgent workspace
                        , ppUrgent = xmobarColor "#C45500" "" . clickable wsIconFull
                        -- Title of active window
                        , ppTitle = const ""
                        -- Order of things (by default its: Workspaces + CurrentLayoutName + FocusedApplicationTitle + Extras)
                        , ppOrder = \(ws : l : _ : _) -> ws : ("<icon=" ++ (map toLower l) ++ ".xbm/>") : []
                        -- Extra things to show in the status bar 
                        , ppExtras  = []
                        }
                }
                `additionalKeysP` myAditionalKeys

