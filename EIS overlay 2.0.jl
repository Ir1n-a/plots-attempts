using Plots 
using CSV
using DataFrames
using NativeFileDialog
using DataInterpolations
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

function EIS(n,mode)
    files=[]
    Nyquist=plot_Nyquist()
    Bode=plot_Bode()
    Module=plot_Module()
    Nyquist_intp=plot_Nyquist()


    for i in 1:n
        f=pick_file()
        push!(files,f)
        df=CSV.read(f,DataFrame)

        idx= 7000 .> df."Frequency (Hz)".>150
        Zre=df."Z' (Ω)"[idx]
        Zimg=df."-Z'' (Ω)"[idx]
        Frequency=df."Frequency (Hz)"[idx]
        Z=df."Z (Ω)"[idx]
        Phase=df."-Phase (°)"[idx]

        @show Zre

        Nyquist_intp=CubicSpline(Zimg,Zre)

        if mode == "basic"
            Nyquist=plot(Nyquist,Zre,Zimg,hover=basename(files[i]),lw=3)
            Bode=plot(Bode,Frequency,Phase,hover=basename(files[i]),lw=3)
            Module=plot(Module,Frequency,Z,hover=basename(files[i]),lw=3)
        else Nyquist_intp=plot!(range(first(Zre),last(Zre),length=5000),
            x->Nyquist_intp(x) ,legend=false,aspect_ratio=1,lw=3)
        end
    end

    save_folder=pick_folder()

    if mode == "basic"
        savefig(Nyquist,joinpath(save_folder,basename(save_folder)*"_Nyquist.html"))
        savefig(Bode,joinpath(save_folder,basename(save_folder)*"_Bode.html"))
        savefig(Module,joinpath(save_folder,basename(save_folder)*"_Module.html"))

    else savefig(Nyquist_intp,joinpath(save_folder,basename(pick_file())*"_Nyquist_intp.html"))
    end
end

EIS(1,"intp")
