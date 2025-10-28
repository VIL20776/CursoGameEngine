package game

Scene :: struct {
    // Data
    tilemaps: [dynamic]TilemapData,
    // Procedures
    setup: [dynamic]proc(ctx: ^Game),
    events: [dynamic]proc(ctx: ^Game),
    update: [dynamic]proc(ctx: ^Game),
    render: [dynamic]proc(ctx: ^Game),
}

ScenePhase :: enum {
    SETUP,
    EVENTS,
    UPDATE,
    RENDER,
}

InitScene :: proc(scene: ^Scene) {
    scene.setup = make([dynamic]proc(ctx: ^Game))
    scene.events = make([dynamic]proc(ctx: ^Game))
    scene.update = make([dynamic]proc(ctx: ^Game))
    scene.render = make([dynamic]proc(ctx: ^Game))
}

DeinitScene :: proc(scene: ^Scene) {
    delete(scene.setup)
    delete(scene.events)
    delete(scene.update)
    delete(scene.render)

    for tilemap in scene.tilemaps {
        delete(tilemap.bit_tiles)
        delete(tilemap.bitmap)
    }
}

AddSystems :: proc(scene: ^Scene, phase: ScenePhase, systems: ..proc(ctx: ^Game)) {
    switch phase {
    case .SETUP:
        append(&scene.setup, ..systems[:])
    case .EVENTS:
        append(&scene.events, ..systems[:])
    case .UPDATE:
        append(&scene.update, ..systems[:])
    case .RENDER:
        append(&scene.render, ..systems[:])
    }
}

