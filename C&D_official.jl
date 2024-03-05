using Plots
using CSV
using DataFrames
using NativeFileDialog
plotlyjs()

#= This is a basic charging-discharging plot
program where the files are input from file 
picker and charge-discharge curves are plotted
together =#

function plot_CD(df,s1)
    x=df."Time (s)" .-s1
    y=df."WE(1).Potential (V)"

    plot!(x,y,dpi=360,title="Charge-Discharge",
    xlabel="Time (s)",ylabel="Potential (V)",
    framestyle=:box,linewidth=2, leg=false,
    right_margin=7*Plots.mm,formatter=:plain,
    top_margin=5*Plots.mm)
end

#= the software used to obtain the data separates 
the charging file from the discharging file and since 
the second cycle is taken to avoid the transient "cycle"
the time won't start from 0 s, and the corrected time 
starts both the discharge and charge from 0 s, which
is not acceptable when plotting both on the same graph.
If I add in the function a find first value, it's going 
to do so for both and I only need the first time value
from the charge data to be substracted form both, hence
I have decided to make function instead of a for loop 
since there are only two data units anyway, so I might
as well just call the pick command twice, and using
the find first index for the first one only and substract
it from both. Yeah, this should work... :D =#

function pick_CD()
    c1=pick_file()
    df=CSV.read(c1,DataFrame)
    s1=collect(first(df[!, [:"Time (s)"]]))
    plot_CD(df,s1)
    d1=pick_file()
    df=CSV.read(d1,DataFrame)
    cd=plot_CD(df,s1)
    savefig(cd,c1*"_C&D.html")
end

plot()
pick_CD()










