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
    for i in 1:n
        f=pick_file()
        push!(files_vector,f)
    end

    @show files_vector
end

I_V_normies(5)
