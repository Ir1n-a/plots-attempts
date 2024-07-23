using Plots
using CSV 
using DataFrames
using NativeFileDialog
#plotlyjs()
gr()
#= I need a program that can plot EIS plots when I drag 
the text file in an open window. I have three different plots, 
usually just 2, but for modelling I think all three might be 
needed. At first I was considering making three different files
for each type of graph, but that might be way too convoluted
and not convenient at all, so I will just keep all three 
plots in the same file since they need different data sections
from the file anyway=#

#= format should be pre-made so I don't have to bother with
this after I wrtie the rest of the code, hence I will put the 
plot in variables =#

function plot_Nyquist(df)
    x=df."Z' (Ω)"
    y=df."-Z'' (Ω)"
    plot(x,y,seriestype=:scatter,dpi=360,
title="Nyquist",xlabel="Zre (Ω)",ylabel="Zimg (Ω)",
right_margin=7*Plots.mm,framestyle=:box,
linewidth=2, formatter=:plain,xlims=[0,
maximum(x)],leg=false,size=(500,500),
markersize=3,top_margin=5*Plots.mm,xticks=[0,2000,4000,6000,8000],
yticks=[0,300,600,900,1200,1500],color=:red)
end 

function plot_Module(df)
    x=df."Frequency (Hz)"
    y=df."Z (Ω)"
    scatter(x,y,dpi=360,xscale=:log10,title="Module",
    xlabel="Frequency (Hz)",ylabel="Z (Ω)",
    framestyle=:box,right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain, xticks=10.0 .^(-2:5),leg=false,top_margin=5*Plots.mm)
end

function plot_Bode(df)
    x=df."Frequency (Hz)"
    y=df."-Phase (°)"
    plot(x,y,dpi=360,xscale=:log10,title="Bode",
    xlabel="Frequency (Hz)",ylabel="Phase Difference (deg)",
    framestyle=:box,right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain, xticks=10.0 .^(-2:5),leg=false,top_margin=5*Plots.mm)
end

#=Now the files with data need to be picked. Since I have 
over 200 EIS graphs, I would prefer to pick them by clicking
on a file not inputing it from the keyboard, so a file picking
stage is needed before plotting the graphs, obv=#

function picking()
fl=pick_file()
df=CSV.read(fl,DataFrame)

#N=
plot_Nyquist(df)
savefig("Nyquist1")
#savefig(N,fl*"_Nyquist.html")

#B=plot_Bode(df)
#savefig(B,fl*"_Bode.html")

#M=plot_Module(df)
#savefig(M,fl*"_Module.html")

end

picking()

#= the file is selected, not i need to assign the x and the y
for each plot. I could make a separate function for each 
type of graph, or I could just name the variables in the plot 
directly =#

