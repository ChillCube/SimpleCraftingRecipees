# SimpleCraftingRecipees API Reference
Generated: 2026-05-18

A simple addon that provides a custom resource to save crafting recipees

## Class: CraftableItem
**Inherits:** [Item](git@github.com:ChillCube/InventoryGodot/blob/main/DOCUMENTATION.md)


### ⚙️ Inspector Variables (Exported)
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| **materials** | `Array[Item]` | `[]` | Items needed to craft this (can have duplicates) |
| **byproducts** | `Array[Item]` | `[]` | Extra items received when crafting (can have duplicates) |
| **broken_down_loss_blacklist** | `Array[Item]` | `[]` | Materials NOT returned when breaking down |

---

