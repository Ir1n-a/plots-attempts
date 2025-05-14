using Plots 
using CSV
using DataFrames
using NativeFileDialog
plotlyjs()

function plot_Nyquist()
    plot(dpi=360,
    xlabel="Zre (Ω)",ylabel="-Zimg (Ω)",
    right_margin=7*Plots.mm,framestyle=:box,
    linewidth=2, formatter=:plain,markersize=3,
    top_margin=5*Plots.mm,legend=false)
end

function plot_Bode()
    plot(dpi=360,xscale=:log10,title="Bode",
    xlabel="Frequency (Hz)",ylabel="Phase Difference (deg)",
    framestyle=:box,right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain,leg=false,
    top_margin=5*Plots.mm)
end

function plot_Module()
    plot(dpi=360,xscale=:log10, title="Bode Module",
    xlabel="Frequency (Hz)",ylabel="Z (Ω)",
    framestyle=:box,right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain,leg=false,
    top_margin=5*Plots.mm)
end

function EIS(n)
    files=[]
    Nyquist=plot_Nyquist()
    Bode=plot_Bode()
    Module=plot_Module()


    for i in 1:n
        f=pick_file()
        push!(files,f)
        df=CSV.read(f,DataFrame)

        idx=df."Frequency (Hz)".>100
        Zre=df."Z' (Ω)"[idx]
        Zimg=df."-Z'' (Ω)"[idx]
        Frequency=df."Frequency (Hz)"[idx]
        Z=df."Z (Ω)"[idx]
        Phase=df."-Phase (°)"[idx]

        Nyquist=plot(Nyquist,Zre,Zimg,hover=basename(files[i]),lw=3)
        Bode=plot(Bode,Frequency,Phase,hover=basename(files[i]),lw=3)
        Module=plot(Module,Frequency,Z,hover=basename(files[i]),lw=3)
    end

    save_folder=pick_folder()

    savefig(Nyquist,joinpath(save_folder,basename(save_folder)*"_Nyquist.html"))
    savefig(Bode,joinpath(save_folder,basename(save_folder)*"_Bode.html"))
    savefig(Module,joinpath(save_folder,basename(save_folder)*"_Module.html"))
end

EIS(5)
