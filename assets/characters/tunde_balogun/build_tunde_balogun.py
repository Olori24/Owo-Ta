"""Build Tunde Balogun, an original stylized contemporary Nigerian character for OWO TÀ.

Run with Blender 4.x in background mode:
  blender --background --python assets/characters/tunde_balogun/build_tunde_balogun.py

All geometry, UVs, textures, rigging and animation are authored by this script.
No external asset, service, add-on, or network access is used.
"""
from __future__ import annotations

import math
import os
import random
import sys
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent
SOURCE = OUT / "source"
TEXTURES = OUT / "textures"
PREVIEW = OUT / "preview"
OUT.mkdir(parents=True, exist_ok=True)
SOURCE.mkdir(parents=True, exist_ok=True)
TEXTURES.mkdir(parents=True, exist_ok=True)
PREVIEW.mkdir(parents=True, exist_ok=True)
# Only delete maps owned by this generator; these are recreated deterministically.
for generated_map in TEXTURES.glob("*_basecolor.png"):
    generated_map.unlink()
random.seed(24031)

# Remove the default scene so generation is clean and repeatable.
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
for datablocks in (bpy.data.meshes, bpy.data.curves, bpy.data.materials, bpy.data.armatures, bpy.data.cameras, bpy.data.lights, bpy.data.actions, bpy.data.images):
    for block in list(datablocks):
        if block.users == 0:
            datablocks.remove(block)


def make_texture(name: str, color: tuple[float, float, float], weave: float = 0.025, size: int = 256):
    """Create a subtle deterministic sRGB fabric/albedo image using Blender only."""
    image = bpy.data.images.new(name, width=size, height=size, alpha=False, float_buffer=False)
    pixels = []
    for y in range(size):
        for x in range(size):
            # Fine crosshatch and low-contrast noise; no photographed material.
            thread = 0.5 + 0.5 * math.sin(x * 1.67) * math.sin(y * 1.41)
            grain = random.uniform(-0.35, 0.35)
            variation = 1.0 + weave * (thread + grain)
            pixels.extend((min(1.0, max(0.0, c * variation)) for c in color))
            pixels.append(1.0)
    image.pixels.foreach_set(pixels)
    image.filepath_raw = str(TEXTURES / f"{name.lower()}_basecolor.png")
    image.file_format = "PNG"
    image.save()
    return image


def make_material(name: str, color: tuple[float, float, float], roughness: float, metallic: float = 0.0, weave: float = 0.025):
    material = bpy.data.materials.new(name)
    material.diffuse_color = (*color, 1.0)
    material.use_nodes = True
    shader = material.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Roughness"].default_value = roughness
    shader.inputs["Metallic"].default_value = metallic
    material["source"] = "Original authored palette region; consolidated into a shared PBR material at export"
    material["palette_color"] = list(color)
    return material


# PBR material set: subdued, contemporary colours; the visual identity is carried
# by clothing cut and palette rather than costume or stereotype.
M_SKIN = make_material("MAT_Skin_WarmBrown", (0.12, 0.035, 0.022), 0.54, 0.0, 0.012)
M_SKIN_LIGHT = make_material("MAT_Skin_Feature", (0.21, 0.065, 0.04), 0.52, 0.0, 0.01)
M_HAIR = make_material("MAT_Hair_DeepBrown", (0.015, 0.010, 0.008), 0.78, 0.0, 0.04)
M_JACKET = make_material("MAT_Jacket_Teal", (0.018, 0.17, 0.15), 0.72, 0.0, 0.035)
M_ACCENT = make_material("MAT_Jacket_CoralAccent", (0.68, 0.20, 0.075), 0.62, 0.0, 0.02)
M_SHIRT = make_material("MAT_Shirt_Oat", (0.62, 0.54, 0.39), 0.82, 0.0, 0.025)
M_TROUSER = make_material("MAT_Trousers_Indigo", (0.035, 0.046, 0.065), 0.88, 0.0, 0.04)
M_STITCH = make_material("MAT_Stitch_Blue", (0.09, 0.15, 0.15), 0.82, 0.0, 0.01)
M_SHOE = make_material("MAT_Sneaker_Cream", (0.47, 0.38, 0.27), 0.50, 0.0, 0.015)
M_SOLE = make_material("MAT_Sneaker_Sole", (0.018, 0.021, 0.020), 0.94, 0.0, 0.01)
M_EYE = make_material("MAT_Eye_White", (0.60, 0.54, 0.45), 0.38, 0.0, 0.0)
M_IRIS = make_material("MAT_Eye_Iris", (0.085, 0.034, 0.015), 0.35, 0.0, 0.0)
M_PUPIL = make_material("MAT_Eye_Pupil", (0.008, 0.006, 0.005), 0.28, 0.0, 0.0)
M_BROW = make_material("MAT_Brow", (0.045, 0.018, 0.012), 0.82, 0.0, 0.0)
M_MOUTH = make_material("MAT_Mouth", (0.13, 0.035, 0.026), 0.76, 0.0, 0.0)
M_ZIP = make_material("MAT_Zipper_Brass", (0.33, 0.20, 0.08), 0.36, 0.65, 0.0)

parts = []
SCALE_X = 1.07
SCALE_Z = 1.04


def make_mesh(name: str, verts, faces, material, weights: dict[str, float] | None = None):
    mesh = bpy.data.meshes.new(name + "Mesh")
    scaled_verts = [(x * SCALE_X, y, z * SCALE_Z) for x, y, z in verts]
    mesh.from_pydata(scaled_verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(material)
    for polygon in mesh.polygons:
        polygon.use_smooth = True
    if weights:
        for bone_name, weight in weights.items():
            if weight > 0.0001:
                group = obj.vertex_groups.get(bone_name) or obj.vertex_groups.new(name=bone_name)
                group.add(list(range(len(verts))), weight, "REPLACE")
    parts.append(obj)
    return obj


def make_ellipsoid(name: str, center, scale, material, bone: str, segments: int = 16, rings: int = 10):
    cx, cy, cz = center
    sx, sy, sz = scale
    verts = []
    for r in range(rings + 1):
        theta = math.pi * r / rings
        for s in range(segments):
            phi = 2.0 * math.pi * s / segments
            verts.append((cx + sx * math.sin(theta) * math.cos(phi), cy + sy * math.sin(theta) * math.sin(phi), cz + sz * math.cos(theta)))
    faces = []
    for r in range(rings):
        for s in range(segments):
            a = r * segments + s
            b = r * segments + (s + 1) % segments
            c = (r + 1) * segments + (s + 1) % segments
            d = (r + 1) * segments + s
            if r == 0:
                faces.append((a, d, c))
            elif r == rings - 1:
                faces.append((a, b, d))
            else:
                faces.append((a, b, c, d))
    return make_mesh(name, verts, faces, material, {bone: 1.0})


def make_tube(name: str, start, end, radius_a: float, radius_b: float, material,
              bone_a: str, bone_b: str | None = None, blend_at: float = 0.72,
              segments: int = 14, rings: int = 12):
    """Low-poly quad tube with smooth weights across the distal joint."""
    a, b = Vector(start), Vector(end)
    axis = (b - a).normalized()
    helper = Vector((0.0, 0.0, 1.0)) if abs(axis.z) < 0.9 else Vector((0.0, 1.0, 0.0))
    u = axis.cross(helper).normalized()
    v = axis.cross(u).normalized()
    verts = []
    for ri in range(rings + 1):
        t = ri / rings
        # Rounded ends; slightly fuller through the middle.
        profile = 0.78 + 0.22 * math.sin(math.pi * t) ** 0.55
        radius = radius_a + (radius_b - radius_a) * t
        for si in range(segments):
            angle = 2.0 * math.pi * si / segments
            p = a + axis * ((b - a).length * t) + u * (math.cos(angle) * radius * profile) + v * (math.sin(angle) * radius * profile)
            verts.append(tuple(p))
    faces = []
    faces.append(tuple(reversed(range(segments))))
    for ri in range(rings):
        for si in range(segments):
            a0 = ri * segments + si
            b0 = ri * segments + (si + 1) % segments
            c0 = (ri + 1) * segments + (si + 1) % segments
            d0 = (ri + 1) * segments + si
            faces.append((a0, b0, c0, d0))
    faces.append(tuple(rings * segments + si for si in range(segments)))
    obj = make_mesh(name, verts, faces, material)
    group_a = obj.vertex_groups.new(name=bone_a)
    group_b = obj.vertex_groups.new(name=bone_b) if bone_b else None
    for ri in range(rings + 1):
        t = ri / rings
        ids = list(range(ri * segments, (ri + 1) * segments))
        blend = 0.0 if group_b is None else max(0.0, min(1.0, (t - blend_at) / max(0.001, 1.0 - blend_at)))
        if blend < 0.999:
            group_a.add(ids, 1.0 - blend, "REPLACE")
        if group_b and blend > 0.001:
            group_b.add(ids, blend, "REPLACE")
    return obj


def make_z_loft(name: str, profile, material, bottom_bone: str, top_bone: str, blend_low: float, blend_high: float, segments: int = 20):
    """Closed quad-ring garment/torso surface; profile tuples are z, center-x, center-y, rx, ry."""
    verts = []
    for z, cx, cy, rx, ry in profile:
        for s in range(segments):
            angle = 2 * math.pi * s / segments
            verts.append((cx + rx * math.cos(angle), cy + ry * math.sin(angle), z))
    faces = [tuple(reversed(range(segments)))]
    for r in range(len(profile) - 1):
        for s in range(segments):
            a = r * segments + s
            b = r * segments + (s + 1) % segments
            c = (r + 1) * segments + (s + 1) % segments
            d = (r + 1) * segments + s
            faces.append((a, b, c, d))
    faces.append(tuple((len(profile) - 1) * segments + s for s in range(segments)))
    obj = make_mesh(name, verts, faces, material)
    low = obj.vertex_groups.new(name=bottom_bone)
    if bottom_bone == top_bone:
        low.add(list(range(len(verts))), 1.0, "REPLACE")
        return obj
    high = obj.vertex_groups.new(name=top_bone)
    for r, row in enumerate(profile):
        z = row[0]
        blend = max(0.0, min(1.0, (z - blend_low) / max(0.001, blend_high - blend_low)))
        ids = list(range(r * segments, (r + 1) * segments))
        if blend < 0.999:
            low.add(ids, 1.0 - blend, "REPLACE")
        if blend > 0.001:
            high.add(ids, blend, "REPLACE")
    return obj


# Anatomical, export-ready deforming armature.
arm_data = bpy.data.armatures.new("RIG_Tunde_Humanoid")
arm = bpy.data.objects.new("RIG_Tunde_Humanoid", arm_data)
bpy.context.collection.objects.link(arm)
bpy.context.view_layer.objects.active = arm
arm.select_set(True)
bpy.ops.object.mode_set(mode="EDIT")
edit_bones = arm_data.edit_bones


def bone(name, head, tail, parent=None, deform=True):
    b = edit_bones.new(name)
    b.head = (head[0] * SCALE_X, head[1], head[2] * SCALE_Z)
    b.tail = (tail[0] * SCALE_X, tail[1], tail[2] * SCALE_Z)
    b.use_deform = deform
    if parent:
        b.parent = edit_bones[parent]
        b.use_connect = False
    return b


bone("root", (0, 0, 0), (0, 0, 0.12), None, False)
bone("pelvis", (0, 0, 0.76), (0, 0, 0.91), "root")
bone("spine", (0, 0, 0.91), (0, 0, 1.17), "pelvis")
bone("chest", (0, 0, 1.17), (0, 0, 1.39), "spine")
bone("neck", (0, 0, 1.39), (0, 0, 1.50), "chest")
bone("head", (0, 0, 1.50), (0, 0, 1.72), "neck")
for side, sign in (("L", 1), ("R", -1)):
    bone(f"clavicle.{side}", (0, 0, 1.34), (0.22 * sign, 0, 1.34), "chest")
    bone(f"upper_arm.{side}", (0.22 * sign, 0, 1.34), (0.46 * sign, 0, 1.205), f"clavicle.{side}")
    bone(f"lower_arm.{side}", (0.46 * sign, 0, 1.205), (0.63 * sign, 0, 1.10), f"upper_arm.{side}")
    bone(f"hand.{side}", (0.63 * sign, 0, 1.10), (0.75 * sign, 0, 1.03), f"lower_arm.{side}")
    bone(f"upper_leg.{side}", (0.12 * sign, 0, 0.83), (0.14 * sign, 0, 0.46), "pelvis")
    bone(f"lower_leg.{side}", (0.14 * sign, 0, 0.46), (0.14 * sign, 0, 0.13), f"upper_leg.{side}")
    bone(f"foot.{side}", (0.14 * sign, 0, 0.13), (0.14 * sign, -0.18, 0.085), f"lower_leg.{side}")
    bone(f"toe.{side}", (0.14 * sign, -0.18, 0.085), (0.14 * sign, -0.28, 0.085), f"foot.{side}")
bpy.ops.object.mode_set(mode="OBJECT")
arm.show_in_front = True
arm_data.display_type = "OCTAHEDRAL"

# Core garments: inner tee, relaxed contemporary zip jacket, straight trousers.
make_z_loft("MESH_TShirt_Torso", [(0.88, 0, 0, .18, .115), (.98, 0, 0, .22, .13), (1.15, 0, 0, .235, .135), (1.34, 0, 0, .24, .13), (1.40, 0, 0, .15, .10)], M_SHIRT, "pelvis", "chest", 1.00, 1.24)
make_z_loft("MESH_Jacket_Body", [(0.94, 0, .004, .23, .145), (1.02, 0, .004, .255, .15), (1.19, 0, .004, .265, .15), (1.34, 0, .004, .255, .145), (1.40, 0, .004, .20, .125)], M_JACKET, "spine", "chest", 1.06, 1.26)
# A single contoured waist/seat loft avoids a detached hip-proxy silhouette.
make_z_loft("MESH_Trouser_Pelvis", [(.69, 0, 0, .18, .12), (.75, 0, 0, .23, .145), (.84, 0, 0, .24, .15), (.90, 0, 0, .23, .145)], M_TROUSER, "pelvis", "pelvis", .70, .89, 24)
# Restrained workshop-inspired details: tailored pockets, seam tabs, and a belt.
make_z_loft("MESH_Belt", [(.887, 0, 0, .235, .151), (.920, 0, 0, .238, .153)], M_STITCH, "pelvis", "spine", .90, .915, 24)
make_ellipsoid("MESH_BeltBuckle", (0, -.158, .904), (.035, .010, .021), M_ZIP, "pelvis", 12, 8)
for side, sign in (("L", 1), ("R", -1)):
    make_ellipsoid(f"MESH_Jacket_Pocket_{side}", (.145 * sign, -.151, 1.235), (.072, .010, .050), M_JACKET, "chest", 12, 8)
    make_tube(f"MESH_Jacket_PocketFlap_{side}", (.088 * sign, -.164, 1.258), (.202 * sign, -.164, 1.258), .006, .006, M_ACCENT, "chest", None, .9, 8, 4)
    make_ellipsoid(f"MESH_Trouser_CargoPocket_{side}", (.205 * sign, -.098, .61), (.012, .012, .060), M_TROUSER, f"upper_leg.{side}", 12, 8)
# Open-front jacket plackets, zipper and restrained cuff/shoulder accents.
for side, sign in (("L", 1), ("R", -1)):
    make_tube(f"MESH_Jacket_Placket_{side}", (0.018 * sign, -0.145, 0.99), (0.018 * sign, -0.134, 1.37), .018, .012, M_ACCENT, "spine", "chest", .25, 8, 8)
make_tube("MESH_Zipper", (0, -0.149, 1.00), (0, -0.139, 1.36), .004, .004, M_ZIP, "spine", "chest", .25, 6, 8)
# Jacket sleeves to the elbow, then visible forearms and open hands.
for side, sign in (("L", 1), ("R", -1)):
    shoulder = (0.22 * sign, 0.0, 1.335)
    elbow = (0.46 * sign, 0.0, 1.205)
    wrist = (0.63 * sign, 0.0, 1.10)
    make_tube(f"MESH_Jacket_Sleeve_{side}", shoulder, elbow, .09, .075, M_JACKET, f"upper_arm.{side}", f"lower_arm.{side}", .68, 14, 12)
    make_tube(f"MESH_Cuff_{side}", (0.43 * sign, 0, 1.222), (0.47 * sign, 0, 1.195), .078, .074, M_ACCENT, f"upper_arm.{side}", f"lower_arm.{side}", .45, 14, 6)
    make_tube(f"MESH_Forearm_{side}", (0.46 * sign, 0, 1.205), wrist, .068, .052, M_SKIN, f"lower_arm.{side}", f"hand.{side}", .72, 14, 12)
    make_ellipsoid(f"MESH_Palm_{side}", (0.68 * sign, -.004, 1.067), (.075, .055, .087), M_SKIN, f"hand.{side}", 14, 8)
    # Five separated, tapered fingers: an open neutral rest hand, no props.
    for fi, offset in enumerate((-0.052, -0.026, 0.0, 0.026, 0.052)):
        length = (0.088, 0.106, 0.114, 0.102, 0.082)[fi]
        base_x = 0.70 * sign
        tip_x = (0.70 + length) * sign
        y = offset
        make_tube(f"MESH_Finger_{side}_{fi+1}", (base_x, y, 1.067), (tip_x, y, 1.067 - length * .25), .012 if fi in (1,2,3) else .010, .007, M_SKIN, f"hand.{side}", None, .9, 8, 6)
    # Straight-fit trousers with articulated knees and clean silhouette.
    make_tube(f"MESH_Trouser_Upper_{side}", (0.12 * sign, 0, .83), (0.14 * sign, 0, .46), .115, .10, M_TROUSER, f"upper_leg.{side}", f"lower_leg.{side}", .72, 16, 16)
    make_tube(f"MESH_Trouser_Lower_{side}", (0.14 * sign, 0, .46), (0.14 * sign, 0, .13), .087, .067, M_TROUSER, f"lower_leg.{side}", f"foot.{side}", .82, 14, 16)
    # Tailored ankle cuff and subtle side seam.
    make_tube(f"MESH_Ankle_Cuff_{side}", (0.14 * sign, 0, .16), (0.14 * sign, 0, .13), .069, .068, M_STITCH, f"lower_leg.{side}", f"foot.{side}", .8, 14, 5)
    # Low-profile everyday sneaker with separate sole and upper.
    make_ellipsoid(f"MESH_Sneaker_Sole_{side}", (0.14 * sign, -.10, .045), (.095, .205, .042), M_SOLE, f"foot.{side}", 18, 8)
    make_ellipsoid(f"MESH_Sneaker_Upper_{side}", (0.14 * sign, -.105, .098), (.082, .175, .075), M_SHOE, f"foot.{side}", 18, 10)
    make_ellipsoid(f"MESH_Sneaker_Toe_{side}", (0.14 * sign, -.218, .11), (.078, .072, .052), M_ACCENT, f"toe.{side}", 16, 8)
    for lace in range(3):
        make_tube(f"MESH_Lace_{side}_{lace+1}", (0.14 * sign - .032, -.12 + lace * .03, .159), (0.14 * sign + .032, -.12 + lace * .03, .159), .004, .004, M_SHIRT, f"foot.{side}", None, .9, 6, 4)

# Neck and head are bespoke ellipsoidal low-poly surfaces with facial features.
make_tube("MESH_Neck", (0, 0, 1.37), (0, 0, 1.53), .075, .070, M_SKIN, "neck", "head", .72, 16, 10)
make_ellipsoid("MESH_Head", (0, -.004, 1.61), (.142, .135, .19), M_SKIN, "head", 24, 16)
# Ears and simple, clearly readable facial features; front is negative Y.
for side, sign in (("L", 1), ("R", -1)):
    make_ellipsoid(f"MESH_Ear_{side}", (.14 * sign, -.005, 1.60), (.032, .045, .058), M_SKIN, "head", 12, 8)
    make_ellipsoid(f"MESH_EarInner_{side}", (.151 * sign, -.041, 1.60), (.010, .012, .027), M_SKIN_LIGHT, "head", 10, 6)
    make_ellipsoid(f"MESH_EyeWhite_{side}", (.052 * sign, -.119, 1.635), (.027, .014, .016), M_EYE, "head", 12, 8)
    make_ellipsoid(f"MESH_Iris_{side}", (.052 * sign, -.132, 1.635), (.010, .006, .011), M_IRIS, "head", 10, 6)
    make_ellipsoid(f"MESH_Pupil_{side}", (.052 * sign, -.137, 1.635), (.0048, .003, .006), M_PUPIL, "head", 8, 6)
    make_tube(f"MESH_Brow_{side}", (.026 * sign, -.123, 1.664), (.078 * sign, -.119, 1.666), .009, .007, M_BROW, "head", None, .9, 8, 5)
# Nose bridge and softly defined nostril tip.
make_tube("MESH_NoseBridge", (0, -.119, 1.635), (0, -.145, 1.578), .018, .012, M_SKIN_LIGHT, "head", None, .9, 10, 8)
make_ellipsoid("MESH_NoseTip", (0, -.147, 1.577), (.025, .020, .018), M_SKIN, "head", 12, 8)
make_tube("MESH_Mouth", (-.035, -.124, 1.552), (.035, -.124, 1.552), .006, .006, M_MOUTH, "head", None, .9, 8, 5)
# Natural short hair silhouette; clustered tiny forms imply tight natural texture
# without an exaggerated hairstyle. Face remains unobstructed.
make_ellipsoid("MESH_HairCap", (0, .003, 1.731), (.148, .137, .052), M_HAIR, "head", 20, 12)
for row, z in enumerate((1.708, 1.733, 1.755)):
    count = (12, 10, 8)[row]
    for i in range(count):
        angle = 2 * math.pi * i / count
        x = .132 * math.cos(angle)
        y = .115 * math.sin(angle) + .003
        if y < -0.04 and z < 1.755:
            continue
        make_ellipsoid(f"MESH_HairTexture_{row}_{i}", (x, y, z), (.022, .020, .022), M_HAIR, "head", 8, 5)

# Tunde's own details: compact trimmed beard and soft studio headphones worn at the collar.
make_ellipsoid("MESH_Beard_Chin", (0, -.119, 1.535), (.065, .025, .035), M_HAIR, "head", 16, 8)
make_ellipsoid("MESH_Beard_Jaw_L", (.071, -.093, 1.552), (.034, .025, .041), M_HAIR, "head", 12, 8)
make_ellipsoid("MESH_Beard_Jaw_R", (-.071, -.093, 1.552), (.034, .025, .041), M_HAIR, "head", 12, 8)
# Two ear cups and a padded band sit naturally against the upper chest.
for side, sign in (("L", 1), ("R", -1)):
    make_ellipsoid(f"MESH_HeadphoneCup_{side}", (.152 * sign, -.076, 1.425), (.043, .034, .066), M_TROUSER, "chest", 14, 10)
    make_ellipsoid(f"MESH_HeadphonePad_{side}", (.153 * sign, -.102, 1.425), (.029, .012, .048), M_ACCENT, "chest", 12, 8)
make_tube("MESH_HeadphoneBand_Left", (-.15, -.07, 1.47), (-.09, -.08, 1.52), .012, .012, M_TROUSER, "chest", None, .9, 10, 8)
make_tube("MESH_HeadphoneBand_Crown", (-.09, -.08, 1.52), (.09, -.08, 1.52), .012, .012, M_TROUSER, "chest", None, .9, 10, 8)
make_tube("MESH_HeadphoneBand_Right", (.09, -.08, 1.52), (.15, -.07, 1.47), .012, .012, M_TROUSER, "chest", None, .9, 10, 8)

# A compact stand collar gives the colour-block field jacket a distinct neckline.
for side, sign in (("L", 1), ("R", -1)):
    make_tube(f"MESH_Collar_{side}", (.02 * sign, -.127, 1.36), (.11 * sign, -.135, 1.425), .027, .024, M_JACKET, "chest", None, .9, 12, 8)
# UV layout: smart-project the assembled quad-forward mesh into non-overlapping islands.
# All clothing/skin pieces retain authored, normalized vertex-group weights.
bpy.ops.object.select_all(action="DESELECT")
for obj in parts:
    obj.select_set(True)
body = parts[0]
bpy.context.view_layer.objects.active = body
bpy.ops.object.join()
body = bpy.context.object
body.name = "MESH_Tunde_Character"
body.data.name = "MESH_Tunde_Character_Data"
body["character_id"] = "tunde_balogun"
body["asset_origin"] = "Original source-authored procedural quad-ring mesh; no external assets"
# Convert the authored palette into four texture-backed metallic-roughness
# materials; material colour variations live in the explicit glTF COLOR_0 data.
master_order = ["skin", "hair", "fabric", "hardware"]
master_materials = {}
master_specs = {
    "skin": ("MAT_PBR_Skin", .50, 0.0, (.97, .96, .94)),
    "hair": ("MAT_PBR_Hair", .72, 0.0, (.97, .96, .94)),
    "fabric": ("MAT_PBR_Fabric", .72, 0.0, (.97, .96, .94)),
    "hardware": ("MAT_PBR_Hardware", .34, .58, (.98, .97, .93)),
}
for category in master_order:
    name, roughness, metallic, tex_color = master_specs[category]
    material = bpy.data.materials.new(name)
    material.use_nodes = True
    nodes = material.node_tree.nodes
    nodes.clear()
    output = nodes.new("ShaderNodeOutputMaterial")
    shader = nodes.new("ShaderNodeBsdfPrincipled")
    shader.inputs["Roughness"].default_value = roughness
    shader.inputs["Metallic"].default_value = metallic
    image_node = nodes.new("ShaderNodeTexImage")
    image_node.image = make_texture(name, tex_color, .009, 256)
    vertex_node = nodes.new("ShaderNodeVertexColor")
    vertex_node.layer_name = "Color"
    multiply = nodes.new("ShaderNodeMixRGB")
    multiply.blend_type = "MULTIPLY"
    multiply.inputs[0].default_value = 1.0
    links = material.node_tree.links
    links.new(image_node.outputs["Color"], multiply.inputs[1])
    links.new(vertex_node.outputs["Color"], multiply.inputs[2])
    links.new(multiply.outputs["Color"], shader.inputs["Base Color"])
    links.new(shader.outputs["BSDF"], output.inputs["Surface"])
    material["source"] = "Original authored PBR material; per-part colour stored as glTF vertex colours"
    master_materials[category] = material

old_materials = list(body.data.materials)
palette = body.data.color_attributes.new(name="Color", type="FLOAT_COLOR", domain="CORNER")
category_indices = {category: index for index, category in enumerate(master_order)}
remapped_polygon_indices = []
for polygon in body.data.polygons:
    source_material = old_materials[polygon.material_index]
    source_name = source_material.name
    if source_name.startswith("MAT_Hair"):
        category = "hair"
    elif source_name == "MAT_Zipper_Brass":
        category = "hardware"
    elif source_name.startswith(("MAT_Skin", "MAT_Eye", "MAT_Brow", "MAT_Mouth")):
        category = "skin"
    else:
        category = "fabric"
    rgba = tuple(source_material.diffuse_color)
    for loop_index in polygon.loop_indices:
        palette.data[loop_index].color = rgba
    polygon.material_index = category_indices[category]
    remapped_polygon_indices.append(category_indices[category])
body.data.materials.clear()
for category in master_order:
    body.data.materials.append(master_materials[category])
for polygon, material_index in zip(body.data.polygons, remapped_polygon_indices):
    polygon.material_index = material_index
for material in old_materials:
    if material.users == 0:
        bpy.data.materials.remove(material)
bpy.ops.object.mode_set(mode="EDIT")
bpy.ops.mesh.select_all(action="SELECT")
bpy.ops.uv.smart_project(island_margin=0.015, area_weight=0.0, correct_aspect=True, scale_to_bounds=False)
bpy.ops.object.mode_set(mode="OBJECT")
# Geometry is authored in metres with origin at the ground plane; keep identity transforms.
body.parent = arm
arm_mod = body.modifiers.new("ARMATURE_Deform", "ARMATURE")
arm_mod.object = arm

# Rig metadata and human-readable bone naming.
arm["rig_type"] = "humanoid"
arm["character_id"] = "tunde_balogun"
arm["identity_note"] = "A Lagos-based community radio field producer; quick-witted, observant and generous with new artists. His everyday look is a colour-block windbreaker, relaxed dark trousers and low-profile trainers; he keeps padded headphones close at hand. One fictional individual, not a general representation of Nigerians."
arm["rest_pose"] = "A-pose"
arm["source"] = "Original armature authored in assets/characters/tunde_balogun/build_tunde_balogun.py"

# Animation actions are authored as keyed skeletal motion, not static labels.
def key_action(name: str, keyed_frames: dict[int, dict[str, tuple[float, float, float]]], root_heights: dict[int, float] | None = None, cyclic: bool = False):
    action = bpy.data.actions.new(name)
    arm.animation_data_create()
    arm.animation_data.action = action
    for frame, bone_values in keyed_frames.items():
        for bone_name, rotation in bone_values.items():
            pb = arm.pose.bones.get(bone_name)
            if pb is None:
                raise RuntimeError(f"Missing animation bone {bone_name}")
            pb.rotation_mode = "XYZ"
            pb.rotation_euler = rotation
            pb.keyframe_insert(data_path="rotation_euler", frame=frame, group=bone_name)
        if root_heights and frame in root_heights:
            root = arm.pose.bones["root"]
            root.location = (0, 0, root_heights[frame])
            root.keyframe_insert(data_path="location", frame=frame, group="root")
    for curve in action.fcurves:
        for key in curve.keyframe_points:
            key.interpolation = "BEZIER"
        if cyclic:
            curve.modifiers.new("CYCLES")
    action.use_fake_user = True
    action["looping"] = bool(cyclic)
    arm.animation_data.action = None
    return action

Z = (0.0, 0.0, 0.0)
key_action("idle", {
    1: {"spine": Z, "chest": Z, "upper_arm.L": (0, 0, .015), "upper_arm.R": (0, 0, -.015)},
    24: {"spine": (.012, 0, 0), "chest": (-.008, 0, 0), "head": (-.008, 0, .008), "upper_arm.L": (0, 0, .025), "upper_arm.R": (0, 0, -.025)},
    48: {"spine": Z, "chest": Z, "head": Z, "upper_arm.L": (0, 0, .015), "upper_arm.R": (0, 0, -.015)},
}, cyclic=True)
key_action("walk", {
    1: {"upper_leg.L": (.42, 0, 0), "upper_leg.R": (-.42, 0, 0), "lower_leg.L": (-.12, 0, 0), "lower_leg.R": (.12, 0, 0), "upper_arm.L": (-.30, 0, 0), "upper_arm.R": (.30, 0, 0), "lower_arm.L": (-.15, 0, 0), "lower_arm.R": (-.15, 0, 0), "spine": (.02, 0, 0)},
    13: {"upper_leg.L": (-.42, 0, 0), "upper_leg.R": (.42, 0, 0), "lower_leg.L": (.12, 0, 0), "lower_leg.R": (-.12, 0, 0), "upper_arm.L": (.30, 0, 0), "upper_arm.R": (-.30, 0, 0), "lower_arm.L": (-.15, 0, 0), "lower_arm.R": (-.15, 0, 0), "spine": (-.02, 0, 0)},
    25: {"upper_leg.L": (.42, 0, 0), "upper_leg.R": (-.42, 0, 0), "lower_leg.L": (-.12, 0, 0), "lower_leg.R": (.12, 0, 0), "upper_arm.L": (-.30, 0, 0), "upper_arm.R": (.30, 0, 0), "lower_arm.L": (-.15, 0, 0), "lower_arm.R": (-.15, 0, 0), "spine": (.02, 0, 0)},
}, cyclic=True)
key_action("run", {
    1: {"upper_leg.L": (.82, 0, 0), "upper_leg.R": (-.82, 0, 0), "lower_leg.L": (-.45, 0, 0), "lower_leg.R": (.08, 0, 0), "upper_arm.L": (-.62, 0, 0), "upper_arm.R": (.62, 0, 0), "lower_arm.L": (-.52, 0, 0), "lower_arm.R": (-.52, 0, 0), "spine": (.09, 0, 0)},
    9: {"upper_leg.L": (-.82, 0, 0), "upper_leg.R": (.82, 0, 0), "lower_leg.L": (.08, 0, 0), "lower_leg.R": (-.45, 0, 0), "upper_arm.L": (.62, 0, 0), "upper_arm.R": (-.62, 0, 0), "lower_arm.L": (-.52, 0, 0), "lower_arm.R": (-.52, 0, 0), "spine": (.09, 0, 0)},
    17: {"upper_leg.L": (.82, 0, 0), "upper_leg.R": (-.82, 0, 0), "lower_leg.L": (-.45, 0, 0), "lower_leg.R": (.08, 0, 0), "upper_arm.L": (-.62, 0, 0), "upper_arm.R": (.62, 0, 0), "lower_arm.L": (-.52, 0, 0), "lower_arm.R": (-.52, 0, 0), "spine": (.09, 0, 0)},
}, cyclic=True)
key_action("jump", {
    1: {"upper_leg.L": (.22, 0, 0), "upper_leg.R": (.22, 0, 0), "lower_leg.L": (-.25, 0, 0), "lower_leg.R": (-.25, 0, 0), "upper_arm.L": (0, 0, -.35), "upper_arm.R": (0, 0, .35), "spine": (.06, 0, 0)},
    10: {"upper_leg.L": (-.18, 0, 0), "upper_leg.R": (-.18, 0, 0), "lower_leg.L": (.2, 0, 0), "lower_leg.R": (.2, 0, 0), "upper_arm.L": (0, 0, -.65), "upper_arm.R": (0, 0, .65), "spine": (-.04, 0, 0)},
    20: {"upper_leg.L": (.08, 0, 0), "upper_leg.R": (.08, 0, 0), "lower_leg.L": (-.1, 0, 0), "lower_leg.R": (-.1, 0, 0), "upper_arm.L": (0, 0, -.45), "upper_arm.R": (0, 0, .45), "spine": Z},
    30: {"upper_leg.L": (.22, 0, 0), "upper_leg.R": (.22, 0, 0), "lower_leg.L": (-.25, 0, 0), "lower_leg.R": (-.25, 0, 0), "upper_arm.L": (0, 0, -.35), "upper_arm.R": (0, 0, .35), "spine": (.06, 0, 0)},
}, root_heights={1: 0.0, 10: .34, 20: .38, 30: 0.0})
key_action("landing", {
    1: {"upper_leg.L": (-.16, 0, 0), "upper_leg.R": (-.16, 0, 0), "lower_leg.L": (.28, 0, 0), "lower_leg.R": (.28, 0, 0), "spine": (-.08, 0, 0), "upper_arm.L": (0, 0, -.18), "upper_arm.R": (0, 0, .18)},
    8: {"upper_leg.L": (.22, 0, 0), "upper_leg.R": (.22, 0, 0), "lower_leg.L": (-.20, 0, 0), "lower_leg.R": (-.20, 0, 0), "spine": (.035, 0, 0)},
    18: {"upper_leg.L": Z, "upper_leg.R": Z, "lower_leg.L": Z, "lower_leg.R": Z, "spine": Z, "upper_arm.L": Z, "upper_arm.R": Z},
})
key_action("turn", {
    1: {"pelvis": Z, "spine": Z, "upper_arm.L": Z, "upper_arm.R": Z},
    10: {"pelvis": (0, 0, .42), "spine": (0, 0, .16), "head": (0, 0, -.12), "upper_arm.L": (.05, 0, -.12), "upper_arm.R": (-.05, 0, .12)},
    20: {"pelvis": (0, 0, .78), "spine": (0, 0, .23), "head": (0, 0, -.18), "upper_arm.L": (.08, 0, -.20), "upper_arm.R": (-.08, 0, .20)},
    30: {"pelvis": Z, "spine": Z, "head": Z, "upper_arm.L": Z, "upper_arm.R": Z},
})
key_action("radio_check", {
    1: {"head": Z, "upper_arm.R": Z, "lower_arm.R": Z, "hand.R": Z, "spine": Z},
    8: {"head": (.03, 0, -.08), "upper_arm.R": (.05, 0, .20), "lower_arm.R": (-.55, 0, .28), "hand.R": (.08, 0, .10), "spine": (-.015, 0, 0)},
    16: {"head": (.06, 0, -.12), "upper_arm.R": (.08, 0, .24), "lower_arm.R": (-.72, 0, .34), "hand.R": (.10, 0, .12), "spine": (-.025, 0, 0)},
    24: {"head": Z, "upper_arm.R": Z, "lower_arm.R": Z, "hand.R": Z, "spine": Z},
})
key_action("stop", {
    1: {"spine": (.12, 0, 0), "upper_leg.L": (.10, 0, 0), "upper_leg.R": (.08, 0, 0), "upper_arm.L": (-.12, 0, 0), "upper_arm.R": (-.12, 0, 0)},
    8: {"spine": (-.06, 0, 0), "upper_leg.L": (-.10, 0, 0), "upper_leg.R": (-.08, 0, 0), "lower_leg.L": (.12, 0, 0), "lower_leg.R": (.12, 0, 0), "upper_arm.L": (.06, 0, 0), "upper_arm.R": (.06, 0, 0)},
    18: {"spine": Z, "upper_leg.L": Z, "upper_leg.R": Z, "lower_leg.L": Z, "lower_leg.R": Z, "upper_arm.L": Z, "upper_arm.R": Z},
})

# Animation export uses one action per named gameplay clip.
arm.animation_data_create()
arm.animation_data.action = bpy.data.actions.get("idle")

# Display scene and camera are included in the .blend for fast artist inspection,
# but excluded from the runtime GLB export below.
world = bpy.data.worlds.new("WORLD_StudioPreview")
world.use_nodes = True
world.node_tree.nodes["Background"].inputs["Color"].default_value = (.08, .09, .105, 1)
world.node_tree.nodes["Background"].inputs["Strength"].default_value = .35
scene = bpy.context.scene
scene.world = world
scene.render.engine = "BLENDER_EEVEE"
scene.render.resolution_x = 900
scene.render.resolution_y = 900
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.render.film_transparent = False
# Create camera and area lights as non-exportable preview-only collection.
preview_collection = bpy.data.collections.new("PREVIEW_ONLY")
scene.collection.children.link(preview_collection)
cam_data = bpy.data.cameras.new("CAM_Preview")
cam = bpy.data.objects.new("CAM_Preview", cam_data)
preview_collection.objects.link(cam)
scene.camera = cam
cam_data.lens = 55
cam_data.type = "ORTHO"
cam_data.ortho_scale = 2.2
cam.location = (2.4, -4.2, 2.25)
cam.rotation_euler = (Vector((0, 0, .88)) - cam.location).to_track_quat("-Z", "Y").to_euler()
for name, loc, power, size in (("KEY", (2.5, -3.0, 3.2), 520, 3.0), ("FILL", (-2.4, -1.0, 1.8), 280, 2.5), ("RIM", (0.0, 2.0, 2.7), 400, 2.0)):
    data = bpy.data.lights.new("LGT_" + name, "AREA")
    data.energy = power
    data.shape = "DISK"
    data.size = size
    obj = bpy.data.objects.new("LGT_" + name, data)
    obj.location = loc
    obj.rotation_euler = (Vector((0, 0, 1.0)) - obj.location).to_track_quat("-Z", "Y").to_euler()
    preview_collection.objects.link(obj)

# Establish consistent scene units and opening state.
scene.unit_settings.system = "METRIC"
scene.unit_settings.scale_length = 1.0
scene.render.image_settings.color_mode = "RGBA"
scene.view_settings.view_transform = "Standard"
scene.frame_start = 1
scene.frame_end = 48
scene.frame_set(24)
arm.animation_data_create()
arm.animation_data.action = bpy.data.actions["idle"]
# Pack textures into the .blend so the editable source is self-contained.
for image in bpy.data.images:
    if image.source == "FILE":
        image.pack()

# Save editable Blender source first.
blend_path = SOURCE / "tunde_balogun.blend"
bpy.context.preferences.filepaths.save_version = 0
bpy.ops.wm.save_as_mainfile(filepath=str(blend_path))

# Export only the character rig and skinned mesh; preview camera/lights stay out.
bpy.ops.object.select_all(action="DESELECT")
arm.select_set(True)
body.select_set(True)
bpy.context.view_layer.objects.active = arm
bpy.ops.export_scene.gltf(
    filepath=str(OUT / "tunde_balogun.glb"),
    export_format="GLB",
    use_selection=True,
    export_animations=True,
    export_animation_mode="ACTIONS",
    export_nla_strips=False,
    export_frame_range=True,
    export_skins=True,
    export_texcoords=True,
    export_normals=True,
    export_materials="EXPORT",
    export_image_format="AUTO",
    export_draco_mesh_compression_enable=False,
    export_apply=False,
    export_yup=True,
)

# Render a visual inspection image from the authored asset (not used as a game asset).
scene.render.filepath = str(PREVIEW / "tunde_balogun_character.png")
scene.render.resolution_percentage = 80
bpy.ops.render.render(write_still=True)
print(f"CHARACTER_ID={arm['character_id']}")
print(f"CHARACTER_SOURCE={blend_path}")
print(f"CHARACTER_GLB={OUT / 'tunde_balogun.glb'}")
print(f"CHARACTER_PREVIEW={PREVIEW / 'tunde_balogun_character.png'}")
