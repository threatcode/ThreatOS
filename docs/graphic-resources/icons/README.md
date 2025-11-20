# ThreatOS Icons

This directory contains the icon resources for ThreatOS, organized by size and category.

## Directory Structure

```
icons/
├── 16x16/        # 16x16 pixel icons
├── 24x24/        # 24x24 pixel icons
├── 32x32/        # 32x32 pixel icons
├── 48x48/        # 48x48 pixel icons
├── 64x64/        # 64x64 pixel icons
├── 128x128/      # 128x128 pixel icons
├── 256x256/      # 256x256 pixel icons
└── 512x512/      # 512x512 pixel icons (for application launchers)
```

## Icon Naming Convention

Icons should follow this naming convention:

```
[category]-[name]-[state]-[size].svg
```

- `category`: The category of the icon (e.g., `app`, `action`, `device`, `mime`)
- `name`: A descriptive name for the icon (e.g., `firefox`, `folder`, `network`)
- `state`: Optional state indicator (e.g., `active`, `disabled`, `hover`)
- `size`: The size of the icon (e.g., `16`, `24`, `32`)

### Examples

- `app-firefox-16.svg` - Firefox application icon (16x16)
- `action-save-24.svg` - Save action icon (24x24)
- `device-printer-32.svg` - Printer device icon (32x32)
- `mime-pdf-48.svg` - PDF file type icon (48x48)

## Icon Design Guidelines

1. **Style**: Icons should follow a consistent style with rounded corners and a 2px stroke width.
2. **Color**: Use the official ThreatOS color palette (see `../colors/color-palette.gpl`).
3. **Grid**: Icons should be centered on a square canvas with appropriate padding.
4. **Format**: All icons should be provided in SVG format for scalability.
5. **Optimization**: Optimize SVGs by removing unnecessary metadata and using basic shapes when possible.

## Creating New Icons

1. Use Inkscape or your preferred vector graphics editor.
2. Set the canvas size to the target icon size.
3. Use the official color palette.
4. Follow the design guidelines above.
5. Save as an optimized SVG.
6. Place the icon in the appropriate size directory.

## Contributing

Please refer to the main [README.md](../README.md) for contribution guidelines.

## License

All icons are licensed under the [Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).
