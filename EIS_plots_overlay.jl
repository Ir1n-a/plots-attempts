using Plots 
using CSV
using DataFrames
using NativeFileDialog
plotlyjs()

#=Now I need a program for plots comparison to asses the 
evolution of a parameter/physical property/supercapacitor
in general. My strategy for this is to use a for loop
separately for Bode and Nyquist, therefore two for loops. 
the program shall be mostly similar, opening a file 
command will be inserted in the for so it can ask me what
data files I want instead of inputing them from the keyboard.
The for parameter i will have to be the only one inputted
from the keyboard since the number of plots will not be 
the same every time, so I will put that above the for loops.
The only other additional thing should be writing plot! instead
of plot and the program should be pretty much done. =#

function plot_Nyquist(df)
    x=df."Z' (Ω)"
    y=df."-Z'' (Ω)"
    plot!(x,y,seriestype=:scatter,dpi=360,
title="Nyquist",xlabel="Zre (Ω)",ylabel="Zimg (Ω)",
right_margin=7*Plots.mm,framestyle=:box,
linewidth=2, formatter=:plain,xlims=[0,
maximum(x)],leg=false,size=(500,500),
markersize=3, top_margin=5*Plots.mm)
end

function plot_Bode(df)
    x=df."Frequency (Hz)"
    y=df."-Phase (°)"
    plot!(x,y,dpi=360,xscale=:log10,title="Bode",
    xlabel="Frequency (Hz)",ylabel="Phase Difference (deg)",
    framestyle=:box,right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain, xticks=10.0 .^(-2:5),leg=false,
    top_margin=5*Plots.mm)
end

function plot_Module(df)
    x=df."Frequency (Hz)"
    y=df."Z (Ω)"
    plot(dpi=360,xscale=:log10,
    xlabel="Frequency (Hz)",ylabel="Z (Ω)",
    framestyle=:box,right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain,leg=false,
    top_margin=5*Plots.mm)
end

function picking_N()
    fl=pick_file()
    df=CSV.read(fl,DataFrame)
    
    N=plot_Nyquist(df)
    savefig(N,fl*"_Nyquist.html")
end

function picking_B()
    fl=pick_file()
    df=CSV.read(fl,DataFrame)

    B=plot_Bode(df)
    savefig(B,fl*"_Bode.html")
end

function picking_M()
    fl=pick_file()
    df=CSV.read(fl,DataFrame)

    M=plot_Module(df)
    savefig(M,fl*"_Module.html")
end
    

j=1 
#=this is for picking how many files will
be compared for each graph=#
plot() 
#=remember to execute this each time 
after one for loop=#

for i in 1:j
    picking_N()
end

for i in 1:j
    picking_B()
end

for i in 1:j
    picking_M()
end