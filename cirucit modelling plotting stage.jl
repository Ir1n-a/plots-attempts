using DataFrames
using Plots
using NativeFileDialog
using CSV
using DataInterpolations
using DelimitedFiles
plotly()


function plot_default()
    plot(dpi=360,framestyle=:box,
    right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain,top_margin=5*Plots.mm,
    legend=false)
end

function sort_files()
    fl=pick_folder()
    files_vector=[]
    F=[]
    for file in readdir(fl,join=true)
            if split(basename(file),".")[end]=="txt" || split(basename(file),".")[end]=="html"
                continue
            else
                push!(files_vector,file)
            end
        end
    print(files_vector)

    permutation_file=pick_file()
    permutation_vector=Int.(readdlm(permutation_file, ' '))
    print(permutation_vector)
    final_files=files_vector[permutation_vector]

    for file in final_files
        df=CSV.read(file,DataFrame)
        push!(F,df)
    end
    return F
end

function plotting_stage()
    plot_Nyquist=plot_default()
    plot_Bode=plot_default()
    plot_Module=plot_default()

    dfs=sort_files()

    for df in dfs
        idx=df."-Z'' (Ω)".>0
        Frequency=df."Frequency (Hz)"[idx]
        Zre=df."Z' (Ω)"[idx]
        Zimg=df."-Z'' (Ω)"[idx]
        Z=df."Z (Ω)"[idx]
        Phase=df."-Phase (°)"[idx]

        plot_Nyquist=plot!(plot_Nyquist,Zre,Zimg,
        #=labels=l[i],=#marker=:circle,legend=true,xlabel="Zre (Ω)",ylabel="Zimg (Ω)")
        display(plot_Nyquist)
    end
end

function singular_plot()
    fl=pick_file()
    df=CSV.read(fl,DataFrame)
    x_f=[]
    M=[]
    I=[]
    
    plot_Nyquist=plot_default()
    plot_Bode=plot_default()
    plot_Module=plot_default()

    idx=df."-Z'' (Ω)".>0
    Frequency=df."Frequency (Hz)"[idx]
    Zre=df."Z' (Ω)"[idx]
    Zimg=df."-Z'' (Ω)"[idx]
    Z=df."Z (Ω)"[idx]
    Phase=df."-Phase (°)"[idx]
    
    for i in 2:(length(Zimg)-1)
        if(Zimg[i-1]<Zimg[i]>Zimg[i+1])
            push!(M,Zimg[i])
            push!(I,i)
        end
    end
    println(M)
    println(I)
    println(idx)
    tangent=(M.-Zimg[1])./(Zre[I].-Zre[1])
    phi=rad2deg.(atan.(tangent))
    println(tangent)
    println(phi)

    line_45= (Zre .- Zre[1]) .* tangent .+ Zimg[1]

    #p=plot(plot_Nyquist,Zre,Zimg, xlims=[100,115],ylims=[0,30])
    p2=plot(Zre,line_45)
    p=plot!(Zre,Zimg, xlims=[100,115],ylims=[0,30])
    fs=pick_folder()
    savefig(p,joinpath(fs,basename(fl)*"_Nyquist.html"))
    print(line_45)
end


singular_plot()
plotting_stage()

sort_files()
    
    