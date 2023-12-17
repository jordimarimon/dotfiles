import Xmobar

config :: Config
config = defaultConfig { font = "Roboto Bold 10"
        , additionalFonts = [ "FontAwesome 12"
          , "FontAwesome Bold 8"
          , "FontAwesome 14"
          , "Hack 19"
          , "Hack 14"
        ]
        , border = NoBorder
        , bgColor = "#F5F5F5"
        , fgColor = "#404040"
        , alpha = 255
        , position = TopSize L 100 40
        , lowerOnStart = True
        , allDesktops = True
        , persistent = False
        , hideOnStart = False
        , iconRoot = ".config/xmobar/icons/"
        , commands = [ Run UnsafeStdinReader
                      , Run $ Date "%a, %d %b   %H:%M" "date" 10
                      , Run $ Com ".config/xmobar/trayer-padding.sh" [] "trayerpad" 20
        ]
        , sepChar = "%"
        , alignSep = "}{"
        , template = "<hspace=8/>%UnsafeStdinReader%}<action=xdotool key super+r>%date%</action>{%trayerpad%"
       }

main :: IO ()
main = configFromArgs config >>= xmobar
