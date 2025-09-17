package game

import "core:fmt"
import rl "vendor:raylib"
import ecs "YggECS/src"


PlayerSetupSystem :: proc(ctx: ^Game) {
    world := ctx.world

    player := ecs.create_entity(world)

    player_name: Name = "Player"
    texture_data, ok := LoadTexture(ctx.tm, "sprites/test.png")
    if (!ok) {
        fmt.println("Error loading texture.")
        return;
    }
    player_texture := Texture{data=texture_data, path="sprites/test.png"}
    player_anim := Animation{
        start=rl.Rectangle{x=0, y=0, height=16, width=16},
        offset=16,
        frames=4,
        size=16*4,
        time=0.5,
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
    
    tilemap := ecs.create_entity(world)

    tilemap_name: Name = "Tilemap"
    texture_data, ok := LoadTexture(ctx.tm, "tiles/test.png")
    if (!ok) {
        fmt.println("Error loading texture.")
        return;
    }
    tilemap_texture := Texture{data=texture_data, path="tiles/test.png"} 
    tilemap_data: Tilemap = {positions={}, tiles={}, tile_size=16}

    ecs.add_component(world, tilemap, tilemap_name)
    ecs.add_component(world, tilemap, tilemap_texture)
    ecs.add_component(world, tilemap, tilemap_data)
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

PlayerSpriteUpdateSystem :: proc(ctx: ^Game) {
    for archetype in ecs.query(ctx.world, ecs.has(Texture), ecs.has(Animation), ecs.has(Movement)) {
        textures := ecs.get_table(ctx.world, archetype, Texture)
        movements := ecs.get_table(ctx.world, archetype, Movement)
        animations := ecs.get_table(ctx.world, archetype, Animation)
        for eid, i in archetype.entities {

            source := &animations[i].start
            move := &movements[i]

            if move.axis_x > 0 do source.x = 16
            if move.axis_x < 0 do source.x = 32
            if move.axis_y > 0 do source.y = 48
            if move.axis_y < 0 do source.y = 0
        }
    }
}

TilemapRenderSystem :: proc(ctx: ^Game) {
    for archetype in ecs.query(ctx.world, ecs.has(Texture), ecs.has(Tilemap)) { 
        textures := ecs.get_table(ctx.world, archetype, Texture)
        tilemaps := ecs.get_table(ctx.world, archetype, Tilemap)
        for eid, i in archetype.entities {
            
        } 
    }
}

SpriteRenderSystem :: proc(ctx: ^Game) {
    for archetype in ecs.query(ctx.world, ecs.has(Texture), ecs.has(Animation), ecs.has(Position)) {
        textures := ecs.get_table(ctx.world, archetype, Texture)
        positions := ecs.get_table(ctx.world, archetype, Position)
        animations := ecs.get_table(ctx.world, archetype, Animation)
        for eid, i in archetype.entities {

            source := &animations[i].start

            offset := animations[i].offset
            frames := animations[i].frames

            if rl.GetTime() >= animations[i].nextTime {
                source.x = cast(f32)((int(source.x) + offset) % (frames * offset))
                animations[i].nextTime = rl.GetTime() + animations[i].time
            }

            dest_pos := &positions[i]
            dest := rl.Rectangle{x=dest_pos.x, y=dest_pos.y, height=16, width=16}
            rl.DrawTexturePro(textures[i].data, source^, dest, {0, 0}, 0, rl.WHITE)
        }
    }
}
