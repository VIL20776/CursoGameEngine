package breakout

main :: proc() {
  ctx: Game

  Init(&ctx, "breakout", 800, 600)
  defer Deinit(&ctx)


  Setup(&ctx)

  for Running(&ctx) {
    HandleEvents(&ctx)
    Update(&ctx)
    Render(&ctx)
  }

  Clean(&ctx)
}
