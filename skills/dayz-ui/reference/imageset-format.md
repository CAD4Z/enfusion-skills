# Imageset format

`.imageset` is a UI texture atlas. It defines named rectangular regions inside a `.edds` texture, used for icons, interface elements, and other UI graphics.

Location: `gui/imagesets/`. Format — Enfusion curly-brace syntax (same as `.layout`), not XML.

Relations to other formats:
- Image source — `.edds` file (see `edds-format.md`).
- Used by `ImageWidget` via the `image0` property (see `widget-catalog.md`).
- Used in styles to assign images to Item slots (see `style-system.md`).

---

## 1. File structure

```
ImageSetClass {
 Name "MyImageSet"
 RefSize 1024 1024
 Textures {
  ImageSetTextureClass {
   mpix 0
   path "{0123456789ABCDEF}gui/imagesets/MyImageSet.edds"
  }
 }
 Images {
  ImageSetDefClass IconRefresh {
   Name "IconRefresh"
   Pos 0 0
   Size 64 64
   Flags 0
  }
 }
 Groups {
  ImageSetGroupClass Icons {
   Name "Icons"
   Images {
    ImageSetDefClass IconClose {
     Name "IconClose"
     Pos 64 0
     Size 64 64
     Flags 0
    }
   }
  }
 }
}
```

The root element is `ImageSetClass`. Inside — three blocks: `Textures`, `Images`, `Groups`.

---

## 2. ImageSetClass — root element

| Property | Type | Description |
|----------|------|-------------|
| `Name` | string | Name of the imageset, used to reference it from a layout |
| `RefSize` | `W H` | Texture size in pixels |
| `Textures` | block | List of source textures |
| `Images` | block | Image definitions at the top level |
| `Groups` | block | Logical grouping of images (optional) |

`Pos` and `Size` of every `ImageSetDefClass` entry inside are specified in pixels relative to `RefSize`.

---

## 3. ImageSetTextureClass — source texture

A single imageset can contain multiple textures — for different levels of detail (LOD).

| Property | Type | Description |
|----------|------|-------------|
| `mpix` | int | Level of detail |
| `path` | string | Path to the `.edds` file with a GUID prefix: `"{GUID}path.edds"` |

Observed `mpix` values: `0`, `1`, `2`, `3`. `mpix 0` is the base texture. Higher values are higher-resolution textures, typically in files with `@2x`, `@3x` suffixes.

```
Textures {
 ImageSetTextureClass {
  mpix 0
  path "{0123456789ABCDEF}gui/imagesets/MyImageSet.edds"
 }
 ImageSetTextureClass {
  mpix 1
  path "{FEDCBA9876543210}gui/imagesets/MyImageSet@2x.edds"
 }
}
```

The GUID is generated when a `.edds` file is imported in Workbench. Details — `edds-format.md`.

---

## 4. ImageSetDefClass — image definition

Describes one named rectangular region on a texture.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `Name` | string | — | Image name (matches the class name) |
| `Pos` | `X Y` | — | Top-left corner of the region in pixels |
| `Size` | `W H` | — | Region size in pixels |
| `Flags` | int / enum | `0` | Tiling flags (bitmask) |

### Flags

Bitmask controlling image tiling at render time:

| Bit | Value | Name | Description |
|-----|-------|------|-------------|
| 0 | `1` | `ISHorizontalTile` | Horizontal tiling |
| 1 | `2` | `ISVerticalTile` | Vertical tiling |

Combinations:

- `0` — no tiling;
- `1` — horizontal;
- `2` — vertical;
- `3` — tiling in both directions.

Both numeric (`3`) and named (`ISHorizontalTile`) forms are accepted:

```
ImageSetDefClass Gradient {
 Name "Gradient"
 Pos 0 317
 Size 75 5
 Flags ISVerticalTile
}
```

---

## 5. ImageSetGroupClass — grouping

Logical grouping of images inside a single imageset. **Does not affect references from layouts** — serves only for organization in the Workbench Image Set Editor.

| Property | Type | Description |
|----------|------|-------------|
| `Name` | string | Group name |
| `Images` | block | Image definitions (`ImageSetDefClass`) |

Images inside a group are accessible from a layout using the same `set:NAME image:IMAGENAME` syntax as top-level images — the group name is not part of the reference.

```
Groups {
 ImageSetGroupClass Checkbox {
  Name "Checkbox"
  Images {
   ImageSetDefClass CheckboxHover {
    Name "CheckboxHover"
    Pos 35 102
    Size 26 26
    Flags 0
   }
  }
 }
}
```

---

## 6. Use in layouts

In `.layout` files, imageset images are connected via the `image0` property of `ImageWidget`:

```
ImageWidgetClass RefreshIcon {
 image0 "set:MyImageSet image:IconRefresh"
 size 32 32
 hexactsize 1
 vexactsize 1
}
```

Format: `set:<imageset_name> image:<image_name>`.

- `<imageset_name>` — the value of the `Name` attribute on the root `ImageSetClass`.
- `<image_name>` — the value of the `Name` attribute of the corresponding `ImageSetDefClass` (either at the top level or inside `Groups`).

---

## 7. Use in styles

In `.styles` files, an imageset is assigned to a style via the `ImageSet` attribute on `<Style>`. Images from this imageset are then available to all `<Item>` slots inside the style:

```xml
<Widget Name="ButtonWidget">
    <Style Name="MyButtonStyle" Font="" ImageSet="MyImageSet" Color="4294967295">
        <State Name="Normal">
            <Item Name="Center" Image="ButtonCenter" />
            <Item Name="Left" Image="ButtonLeft" />
            <Item Name="Right" Image="ButtonRight" />
        </State>
    </Style>
</Widget>
```

Details on `.styles` — `style-system.md`.

---

## 8. Registration via CfgMods

For the engine to load a mod's `.imageset` files, they must be registered in `config.cpp` via the `class defs { class imageSets { ... } }` section:

```cpp
class CfgMods
{
    class MyMod
    {
        dir = "MyMod";
        type = "mod";

        class defs
        {
            class imageSets
            {
                files[] =
                {
                    "MyMod/GUI/Imagesets/MyImageSet.imageset",
                    "MyMod/GUI/Imagesets/Icons.imageset"
                };
            };
        };
    };
};
```

Without registration, the `.imageset` file is not loaded by the engine — widgets that reference its images via `set:... image:...` show no image.

Multiple `.imageset` files can be registered in a single `imageSets` section — the order in `files[]` determines load order. `.imageset` registration is independent of `.styles` registration — they are separate sections inside `class defs`.
