#+feature dynamic-literals
package game

import "core:fmt"
import rl "vendor:raylib"
import ecs "YggECS/src"

Game :: struct {
    world: ^ecs.World,
    scene: ^Scene,
    tm: ^TextureManager,
    title: cstring,
    width, height: i32,
    isRunning: bool,
    dT: f32,
}

//Tilemap and bitmap data

//Scenes

SetupSampleScene :: proc(scene: ^Scene) {

    grass_bit_tiles := [dynamic]byte{
        0, 1, 1, 0, 
        1, 0, 1, 1 
    }
    grass_tilemap := TilemapData{
        name = "Grass",
        texture_path = "tiles/Grass.png",
        bitmap = map[byte]rl.Vector2{
              2 = rl.Vector2{   0,  80 }, // north
              8 = rl.Vector2{  48,  96 },
             10 = rl.Vector2{  80, 112 },
             11 = rl.Vector2{  48,  80 },
             16 = rl.Vector2{   0,  96 },
             18 = rl.Vector2{  64, 112 },
             22 = rl.Vector2{  16,  80 },
             24 = rl.Vector2{  16,  96 },
             26 = rl.Vector2{ 144,  32 },
             27 = rl.Vector2{ 144,  80 },
             30 = rl.Vector2{  96,  80 },
             31 = rl.Vector2{  32,  80 },
             64 = rl.Vector2{   0,  32 },
             66 = rl.Vector2{   0,  48 },
             72 = rl.Vector2{  80,  96 },
             74 = rl.Vector2{ 128,  32 },
             75 = rl.Vector2{ 112,  80 },
             80 = rl.Vector2{  64,  96 },
             82 = rl.Vector2{ 144,  48 },
             86 = rl.Vector2{ 128,  80 },
             88 = rl.Vector2{ 128,  48 },
             90 = rl.Vector2{   0, 112 },
             91 = rl.Vector2{  32, 112 },
             94 = rl.Vector2{  96,  48 },
             95 = rl.Vector2{  96, 112 },
            104 = rl.Vector2{  48,  48 },
            106 = rl.Vector2{ 144,  64 },
            107 = rl.Vector2{  48,  64 },
            120 = rl.Vector2{ 112,  64 },
            122 = rl.Vector2{  48, 112 },
            123 = rl.Vector2{ 112, 112 },
            126 = rl.Vector2{  48, 112 },
            127 = rl.Vector2{  64,  64 },
            208 = rl.Vector2{  16,  48 },
            210 = rl.Vector2{  96,  64 },
            214 = rl.Vector2{  16,  64 },
            216 = rl.Vector2{ 128,  64 },
            218 = rl.Vector2{  96,  32 },
            219 = rl.Vector2{  32, 112 },
            222 = rl.Vector2{  96,  96 },
            223 = rl.Vector2{  80,  64 },
            248 = rl.Vector2{  32,  48 },
            250 = rl.Vector2{ 112,  96 },
            251 = rl.Vector2{  64,  80 },
            254 = rl.Vector2{  80,  80 },
            255 = rl.Vector2{   0,   0 },
              0 = rl.Vector2{ 16,  32 }
        },
        bit_tiles = grass_bit_tiles[:],
        width = 4,
        height = 2,
    }

    append(&scene.tilemaps, grass_tilemap)

    AddSystems(scene, .SETUP, TilemapSetupSystem)
    AddSystems(scene, .SETUP, PlayerSetupSystem)
    AddSystems(scene, .SETUP, CameraSetupSystem)
    AddSystems(scene, .EVENTS, InputEventSystem)
    AddSystems(scene, .UPDATE, MovementUpdateSystem)
    AddSystems(scene, .UPDATE, CameraUpdateSystem)
    AddSystems(scene, .UPDATE, PlayerSpriteUpdateSystem)
    AddSystems(scene, .RENDER, TilemapRenderSystem)
    AddSystems(scene, .RENDER, SpriteRenderSystem)
}

Init :: proc(ctx: ^Game, name: cstring, width: i32, height: i32) {
    ctx.world = ecs.create_world()
    ctx.title, ctx.width, ctx.height = name, width, height
    ctx.isRunning = true
}

Deinit :: proc(ctx: ^Game) {
    ecs.delete_world(ctx.world)
}

Setup :: proc(ctx: ^Game) {
    rl.InitWindow(ctx.width, ctx.height, ctx.title)
    rl.SetTargetFPS(60)

    for sys in ctx.scene.setup do sys(ctx)
}

HandleEvents :: proc(ctx: ^Game) {
    ctx.dT = rl.GetFrameTime()

    if rl.WindowShouldClose()  {
        ctx.isRunning = false
    }

    for sys in ctx.scene.events do sys(ctx)
}

Update :: proc(ctx: ^Game) {
    for sys in ctx.scene.update do sys(ctx)
}

Render :: proc(ctx: ^Game) {
    rl.BeginDrawing()

    rl.ClearBackground(rl.RAYWHITE)
    cstr := fmt.caprintf("FPS: %d", rl.GetFPS())

    rl.BeginMode2D(ctx.scene.camera)
    for sys in ctx.scene.render do sys(ctx)
    rl.EndMode2D()

    rl.DrawText(cstr, posX = 10, posY = 10, fontSize = 20, color = rl.GRAY)
    rl.EndDrawing()
}

Running :: proc(ctx: ^Game) -> bool {
    return ctx.isRunning
}

Clean :: proc(ctx: ^Game) {
    UnloadAllTextures(ctx.tm)
    rl.CloseWindow()
}


