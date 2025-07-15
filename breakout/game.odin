package breakout

import "core:fmt"
import rl "vendor:raylib"

Game :: struct {
  title: cstring,
  width, height: i32,
  counter: i32,
  isRunning: bool,
}

// Game elements
ball: rl.Rectangle
paddle: rl.Rectangle

// Game properties
ball_speed := rl.Vector2{150, 150}
paddle_speed: f32 = 200

ROWS :: 4
COLUMNS :: 10
blocks: [ROWS * COLUMNS]rl.Rectangle
blocks_len := ROWS * COLUMNS;

Init :: proc(ctx: ^Game, name: cstring, width: i32, height: i32) {
  ctx.title, ctx.width, ctx.height = name, width, height
  ctx.isRunning = true
  ctx.counter = 0
}

Deinit :: proc(ctx: ^Game) {}

Setup :: proc(ctx: ^Game) {
  rl.InitWindow(ctx.width, ctx.height, ctx.title)
  rl.SetTargetFPS(60)

  ball = rl.Rectangle{x = 10, y = f32(ctx.height / 5) + 10, width = 15, height = 15}
  paddle = rl.Rectangle{x = f32(ctx.width/2) - ball.width*5, y = f32(ctx.height - 15), width = ball.width*10, height = 15}

  // Calculate blocks
  block_width: f32 = f32(ctx.width / COLUMNS)
  block_height: f32 = f32((ctx.height / 5) / ROWS)

  for i in 0 ..< blocks_len {
      x := f32(i % COLUMNS) * block_width
      y := f32(int(i / COLUMNS)) * block_height
      blocks[i] = rl.Rectangle{x, y, block_width, block_height}
    
  }
}

HandleEvents :: proc(ctx: ^Game) {
  dT := rl.GetFrameTime()

  if rl.WindowShouldClose()  {
    ctx.isRunning = false
  }

  if rl.IsKeyDown(rl.KeyboardKey.RIGHT) && paddle.x < f32(ctx.width) - paddle.width {
    paddle.x += paddle_speed * dT 
  }

  if rl.IsKeyDown(rl.KeyboardKey.LEFT) && paddle.x > 0 {
    paddle.x -= paddle_speed * dT 
  }
}

Update :: proc(ctx: ^Game) {
  dT := rl.GetFrameTime()

  if ball.x >= f32(ctx.width) - ball.width {
    ball_speed.x *= -1
  }
  if ball.x < 0 {
    ball_speed.x *= -1
  } 
  if ball.y >= f32(ctx.height) {
    fmt.print("\n=======YOU FAIL=======\n")
    ctx.isRunning = false
  }
  if rl.CheckCollisionRecs(ball, paddle) {
    ball_speed.y *= -1;
    // ball_speed.x = paddle_speed 
  }

  if (ball.y < 0) {
    ball_speed.y *= -1
  }
  
  for i in 0 ..< blocks_len {
    b := blocks[i]
    if rl.CheckCollisionRecs(ball, b) {
      fmt.printf("Collision with block %f %f", b.x, b.y)

      blocks[i] = blocks[blocks_len - 1]
      blocks_len -= 1

      ball_speed.y *= -1
    }
  }

  if blocks_len <= 0 {
    fmt.print("\n=======YOU WIN=======\n")
    ctx.isRunning = false
  }
  
  ball.x += ball_speed.x * dT
  ball.y += ball_speed.y * dT
}

Render :: proc(ctx: ^Game) {
  rl.BeginDrawing()
  rl.ClearBackground(rl.BLACK)
  cstr := fmt.caprintf("FPS: %d", rl.GetFPS())
  rl.DrawText(cstr, posX = 10, posY = 10, fontSize = 20, color = rl.GRAY)
  
  rl.DrawRectangleRec(ball, rl.WHITE)
  rl.DrawRectangleRec(paddle, rl.WHITE)
  for i in 0 ..< blocks_len do rl.DrawRectangleRec(blocks[i], rl.BLUE)
  rl.EndDrawing()
}

Running :: proc(ctx: ^Game) -> bool {
  return ctx.isRunning
}

Clean :: proc(ctx: ^Game) {
  rl.CloseWindow()
}


