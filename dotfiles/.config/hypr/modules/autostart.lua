-- ==========================================
-- Autostart
-- ==========================================

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start plasma-polkit-agent.service")
end)
