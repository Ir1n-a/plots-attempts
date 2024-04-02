using Plots
using CSV
using DataFrames
using NativeFileDialog
plotlyjs()

function plot_CorD_overlay(df)
    x=df."Corrected time (s)"
    y=df."WE(1).Potential (V)"

    plot!(x,y,dpi=360,title="Charge-Discharge",
    xlabel="Time (s)",ylabel="Potential (V)",
    framestyle=:box,linewidth=2, leg=false,
    right_margin=7*Plots.mm,formatter=:plain,
    top_margin=5*Plots.mm)
end

function pick_CorD_overlay(name)
    cORd=pick_file()
    df=CSV.read(cORd,DataFrame)
    CorD_overlay=plot_CorD_overlay(df)
    savefig(CorD_overlay,name*"_CorD_overlay.html")
end

j=7
name="name"
for i in 1:j
    pick_CorD_overlay(name)
end

plot()