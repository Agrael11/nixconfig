
{ ... }:

{
  users.users = {
    SHARE = {
      isSystemUser = true;
      group = "SHARE";
    };

    MEDIASHARE = {
      isSystemUser = true;
      group = "MEDIASHARE";
    };
  };

  users.groups = {
    SHARE = {};
    MEDIASHARE = {};
  };

  services.samba.settings = {
    "moviestuff_2" = {
      path = "/media/romdisk";
      browseable = "yes";
      "read only" = "yes";
      "valid users" = "SHARE MEDIASHARE";
      "write list" = "SHARE";
      "force user" = "tachi";
      "guest ok" = "no";
    };

    "moviestuff" = {
      path = "/media/mediadisk";
      browseable = "yes";
      "read only" = "no";
      "valid users" = "SHARE";
      "force user" = "tachi";
      "guest ok" = "no";
    };

    "PS2" = {
      path = "/media/romdisk/ROMS/PS2";
      browseable = "yes";
      "read only" = "no";
      "valid users" = "SHARE";
      "force user" = "tachi";
      "guest ok" = "no";
    };

    "F" = {
      path = "/media/tachi/DATA_MAIN";
      browseable = "yes";
      "read only" = "no";
      "valid users" = "SHARE";
      "force user" = "tachi";
      "guest ok" = "no";
    };

    "Users" = {
      path = "/media/tachi/DATA_SYSTEM/Users";
      browseable = "yes";
      "read only" = "no";
      "valid users" = "SHARE";
      "force user" = "tachi";
      "guest ok" = "no";
    };
  };
}
