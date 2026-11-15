{ config, ... }: {
  nixconfig.mutable = [
    { kind = "ini"; path = ".config/retroarch/retroarch.cfg"; values."" = {
      video_driver = ''"vulkan"''; video_vsync = ''"true"'';
      menu_driver = ''"ozone"''; video_fullscreen = ''"true"'';
      video_windowed_fullscreen = ''"true"''; gamemode_enable = ''"true"'';
      savestate_auto_save = ''"false"''; savestate_auto_load = ''"false"'';
      autosave_interval = ''"0"'';
    }; }
    { kind = "ini"; path = ".config/MangoHud/MangoHud.conf"; values."" = {
      fps_limit = config.nixconfig.fpsLimit;
      toggle_fps_limit = "Shift_L+F1"; toggle_hud = "Shift_L+F10";
      table_columns = "4"; font_size = toString config.nixconfig.mangohudFontSize;
      time_format = "%d.%m.%Y %H:%M";
    }; flags = [ "horizontal" "time" "cpu_stats" "cpu_temp" "cpu_mhz"
      "gpu_stats" "gpu_temp" "gpu_core_clock" "ram" "procmem" "vram" "fps" "frame_timing" ]; }
  ];
}
