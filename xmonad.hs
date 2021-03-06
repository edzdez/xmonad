import qualified Data.Map as M
import System.Exit
import System.IO
import XMonad hiding ((|||))
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ServerMode
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.WindowSwallowing
import XMonad.Layout
import XMonad.Layout.BoringWindows
import XMonad.Layout.Named
import XMonad.Layout.ShowWName
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.WindowNavigation
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig
import XMonad.Util.Run
import XMonad.Util.Themes
import XMonad.Util.Ungrab

myWorkspaces :: [[Char]]
myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

myShowWNameTheme :: SWNConfig
myShowWNameTheme =
  def
    { swn_font = "xft:Jetbrains Mono:bold:size=48",
      swn_fade = 1.00,
      swn_bgcolor = "#1c1f24",
      swn_color = "#eceff4"
    }

myStartup :: X ()
myStartup = do
  spawn "$HOME/.local/share/xmonad/autostart.sh"

myLayout = boringWindows $ avoidStruts $ tiled ||| centeredMaster ||| simplestFloat ||| tabbed ||| Full
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled = addTabs shrinkText theme $ Tall nmaster delta ratio
    centeredMaster = ThreeColMid nmaster delta ratio
    tabbed =
      named "Tabbed" $
        tabbedBottomAlways shrinkText theme
    -- theme
    theme =
      def
        { fontName = "xft:JetbrainsMono",
          inactiveColor = "#2e3440"
        }
    -- The default number of windows in the master pane
    nmaster = 1
    -- Default proportion of screen occupied by master pane
    ratio = 1 / 2
    -- Percent of screen to increment by when resizing panes
    delta = 5 / 100

myEvent = swallowEventHook (className =? "Alacritty" <||> className =? "Kitty") (return True)

myManage :: ManageHook
myManage =
  composeAll
    [ -- New windows should spawn at the end of the stack
      insertPosition Below Newer,
      isDialog --> doF W.swapUp,
      -- Make GColor always float
      className =? "Gcolor3" --> doFloat
    ]

main :: IO ()
main = do
  xmonad $
    ewmhFullscreen . ewmh . docks $
      def
        { -- Rebind Mod to Super
          modMask = mod4Mask,
          -- Set terminal to alacritty
          terminal = "alacritty",
          -- Set border width to 0
          borderWidth = 0,
          -- Set focusFollowsMouse
          focusFollowsMouse = True,
          -- Set clickJustFocuses
          clickJustFocuses = False,
          -- Set workspace names
          workspaces = myWorkspaces,
          -- Set startup hook
          startupHook = myStartup,
          -- Set layout hook
          layoutHook = showWName' myShowWNameTheme $ spacingWithEdge 2 $ myLayout,
          -- Set event hook
          handleEventHook = serverModeEventHook <+> myEvent,
          -- Set manage hook
          manageHook = manageDocks <+> myManage,
          -- Set log hook
          logHook = dynamicLogWithPP $ def {ppOutput = writeFile "/home/edzdez/.config/xmonad/xmonad.log"}
        }
        `removeKeys` [
                       -- Unbind default terminal binding
                       (mod4Mask .|. shiftMask, xK_Return),
                       -- Unbind default dmenu binding
                       (mod4Mask, xK_p),
                       -- Unbind default close/kill binding
                       (mod4Mask .|. shiftMask, xK_c),
                       -- Unbind default layout cycle binding
                       (mod4Mask, xK_space),
                       -- Unbind reset layout keybind
                       (mod4Mask .|. shiftMask, xK_space),
                       -- Unbind resize/refresh layouts to correct size binding
                       (mod4Mask, xK_n),
                       -- Unbind default help message binding
                       (mod4Mask .|. shiftMask, xK_slash),
                       -- Unbind mod-tab and mod-shift-tab bindings for changing focus
                       (mod4Mask, xK_Tab),
                       (mod4Mask .|. shiftMask, xK_Tab),
                       -- Unbind default swap with master keybind
                       (mod4Mask, xK_Return),
                       -- Unbind default floating/tiling keybind
                       (mod4Mask, xK_t),
                       -- Unbind default increase/decrease num masters
                       (mod4Mask, xK_comma),
                       (mod4Mask, xK_period),
                       -- Unbind default quit keybind
                       (mod4Mask .|. shiftMask, xK_q),
                       -- Unbind default recompile keybind
                       (mod4Mask, xK_q)
                     ]
        `additionalKeys` [
                           -- Spawn dmenu
                           -- ((mod4Mask, xK_d), spawn "j4-dmenu-desktop -term=alacritty --no-generic --dmenu='dmenu -X 4 -Y 4 -W 1912'"),
                           ((mod4Mask, xK_d), spawn "$HOME/.config/rofi/launchers/misc/launcher.sh"),
                           -- Spawn dmenu alt-tab script
                           -- ((mod1Mask, xK_Tab), spawn "$HOME/.config/xmonad/scripts/switch"),
                           ((mod1Mask, xK_Tab), spawn "rofi -no-lazy-grab -show window -theme '.config/rofi/launchers/misc/blurry'"),
                           -- Spawn Web Browser
                           ((mod4Mask, xK_b), spawn "brave"),
                           -- Spawn File Manager
                           ((mod4Mask, xK_f), spawn "nemo"),
                           -- Spawn Terminal
                           ((mod4Mask, xK_Return), spawn "alacritty"),
                           ((mod4Mask .|. shiftMask, xK_Return), spawn "kitty"),
                           -- Spawn Emacs
                           ((mod4Mask, xK_e), spawn "emacsclient -c"),
                           -- Restart Emacs
                           ((mod4Mask .|. shiftMask, xK_e), spawn "$HOME/.config/xmonad/restartemacs.sh"),
                           -- Close/Kill Client Binding
                           ((mod4Mask .|. shiftMask, xK_q), kill),
                           -- Cycle Layouts Binding
                           ((mod4Mask .|. mod1Mask, xK_Tab), sendMessage NextLayout),
                           -- Set Floating/Tiled
                           ((mod4Mask .|. shiftMask, xK_space), withFocused $ windows . W.sink),
                           -- Toggle Bar
                           ((mod4Mask .|. shiftMask, xK_b), spawn "$HOME/.config/xmonad/togglepolybar.sh"),
                           -- Inc/Dec Num Masters
                           ((mod4Mask .|. shiftMask, xK_i), sendMessage (IncMasterN 1)),
                           ((mod4Mask .|. shiftMask, xK_d), sendMessage (IncMasterN (-1))),
                           -- Inc/Dec/Reset Gaps
                           ((mod4Mask .|. mod1Mask .|. shiftMask, xK_equal), incScreenWindowSpacing 1),
                           ((mod4Mask .|. mod1Mask, xK_minus), incScreenWindowSpacing (-1)),
                           ((mod4Mask .|. mod1Mask, xK_equal), setScreenWindowSpacing 2),
                           -- Layout Switching
                           ((mod4Mask .|. mod1Mask, xK_t), sendMessage $ JumpToLayout "Tall"),
                           ((mod4Mask .|. mod1Mask, xK_m), sendMessage $ JumpToLayout "Full"),
                           ((mod4Mask .|. mod1Mask, xK_f), sendMessage $ JumpToLayout "SimplestFloat"),
                           ((mod4Mask .|. mod1Mask, xK_c), sendMessage $ JumpToLayout "ThreeCol"),
                           ((mod4Mask .|. mod1Mask, xK_w), sendMessage $ JumpToLayout "Tabbed"),
                           -- Lock screen
                           ((mod4Mask, xK_i), spawn "$HOME/.config/xmonad/lock.sh"),
                           -- Screen Brightness
                           ((mod4Mask, xK_F2), spawn "$HOME/.config/xmonad/scripts/brightnessdown.sh"),
                           ((mod4Mask, xK_F3), spawn "$HOME/.config/xmonad/scripts/brightnessup.sh"),
                           -- Speaker Control
                           ((mod4Mask, xK_F5), spawn "$HOME/.config/xmonad/scripts/muteaudio.sh"),
                           ((mod4Mask, xK_F6), spawn "$HOME/.config/xmonad/scripts/decvolume.sh"),
                           ((mod4Mask, xK_F7), spawn "$HOME/.config/xmonad/scripts/incvolume.sh"),
                           -- Mic Mute
                           ((mod4Mask, xK_F8), spawn "$HOME/.config/xmonad/scripts/mutemic.sh"),
                           -- Change Keyboard to INTL
                           ((mod4Mask, xK_space), spawn "$HOME/.config/xmonad/scripts/switchkb.sh"),
                           -- Screenshot
                           ((mod4Mask, 0x0000ff61), spawn "$HOME/.config/xmonad/scripts/sshot.sh"),
                           -- Recompile XMonad
                           ((mod4Mask .|. shiftMask, xK_c), spawn "xmonad --recompile; xmonad --restart"),
                           -- Quit XMonad
                           ((mod4Mask .|. mod1Mask, xK_e), io (exitWith ExitSuccess))
                         ]
