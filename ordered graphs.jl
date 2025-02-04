using Plots
using DataFrames
using CSV
using NativeFileDialog
using Colors
using ColorSchemes
using NumericalIntegration
using DelimitedFiles
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

function folder_input(mode)
    fld=pick_folder()
    v=[]
    u=[]
    l=[]
    w=[]
    files_content=[]
    for file in readdir(fld,join=true)
        push!(v,file)
    end

    print(v)

    if mode
        w=permutedims(readdlm(pick_file(),' ',Int,'\n'))[:, 1]
    else for i in eachindex(v)
        df=v[i]
        push!(u,parse(Float64,basename(v[i])))
            end
        w=sortperm(u)
    end
    println(w)

    for i in eachindex(v)
        df=CSV.read(v[w][i],DataFrame)
        println(df)
        push!(files_content,df)
        push!(l,basename(string(v[w[i]])))
    end

    #=println(v[w])
    println(l)
    return files_content
    println(v)=#
    println(v)
    println(v[w])
    println(l)
end

folder_input(true)