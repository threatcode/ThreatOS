# ThreatOS Themes

This directory contains the theme resources for ThreatOS, including GTK themes, icon themes, and cursor themes.

## Directory Structure

```
themes/
├── gtk/           # GTK theme files
│   ├── 3.0/      # GTK 3 theme
│   └── 4.0/      # GTK 4 theme
├── icons/        # Icon theme
│   ├── 16x16/
│   ├── 24x24/
│   └── ...
└── cursors/      # Cursor theme
    ├── default/  # Default cursor set
    └── dark/     # Dark cursor set
```

## GTK Theme

The GTK theme controls the appearance of all GTK-based applications in ThreatOS.

### Features

- Light and dark variants
- Support for GTK 3 and GTK 4
- Custom widgets and controls
- Consistent styling across applications

### Development

1. **Prerequisites**:
   - GTK development libraries
   - SASS/SCSS compiler
   - Python 3.x

2. **Building the theme**:
   ```bash
   cd gtk
   ./build.sh
   ```

3. **Installing the theme**:
   ```bash
   ./install.sh
   ```

## Icon Theme

The icon theme provides a consistent set of icons for system and application use.

### Icon Sizes

Icons are provided in standard sizes: 16x16, 24x24, 32x32, 48x48, 64x64, 128x128, 256x256, and 512x512 pixels.

### Icon Naming

Icons should follow the [Freedesktop Icon Naming Specification](https://specifications.freedesktop.org/icon-naming-spec/icon-naming-spec-latest.html).

## Cursor Theme

The cursor theme provides a consistent set of mouse cursors for the desktop environment.

### Cursor Sizes

Cursors are provided in multiple sizes to support different display resolutions:
- 24x24 (small)
- 32x32 (medium)
- 48x48 (large)
- 64x64 (extra large)

### Cursor States

Each cursor has multiple states:
- Normal
- Hover
- Click
- Drag
- Drop
- Not allowed
- Move
- Resize (N, NE, E, SE, S, SW, W, NW)
- Text selection
- Help
- Wait
- Progress
- Context menu

## Creating Custom Themes

### GTK Theme

1. Create a new directory in `gtk/` with your theme name
2. Follow the structure of the default theme
3. Modify the SCSS files to customize the appearance
4. Build and test your theme

### Icon Theme

1. Create a new directory in `icons/` with your theme name
2. Create an `index.theme` file with the theme metadata
3. Organize icons in subdirectories by size and category
4. Follow the icon naming conventions

### Cursor Theme

1. Create a new directory in `cursors/` with your theme name
2. Create a `cursor.theme` file with the theme metadata
3. Include cursor images in X11 cursor format (.xcf or .png)
4. Create a `Makefile` to generate the cursor files

## Contributing

1. Fork the repository
2. Create a feature branch for your changes
3. Follow the existing style and structure
4. Test your changes thoroughly
5. Submit a pull request with a clear description of your changes

## License

All themes are licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html).

## Resources

- [GTK Documentation](https://docs.gtk.org/)
- [Freedesktop Icon Theme Specification](https://specifications.freedesktop.org/icon-theme-spec/icon-theme-spec-latest.html)
- [X11 Cursor Theme Documentation](https://www.x.org/releases/current/doc/man/man7/Xcursor.7.xhtml)
