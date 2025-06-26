using Plots
using CSV 
using DataFrames
using NativeFileDialog
using NumericalIntegration
#plotlyjs()
gr()

#=Now I need a program where charge and discharge are plotted
separately, as well as capacitance calculation for a single
plot. I will make one plot function and whether it's charge or 
discharge will be determined by the file itself, since everything
else about the plots is essentially the same, this time corrected 
time will be used since it's C and D separate=# 

function plot_CorD()
    
    plot(dpi=360,
    xlabel="Time (s)",ylabel="Potential (V)",
    framestyle=:box,linewidth=2, leg=:outerbottom,
    right_margin=7*Plots.mm,formatter=:plain,
    top_margin=5*Plots.mm)
end

function pick_CorD(n,Current)

    CorD=plot_CorD()

    for i in 1:n
        cd1=pick_file()
        df=CSV.read(cd1,DataFrame)
        x=df."Corrected time (s)"
        y=df."WE(1).Potential (V)"

        Integral=integrate(x,y)
        V=maximum(y)
        C=(2*Current*Integral)/(V^2)
        C_mF=C*1000

        @show C
        CorD=plot(CorD,x,y,label=(basename(cd1),"C = $C_mF mF"))
    end

    save_f=pick_folder()
    savefig(CorD,save_f*"_CD.png")
end

pick_CorD(3,0.001)
plot()
pick_CorD()

#=huh, you can actually use this as the overlay version too
if you don't clean the plot=# 