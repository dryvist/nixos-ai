# Locale, keyboard, and timezone defaults. Ported from nix-ai-server
# (modules/system/locale-time.nix). Timezone is a mkDefault so a host's
# `time.timeZone` (from vars.nix) always wins.
{ config, lib, ... }:
{
  options.baseline.localeTime.enable = lib.mkEnableOption "the locale/keyboard/timezone baseline";

  config = lib.mkIf config.baseline.localeTime.enable {
    time.timeZone = lib.mkDefault "UTC";

    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

    console = {
      keyMap = lib.mkDefault "us";
      earlySetup = true;
    };
  };
}
