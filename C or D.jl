using Plots
using CSV 
using DataFrames
using NativeFileDialog
plotlyjs()

#=Now I need a program where charge and discharge are plotted
separately, as well as capacitance calculation for a single
plot. I will make one plot function and whether it's charge or 
discharge will be determined by the file itself, since everything
else about the plots is essentially the same, this time corrected 
time will be used since it's C and D separate=# 

function plot_CorD(df)
    x=df."Corrected time (s)"
    y=df."WE(1).Potential (V)"

    plot!(x,y,dpi=360,title="Charge-Discharge",
    xlabel="Time (s)",ylabel="Potential (V)",
    framestyle=:box,linewidth=2, leg=false,
    right_margin=7*Plots.mm,formatter=:plain,
    top_margin=5*Plots.mm)
end

function pick_CorD()
    cd1=pick_file()
    df=CSV.read(cd1,DataFrame)
    CorD=plot_CorD(df)
    savefig(CorD,cd1*"_CorD.html")
end

plot()
pick_CorD()

#=huh, you can actually use this as the overlay version too
if you don't clean the plot=# 