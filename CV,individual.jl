using Plots
using CSV
using DataFrames
using NativeFileDialog
plotlyjs()

#= This program will be concerned with CV plots, individual ones. Ah, yes,
finally CV plots...this can also be overlay, again, if you don't 
clean the plot before making the next one. So, there it is, CV plots.
Three cycles are being measured, 2nd for accounting for transient cycle and 
3rd as a first test for stability, tracking whether the current value decreases significantly
with each cycle iteration. For the plots, though, I only need the second cycle, with a few extra points 
added to close the figure. That and the capacitance calculation per quadrant are the two "challenges"
for this type of plots.=# 

function plot_CVi(df)
    x=df."WE(1).Potential (V)"
    y=df."WE(1).Current (A)"
    idx= df[!, :Scan] .==2 
    x=x[idx]
    y=y[idx]
    push!(x,first(x))
    push!(y,first(y))

    plot!(x,y*1000,dpi=360,title="Cyclic Voltammetry",
    xlabel="Potential (V)",ylabel="Current (mA)",
    framestyle=:box,linewidth=2, legend=false,
    right_margin=7*Plots.mm,top_margin=5*Plots.mm)
end
    
function pick_CVi()
    cv1=pick_file()
    df=CSV.read(cv1,DataFrame)
    CVi=plot_CVi(df)
    savefig(CVi,cv1*"_CVi.html")
end

plot()
pick_CVi()