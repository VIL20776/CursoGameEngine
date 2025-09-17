package game

import "core:fmt"

ctx: Game
sample: Scene
tm: TextureManager

main :: proc() {
    Init(&ctx, "breakout", 800, 600)
    defer Deinit(&ctx)

    InitScene(&sample)
    defer DeinitScene(&sample)

    SetupSampleScene(&sample)

    ctx.scene = &sample
    ctx.tm = &tm

    Setup(&ctx)

    fmt.println("Starting game")
    for Running(&ctx) {
        HandleEvents(&ctx)
        Update(&ctx)
        Render(&ctx)
    }

    Clean(&ctx)
}
