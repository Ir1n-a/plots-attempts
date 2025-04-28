using Plots
using DataFrames
using NativeFileDialog
using CSV
using DelimitedFiles
using DataInterpolations
plotly()

function plot_default()
    plot(dpi=360,framestyle=:box,
    right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain,top_margin=5*Plots.mm,
    legend=false)
end

function I_V_normies(n)
    files_vector=[]
    df_vector=[]
    plot_IV=plot_default()

    for i in 1:n
        f=pick_file()
        push!(files_vector,f)
        df=CSV.read(f,DataFrame)
        Potential=df."Potential applied (V)"
        Current=df."WE(1).Current (A)"

        plot_IV=plot!(plot_IV,Potential,Current,xlabel="Potential (V)",
        ylabel="Current (A)",lw=3,hover=i)
    end

    save_folder=pick_folder()
    savefig(plot_IV,joinpath(save_folder,basename(save_folder)*"_I_V_normie.html"))

    @show files_vector
    #@show df_vector
end

I_V_normies(5)
