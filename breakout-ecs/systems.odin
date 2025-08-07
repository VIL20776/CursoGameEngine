package breakout

import "core:fmt"
import rl "vendor:raylib"
import ecs "YggECS/src"

// Components
Name :: string
Color :: rl.Color
Rectangle :: rl.Rectangle
Velocity :: rl.Vector2
Movement :: struct {
  dir : f32,
  speed: f32 
}

// Systems
moveSystem :: proc(ctx: ^Game) {
  for archtype in ecs.query(ctx.world, ecs.has(Velocity), ecs.has(Rectangle)) {
    velocities := ecs.get_table(ctx.world, archtype, Velocity)
    rectangles := ecs.get_table(ctx.world, archtype, Rectangle)
    for eid, i in archtype.entities {
      ball := &rectangles[i]
      vel := &velocities[i]

      ball.x += vel.x * ctx.dT
      ball.y += vel.y * ctx.dT
    }
  }
}

limitSystem :: proc(ctx: ^Game) {
  for archtype in ecs.query(ctx.world, ecs.has(Velocity), ecs.has(Rectangle)) {
    velocities := ecs.get_table(ctx.world, archtype, Velocity)
    rectangles := ecs.get_table(ctx.world, archtype, Rectangle)
    for eid, i in archtype.entities {
      ball := &rectangles[i]
      vel := &velocities[i]

      if ball.x > f32(ctx.width) - ball.width {
        vel.x *= -1
      }
  
      if ball.x <= 0 {
        vel.x *= -1
      }

      if ball.y <= 0 {
        vel.y *= -1
      }

      if ball.y >= f32(ctx.height) {
        ecs.remove_component(ctx.world, eid, Rectangle)
        ecs.remove_component(ctx.world, eid, Velocity)
      }
    }
  }
}

inputSystem :: proc(ctx: ^Game) {
  for archtype in ecs.query(ctx.world, ecs.has(Movement), ecs.has(Rectangle)) {
    moves := ecs.get_table(ctx.world, archtype, Movement)
    rectangles := ecs.get_table(ctx.world, archtype, Rectangle)
    for eid, i in archtype.entities {
      paddle := &rectangles[i]
      move := &moves[i]

      move.dir = 0
      if rl.IsKeyDown(rl.KeyboardKey.RIGHT) && paddle.x < f32(ctx.width) - paddle.width {
        move.dir = 1
      }

      if rl.IsKeyDown(rl.KeyboardKey.LEFT) && paddle.x > 0 {
        move.dir = -1
      }

      paddle.x += move.dir * move.speed * ctx.dT
    }
  }
}

collisionSystem :: proc(ctx: ^Game) {
  for archtype_ball in ecs.query(ctx.world, ecs.has(Velocity), ecs.has(Rectangle)) {
    balls := ecs.get_table(ctx.world, archtype_ball, Rectangle)
    velocities := ecs.get_table(ctx.world, archtype_ball, Velocity)
    for eid, i in archtype_ball.entities {
      vel := &velocities[i]
      ball := &balls[i]

      for archtype_blocks in ecs.query(ctx.world, ecs.has(Rectangle), ecs.not(Movement)) {
        blocks := ecs.get_table(ctx.world, archtype_blocks, Rectangle)
        for other_eid, other in archtype_blocks.entities {
          block := &blocks[other]

          if rl.CheckCollisionRecs(ball^, block^) && eid != other_eid{
            ecs.remove_entity(ctx.world, other_eid)
            vel.y *= -1
          }
        }
      }

      for archtype_paddle in ecs.query(ctx.world, ecs.has(Rectangle), ecs.has(Movement)) {
        paddles := ecs.get_table(ctx.world, archtype_paddle, Rectangle)
        moves := ecs.get_table(ctx.world, archtype_paddle, Movement)
        for other_eid, other in archtype_paddle.entities {
          paddle := &paddles[other]
          move := &moves[other]

          if rl.CheckCollisionRecs(ball^, paddle^) {
            vel.x = move.speed * move.dir
            vel.y *= -1
          }
        }
      }
    }
  }
}

renderSystem :: proc(ctx: ^Game) { 
  for archtype in ecs.query(ctx.world, ecs.has(Rectangle), ecs.has(Color)) {
    rectangles := ecs.get_table(ctx.world, archtype, Rectangle)
    colors := ecs.get_table(ctx.world, archtype, Color)

    for eid, i in archtype.entities {
      rec := &rectangles[i]
      color := &colors[i]

      rl.DrawRectangleRec(rec^, color^)
    }

  }
}

victorySystem :: proc(ctx: ^Game) {
  if ecs.query(ctx.world, ecs.has(Velocity), ecs.has(Rectangle)) == nil {
    fmt.print("\n=======YOU LOSE=======\n")
    ctx.isRunning = false
  }

  for archtype in ecs.query(ctx.world, ecs.has(Rectangle)) {
    if len(archtype.entities) == 2 {
      fmt.print("\n=======YOU WIN=======\n")
      ctx.isRunning = false
    }
  }
}
