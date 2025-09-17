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

    AddSystems(scene, .SETUP, PlayerSetupSystem)
    AddSystems(scene, .EVENTS, InputEventSystem)
    AddSystems(scene, .UPDATE, MovementUpdateSystem)
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

    for sys in ctx.scene.render do sys(ctx)

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


