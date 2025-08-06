package breakout

import "core:fmt"
import rl "vendor:raylib"
import mu "vendor:microui"
import ecs "YggECS/src"

Game :: struct {
  world: ^ecs.World,
  title: cstring,
  width, height: i32,
  counter: i32,
  isRunning: bool,
  dT: f32,
}

DEBUG_PANEL_WIDTH :: 500

ROWS :: 4
COLUMNS :: 10 

Init :: proc(ctx: ^Game, name: cstring, width: i32, height: i32) {
  ctx.world = ecs.create_world()
  ctx.title, ctx.width, ctx.height = name, width, height
  ctx.isRunning = true
  ctx.counter = 0
}

Deinit :: proc(ctx: ^Game) {
  ecs.delete_world(ctx.world)
}

Setup :: proc(ctx: ^Game) {
  rl.InitWindow(ctx.width + DEBUG_PANEL_WIDTH, ctx.height, ctx.title)
  rl.SetTargetFPS(60)

  ball := ecs.add_entity(ctx.world)
  ball_rec := Rectangle{x = 10, y = f32(ctx.height / 2) + 10, width = 15, height = 15}
  ball_name: Name = "Ball"
  ecs.add_component(ctx.world, ball, ball_name)
  ecs.add_component(ctx.world, ball, ball_rec)
  ecs.add_component(ctx.world, ball, rl.WHITE)
  ecs.add_component(ctx.world, ball, Velocity{150, 150})
  
  paddle := ecs.add_entity(ctx.world)
  paddle_rec := Rectangle{x = f32(ctx.width/2) - ball_rec.width*5, y = f32(ctx.height - 15), width = ball_rec.width*10, height = 15}
  paddle_name: Name = "Paddle"
  ecs.add_component(ctx.world, paddle, paddle_name)
  ecs.add_component(ctx.world, paddle, paddle_rec)
  ecs.add_component(ctx.world, paddle, rl.WHITE)
  ecs.add_component(ctx.world, paddle, Movement{dir = 1, speed = 200})

  // Calculate blocks
  block_width := f32(ctx.width / COLUMNS)
  block_height := f32((ctx.height / 5) / ROWS)

  for i in 0 ..< ROWS * COLUMNS {
    x := f32(i % COLUMNS) * block_width
    y := f32(int(i / COLUMNS)) * block_height
    block := Rectangle{x, y, block_width, block_height}

    b := ecs.add_entity(ctx.world)
    b_name: Name = fmt.caprintf("Block %d", b)
    ecs.add_component(ctx.world, b, b_name)
    ecs.add_component(ctx.world, b, block)
    ecs.add_component(ctx.world, b, rl.BLUE)
  }
}

HandleEvents :: proc(ctx: ^Game) {
  ctx.dT = rl.GetFrameTime()

  if rl.WindowShouldClose()  {
    ctx.isRunning = false
  }

  inputSystem(ctx)
}

Update :: proc(ctx: ^Game) {
  limitSystem(ctx)
  victorySystem(ctx)
  collisionSystem(ctx)
  moveSystem(ctx)
}

Render :: proc(ctx: ^Game) {
  rl.BeginDrawing()

  rl.ClearBackground(rl.BLACK)
  cstr := fmt.caprintf("FPS: %d", rl.GetFPS())
  rl.DrawText(cstr, posX = 10, posY = 10, fontSize = 20, color = rl.GRAY)
  
  renderSystem(ctx)

  rl.EndDrawing()
}

Running :: proc(ctx: ^Game) -> bool {
  return ctx.isRunning
}

Clean :: proc(ctx: ^Game) {
  rl.CloseWindow()
}


