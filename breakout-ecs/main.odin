package breakout

import "core:fmt"
import "core:thread"

main :: proc() {
  ctx: Game
  dbg: Debug

  Init(&ctx, "breakout", 800, 800)
  defer Deinit(&ctx)

  Setup(&ctx)
  //p := thread.create_and_start_with_data(&ctx, procGUI)

  fmt.println("Starting game")
  for Running(&ctx) {
    HandleEvents(&ctx)
    Update(&ctx)
    Render(&ctx)
    RenderGUI(&ctx, &dbg)
  }

  Clean(&ctx)
}
