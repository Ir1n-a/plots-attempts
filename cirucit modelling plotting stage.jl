using DataFrames
using Plots
using NativeFileDialog
using CSV
using DataInterpolations
#plotly()
gr()

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


plotting_stage()

sort_files()
    
    