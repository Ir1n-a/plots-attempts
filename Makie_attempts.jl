using CairoMakie


seconds=1:1:10
Physical_unit=[1090.5,2990,400.6,7,9009, 10000,290076,40005,30490,432532]

f=Figure()
acxe=Axis(f[7,4],xlabel="x",ylabel="y",title="yuh")
scatter!(seconds,Physical_unit,rasterize=50,markersize=30)
lines!(seconds,exp.(seconds),rasterize=50)
lines!(1:0.5:10,sin)
fs=current_figure()
current_axis()
save("pffh.png",fs)