# Gemini CLI Development Context: Personal Configuration Manager

This project is a repository for managing and versioning personal configuration files for various development tools. The primary goal is to maintain a consistent and personalized development environment.

## Core Technologies

*   **Neovim Configuration:** Lua (`.lua`)
*   **WezTerm Configuration:** Lua (`.lua`)
*   **Installation/Setup:** PowerShell (`.ps1`)

## File Structure Guide

*   `nvim/lua/custom/`: This is the main directory for all custom Neovim configurations written in Lua.
    *   `nvim/lua/custom/plugins/`: All new Neovim plugin configurations should be added here as separate `.lua` files to keep the setup modular.
*   `wezterm/`: Contains the configuration for the WezTerm terminal emulator.
*   `install.ps1`: A PowerShell script used to install, link, or set up the configurations on a new system. When adding support for a new tool, this script should be updated accordingly.
*   `doc/`: Contains project documentation.

## Development Guidelines

1.  **Be Idiomatic:** When modifying files, strictly adhere to the existing code style, structure, and language (Lua or PowerShell).
2.  **Modularity is Key:** For Neovim, prefer creating new files for new plugins under `nvim/lua/custom/plugins/` rather than adding to existing files. This makes configurations easier to manage.
3.  **Update Installation Script:** If a new tool or configuration is added, update `install.ps1` to automate its setup.
4.  **Focus on Configuration:** This project is about software configuration. Do not introduce general-purpose libraries or application logic unless it directly relates to configuring a tool.
5.  **Clarity:** For any complex or non-obvious Lua logic in the configurations, add comments to explain the *why*, not the *what*.
