using Plots 
using CSV
using DataFrames
using NativeFileDialog
using DataInterpolations
plotlyjs()

function plot_Nyquist(n)
    plot(dpi=360,
    xlabel="Zre (Ω)",ylabel="-Zimg (Ω)",
    right_margin=7*Plots.mm,framestyle=:box,
    linewidth=2, formatter=:plain,markersize=3,
    top_margin=5*Plots.mm,legend=true,label=:outerbottom,
    legendcolumns=n)
end

function plot_Bode()
    plot(dpi=360,xscale=:log10,
    xlabel="Frequency (Hz)",ylabel="Phase Difference (deg)",
    framestyle=:box,right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain,leg=false,
    top_margin=5*Plots.mm)
end

function plot_Module()
    plot(dpi=360,xscale=:log10,
    xlabel="Frequency (Hz)",ylabel="Z (Ω)",
    framestyle=:box,right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain,leg=false,
    top_margin=5*Plots.mm)
end

function EIS(n,mode)
    files=[]
    Nyquist=plot_Nyquist(n)
    Bode=plot_Bode()
    Module=plot_Module()
    Nyquist_intp=plot_Nyquist(n)
    del_idx=[]
    idx_intp=[]
    ha=[]
    huh=[]


    for i in 1:n
        f=pick_file()
        push!(files,f)
        df=CSV.read(f,DataFrame)

        idx= 100 .> df."-Z'' (Ω)" .>0
        Zre=df."Z' (Ω)"[idx]
        Zimg=df."-Z'' (Ω)"[idx]
        Frequency=df."Frequency (Hz)"[idx]
        Z=df."Z (Ω)"[idx]
        Phase=df."-Phase (°)"[idx]

        @show length(Zre)
        @show length(Zimg)

        for j in 2:(length(Zre))
            if Zre[j-1] .> Zre[j]
                push!(del_idx,j)
                #deleteat!(Zre,j)
            else continue
            end
        end
        
        deleteat!(Zre,del_idx)
        deleteat!(Zimg,del_idx)
        
        
        @show length(Zre)
        @show length(Zimg)


        
        #idx_intp=Zre
        

        @show del_idx
        @show Zre

        for k in 2:length(Zre)
            if Zre[k-1] .> Zre[k]
                push!(ha,k)
                push!(huh,Zre)
            else continue
            end
        end

        print(ha)
        @show huh

        Nyquist_intp=CubicSpline(Zimg,Zre)

        if mode == "basic"
            Nyquist=plot(Nyquist,Zre,Zimg,label=basename(files[i]),lw=3,legend=false)
            Bode=plot(Bode,Frequency,Phase,label=basename(files[i]),lw=3,legend=false,
            formatter=:plain)
            Module=plot(Module,Frequency,Z,label=basename(files[i]),lw=3,legend=false)
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
