using Plots
using CSV
using DataFrames
using NativeFileDialog
using NumericalIntegration
plotlyjs()

#= This program will deal with the capacitance calculation
for charge/discharge curves from 0 to V or from V to 0 for now.
I will update it for a general case in the future, when I'll have 
to deal with a general case XS =#

function plot_Capacitance(df,i,p)
    x=df."Corrected time (s)"
    y=df."WE(1).Potential (V)"

    Integral=integrate(x,y)
    V=maximum(y)
    C=(2*i*Integral)/((V^2)*p)
    print(V," ")

    plot!(x,y,dpi=360,xlabel="Time (s)",ylabel="Potential (V)",
    framestyle=:box,linewidth=2,
    # right_margin=7*Plots.mm,formatter=:plain,
    # top_margin=5*Plots.mm,
    legend=(0.4,-0.2),
    label="Capacitance = "*sprint(show, C, context=:compact => true)*" F")
end
# p is physical unit/quantity, mass, surface or volume, pick whichever you need and name it accordingly

function pick_Capacitance(p,i,name)
    Cp1=pick_file()
    df=CSV.read(Cp1,DataFrame)
    Capacitance=plot_Capacitance(df,i,p)
    savefig(Capacitance,name*"_Capacitance.html")
end

plot()
pick_Capacitance(2,0.0005,"test cap ")