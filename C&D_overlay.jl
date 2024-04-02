using Plots
using CSV
using DataFrames
using NativeFileDialog
plotlyjs()

function plot_CD_overlay(df,s1)
    x=df."Time (s)" .-s1
    y=df."WE(1).Potential (V)"

    plot!(x,y,dpi=360,title="Charge-Discharge",
    xlabel="Time (s)",ylabel="Potential (V)",
    framestyle=:box,linewidth=2, leg=false,
    right_margin=7*Plots.mm,formatter=:plain,
    top_margin=5*Plots.mm)
end

function pick_CD_overlay(name)
    c2=pick_file()
    df=CSV.read(c2,DataFrame)

    s1=collect(first(df[!, [:"Time (s)"]]))

    plot_CD_overlay(df,s1)

    d2=pick_file()
    df=CSV.read(d2,DataFrame)

    cdo=plot_CD_overlay(df,s1)
    savefig(cdo,name*"_C&D_overlay.html")
end

k=2
name="something"
for i in 1:k
    pick_CD_overlay(name)
end

plot()

#= for this particular program the order of picking files is important
    it must go C1, D1, C2 , D2 etc, otherwise different s1 values will 
    be substracted from Ci and Di, when it should be the maximum of 
    the Ci detracted from a Di, not a Dk,as it would happen if the choice
    of files were to be randomized. I will work on a version where order 
    doesn't matter, but I believe this aspect is pretty inconsequential
    to the intent of the program=#