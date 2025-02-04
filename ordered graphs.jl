using Plots
using DataFrames
using CSV
using NativeFileDialog
using Colors
using ColorSchemes
using NumericalIntegration
plotly()

function plot_default()
    plot(dpi=360,framestyle=:box,
    right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain,top_margin=5*Plots.mm,
    legend=false)
end

function skip_html(file)
    fas=split(basename(file),".")
    if fas[end]=="html"
        return true
    else 
        return false
    end
end

function folder_input()
    fld=pick_folder()
    v=[]
    u=[]
    l=[]
    for file in readdir(fld,join=true)
        push!(v,file)
    end

    for i in eachindex(v)
        df=v[i]
        push!(u,parse(Float64,basename(v[i])))
    end
    w=sortperm(u)

    for i in eachindex(v)
        df=CSV.read(v[w][i],DataFrame)
        println(df)
        push!(l,basename(string(v[w[i]])))
    end

    println(v[w])
    println(l)
    return df,v[w],l
end

folder_input()