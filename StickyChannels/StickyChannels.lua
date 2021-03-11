-- StickyChannels by Varstahl
-- Modified by MindScape for 7.2.5 + Close Button + Reload Hint

local ChatTypes = { "SAY"; "WHISPER"; "BN_WHISPER"; "EMOTE"; "CHANNEL"; "PARTY"; "INSTANCE_CHAT"; "GUILD"; "OFFICER"; "YELL"; "RAID"; "RAID_WARNING"; }
local ChatDescr = { "Say (/s)"; "Whispers (/w, /r, r, shift+r)"; "BNet Whispers"; "Emotes (/me)"; "Channels (/1, /2, ...)"; "Party (/p)"; "Instance (/i, /bg)"; "Guild (/g)"; "Officer (/o)"; "Yell (/y)"; "Raid (/ra)"; "Raid Warning (/rw)"; }

local Realm = GetRealmName();
local Char  = UnitName("player");
local StickyDefaults = { SAY=1; WHISPER=0; BN_WHISPER=0; EMOTE=0; CHANNEL=0; PARTY=1; INSTANCE_CHAT=1; GUILD=1; OFFICER=0; YELL=0; RAID=1; RAID_WARNING=0; };
local StickyChannelConfSetup = false;
local StickyChannelSettSetup = false;

function StickyChannels_OnLoad(self)
    self:RegisterEvent("ADDON_LOADED");

    SlashCmdList["STICKYCHANNELS"] = function(msg)
      StickyChannels_SlashCommand(msg);
    end;
    SLASH_STICKYCHANNELS1 = "/sc";
    SLASH_STICKYCHANNELS2 = "/stickychans";
    SLASH_STICKYCHANNELS3 = "/stickychannels";

    StickyPrint("StickyChannels v1.5 loaded");
end

function StickyPrint(msg)
    if (DEFAULT_CHAT_FRAME) then
      DEFAULT_CHAT_FRAME:AddMessage(msg, 1.0, 1.0, 0);
    else
      UIErrorsFrame:AddMessage(msg, 1.0, 1.0, 0, 1.0, UIERRORS_HOLD_TIME);
    end
end

function StickyChannels_OnEvent(self, event, ...)
    local arg1 = ... ;
    if ( ( "ADDON_LOADED" == event ) and ( "StickyChannels" == arg1 ) ) then
      StickyChannels_VARIABLES_LOADED();
    end
end

function StickyChannels_VARIABLES_LOADED()
    if ( not StickyChannelsConfig ) then
      StickyChannelsConfig = {};
    end

    if ( not StickyChannelsConfig[Realm] ) then
      StickyChannelsConfig[Realm] = {};
    end

    if ( not StickyChannelsConfig[Realm][Char] ) then
      StickyChannelsConfig[Realm][Char] = StickyDefaults;
    end

    foreach(ChatTypes, function(k,v) if (not StickyChannelsConfig[Realm][Char][v]) then StickyChannelsConfig[Realm][Char][v] = StickyDefaults[v]; end; end);

    StickyChannelsSetup();
end

function StickyChannels_Reset()
    StickyChannelsConfig[Realm][Char] = StickyDefaults;
    StickyChannelConfSetup = false;
    StickyChannelsSetup();
end

function StickyChannelsSetup()
    if (not StickyChannelSettSetup) then
      StickyChannelSettSetup = true;
      foreach(ChatTypes, function(k,v) getglobal("StickyChannelsSettingsCheckButton"..k.."Text"):SetText(" "..ChatDescr[k]); end);
    end
    if (not StickyChannelConfSetup) then
      StickyChannelConfSetup = true;
      foreach(ChatTypes, function(k,v) ChatTypeInfo[v].sticky = StickyChannelsConfig[Realm][Char][v]; end);
    end
    foreach(ChatTypes, function(k,v) getglobal("StickyChannelsSettingsCheckButton"..k):SetChecked(1 == ChatTypeInfo[v].sticky); end);
end

function StickyChannels_SlashCommand(msg)
    if (msg) then
      local command = string.lower(string.trim(msg));
      if (string.len(msg) == 0) then
        if (StickyChannelsSettings:IsVisible()) then
          StickyChannelsSettings:Hide();
        else
          StickyChannelsSettings:Show();
        end
      else
        if (command == "reset") then
          StickyChannels_Reset();
          StickyPrint("StickyChannels configuration reset to default...");
        else
          StickyPrint("Sticky Channels - Unknown command.");
          StickyPrint(" ");
          StickyPrint("Available commands");
          StickyPrint("- /sc       - Shows/Hides config window");
          StickyPrint("- /sc reset - Resets config to default");
        end
      end
    end
end

function StickyChannels_OnCBClick(id)
    if (getglobal("StickyChannelsSettingsCheckButton"..id):GetChecked()) then
      StickyChannelsConfig[Realm][Char][ChatTypes[id]] = 1;
    else
      StickyChannelsConfig[Realm][Char][ChatTypes[id]] = 0;
    end
    ChatTypeInfo[ChatTypes[id]].sticky = StickyChannelsConfig[Realm][Char][ChatTypes[id]];
end