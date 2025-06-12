using CairoMakie


seconds=1:1:10
Physical_unit=[1090.5,2990,400.6,7,9009, 10000,290076,40005,30490,432532]

scatter(seconds,Physical_unit,rasterize=20,markersize=10)
lines!(seconds,exp.(seconds))
current_figure()