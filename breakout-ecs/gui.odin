package breakout

import "core:fmt"
import mu "vendor:microui"
import rl "vendor:raylib"
import ecs "YggECS/src"

Debug :: struct {
    selected: i32
}

RenderGUI :: proc(ctx: ^Game, debug: ^Debug) {
    ids: [dynamic]Name
    entities: [dynamic]ecs.EntityID
    defer delete(ids)
    defer delete(entities)

    for archtype in ecs.query(ctx.world, ecs.has(Name)) {
        append(&ids, ..ecs.get_table(ctx.world, archtype, Name))
        append(&entities, ..archtype.entities[:])
    }

    rl.GuiDropdownBox(
        {x=10 + f32(ctx.width), y=20, width=180, height=15},
        rl.TextJoin(raw_data(ids[:]), i32(len(ids)), ";"),
        &debug.selected, true)
    GUIShowRectangles(ctx, entities[debug.selected % i32(len(entities))])

}

GUIShowColors :: proc(world: ^ecs.World) {

}

GUIShowRectangles :: proc(ctx: ^Game, entity_id: ecs.EntityID) {
    for archtype in ecs.query(ctx.world, ecs.has(Rectangle)) {
        rectangles := ecs.get_table(ctx.world, archtype, Rectangle)
        for eid, i in archtype.entities {
            if eid == entity_id {
                rl.GuiSlider(
                    {x=220 + f32(ctx.width), y=20, width=200, height=20},
                    "X",
                    rl.TextFormat("%.2f", rectangles[i].x),
                    &rectangles[i].x, 0, f32(ctx.width))
                rl.GuiSlider(
                    {x=220 + f32(ctx.width), y=50, width=200, height=20},
                    "Y",
                    rl.TextFormat("%.2f", rectangles[i].x),
                    &rectangles[i].y, 0, f32(ctx.height))
                rl.GuiSlider(
                    {x=220 + f32(ctx.width), y=80, width=200, height=20},
                    "Width",
                    rl.TextFormat("%.2f", rectangles[i].x),
                    &rectangles[i].width, 0, f32(ctx.width))
                rl.GuiSlider(
                    {x=220 + f32(ctx.width), y=110, width=200, height=20},
                    "Height",
                    rl.TextFormat("%.2f", rectangles[i].x),
                    &rectangles[i].height, 0, f32(ctx.height))
                return
            }
        }
    }
}
GUIShowMovements :: proc(world: ^ecs.World) {}
GUIShowVelocities :: proc(world: ^ecs.World) {}
