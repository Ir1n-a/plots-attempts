using Plots
using CSV
using DataFrames
using NativeFileDialog
using DelimitedFiles
using DataInterpolations
plotly()

function plot_IV_format()
    plot(dpi=360,framestyle=:box,
    right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain,top_margin=5*Plots.mm,
    legend=false)
end

function sort_files()
    fl=pick_folder()
    files_vector=[]
    for file in readdir(fl,join=true)
            if split(basename(file),".")[end]=="txt" || split(basename(file),".")[end]=="html"
                continue
            else
                push!(files_vector,file)
            end
        end
    return files_vector

end

function sort_files_for_Real()
    F=[]
    files_labels=[]
    files_vector=sort_files()
    permutation_file=pick_file()

    @show readdlm(permutation_file)

    permutation_vector=Int.(readdlm(permutation_file, ' '))
    print(permutation_vector)
    final_files=files_vector[permutation_vector]

    

    for file in final_files
        df=CSV.read(file,DataFrame)
        push!(F,df)
        push!(files_labels,basename(file))
    end

    @show files_vector
    @show files_labels
    @show permutedims(final_files)
    return F,files_labels
end

function I_V()
    File_df,files_labels=sort_files_for_Real()
    plot_IV=plot_IV_format()

    for (i,df) in enumerate(File_df)
        Potential=df."Potential applied (V)"
        Current=df."WE(1).Current (A)"

        plot_IV=plot!(plot_IV,Potential,Current,xlabel="Potential (V)",
        ylabel="Current (A)",lw=3,hover=files_labels[i])
    end

    save_folder=pick_folder()
    savefig(plot_IV,joinpath(save_folder,basename(save_folder)*"_I_V.html"))
end

I_V()





sort_files()
sort_files_for_Real()

