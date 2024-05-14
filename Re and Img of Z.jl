using Plots
using CSV
using DataFrames
using NativeFileDialog
plotlyjs()



function Real(n,m,name)
    file=pick_file()
    df=CSV.read(file,DataFrame)
    x=df."Frequency (Hz)"
    y=df."Z' (Ω)"
    R=plot!(x,y,seriestype=:scatter,dpi=360,
title=m,xlabel="Frequency (Hz)",ylabel=n,
right_margin=7*Plots.mm,framestyle=:box,
linewidth=2, formatter=:plain,xlims=[0,
maximum(x)],leg=false,size=(500,500),
markersize=3, top_margin=5*Plots.mm,xscale=:log10)
    savefig(R,name*"_Real.html")
end

function Imaginary(n,m,name)
    file=pick_file()
    df=CSV.read(file,DataFrame)
    x=df."Frequency (Hz)"
    y=df."-Z'' (Ω)"
    I=plot!(x,y,seriestype=:scatter,dpi=360,
title=m,xlabel="Frequency (Hz)",ylabel=n,
right_margin=7*Plots.mm,framestyle=:box,
linewidth=2, formatter=:plain,xlims=[0,
maximum(x)],leg=false,size=(500,500),
markersize=3, top_margin=5*Plots.mm,xscale=:log10)
    savefig(I,name*"_Real.html")
end


Real("ReZ","RealZ","test")
Imaginary("ImZ","Imaginary","testi")

plot()

#smarter version pending 