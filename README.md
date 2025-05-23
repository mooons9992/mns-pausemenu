# 🎮 MNS Pause Menu

![Banner](https://github.com/yourusername/mns-pausemenu/raw/main/preview.png)

A modern, feature-rich custom pause menu replacement for your QBCore FiveM server.

## ✨ Features

- **🎯 QBCore Optimized**: Built exclusively for QBCore with deep integration
- **👤 Player Information**: Display character details, job, stats, and money
- **🛡️ Admin Panel**: Staff management tools for administrators
- **🖼️ Modern UI**: Sleek, responsive design that looks great on all resolutions
- **🚀 Performance Focused**: Low resource usage with smooth animations
- **🔧 Highly Configurable**: Extensive options to customize appearance and features
- **🧩 Custom Buttons**: Add your own custom buttons with custom actions
- **🏙️ Server Info**: Display server rules, Discord link and more
- **👥 Player List**: View and manage online players (admin only)
- **🎨 Theme Support**: Easily customize colors to match your server's branding
- **🖱️ Interactive**: Full mouse and keyboard support
- **📱 Responsive**: Works on all screen resolutions

## 📋 Requirements

- QBCore Framework
- ox_lib
- oxmysql

## 🔧 Installation

1. Download the latest release from the GitHub repository
2. Extract the files to your server's resources folder
3. Add `ensure mns-pausemenu` to your server.cfg
4. Configure the script in `config.lua` to match your server's requirements
5. Restart your server

## ⚙️ Configuration

The `config.lua` file contains a wide range of customization options:

```lua
Config = {}

-- Framework Settings
Config.Framework = 'qbcore'  -- Only QBCore is supported in this version

-- Server Branding
Config.ServerInfo = {
    name = 'Your Server Name',
    description = 'Welcome to our server! Enjoy your stay.',
    discord = 'https://discord.gg/yourserver',
    -- Additional options...
}

-- Menu Features
Config.Features = {
    playerStats = true,  -- Show player statistics
    jobInfo = true,      -- Show job information
    adminPanel = true,   -- Show admin panel for staff
    -- Additional options...
}

-- More configuration options available in the file...
```

## 📱 UI Customization

You can easily customize the UI appearance by modifying the CSS variables in `ui/css/style.css`:

```css
:root {
  /* Primary colors - Change these to match your server theme */
  --primary: #4F7CAC;
  --primary-hover: #3a5d80;
  /* Additional options... */
}
```

## 🔑 Admin Features

The admin panel provides several powerful tools for staff members:

- 📋 Player List: View all online players with information
- 🌐 Teleport: Teleport to players or bring them to you
- 🌦️ Weather Control: Change server weather
- 📢 Announcements: Send server-wide announcements
- 🛠️ Quick Actions: Common administrative actions

## 🎮 Keybinds and Commands

- Default keybind: `ESC` (Escape key)
- Command: `/pausemenu`
- Alternative commands: `/pmenu`, `/pscreen`

## 🖼️ Screenshots

![Main Menu](https://github.com/yourusername/mns-pausemenu/raw/main/screenshots/main.png)
![Player Stats](https://github.com/yourusername/mns-pausemenu/raw/main/screenshots/stats.png)
![Admin Panel](https://github.com/yourusername/mns-pausemenu/raw/main/screenshots/admin.png)

## 💻 Development

This script is designed to be easily extended. The code is well-commented and follows a modular structure for easy modifications.

### Adding Custom Buttons

You can add custom buttons in the `config.lua` file:

```lua
Config.CustomButtons = {
    {
        label = "Change Character",
        description = "Switch to another character",
        icon = "fa-solid fa-user-group",
        action = "changeCharacter"
    },
    -- Add more buttons as needed
}
```

## 📄 License

This project is licensed under the MIT License. See the LICENSE file for details.

## 📞 Contact

- **Website**: [MoonSystems.net](https://www.moonsystems.net)
- **Discord**: [MoonSystems Discord](https://discord.gg/moonsystems)
- **Email**: support@moonsystems.net

---

Developed with ❤️ by MoonSystems.
