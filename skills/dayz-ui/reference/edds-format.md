# EDDS format

`.edds` (Enfusion DDS) is the texture format of the Enfusion engine. It's the primary texture format in DayZ, including for all UI graphics. Created from source images (PNG, TGA) via Workbench import.

In UI, `.edds` is used in two ways:

1. As the source for **imageset atlases** — multiple images packed into one texture, with regions described in a `.imageset` file. See `imageset-format.md`.
2. As a **direct texture** for `ImageWidget` via the `imageTexture` property, or for `VideoWidget` (video textures). See `widget-catalog.md`.

---

## 1. Import and GUID

`.edds` files are not written by hand — they are created by Workbench from source PNG/TGA via the import procedure (`Resource Manager` → `Import as`).

On import, each file receives a unique **GUID** — a 16-character hex identifier, used in resource paths.

In resource paths, the GUID is optional but **recommended**. With GUID:

```
{0123456789ABCDEF}gui/imagesets/MyImageSet.edds
```

Without GUID:

```
gui/imagesets/MyImageSet.edds
```

Format: `{GUID}path-from-project-root` or simply `path-from-project-root`. The path is relative to the project root.

The GUID is bound to the file and does not change when the source PNG is later modified. If the file is deleted and re-imported — a new GUID is generated.

The GUID of an existing file can be retrieved in Workbench (context menu → `Copy Resource Name`) or by opening the `.edds.meta` file (see below).

---

## 2. .edds.meta files

Next to every `.edds` file, Workbench creates a `.edds.meta` file with import settings (target format, compression, mip generation, etc.). UI development does not require working with this file — it's managed automatically by Workbench.

When copying or moving a `.edds` file, the `.edds.meta` must be copied along with it.

---

## 3. Use in imagesets

For use in an imageset atlas, the path to a `.edds` is specified in the `Textures` block of the `.imageset` file:

```
Textures {
 ImageSetTextureClass {
  mpix 0
  path "{0123456789ABCDEF}gui/imagesets/MyImageSet.edds"
 }
}
```

A single imageset can reference several `.edds` files at different levels of detail (`mpix`). Details — `imageset-format.md`.

---

## 4. Direct use in widgets

### ImageWidget — static images

A direct texture is set via the `imageTexture` property:

```
ImageWidgetClass Background {
 imageTexture "{0123456789ABCDEF}gui/textures/background.edds"
 size 1.0 1.0
}
```

The `imageTexture` and `image0` (imageset) properties are mutually exclusive. If both are set on a widget, the behaviour is engine-dependent — use only one.

The script equivalent is `ImageWidget.LoadImageFile()`. See `widget-scripting.md` and `widget-catalog.md`.

### Render targets

`RTTextureWidget` creates a `.edds`-compatible render texture in memory (no file on disk), which can be used as a source for `ImageWidget` via `SetImageTexture()`. Details — `widget-catalog.md`.

---

## 5. Related resources

`.edds` files are the image source for both UI and other game subsystems (model textures, terrain, particles). A single `.edds` can be used simultaneously from different places by its GUID.

When a mod is published, `.edds` files are packed into PBO along with the rest of the resources; GUIDs continue to work because they are bound to content, not to location.
