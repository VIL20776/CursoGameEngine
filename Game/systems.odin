package game

import "core:fmt"
import rl "vendor:raylib"
import ecs "YggECS/src"


PlayerSetupSystem :: proc(ctx: ^Game) {
    world := ctx.world

    player := ecs.create_entity(world)

    player_name: Name = "Player"
    texture_data, ok := LoadTexture(ctx.tm, "sprites/cat.png")
    if (!ok) {
        fmt.println("Error loading texture.")
        return;
    }
    player_texture := Texture{data=texture_data, path="sprites/cat.png"}
    player_anim := Animation{
        start=rl.Vector2{16, 16},
        size=rl.Vector2{16, 16},
        offset=48,
        frames=8,
        time=0.25,
        nextTime=0.0,
    }

    player_movement := Movement{speed=200, axis_x=0, axis_y=0}
    
    ecs.add_component(world, player, Position{60, 60})
    ecs.add_component(world, player, player_name)
    ecs.add_component(world, player, player_texture)
    ecs.add_component(world, player, player_movement)
    ecs.add_component(world, player, player_anim)
}

TilemapSetupSystem :: proc(ctx: ^Game) {
    world := ctx.world
    
    for &tilemap in ctx.scene.tilemaps {
        tilemap_eid := ecs.create_entity(world)

        texture_data, ok := LoadTexture(ctx.tm, tilemap.texture_path)
        if (!ok) {
            fmt.println("Error loading texture.")
            return;
        }
        tilemap_texture := Texture{data=texture_data, path=tilemap.texture_path} 
        for tile, i in tilemap.bit_tiles {
            fmt.printfln("bit: %d tile %d", tile, i)
        }
        tilemap_data: Tilemap = AutoTilingSetup(&tilemap)
        tilemap_data.tile_size = 16
        tilemap_data.draw_size = 32
        fmt.printfln("size: %d", tilemap_data.size)

        ecs.add_component(world, tilemap_eid, tilemap.name)
        ecs.add_component(world, tilemap_eid, tilemap_texture)
        ecs.add_component(world, tilemap_eid, tilemap_data)
    }
}

CameraSetupSystem :: proc(ctx: ^Game) {
    world := ctx.world
    
    ctx.scene.camera = Camera{
        offset = Position{f32(ctx.width)/2, f32(ctx.height/2)},
        rotation = 0,
        zoom = 1
    }

    for archetype in ecs.query(ctx.world, ecs.has(Position), ecs.has(Movement)) {
        positions := ecs.get_table(ctx.world, archetype, Position)
        for eid, i in archetype.entities {
            pos := &positions[i]

            ctx.scene.camera.target = Position{pos.x + 16, pos.y + 16}
        }
    }

}

InputEventSystem :: proc(ctx: ^Game) {
    for archetype in ecs.query(ctx.world, ecs.has(Movement)) {
        movements := ecs.get_table(ctx.world, archetype, Movement)
        for eid, i in archetype.entities {
            if rl.IsKeyPressed(.RIGHT) do movements[i].axis_x = 1;
            if rl.IsKeyPressed(.LEFT) do movements[i].axis_x = -1;
            if rl.IsKeyPressed(.DOWN) do movements[i].axis_y = 1;
            if rl.IsKeyPressed(.UP) do movements[i].axis_y = -1;

            if rl.IsKeyReleased(.RIGHT) || rl.IsKeyReleased(.LEFT) do movements[i].axis_x = 0
            if rl.IsKeyReleased(.DOWN) || rl.IsKeyReleased(.UP) do movements[i].axis_y = 0
        }
    }
}

MovementUpdateSystem :: proc(ctx: ^Game) {
    for archetype in ecs.query(ctx.world, ecs.has(Position), ecs.has(Movement)) {
        positions := ecs.get_table(ctx.world, archetype, Position)
        movements := ecs.get_table(ctx.world, archetype, Movement)
        for eid, i in archetype.entities {
            pos := &positions[i]
            move := &movements[i]

            pos.x += move.axis_x * move.speed * ctx.dT
            pos.y += move.axis_y * move.speed * ctx.dT
        }
    }
}

CameraUpdateSystem :: proc(ctx: ^Game) {
    camera := &ctx.scene.camera
    for archetype in ecs.query(ctx.world, ecs.has(Position), ecs.has(Movement)) {
        positions := ecs.get_table(ctx.world, archetype, Position)
        for eid, i in archetype.entities {
            pos := &positions[i]

            camera.target = Position{pos.x + 16, pos.y + 16}
        }
    }
}

PlayerSpriteUpdateSystem :: proc(ctx: ^Game) {
    for archetype in ecs.query(ctx.world, ecs.has(Texture), ecs.has(Animation), ecs.has(Movement)) {
        textures := ecs.get_table(ctx.world, archetype, Texture)
        movements := ecs.get_table(ctx.world, archetype, Movement)
        animations := ecs.get_table(ctx.world, archetype, Animation)
        for eid, i in archetype.entities {

            source := &animations[i].start
            move := &movements[i]

            if move.axis_x > 0 do source.y = 160 + 192
            if move.axis_x < 0 do source.y = 112 + 192
            if move.axis_y > 0 do source.y = 16 + 192
            if move.axis_y < 0 do source.y = 64 + 192
            if move.axis_y + move.axis_x == 0 {
                if source.y > 192 do source.y -= 192
            }
        }
    }
}

TilemapRenderSystem :: proc(ctx: ^Game) {
    for archetype in ecs.query(ctx.world, ecs.has(Texture), ecs.has(Tilemap)) { 
        textures := ecs.get_table(ctx.world, archetype, Texture)
        tilemaps := ecs.get_table(ctx.world, archetype, Tilemap)
        for eid, i in archetype.entities {
            tilemap := tilemaps[i]
            texture := textures[i]

            for j := 0; j < tilemap.size; j += 1 {
                dest_pos := tilemap.positions[j] * tilemap.draw_size
                src_pos := tilemap.tiles[j]

                dest := rl.Rectangle{x=dest_pos.x, y=dest_pos.y, height=tilemap.draw_size, width=tilemap.draw_size}
                source := rl.Rectangle{x=src_pos.x, y=src_pos.y, height=tilemap.tile_size, width=tilemap.tile_size}    
                rl.DrawTexturePro(texture.data, source, dest, {0, 0}, 0, rl.WHITE)
            }
        } 
    }
}

SpriteRenderSystem :: proc(ctx: ^Game) {
    for archetype in ecs.query(ctx.world, ecs.has(Texture), ecs.has(Animation), ecs.has(Position)) {
        textures := ecs.get_table(ctx.world, archetype, Texture)
        positions := ecs.get_table(ctx.world, archetype, Position)
        animations := ecs.get_table(ctx.world, archetype, Animation)
        for eid, i in archetype.entities {

            source_pos := &animations[i].start
            size := animations[i].size

            offset := animations[i].offset
            frames := animations[i].frames

            if rl.GetTime() >= animations[i].nextTime {
                source_pos.x = cast(f32)((int(source_pos.x) + offset) % (frames * offset))
                animations[i].nextTime = rl.GetTime() + animations[i].time
            }

            dest_pos := &positions[i]
            dest := rl.Rectangle{x=dest_pos.x, y=dest_pos.y, height=size.x*2, width=size.y*2}
            source := rl.Rectangle{x=source_pos.x, y=source_pos.y, height=size.x, width=size.y}
            rl.DrawTexturePro(textures[i].data, source, dest, {0, 0}, 0, rl.WHITE)
        }
    }
}
