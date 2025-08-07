package breakout

import "core:strings"
import "core:fmt"
import mu "vendor:microui"
import rl "vendor:raylib"
import ecs "YggECS/src"

GUI_PANEL_WIDTH :: 300

GUI :: struct {
    ctx: mu.Context,
}

InitGUI :: proc(gui: ^GUI) {
    ctx := &gui.ctx
    mu.init(ctx)
    ctx.text_width = mu.default_atlas_text_width
	ctx.text_height = mu.default_atlas_text_height
}

UpdateGUI :: proc(game: ^Game, gui: ^GUI) {
    ctx := &gui.ctx

    ids: [dynamic]Name
    entities: [dynamic]ecs.EntityID
    defer delete(ids)
    defer delete(entities)

    for archtype in ecs.query(game.world, ecs.has(Name)) {
        append(&ids, ..ecs.get_table(game.world, archtype, Name))
        append(&entities, ..archtype.entities[:])
    }

    mouse_pos := [2]i32{rl.GetMouseX(), rl.GetMouseY()}
	mu.input_mouse_move(ctx, mouse_pos.x, mouse_pos.y)
    if rl.IsMouseButtonPressed(.LEFT) { 
		mu.input_mouse_down(ctx, mouse_pos.x, mouse_pos.y, .LEFT)
    } else if rl.IsMouseButtonReleased(.LEFT) { 
        mu.input_mouse_up(ctx, mouse_pos.x, mouse_pos.y, .LEFT)
    }

    mu.begin(ctx)

    if mu.window(ctx, "Entities", {x = game.width, y = 0, w=GUI_PANEL_WIDTH, h=game.height}) {
        for id, i in ids {
            if .ACTIVE in mu.treenode(ctx, id) {
                GUIShowRectangles(game, gui, entities[i])
                GUIShowColors(game, gui, entities[i])
                GUIShowMovements(game, gui, entities[i])
                GUIShowVelocities(game, gui, entities[i])
            }
        }
    }


    mu.end(ctx)
}

RenderGUI :: proc(game: ^Game, gui: ^GUI) {
    ctx := &gui.ctx

	command_backing: ^mu.Command
	for variant in mu.next_command_iterator(ctx, &command_backing) {
		switch cmd in variant {
		case ^mu.Command_Text:
			rl.DrawText(strings.clone_to_cstring(cmd.str), cmd.pos.x, cmd.pos.y, 10, rl.RAYWHITE)
		case ^mu.Command_Rect:
			rl.DrawRectangle(cmd.rect.x, cmd.rect.y, cmd.rect.w, cmd.rect.h, transmute(rl.Color)cmd.color)
		case ^mu.Command_Icon:
            continue
		case ^mu.Command_Clip:
			rl.EndScissorMode()
			rl.BeginScissorMode(cmd.rect.x, rl.GetScreenHeight() - (cmd.rect.y + cmd.rect.h), cmd.rect.w, cmd.rect.h)
		case ^mu.Command_Jump: 
			unreachable()
		}
    }
}

GUIShowColors :: proc(game: ^Game, gui: ^GUI, entity_id: ecs.EntityID) {
    ctx := &gui.ctx
    for archtype in ecs.query(game.world, ecs.has(Color)) {
        colors := ecs.get_table(game.world, archtype, Color)
        for eid, i in archtype.entities {
            if eid == entity_id { 
                mu.label(ctx, "Colors")

                tmp_r := mu.Real(colors[i].r)
                tmp_g := mu.Real(colors[i].g)
                tmp_b := mu.Real(colors[i].b)

                mu.slider(ctx, &tmp_r, 0, 255, 0, "R: %.0f")
                mu.slider(ctx, &tmp_g, 0, 255, 0, "G: %.0f")
                mu.slider(ctx, &tmp_b, 0, 255, 0, "B: %.0f")

                colors[i].r = u8(tmp_r)
                colors[i].g = u8(tmp_g)
                colors[i].b = u8(tmp_b)
            }
        }
    }
    
}

GUIShowRectangles :: proc(game: ^Game, gui: ^GUI, entity_id: ecs.EntityID) {
    ctx := &gui.ctx
    for archtype in ecs.query(game.world, ecs.has(Rectangle)) {
        rectangles := ecs.get_table(game.world, archtype, Rectangle)
        for eid, i in archtype.entities {
            if eid == entity_id {
                mu.label(ctx, "Rectangle")
                mu.slider(ctx, &rectangles[i].x, 0, f32(game.width), 0.1, "x: %.2f")
                mu.slider(ctx, &rectangles[i].y, 0, f32(game.height), 0.1, "y: %.2f")
                mu.slider(ctx, &rectangles[i].width, 0, f32(game.width), 0.1, "width: %.2f")
                mu.slider(ctx, &rectangles[i].height, 0, f32(game.height), 0.1, "height: %.2f")
            }
        }
    }
}
GUIShowMovements :: proc(game: ^Game, gui: ^GUI, entity_id: ecs.EntityID) {
    ctx := &gui.ctx
    for archtype in ecs.query(game.world, ecs.has(Movement)) {
        movements := ecs.get_table(game.world, archtype, Movement)
        for eid, i in archtype.entities {
            if eid == entity_id {
                mu.label(ctx, "Movement")
                mu.slider(ctx, &movements[i].dir, -1, 1, 1, "Direction: %.2f")
                mu.slider(ctx, &movements[i].speed, 0, 300, 0.1, "Speed: %.2f")
            }
        }
    }
}

GUIShowVelocities :: proc(game: ^Game, gui: ^GUI, entity_id: ecs.EntityID) {
    ctx := &gui.ctx
    for archtype in ecs.query(game.world, ecs.has(Velocity)) {
        velocities := ecs.get_table(game.world, archtype, Velocity)
        for eid, i in archtype.entities {
            if eid == entity_id {
                mu.label(ctx, "Velocity")
                mu.slider(ctx, &velocities[i].x, -300, 300, 0.1, "x: %.2f")
                mu.slider(ctx, &velocities[i].y, -300, 300, 0.1, "y: %.2f")
            }
        }
    }
}
